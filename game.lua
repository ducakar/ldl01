local atlas  = require 'atlas'
local net    = require 'net'
local orbis  = require 'orbis'
local Bot    = require 'Bot'
local Device = require 'Device'
local ui     = require 'ui'
local stream = require 'stream'

local actor = nil

local game = {}

function game.keyPressed(key)
  ui.keyPressed(key)

  if key == '1' then
    net.timeWarp = 2
  elseif key == '2' then
    net.timeWarp = 3
  elseif key == '3' then
    net.timeWarp = 4
  elseif key == '4' then
    net.timeWarp = 5
  elseif key == 'd' then
    ui.show([[
    Decompressing Linux... Parsing ELF... done.
    Booting the kernel.
    starting version 337]],
    { 'Yes', 'No' })
  end
end

function game.mousePressed(x, y, button)
  if ui.active() then
    ui.mousePressed(x, y, button)
  else
    local fieldX, fieldY = math.floor(x / atlas.DIM) + 1, math.floor(y / atlas.DIM) + 1

    if 1 <= fieldX and fieldX <= orbis.width and 1 <= fieldY and fieldY <= orbis.height then
      actor:setPathTo((fieldY - 1) * orbis.width + fieldX)
    end
  end
end

function game.mouseMoved(x, y)
  if ui.active() then
    ui.mouseMoved(x, y)
  end
end

function game.init()
  ui.init()

  local o = stream.read('autosave.lua')
  -- o = nil

  if o then
    net.init(o.net)
    orbis.init(o.orbis)
  else
    net.init()
    orbis.init({ map = 'maps/warehouse' })

    Bot:new({ field = orbis.field(4, 4) }):place()

    Device.Warning:new({ field = orbis.field(23, 13) }):place()
    Device.Server:new({ field = orbis.field(12, 6) }):place()
    Device.Switch:new({ field = orbis.field(20, 10) }):place()
  end

  for _, obj in pairs(orbis.objects) do
    if obj.class == 'Bot' then
      actor = obj
      break
    end
  end
end

function game.quit()
  stream.write('autosave.lua', {
    net   = net.write(),
    orbis = orbis.write()
  })
end

function game.draw()
  orbis.draw()
  ui.draw()
end

function game.update(dt)
  if not ui.active() then
    net.update(dt)
    orbis.update(dt)
  end

  ui.update(dt)

  if ui.selection == 2 then
    love.event.quit()
  end
end

return game
