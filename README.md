## swayblocks
I guess you can call this my version of i3blocks. Supports scripts in any language, click events, and can handle a bit of custom input through stdin.

### Installation
Available through the [AUR](https://aur.archlinux.org/packages/swayblocks/)

For manual installation, clone this repository and run the commands
```
make create && make build
```
Then, move the `swayblocks` script to `/usr/bin` and set your `status_command` to the following:
```config
bar {
  status_command swayblocks
}
```
If you want custom input, you have to modify your status_command, take a look at the [Other Input](https://github.com/rei2hu/swayblocks/wiki/Other-Input) page on the wiki.

### Usage
Check out the [wiki](https://github.com/rei2hu/swayblocks/wiki).

### Screenshot
This is how it looks with the packaged scripts... assuming they work for you
![a picture of the bar](https://i.imgur.com/46pFMLg.png)
Music not included, using xos4 Terminus for the font
