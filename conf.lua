function love.conf(t)
  -- App identity corresponds to save location
  t.identity = 'com.COMPANYNAME.GAME'

  -- Configure the window
  t.window.title = 'GAME'
  t.window.width = 1280
  t.window.height = 720

  -- Configure modules we need
  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = true
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = true
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.window = true
end
