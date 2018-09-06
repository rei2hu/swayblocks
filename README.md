##### Disclaimer

Forgive me for any mistakes for I am new to Elixir.

# Sway.Blocks

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

Once you've added your script files, go into `mix.exs` and throw them in the application module thing

```exs
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod:
        {SwayStatus,
         [
           # make sure the file paths are put in as atoms
           # also it doesn't have to be in the scripts folder, i lied
           # and the second number is a timer. if you have an expensive script,
           # you can give it a longer timer and it will be run less often
           # for example, you might want your external ip but dont want to
           # ping a service every 5 seconds so we could add
           # {:"scripts/pubip, 60000} to only update that block every minute
           # also why didn't i put the comments in the actual file who knows
           {:"scripts/wifi", 5000},
           {:"scripts/battery", 1500}
         ]},
      extra_applications: [:logger]
    ]
  end
```

Also you can update the scripts and they'll be used as long as they were loaded in the beginning

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

