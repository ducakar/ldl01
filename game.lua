local orbis  = require 'orbis'
local net    = require 'net'
local Bot    = require 'Bot'
local stream = require 'stream'
local ui     = require 'ui'
local atlas  = require 'atlas'

local TILES = {
  4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3,
  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 7, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 7, 7, 8, 8, 8, 7, 8, 8, 8, 8, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 7, 7, 7, 8, 7, 7, 8, 7, 7, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 8, 8, 7, 7, 8, 7, 7, 8, 7, 8, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 7, 7, 7, 7, 8, 7, 8, 8, 7, 8, 7, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 8, 7, 7, 7, 7, 7, 8, 7, 7, 7, 7, 8, 7, 8, 1, 1, 1, 1, 1, 9, 1, 1, 5,
  6, 1, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5,
  4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3
}

local actor = nil
local game  = {}

function game.keyPressed(key)
  ui.keyPressed(key)

  if key == '`' then
    net.timeWarp = 1
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

function game.draw(batch)
  local fieldBase = 0

  for y = 1, orbis.height + 1 do
    for x = 1, orbis.width + 1 do
      local field = fieldBase + x

      if x <= orbis.width then
        local floor = orbis.tiles[field]
        if floor then
          local quad = atlas.FIELDS[floor].quads[1]
          if quad then
            batch:add(quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM)
          end
        end
      end
      if x <= orbis.width then
        local object = orbis.objects[field - orbis.width]
        if object then
          object:draw(batch)
        end
      end
      if 1 < x then
        local wall = orbis.tiles[field - orbis.width - 1]
        if wall then
          local quad = atlas.FIELDS[wall].quads[2]
          if quad then
            batch:add(quad, (x - 2) * atlas.DIM, (y - 2) * atlas.DIM, 0, 1, 1, 0, atlas.DIM)
          end
        end
      end
    end

    fieldBase = fieldBase + orbis.width
  end
end

function game.init()
  ui.init()

  local o = stream.read('autosave.lua')

  if o then
    orbis.init(o.orbis)

    local _, object = next(o.objects)

    actor = Bot:new(object)
    actor:place(actor.field)
  else
    orbis.init()
    orbis.setTiles(TILES, atlas.FIELDS)

    actor = Bot:new()
    actor:place(orbis.field(4, 4))
  end
end

function game.quit()
  stream.write('autosave.lua', {
    orbis = orbis.write(),
    objects = orbis.objects
  })
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
