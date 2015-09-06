local atlas = require 'atlas'
local ui    = require 'ui'
local game  = require 'game'

local lg = love.graphics

local canvas = {}
local batch

function love.keypressed(key)
  if key == 'f11' then
    love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
  elseif key == 'escape' then
    love.event.quit()
  else
    game.keyPressed(key)
  end
end

function love.mousepressed(x, y, button)
  local localX, localY = (x - canvas.offsetX) / canvas.width * atlas.WIDTH, (y - canvas.offsetY) / canvas.height * atlas.HEIGHT
  game.mousePressed(localX, localY, button)
end

function love.mousemoved(x, y)
  local localX, localY = (x - canvas.offsetX) / canvas.width * atlas.WIDTH, (y - canvas.offsetY) / canvas.height * atlas.HEIGHT
  game.mouseMoved(localX, localY)
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
  local windowWidth, windowHeight = love.window.getDimensions()

  love.resize(windowWidth, windowHeight)
  love.window.setMode(windowWidth, windowHeight, { resizable = true })
  love.window.setFullscreen(true, 'desktop')

  lg.setDefaultFilter('nearest', 'nearest')

  canvas.handle = lg.newCanvas(atlas.WIDTH, atlas.HEIGHT)

  atlas.init(batch)
  batch = lg.newSpriteBatch(atlas.image)

  game.init()
end

function love.quit()
  game.quit()
end

function love.draw()
  game.draw(batch)

  lg.setCanvas(canvas.handle)
  lg.clear()
  lg.draw(batch)
  ui.draw()
  lg.setCanvas()
  lg.draw(canvas.handle, canvas.offsetX, canvas.offsetY, 0, canvas.scale, canvas.scale)

  batch:clear()
end

function love.update(dt)
  game.update(dt)
end
