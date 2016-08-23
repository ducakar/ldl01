function love.conf(t)
  t.identity          = 'ldl01'
  t.version           = '0.10.1'

  t.window.title      = 'ldl01'
  t.window.width      = 320
  t.window.height     = 240
  t.window.resizable  = true
  t.window.fullscreen = false

  t.modules.joystick  = false
  t.modules.math      = false
  t.modules.physics   = false
  t.modules.system    = false
  t.modules.thread    = false
end
