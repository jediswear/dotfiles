hl.env("GDK_SCALE", "1")
hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
for workspace = 2, 6 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "HDMI-A-2" })
end

o.window("google-chrome", { workspace = "1", maximize = true })
o.window("jetbrains-webstorm", { workspace = "2" })
o.window("md.obsidian.Obsidian", { workspace = "3", maximize = true })
o.window("com.mitchellh.ghostty", { workspace = "5" })
o.window("org\\.telegram.+", { workspace = "4" })
o.window("slack", { workspace = "4" })
o.window("discord", { workspace = "4" })
o.window("cursor", { workspace = "6" })

o.window("chrome-chatgpt.com__-Default", { float = true, max_size = { 800, 600 } })
o.window("jetbrains-webstorm", { no_blur = true, opacity = "1 override" })
-- focus on webstorm popups when hovering with mouse
o.window({ class = "jetbrains-webstorm", float = true }, { no_follow_mouse = false })

-- blur walker
hl.layer_rule({ match = { namespace = "walker" }, blur = true, ignore_alpha = 0.5 })

-- blur waybar
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
