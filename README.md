# swapintro.nvim
Plugin for Neovim that replaces intro screen with your buffer.
A half-fork of [eoh-bse/minintro.nvim](https://github.com/eoh-bse/minintro.nvim)

##Installation
```lua
--Plug
plug 'bobon4uto/swapintro.nvim'
```
You need to run setup, and provide your values if you dont want the defaults.
##Example configuration:
```lua
require('swapintro').setup( {
intro = {
[[ ____  _____ _____ _   _   _ _   _____ ]],
[[|  _ \| ____|  ___/ \ | | | | | |_   _|]],
[[| | | |  _| | |_ / _ \| | | | |   | |  ]],
[[| |_| | |___|  _/ ___ \ |_| | |___| |  ]],
[[|____/|_____|_|/_/   \_\___/|_____|_|  ]]
},
buf_name = "intro",
buf_type = "none",
center = true,
center_individually = false
}
)
```
`intro` is the text you want to be displayed.
`buf_name` is what will be displayed instead of a filename.
`buf_type` is what will be displayed instead of a filetype.
`center` if set to true, the text will be centered as solid block.
`center_individually` if set to true, lines will be centered separatly.
Note that `center_individually` will not work without `center` set to true.



