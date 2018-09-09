###### Disclaimer
Forgive me for any mistakes for I am new to Elixir.

### swayblocks
I guess you can call this my version of i3blocks.

General Rules:
1. Make sure your scripts are executable (`chmod +x your/script`)
2. Make sure they have the right [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))

##### Installation
Clone this repository and run the commands
```
make create && make build
```
`make create` will create `~/.config/swayblocks/` folder and move `config.exs` and the `scripts` folder into
it. `config.exs` is the configuration file where you add scripts and times, the scripts folder is just a few
simple scripts that come prepackaged as an example of how to configure the application.

`make build` should give you a file where the first line is `#!/usr/bin/env_escript`. This is what should be
your `status_command` should be set to.

Available through the [AUR](https://aur.archlinux.org/packages/swayblocks/)

##### config.exs
In the config file, you will find this; an array of tuples. The first entry in the tuple is the block script,
the second entry in the tuple is the time to update it, and the third entry in the tuple (optional) is the script
to run when the block is clicked. Feel free to add or delete from here as you please.

```elixir
config :SwayBlocks,
  args: [
    {"~/.config/swayblocks/scripts/date", 1000},
    {"~/.config/swayblocks/scripts/battery", 30000},
    {"~/.config/swayblocks/scripts/brightness", 10000},
    {"~/.config/swayblocks/scripts/wifi", 5000},
    {"~/.config/swayblocks/scripts/volume", 5000, "~/.config/swayblocks/scripts/click/volctrl"},
    {"~/.config/swayblocks/scripts/cmus", 5000, "~/.config/swayblocks/scripts/click/pause"}
  ]
```

##### Blocks
For scripts for blocks, make sure the output is in the format `key:value///key:value\n` where key is something from the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html) and value is what you want it to be.

For example:
```bash
#!/bin/bash

echo -n "full_text:$(date)///" # using -n flag so there's no newline
echo "color:#fffff" # here's a new line

echo -n "full_text:another block nani???///" # you can have one script output multiple blocks
echo "border:#123456///color:#ff0000" # mainly so they can use different borders or colors

echo "full_text:if you really wanted///short_text:it could be on the same line"
```

##### Click Events
When you click a block, it will automatically update itself. Also, if you put a `click_script`, it will be
executed. It will be executed like `./your/script somestring`. The string will be the click event
that is sent by the bar; you can find the structure at the bottom of the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html). 

Here's an example of the passed info from `swaybar`, you probably notice it's missing some things that i3 has.
It doesn't really matter because it's up to your script to handle it.
```
{"y":16,"x":1121,"name":"/home/rmu/.config/swayblocks/scripts/volume","button":1}
```
For example, if you take a look at the sample script [volctrl](https://github.com/rei2hu/swayblocks/blob/master/scripts/click/volctrl), you will see that it reads parses the json and executes an action based on the button.
```js
    // ...
    switch (clickInfo.button) {
        case 1: // primary
            execSync('amixer set Master 10%+')
    // ...
```

##### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Music not included, using xos4 Terminus for the font
