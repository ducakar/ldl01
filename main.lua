require 'bot'
require 'atlas'

local lg = love.graphics

local WIDTH  = 480
local HEIGHT = 270

local canvas = {}
local actor = Bot:new()

function love.resize(windowWidth, windowHeight)
  local canvasRatio = WIDTH / HEIGHT
  local windowRatio = windowWidth / windowHeight

  if canvasRatio < windowRatio then
    canvas.scale   = windowHeight / HEIGHT
    canvas.width   = windowHeight * canvasRatio
    canvas.height  = windowHeight
    canvas.offsetX = (windowWidth - canvas.width) / 2
    canvas.offsetY = 0
  else
    canvas.scale   = windowWidth / WIDTH
    canvas.width   = windowWidth
    canvas.height  = windowWidth / canvasRatio
    canvas.offsetX = 0
    canvas.offsetY = (windowHeight - canvas.height) / 2
  end
end

function love.load(table)
  local windowWidth, windowHeight = love.window.getDimensions()

  love.resize(windowWidth, windowHeight)
  love.window.setMode(windowWidth, windowHeight, { resizable = true })
  love.window.setFullscreen(true, 'desktop')

  canvas.handle = lg.newCanvas(WIDTH, HEIGHT)
  canvas.handle:setFilter('nearest', 'nearest')

  lg.setFont(lg.newFont('base/DroidSansMono.ttf', 12))
  atlas:init()
  batch = lg.newSpriteBatch(atlas.image)

  orbis:init()
  actor:insert(orbis:field(5, 5))
end

function love.mousepressed(x, y, button)
  -- if button == 'r' then
    local localX, localY = (x - canvas.offsetX) / canvas.width * WIDTH, (y - canvas.offsetY) / canvas.height * HEIGHT
    local fieldX, fieldY = math.floor(localX / DIM), math.floor(localY / DIM)

    if 1 <= fieldX and fieldX <= orbis.width and 1 <= fieldY and fieldY <= orbis.height then
      actor:setPathTo((fieldY - 1) * orbis.width + fieldX)
    end
  -- end
end

function love.keypressed(key)
  if key == 'f11' then
    love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
  elseif key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  orbis:update(dt)
end

function orbis:draw(batch)
  local fieldBase = 0

  for y = 1, self.height + 1 do
    for x = 1, self.width + 2 do
      local field = fieldBase + x

      if x <= self.width then
        local floor = self.props[field]
        if floor then
          local quad = FIELDS[floor].quads[1]
          if quad then
            batch:add(quad, x * DIM, y * DIM, 0, 1, 1, 0, DIM)
          end
        end
      end
      if 1 < x and x <= self.width + 1 then
        local object = self.objects[field - self.width - 1]
        if object then
          local ox, oy = object:pos()
          batch:add(atlas.robot[object.dir][1], ox * DIM, oy * DIM, 0, 1, 1, 0, DIM)
        end
      end
      if 2 < x then
        local wall = self.props[field - self.width - 2]
        if wall then
          local quad = FIELDS[wall].quads[2]
          if quad then
            batch:add(quad, (x - 2) * DIM, (y - 1) * DIM, 0, 1, 1, 0, DIM)
          end
        end
      end
    end

    fieldBase = fieldBase + self.width
  end
end

function love.draw()
  orbis:draw(batch)

  lg.setCanvas(canvas.handle)
  lg.clear()
  lg.draw(batch)
  lg.setCanvas()
  lg.draw(canvas.handle, canvas.offsetX, canvas.offsetY, 0, canvas.scale, canvas.scale)

  batch:clear()
end
