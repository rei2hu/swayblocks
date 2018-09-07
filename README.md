##### Disclaimer

Forgive me for any mistakes for I am new to Elixir.

### swayblocks

#### Scripts
So just make a scripts folder in the project and dump some bash scripts in them. Echo things out like in the following example

```bash
#!/bin/bash

# /// is used to seperate the different fields, there's no need to escape quotes here
# the newline is used to seperate blocks, this means you can have one script spit
# out multiple blocks

echo -n "full_text:$(date)///"
echo "color:#fffff"

echo -n "full_text:another block nani???///"
echo -n "border:#123456///"
echo "color:#ff0000"
```

See [this link](https://i3wm.org/docs/i3bar-protocol.html) for the list of valid fields and stuff

Once you've added your script files, go into `mix.exs` and throw them in the application module thing. Each tuple must have
at least 2 entries and can have at most 3 like `{script, timer, click_script}` where `click_script` is optional. Make sure the script names are atoms and the highest a timer can be is `999999` because that's the number I put in the code.

```exs
  def application do
    [
      mod:
        {SwayStatus,
         [
           {:"scripts/date", 1000},
           {:"scripts/battery", 10000},
           {:"scripts/brightness", 1000},
           {:"scripts/wifi", 5000},
           {:"scripts/volume", 5000, :"scripts/mute"},
           {:"scripts/cmus", 5000}
         ]},
      extra_applications: [:logger]
    ]
  end
```

Also you can update the scripts and they'll be used as long as they were loaded in the beginning.

#### Click Events

It may or may not get kind of laggy when you click something. Clicking a block will update it's contents
in addition to running whatever script you defined in the `mix.exs` file.

#### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Workspaces not included, using xos4 Terminus for the font


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sway_status` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sway_status, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sway_status](https://hexdocs.pm/sway_status).

