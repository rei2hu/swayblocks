configdir = ~/.config/swayblocks/
configfile = config.exs
scriptsdir = ./scripts

create:

ifeq ("$(wildcard $(configdir)$(configfile))", "")
	@echo "### Creating $(configdir) and moving $(configfile) into it"
	mkdir -p $(configdir) && cp ./config.exs $(configdir)$(configfile)
	@echo "### Copying $(scriptsdir) to $(configdir)"
	cp -r $(scriptsdir) $(configdir)
else
	@echo "### Found $(configdir)$(configfile), not copying defaults over"
endif

build:
	@echo "### Installing elixir dependencies"
	mix deps.get
	@echo "### Building file"
	mix escript.build
	@echo "### Finished, you should now have a swayblocks standalone binary"
