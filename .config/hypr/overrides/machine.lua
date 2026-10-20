local paths = require("default.hypr.paths")
local apple_silicon = paths.omarchy_path .. "/bin/omarchy-hw-apple-silicon"

return {
  -- Detect which machine this config is running on, so overrides can branch on it.
  apple_silicon = o.shell_succeeds(o.shell_quote(apple_silicon)),
}
