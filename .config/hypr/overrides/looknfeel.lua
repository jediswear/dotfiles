hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    col = {
      inactive_border = "rgba(75737360)",
      active_border = "rgba(0078d4ff)",
    },
  },

  decoration = {
    rounding = 0,

    blur = {
      enabled = true,
      size = 12,
      passes = 3,
      noise = 0.03,
      vibrancy = 0.7,
      vibrancy_darkness = 1,
      contrast = 1.5,
      brightness = 0.6
    },

    shadow = {
      enabled = false,
    },

    dim_inactive = true,
    dim_strength = 0.3,
  },
})

-- mako blur
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.3 })

-- omarchy menu blur (ignore_alpha > scrim-alpha so only the card is blurred)
hl.layer_rule({ match = { namespace = "omarchy-menu" }, blur = true, ignore_alpha = 0.6 })

-- omarchy bar blur
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true })
