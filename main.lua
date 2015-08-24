require 'bot'
require 'atlas'

local canvas = {}
local actor = Bot:new({
  speed = 4.0
})

function love.load(table)
  local canvasRatio = WIDTH / HEIGHT

  canvas.desktopWidth, canvas.desktopHeight = lw.getDesktopDimensions()
  canvas.desktopRatio = canvas.desktopWidth / canvas.desktopHeight

  lw.setMode(canvas.desktopWidth, canvas.desktopHeight, { fullscreen = true })

  canvas.handle = lg.newCanvas(WIDTH, HEIGHT)
  canvas.handle:setFilter('nearest', 'nearest')

  -- Adjust canvas scaling
  if canvasRatio < canvas.desktopRatio then
    canvas.scale   = canvas.desktopHeight / HEIGHT
    canvas.width   = canvas.desktopHeight * canvasRatio
    canvas.height  = canvas.desktopHeight
    canvas.offsetX = (canvas.desktopWidth - canvas.width) / 2
    canvas.offsetY = 0
  else
    canvas.scale   = canvas.desktopWidth / WIDTH
    canvas.width   = canvas.desktopWidth
    canvas.height  = canvas.desktopWidth / canvasRatio
    canvas.offsetX = 0
    canvas.offsetY = (canvas.desktopHeight - canvas.height) / 2
  end

  lg.setFont(lg.newFont('base/DroidSansMono.ttf', 12))
  atlas:init('img/atlas.png')
  batch = lg.newSpriteBatch(atlas.image)

  orbis:init()
  actor:insert(5, 5)
end

function love.mousepressed(x, y, button)
  if button == 'r' then
    local lX, lY = (x - canvas.offsetX) / canvas.width * WIDTH, (y - canvas.offsetY) / canvas.height * HEIGHT
    lX = math.min(math.max(math.ceil(lX / DIM), 3), 16)
    lY = math.min(math.max(math.ceil(lY / DIM), 3), 12)
    local field = (lY - 2) * orbis.width + lX - 1
    actor:setPathTo(field)
  end
end

function love.update(dt)
  actor:update(dt)
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
