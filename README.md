###### Disclaimer
Forgive me for any mistakes for I am new to Elixir.

### swayblocks
I guess you can call this my version of i3blocks.

General Rules:
1. Make sure your scripts are executable (`chmod +x your/script`)
2. Make sure they have the right [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))

##### Table of Contents
1. [Installation](#installation)
2. [config.exs](#configexs)
3. [Blocks](#blocks)
4. [Click Events](#click-events)
5. [Other Input](#other-input)
6. [Screenshot](#screenshot)

##### Installation
Available through the [AUR](https://aur.archlinux.org/packages/swayblocks/)

For manual installation, clone this repository and run the commands
```
make create && make build
```
`make create` will create `~/.config/swayblocks/` folder and move `config.exs` and the `scripts` folder into
it. `config.exs` is the configuration file where you add scripts and times, the scripts folder is just a few
simple scripts that come prepackaged as an example of how to configure the application.

`make build` should give you a file where the first line is `#!/usr/bin/env_escript`. This is what should be
your `status_command` should be set to, for example
```bash
status_command swayblocks
```

##### config.exs
In the config file, you will find a list of maps. The following keys are used to customize the behaviour of
the blocks. Only name is necessary. The defaults for the other keys are shown below:
```elixir
%{
  :name => "~/some/path", # the script that determines the block's appearance
  :time => 999_999, # the time this block will refresh in
  :click => nil, # the script that will be run when the block is clicked
  :status => 1 # whether or not this block is updating, 1 means enabled
}
```

##### Blocks
For scripts for blocks, make sure the output is in the format `key:value///key:value\n` where key is
something from the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html) and value is what you
want it to be. For example:
```bash
#!/bin/bash

echo -n "full_text:$(date)///" # using -n flag so there's no newline
echo "color:#fffff" # here's a new line

echo -n "full_text:another block nani???///" # you can have one script output multiple blocks
echo "border:#123456///color:#ff0000" # mainly so they can use different borders or colors

echo "full_text:if you really wanted///short_text:it could be on the same line"
```

##### Click Events
When you click a block, it will automatically update itself. Also, if you provided a `:click` script, it will be
executed like `./your/script somestring`. The string will be the click event that is sent by the bar; you can
find the structure at the bottom of the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html). An example
of the information from `swaybar` can be found below.
```
{"y":16,"x":1121,"name":"/home/rmu/.config/swayblocks/scripts/volume","button":1}
```
This can be used to determine what action to take in your script. If you take a look at the sample script [volctrl](https://github.com/rei2hu/swayblocks/blob/master/scripts/click/volctrl), you will see that it parses the json and
executes an action based on the button.
```js
    const clickInfo = JSON.parse(process.argv[2]);
    // ...
    switch (clickInfo.button) {
        case 1: // primary
            execSync('amixer set Master 10%+')
    // ...
```

##### Other Input
You can also change the state of the blocks without clicking on them now, however this requires the use of a named pipe
as a kind of funnel, so first you need to change your `status_command`.
```bash
status_command mkfifo .swayblocks.pipe;(swayblocks<.swayblocks.pipe 3>.swayblocks.pipe &);cat>.swayblocks.pipe
```
Here, we create a pipe, make `swayblocks` take input from it, use `swayblocks` to keep the pipe 
open (potentially bad idea), and pipe `i3bar`/`swaybar`'s input into the pipe instead of directly to swayblocks with `cat`.

Since `swaybar`/`i3bar` spit out json for click events, I have also decided that custom input should be json. There are two
necessary keys, `action` and `name`. 

Right now, there are 3 actions: `update`, `enable`, and `disable`, which will update, enable, or disable the block
labeled in name respectively. For example, by echoing a disable action to the pipe, I disabled the `cmus` block from
updating itself. It could be enabled again by echoing the `enable` action to it.
```bash
echo "{\"action\":\"disable\", \"name\":\"~/.config/swayblocks/scripts/cmus\"}" > ~/.swayblocks.pipe
```

One thing to note is that I look for the `button` key to determine whether or not the input is a click, so you can fake
clicks by sending json with `name` and `button` keys; for example this will make the bar think the `cmus` block was left
clicked.
```bash
echo "{\"button\":1, \"name\":\"~/.config/swayblocks/scripts/cmus\"}" > ~/.swayblocks.pipe
```

##### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Music not included, using xos4 Terminus for the font
