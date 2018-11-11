defmodule EventLoop do
  def start(settings) do
    BlocksLogger.info("Starting swayblocks...")
    IO.puts("{\"version\":1,\"click_events\":true}")
    IO.puts("[")

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
           :content => "{}",
           :status => 1,
           :default => %{}
         })
       )}
    end)
    |> init
  end

  def init({order, blocks}) do
    get_min_time(blocks)
    |> (&Process.send_after(self(), {:update, &1}, &1)).()
    |> init(blocks, Enum.reverse(order))
  end

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
          update_self(blocks, order, timeout)
      end

    newblocks
    |> reset_timer(timer)
    # order shouldnt change
    |> init(newblocks, order)
  end

  defp reset_timer(blocks, timer) do
    min = get_min_time(blocks)

    case Process.read_timer(timer) do
      # timer still running
      # x is the ms until it's over
      x when is_integer(x) ->
        if min < x do
          Process.cancel_timer(timer)
          Process.send_after(self(), {:update, min}, min)
        else
          timer
        end

      # if false, timer is already over
      false ->
        Process.send_after(self(), {:update, min}, min)
    end
  end

  # if something times out, the message will
  # be received by this and update the state be handled
  defp late_update(blocks, block, content) do
    cond do
      blocks[block] != nil -> put_in(blocks[block].content, content)
      true -> blocks
    end
  end

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

  defp handle_custom(blocks, order, %{"name" => blockname, "action" => action} = map) do
    # pull out relvant state for action
    # %{^blockname => block} = blocks

    case action do
      "update" ->
        put_in(blocks[blockname].left, 0)
        |> update_self(order, 0)

      "enable" ->
        put_in(blocks[blockname].status, 1)

      "disable" ->
        put_in(blocks[blockname].status, 0)

      "set" ->
        put_in(blocks[blockname][String.to_atom(map["key"])], map["value"])

      "setdefaultkey" ->
        put_in(blocks[blockname].default[map["key"]], map["value"])

      _unrecognized ->
        BlocksLogger.warn("Unrecognized custom action: #{action}")
        blocks
    end
  end

  defp handle_click(blocks, order, %{"name" => blockname} = map) do
    %{^blockname => block} = blocks

    case block[:click] do
      nil ->
        BlocksLogger.warn("Block with no script clicked: #{blockname}")
        blocks

      script ->
        {:ok, str} = Poison.encode(map)

        try do
          Task.await(Task.async(fn -> System.cmd(Path.expand(script), [str]) end), 100)
        catch
          :exit, _ ->
            BlocksLogger.warn("Click script for #{blockname} timed out")
        end
    end

    put_in(blocks[blockname].left, 0)
    |> update_self(order, 0)
  end

  defp update_self(blocks, order, elapsed) do
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
          left - elapsed <= 0 ->
            {[Task.async(fn -> {name, BlockRunner.update(name, default)} end) | tasks],
             Map.put(newblocks, name, Map.put(map, :left, refresh))}

          status == 1 ->
            # update map and then put it inside new state
            {tasks, Map.put(newblocks, name, Map.put(map, :left, left - elapsed))}

          # do nothing because this is a disabled block
          true ->
            {tasks, Map.put(newblocks, name, map)}
        end
      end)

    # run tasks
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
    # send updated stuff
    |> send_blocks(order)
  end

  defp send_blocks(blocks, order) do
    order
    |> Enum.map_join(",", fn x ->
      %{^x => %{:content => content}} = blocks
      content
    end)
    |> (&IO.puts("[" <> &1 <> "],")).()

    blocks
  end
end
