require 'bot'
require 'atlas'

local lg = love.graphics

-- local WIDTH  = 640
-- local HEIGHT = 360
local WIDTH  = 320
local HEIGHT = 240

local canvas = {}
local actor = Bot:new({
  speed = 4.0
})

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
  -- love.window.setFullscreen(true, 'desktop')

  canvas.handle = lg.newCanvas(WIDTH, HEIGHT)
  canvas.handle:setFilter('nearest', 'nearest')

  lg.setFont(lg.newFont('base/DroidSansMono.ttf', 12))
  atlas:init('img/atlas.png')
  batch = lg.newSpriteBatch(atlas.image)

  orbis:init()
  actor:insert(orbis:field(5, 5))
end

function love.mousepressed(x, y, button)
  -- if button == 'r' then
    local localX, localY = (x - canvas.offsetX) / canvas.width * WIDTH, (y - canvas.offsetY) / canvas.height * HEIGHT
    local fieldX, fieldY = math.floor(localX / DIM), math.floor(localY / DIM)
    local field = (fieldY - 1) * orbis.width + fieldX

    if 1 <= field and field <= orbis.length then
      actor:setPathTo(field)
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
  actor:update(dt)
end

function orbis:draw(batch)
  for y = 1, self.height do
    for x = 1, self.width do
      local field  = (y - 1) * self.width + x
      local quads  = FIELDS[self.props[field]].quads
      local object = self.objects[field - self.width]
      local px, py = x * DIM, y * DIM

      if quads[1] then
        batch:add(quads[1], px, py, 0, 1, 1, 0, DIM)
      end
      if object then
        local ox, oy = object:pos()
        batch:add(atlas.robot[object.dir][1], ox * DIM, oy * DIM, 0, 1, 1, 0, DIM)
      end
      if quads[2] then
        batch:add(quads[2], px, py, 0, 1, 1, 0, DIM)
      end
    end
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
