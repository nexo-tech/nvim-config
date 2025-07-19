local autoconf = require("autoconf")
local themekit = require("themekit")

autoconf.define_resolver("editor.theme", {
    resolver = function(name) return themekit.apply(name) end,
    lifecycle = autoconf.Lifecycle.LATE,
})
autoconf.define_command_resolver("open_theme_picker",
    function(_) return vim.cmd("ThemePicker") end)
