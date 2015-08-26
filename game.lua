require 'orbis'
require 'bot'
require 'ui'
require 'atlas'

game = {
  timeWarp = 1.0
}

actor = Bot:new {}

function game:keyPressed(key)
  if key == ' ' then
    if ui:active() then
      ui:show(nil)
    else
      actor:setTask(true)
    end
  elseif key == 'd' then
    ui:show('drek')
  end
end

function game:mousePressed(x, y, button)
  if ui:active() then
  else
    local fieldX, fieldY = math.floor(x / DIM), math.floor(y / DIM)

    if 1 <= fieldX and fieldX <= orbis.width and 1 <= fieldY and fieldY <= orbis.height then
      actor:setPathTo((fieldY - 1) * orbis.width + fieldX)
    end
  end
end

function game:draw(batch)
  local fieldBase = 0

  for y = 1, orbis.height + 1 do
    for x = 1, orbis.width + 1 do
      local field = fieldBase + x

      if x <= orbis.width then
        local floor = orbis.props[field]
        if floor then
          local quad = FIELDS[floor].quads[1]
          if quad then
            batch:add(quad, x * DIM, y * DIM, 0, 1, 1, 0, DIM)
          end
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
        local wall = orbis.props[field - orbis.width - 1]
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

function game:update(dt)
  orbis:update(dt)
end

function game:init()
  orbis:init()

  actor:insert(orbis:field(5, 5))

  ui:show([[
  AVA: Hello, are you alive?
  Kakanahishi
  Radamayoto
  Makito Narami
  Samayama
  Matako Koyama
  Ritomasashito
  ]])
end
