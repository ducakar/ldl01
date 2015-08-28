require 'orbis'
require 'bot'
require 'device'
require 'ui'
require 'atlas'

local TILES = {
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 3, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 3, 3, 4, 4, 4, 3, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 3, 3, 3, 4, 3, 3, 4, 3, 3, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 4, 4, 3, 3, 4, 3, 3, 4, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 3, 3, 3, 3, 4, 3, 4, 4, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 3, 3, 3, 3, 3, 4, 3, 3, 3, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
}

local timeWarp = 1.0
local actor
local server

FIELDS = {
  {
    layers = { 1, 0 },
    space = true
  },
  {
    layers = { 1, 0 },
    space = false
  },
  {
    layers = { 2, 0 },
    space = true
  },
  {
    layers = { 0, 1 },
    space = false
  }
}

game = {}

function game.keyPressed(key)
  ui.keyPressed(key)

  if key == 'd' then
    ui.show('AVA> Are you alive?\n\nAVA> What da fuck?', { 'Yes', 'No' })
  end
end

function game.mousePressed(x, y, button)
  if ui.active() then
    ui.mousePressed(x, y, button)
  else
    local fieldX, fieldY = math.floor(x / DIM) + 1, math.floor(y / DIM) + 1

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
          local quad = FIELDS[floor].quads[1]
          if quad then
            batch:add(quad, (x - 1) * DIM, (y - 1) * DIM)
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
          local quad = FIELDS[wall].quads[2]
          if quad then
            batch:add(quad, (x - 2) * DIM, (y - 2) * DIM, 0, 1, 1, 0, DIM)
          end
        end
      end
    end

    fieldBase = fieldBase + orbis.width
  end
end

function game.update(dt)
  if not ui.active() then
    orbis.update(dt, timeWarp)
  end

  ui.update(dt)
end

function game.init()
  ui.init()

  Bot:init()

  orbis.init()
  orbis.setTiles(TILES, FIELDS)

  actor = Bot:new()
  -- server = Device:new()

  actor:place(orbis.field(4, 4))
  -- server:place(orbis.field(13, 6))
end
