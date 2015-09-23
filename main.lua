local atlas = require 'atlas'
local le    = love.event
local lg    = love.graphics
local lw    = love.window

local stage
local canvas = {}

function love.keypressed(key)
  if key == 'f11' then
    lw.setFullscreen(not lw.getFullscreen(), 'desktop')
  elseif key == 'escape' then
    le.quit()
  elseif stage then
    stage.keyPressed(key)
  end
end

function love.mousepressed(x, y, button)
  if stage then
    local localX = (x - canvas.offsetX) / canvas.width * atlas.WIDTH
    local localY = (y - canvas.offsetY) / canvas.height * atlas.HEIGHT

    if 0 <= localX and localX < atlas.WIDTH and 0 <= localY and localY < atlas.HEIGHT then
      stage.mousePressed(localX, localY, button)
    end
  end
end

function love.mousemoved(x, y)
  if stage then
    local localX = (x - canvas.offsetX) / canvas.width * atlas.WIDTH
    local localY = (y - canvas.offsetY) / canvas.height * atlas.HEIGHT

    if 0 <= localX and localX < atlas.WIDTH and 0 <= localY and localY < atlas.HEIGHT then
      stage.mouseMoved(localX, localY)
    end
  end
end

function love.resize(windowWidth, windowHeight)
  local canvasRatio = atlas.WIDTH / atlas.HEIGHT
  local windowRatio = windowWidth / windowHeight

  if canvasRatio < windowRatio then
    canvas.scale   = windowHeight / atlas.HEIGHT
    canvas.width   = windowHeight * canvasRatio
    canvas.height  = windowHeight
    canvas.offsetX = (windowWidth - canvas.width) / 2
    canvas.offsetY = 0
  else
    canvas.scale   = windowWidth / atlas.WIDTH
    canvas.width   = windowWidth
    canvas.height  = windowWidth / canvasRatio
    canvas.offsetX = 0
    canvas.offsetY = (windowHeight - canvas.height) / 2
  end
end

function love.load()
  local windowWidth, windowHeight = lw.getDimensions()

  lw.setMode(windowWidth, windowHeight, { resizable = true })
  lw.setFullscreen(true, 'desktop')
  lg.setDefaultFilter('nearest', 'nearest')

  love.resize(windowWidth, windowHeight)
  canvas.handle = lg.newCanvas(atlas.WIDTH, atlas.HEIGHT)

  atlas.init()

  stage = require 'game'
  stage.init()
end

function love.quit()
  stage.quit()
end

function love.draw()
  lg.setCanvas(canvas.handle)
  stage.draw()
  lg.setCanvas()
  lg.setColor(255, 255, 255)
  lg.draw(canvas.handle, canvas.offsetX, canvas.offsetY, 0, canvas.scale, canvas.scale)
end

function love.update(dt)
  stage.update(dt)
end
