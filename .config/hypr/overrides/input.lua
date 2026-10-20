local machine = require("hypr.overrides.machine")

hl.config({
  input = {
    kb_layout = "us,ru",

    sensitivity = machine.apple_silicon and 0 or -0.86,
    touchpad = {
      natural_scroll = true,
    },
  },

  misc = {
    focus_on_activate = false,
  },
})

o.exec_on_start("hyprctl setcursor aero 24")
