##### Disclaimer
Forgive me for any mistakes for I am new to Elixir.

### swayblocks
I guess you can call this my version of i3blocks.

General Rules:
1. Make sure your scripts are executable (`chmod +x your/script`).
2. Make sure they have the right [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
3. Make sure they are entered as atoms in the `mix.exs` file with a path which will be relative to the cwd

##### Scripts
For scripts that will output to the status bar, each block should be in the format `key:value///key:value\n`.

For example:
```bash
#!/bin/bash

echo -n "full_text:$(date)///" # using -n flag so there's no newline
echo "color:#fffff" # here's a new line

echo -n "full_text:another block nani???///" # you can have one script output multiple blocks
echo -n "border:#123456///" # mainly so they can use different borders
echo "color:#ff0000" # or colors

echo "full_text:if you really wanted///short_text:it could be on the same line"
```

Read the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html) for information on how to customize
your blocks.

Once you've created your script files, go into `mix.exs` make a tuple for each script. Tuples are in the 
form `{script, timer, click_script}` where `click_script` is optional. The timer can be as high as you 
want it to be, but know that the bar will always be drawn after at most 999999 milliseconds because that's
the number I put in the code and not like Infinity.
```exs
  def application do
    [
      mod:
        {SwayStatus,
         [
           {:"scripts/date", 1000},
           {:"scripts/battery", 30000},
           {:"scripts/brightness", 10000},
           {:"scripts/wifi", 5000},
           {:"scripts/volume", 5000, :"scripts/click/volctrl"},
           {:"scripts/cmus", 5000, :"scripts/click/pause"}
         ]},
      extra_applications: [:logger]
    ]
  end
```
Also you can update the scripts and they'll be used as long as they were loaded in the beginning.

##### Click Events
When you click a block, it will automatically update itself. Also, if you put a `click_script`, it will be
executed. It will be executed like `./your/script somejsonstring`. The json string will be the click event
that is sent by the bar, you can find the structure at the bottom of the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html). 

If you take a look at the sample script [volctrl](https://github.com/rei2hu/swayblocks/blob/master/scripts/click/volctrl), you will see 
```js
    const clickInfo = JSON.parse(process.argv[2]);
    const { execSync } = require('child_process');
    switch (clickInfo.button) {

        case 1: // primary
            execSync('amixer set Master 10%+')
    // ...
```
1. It's written in node.js instead of bash and it works
2. It parses the passed string and uses that to determine what command to run

##### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Music not included, using xos4 Terminus for the font

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

