local atlas  = require 'atlas'
local net    = require 'net'
local orbis  = require 'orbis'
local _      = require 'Bot'
local _      = require 'Device'
local ui     = require 'ui'
local stream = require 'stream'
local la     = love.audio
local lf     = love.filesystem

local tracks     = {}
local trackIndex = 1
local music      = nil
local game       = {}

function game.keyPressed(key)
  ui.keyPressed(key)

  if ui.active() then
    return
  end

  if key == 'tab' then
    net.mapView = not net.mapView
  elseif key == '1' then
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

function game.textInput(char)
  ui.textInput(char)
end

function game.mousePressed(x, y, button)
  if ui.active() then
    ui.mousePressed(x, y, button)
  elseif net.mapView then
    net.mousePressed(x, y, button)
  else
    local fieldX, fieldY = math.floor(x / atlas.DIM) + 1, math.floor(y / atlas.DIM) + 1

    orbis.actor:setPathTo(orbis.field(fieldX, fieldY))
  end
end

function game.mouseMoved(x, y)
  ui.mouseMoved(x, y)
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

    orbis.actor = orbis.Object.Bot:new{ field = orbis.field(4, 4) }
    orbis.actor:place()

    orbis.Object.Warning:new{ field = orbis.field(24, 13) }:place()
    orbis.Object.Server:new{ field = orbis.field(12, 6) }:place()
    orbis.Object.Switch:new{ field = orbis.field(20, 10) }:place()
  end

  tracks = lf.getDirectoryItems('music')
end

function game.quit()
  stream.write('autosave.lua', {
    net   = net.save(),
    orbis = orbis.save()
  })
end

function game.draw()
  if net.mapView then
    net.draw()
  else
    orbis.draw()
  end

  ui.draw()
end

function game.update(dt)
  if not ui.active() then
    net.update(dt)
    orbis.update(dt)
  end

  ui.update(dt)

  if (not music or music:isStopped()) and #tracks ~= 0 then
    trackIndex = math.fmod(trackIndex + 1, #tracks)

    music = la.newSource('music/' .. tracks[1 + trackIndex])
    music:play()
  end
end

return game
