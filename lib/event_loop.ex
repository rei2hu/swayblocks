defmodule EventLoop do
  # entry point
  def start(settings) do
    BlocksLogger.info("Starting swayblocks...")
    IO.puts("{\"version\":1,\"click_events\":true}")
    IO.puts("[")

    # merge config with default settings
    settings
    |> Enum.map_reduce(%{}, fn x, acc ->
      %{:name => name} = x

      {name,
       Map.put(
         acc,
         name,
         Enum.into(x, %{
           :click => nil,
           :time => 999_999,
           :left => 0,
           :status => 1,
           :content => "{}",
           :default => %{}
         })
       )}
    end)
    |> pre_init
  end

  # generic setup that will
  # only happen the first iteration
  # through
  defp pre_init({order, blocks}) do
    get_min_time(blocks)
    |> (&Process.send_after(self(), {:update, &1}, &1)).()
    |> init(blocks, Enum.reverse(order))
  end

  # the actual event loop
  defp init(timer, blocks, order) do
    newblocks =
      receive do
        # handle click
        {:click, map} ->
          BlocksLogger.info("Click message recieved #{inspect(map)}")
          handle_click(blocks, order, map)

        # handle custom
        {:custom, map} ->
          BlocksLogger.info("Custom message recieved #{inspect(map)}")
          handle_custom(blocks, order, map)

        # handle a timed out script
        {_ref, {block, content}} ->
          BlocksLogger.info("Timed out message recieved from #{block} #{inspect(content)}")
          late_update(blocks, block, content)

        # update self due to timer
        {:update, timeout} ->
          BlocksLogger.info("Timer message recieved #{timeout}")

          update_self(blocks, timeout)
          |> send_blocks(order)
      end

    newblocks
    |> reset_timer(timer)
    |> init(newblocks, order)
  end

  # reset the timer if it ended or if there
  # is a shorter time until the next script
  # executes e.g. a block with less time
  # is enabled
  defp reset_timer(blocks, timer) do
    min = get_min_time(blocks)

    case Process.read_timer(timer) do
      # timer still running
      # x is the ms until it's over
      x when is_integer(x) ->
        if min < x do
          BlocksLogger.info("Sending timer message to self in #{min}")
          Process.cancel_timer(timer)
          Process.send_after(self(), {:update, min}, min)
        else
          timer
        end

      # if false, timer is already over
      false ->
        BlocksLogger.info("Sending timer message to self in #{min}")
        Process.send_after(self(), {:update, min}, min)
    end
  end

  # calculates the minimum time until
  # the next block will execute. only
  # considers the time for enabled blocks
  defp get_min_time(blocks) do
    blocks
    |> Enum.reduce(999_999, fn x, acc ->
      {_, %{:left => left, :status => status}} = x

      case status do
        1 ->
          min(left, acc)

        _ ->
          acc
      end
    end)
  end

  # if something times out, the message will
  # be received by this and update the state be handled
  defp late_update(blocks, block, content) do
    cond do
      blocks[block] != nil -> put_in(blocks[block].content, Enum.join(content, ","))
      true -> blocks
    end
  end

  # handles a custom event
  # this will not update the
  # update block is used
  defp handle_custom(blocks, order, %{"name" => blockname, "action" => action} = map) do
    # pull out relvant state for action

    case action do
      "update" ->
        BlocksLogger.info("Updating block #{blockname}")
        status = blocks[blockname].status

        # manually enable the block
        # this is so it will update even if disabled
        blocks
        |> put_in([blockname, :status], 1)
        |> put_in([blockname, :left], 0)
        |> update_self(0)
        # reset the status
        |> put_in([blockname, :status], status)
        |> send_blocks(order)

      "enable" ->
        BlocksLogger.info("Enabling block #{blockname}")
        put_in(blocks[blockname].status, 1)

      "disable" ->
        BlocksLogger.info("Disabling block #{blockname}")
        put_in(blocks[blockname].status, 0)

      "set" ->
        BlocksLogger.info("Setting key for #{blockname}")
        put_in(blocks[blockname][String.to_atom(map["key"])], map["value"])

      "setdefaultkey" ->
        BlocksLogger.info("Setting default key for #{blockname}")
        put_in(blocks[blockname].default[map["key"]], map["value"])

      "refresh" ->
        BlocksLogger.info("Refreshing output")
        send_blocks(blocks, order)

      _unrecognized ->
        BlocksLogger.warn("Unrecognized custom action: #{action}")
        blocks
    end
  end

  # handles a click event
  # this will update the block
  # if the block is enabled
  defp handle_click(blocks, order, %{"name" => blockname} = map) do
    %{^blockname => block} = blocks

    case block[:click] do
      nil ->
        BlocksLogger.warn("Block with no script clicked: #{blockname}")
        blocks

      script ->
        {:ok, str} = Poison.encode(map)

        try do
          Task.await(
            Task.async(fn ->
              System.cmd(Path.expand(script), [str, "[" <> block.content <> "]"])
            end),
            100
          )
        catch
          :exit, _ ->
            BlocksLogger.warn("Click script for #{blockname} timed out")
        end
    end

    put_in(blocks[blockname].left, 0)
    |> update_self(0)
    |> send_blocks(order)
  end

  # update blocks because time passed
  defp update_self(blocks, elapsed) do
    {tasks, newblocks} =
      blocks
      # a tuple of tasks and blocks
      |> Enum.reduce({[], %{}}, fn {name,
                                    %{
                                      :time => refresh,
                                      :left => left,
                                      :status => status,
                                      :default => default
                                    } = map},
                                   {tasks, newblocks} ->
        cond do
          # add to tasks, reset to refresh
          # if enabled and time has expired, run block
          status == 1 && left - elapsed <= 0 ->
            {[Task.async(fn -> {name, BlockRunner.update(name, default)} end) | tasks],
             Map.put(newblocks, name, Map.put(map, :left, refresh))}

          # else if enabled, then update time remaining for this block
          status == 1 ->
            # update map and then put it inside new state
            {tasks, Map.put(newblocks, name, Map.put(map, :left, left - elapsed))}

          # do nothing because this is a disabled block
          true ->
            {tasks, Map.put(newblocks, name, map)}
        end
      end)

    # run scripts
    tasks
    |> Enum.map(fn x ->
      try do
        Task.await(x, 100)
      catch
        :exit, _ ->
          BlocksLogger.warn("An update script timed out")
          {nil, []}
      end
    end)
    # ignore timed out things
    |> Enum.filter(fn {file, _} -> file != nil end)
    # update blocks with new content
    |> Enum.into(newblocks, fn {file, content} ->
      case content do
        nil ->
          {file, newblocks[file]}

        _ ->
          %{^file => map} = newblocks
          {file, Map.put(map, :content, Enum.join(content, ","))}
      end
    end)
  end

  # print blocks to stdout
  defp send_blocks(blocks, order) do
    BlocksLogger.info("Sending blocks")

    order
    |> Enum.map_join(",", fn x ->
      %{^x => %{:content => content}} = blocks
      content
    end)
    |> (&IO.puts("[" <> &1 <> "],")).()

    blocks
  end
end
