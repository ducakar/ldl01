function love.conf(t)
  t.identity              = 'ldl01'
  t.version               = '0.9.2'

  t.window.title          = 'ldl01'
  t.window.width          = 1024
  t.window.height         = 576
  t.window.resizable      = true
  t.window.fullscreen     = true
  t.window.fullscreentype = 'desktop'

  t.modules.joystick      = false
  t.modules.math          = false
  t.modules.physics       = false
  t.modules.system        = false
  t.modules.thread        = false
end
