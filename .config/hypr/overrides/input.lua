local machine = require("hypr.overrides.machine")

hl.config({
  input = {
    kb_layout = "us,ru",
    -- Swap Option/Command on the Mac keyboard so the bottom row reads Ctrl, Super, Alt like a PC keyboard
    kb_options = machine.apple_silicon and "compose:caps,shift:both_capslock_cancel,altwin:swap_lalt_lwin" or nil,

    sensitivity = machine.apple_silicon and 0 or -0.86,
    touchpad = {
      natural_scroll = true,
    },
  },

  gestures = {
    workspace_swipe_distance = 1500,
    workspace_swipe_cancel_ratio = 0.05,
  },

  misc = {
    focus_on_activate = false,
  },
})

-- Swipe between workspaces with three fingers, like macOS Spaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

o.exec_on_start("hyprctl setcursor aero 24")
