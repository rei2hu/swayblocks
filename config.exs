[
  %{
    :name => "~/.config/swayblocks/scripts/date",
    :time => 1000,
    :default => %{
      "color" => "#ff44ff",
      "separator_block_width" => 25
    }
  },
  %{
    :name => "~/.config/swayblocks/scripts/battery",
    :time => 30000,
    :default => %{
      "separator_block_width" => 25
    }
  },
  %{
    :name => "~/.config/swayblocks/scripts/brightness",
    :time => 1000,
    :default => %{
      "separator_block_width" => 25
    }
  },
  %{
    :name => "~/.config/swayblocks/scripts/wifi",
    :time => 1000,
    :default => %{
      "separator_block_width" => 25
    }
  },
  %{
    :name => "~/.config/swayblocks/scripts/volume",
    :time => 1000,
    :click => "~/.config/swayblocks/scripts/click/volctrl",
    :default => %{
      "separator_block_width" => 25
    }
  },
  %{
    :name => "~/.config/swayblocks/scripts/cmus",
    :time => 1000,
    :click => "~/.config/swayblocks/scripts/click/pause",
    :default => %{
      "separator_block_width" => 25,
      "color" => "#44ffff"
    }
  }
]
