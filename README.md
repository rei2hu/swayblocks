###### Disclaimer
Forgive me for any mistakes for I am new to Elixir.

## swayblocks
I guess you can call this my version of i3blocks.

General Rules:
1. Make sure your scripts are executable (`chmod +x your/script`)
2. Make sure they have the right [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))

### Table of Contents
1. [Installation](#installation)
2. [Config](#config)
3. [Blocks](#blocks)
4. [Click Events](#click-events)
5. [Other Input](#other-input)
6. [Screenshot](#screenshot)

### Installation
Available through the [AUR](https://aur.archlinux.org/packages/swayblocks/)

For manual installation, clone this repository and run the commands
```
make create && make build
```
`make create` will create the `~/.config/swayblocks/` folder and move `config.exs` and the `scripts` folder into
it. `config.exs` is the configuration file where you add scripts and times, the scripts folder is just a few
simple scripts that come prepackaged as an example of how to configure the application.

`make build` should give you a file where the first line is `#!/usr/bin/env_escript`. This is what should be
your `status_command` should be set to, for example
```config
bar {
  status_command swayblocks
}
```

### Config
In the `~/.config/swayblocks/config.exs` ([config.exs](https://github.com/rei2hu/swayblocks/blob/master/config.exs)) file, 
you will find a list of maps. The following keys are used to customize the behaviour of each block. Only `name` is
necessary. The defaults for the other keys are shown below:
```elixir
%{
  :name => "~/some/path", # the script that determines the block's appearance
  :time => 999_999, # the time this block will refresh in
  :click => nil, # the script that will be run when the block is clicked
  :status => 1, # whether or not this block is updating, 1 means enabled
  :default => %{} # the default options to apply to each block
}
```

##### Defaults
The default is a map where properties will be pulled from if they are not output from the script. For example with
```exs
:name => "~/some/script",
:default => %{
  "full_text" => "bottom text",
  "color" => "#ff0000"
}
```
If some script does not output anything for `full_text` or `color`, those values will end up being what is defined in
`:default`; in this case "bottom text" and red, respectively. The default is applied to all blocks that are output
from the named script.

### Blocks
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

### Click Events
When you click a block, it will automatically update itself. Also, if you provided a `:click` script, it will be
executed like `./your/script somestring`. The string will be the click event that is sent by the bar; you can
find the structure at the bottom of the [i3bar protocol](https://i3wm.org/docs/i3bar-protocol.html). 

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

### Other Input
You can also change the state of the blocks without clicking on them, however this requires the use of a named pipe
as a kind of funnel, so first you need to change your `status_command`.
```bash
bar {
  status_command mkfifo .swayblocks.pipe;(swayblocks<.swayblocks.pipe &);cat>.swayblocks.pipe
}
```
Here, we create a pipe, make `swayblocks` take input from it and pipe `i3bar`/`swaybar`'s input into the 
with `cat` instead of directly to `swayblocks`.

To keep things simple, what you send to the pipe should also be in json like the click events. There are two
necessary keys, `action` and `name`. 

Right now, there are 4 actions: `update`, `enable`, `disable`, and `set`.

##### Update
Sending an `update` action to the pipe will force the block to update.
```bash
echo '{"action":"update", "name":"~/.config/swayblocks/scripts/battery"}' > ~/.swayblocks.pipe 
```

##### Enable/Disable
Sending an `enable` action to the pipe will set its `status` to 1, which means it will update itself when its time comes.
```bash
echo '{"action":"enable", "name":"~/.config/swayblocks/scripts/cmus"}' > ~/.swayblocks.pipe 
```
Disable will do the opposite. Do note that this just stops the block from updating and does not remove the block.

##### Set
`set` is kind of the all powerful action which let's you modify any part of the state of the program. First, I will lay
out the general structure of the state of each block:
```elixir
%{
  :click => the click event,
  :time => the interval to refresh the block,
  :left => the time until this block will be refreshed,
  :status => whether the block is updating itself or not,
  :content => the actual content of the block (list of encoded/stringified json)
}
```
This time, you want to send a `key` and `value`. For example, we don't want to see the brightness block anymore so we set its `:content` to `["{}"]`
```bash
echo '{"action":"set", "name":"~/.config/swayblocks/scripts/brightness", "key":"content", "value":["{}"]}' > ~/.swayblocks.pipe 
```
Follow up with a `disable` action and this block won't ever show up again until you `enable` it. Or maybe you want to use a
different script when the block is clicked
```bash
echo '{"action":"set", "name":"~/.config/swayblocks/scripts/brightness", "key":"click", "value":"~/some/new/click/handling/script}' > ~/.swayblocks.pipe 
```

##### Caveats
One thing to note is that I look for the `button` key to determine whether or not the input is a click, so you can fake
clicks by sending json with `name` and `button` keys; for example this will make the bar think the `cmus` block was left
clicked.
```bash
echo '{"button":"1", "name":"~/.config/swayblocks/scripts/cmus"}' > ~/.swayblocks.pipe 
```

Also, lowering the `:left` time for a block won't cause it to update faster because it won't touch the internal timer
that is used.

### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Music not included, using xos4 Terminus for the font
