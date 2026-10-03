o.bind("SUPER + SHIFT + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

o.bind("ALT + SPACE", "ChatGPT", "~/toggle-chatgpt.sh")

-- Replace default swap window up/down
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("SUPER + SHIFT + UP", "Move window to up monitor", hl.dsp.window.move({ monitor = "+1" }))
o.bind("SUPER + SHIFT + DOWN", "Move window to down monitor", hl.dsp.window.move({ monitor = "-1" }))
o.bind("CTRL + grave", "Next app instance", hl.dsp.window.cycle_next())

-- Replace default move window into group left/right
hl.unbind("SUPER + ALT + RIGHT")
hl.unbind("SUPER + ALT + LEFT")
o.bind("SUPER + ALT + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "+1" }))
o.bind("SUPER + ALT + LEFT", "Prev workspace", hl.dsp.focus({ workspace = "-1" }))

hl.unbind("SUPER + CTRL + B")
o.bind("SUPER + A", "Bluetooth controls", "omarchy-shell shell toggle omarchy.bluetooth")

o.bind("CTRL + SHIFT + SPACE", "Switch keyboard layout", "hyprctl switchxkblayout all next")
o.bind("CTRL + SHIFT + ALT + SPACE", "Reset keyboard layout", "hyprctl switchxkblayout all 0")

hl.unbind("SUPER + SHIFT + N")
o.bind("SUPER + SHIFT + N", "Editor", "webstorm")

-- Keyboard passthrough for Citrix/VMs: disables all other bindings until exited
o.bind("SUPER + GRAVE", "Enter keyboard passthrough (Citrix/VMs)", function()
  hl.dispatch(hl.dsp.submap("passthrough"))
  hl.dispatch(hl.dsp.exec_cmd("notify-send 'Keyboard passthrough ON' 'Press SUPER+SHIFT+\\` to exit'"))
end)

hl.define_submap("passthrough", function()
  hl.bind("SUPER + SHIFT + GRAVE", function()
    hl.dispatch(hl.dsp.submap("reset"))
    hl.dispatch(hl.dsp.exec_cmd("notify-send 'Keyboard passthrough OFF'"))
  end)
end)
