require 'orbis'
require 'bot'
require 'device'
require 'ui'
require 'atlas'

local TILES = {
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 2, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 1, 2, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
}

FIELDS = {
  {
    layers = { 1, 0 },
    space = true
  },
  {
    layers = { 0, 1 },
    space = false
  }
}

game = {
  timeWarp = 1.0
}

actor = Bot:new {}
server = Device:new {}

function game.keyPressed(key)
  ui.keyPressed(key)
end

function game.mousePressed(x, y, button)
  if ui.active() then
    ui.mousePressed(x, y, button)
  else
    local fieldX, fieldY = math.floor(x / DIM), math.floor(y / DIM)

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
            batch:add(quad, x * DIM, y * DIM, 0, 1, 1, 0, DIM)
          end
        end
        if not orbis.spaces[field] then
          batch:add(atlas.cross, x * DIM, y * DIM, 0, 1, 1, 0, DIM)
        end
      end
      if x <= orbis.width then
        local object = orbis.objects[field - orbis.width]
        if object then
          local ox, oy = object:pos()
          batch:add(atlas.robot[object:frame()], ox * DIM, oy * DIM, 0, 1, 1, 0, DIM)
        end
      end
      if 1 < x then
        local wall = orbis.tiles[field - orbis.width - 1]
        if wall then
          local quad = FIELDS[wall].quads[2]
          if quad then
            batch:add(quad, (x - 1) * DIM, (y - 1) * DIM, 0, 1, 1, 0, DIM)
          end
        end
      end
    end

    fieldBase = fieldBase + orbis.width
  end
end

function game.update(dt)
  if not ui.active() then
    orbis.update(dt)
  end

  if server.field ~= 0 and orbis.time > 10 then
    server:remove()
  end
end

function game.init()
  ui.init()

  orbis.init()
  orbis.setTiles(TILES, FIELDS)
  actor:place(orbis.field(5, 5))
  server:place(orbis.field(3, 8))

  ui.show([[
  AVA: Hello, are you alive?
  ]])
end
