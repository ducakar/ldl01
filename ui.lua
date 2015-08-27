require 'orbis'

local lg = love.graphics

local ASCII      = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]
local MARGINX    = 78
local MARGINY    = 20
local BOX_MARGIN = 2

local boxX       = MARGINX
local boxY       = MARGINY
local boxWidth   = nil
local boxHeight  = nil
local textX      = boxX + BOX_MARGIN
local textY      = boxY + BOX_MARGIN
local textWidth  = nil

local normalCursor, hoverCursor

ui = {
  text = nil,
  choices = nil
}

function ui.active()
  return ui.text
end

function ui.show(text, choices)
  ui.text = text
  ui.choices = choices
end

function ui.keyPressed(key)
  if key == ' ' then
    if ui.text and not ui.choices then
      ui.text = nil
    end
  end
end

function ui.mousePressed(x, y, button)
end

function ui.mouseMoved(x, y)
end

function ui.draw()
  local hour     = math.floor(orbis.time / 3600)
  local minute   = math.floor(math.fmod(orbis.time, 3600) / 60)
  local second   = math.fmod(orbis.time, 60)
  local timeText = string.format('Day %d %02d:%02d', orbis.day, hour, minute)

  lg.setColor(128, 128, 128)
  lg.printf(timeText, WIDTH - 82, 2, 80, 'right')
  lg.printf(love.timer.getFPS(), WIDTH - 82, 11, 80, 'right')

  if ui.text then
    lg.setColor(80, 70, 60)
    lg.rectangle('fill', boxX - 4, boxY - 4, boxWidth + 8, boxHeight + 8)
    lg.setColor(0, 25, 20)
    lg.rectangle('fill', boxX, boxY, boxWidth, boxHeight)
    lg.setColor(255, 255, 255)
    lg.printf(ui.text, textX, textY, textWidth)
  else
    lg.setColor(255, 255, 255)
  end
end

function ui.update(dt)
end

function ui.init()
  boxWidth  = WIDTH - 2 * MARGINX
  boxHeight = HEIGHT - 2 * MARGINY
  textWidth = boxWidth - 2 * BOX_MARGIN

  normalCursor = love.mouse.newCursor('base/normalCursor.png')
  hoverCursor = love.mouse.newCursor('base/hoverCursor.png')

  love.mouse.setCursor(normalCursor)

  lg.setFont(lg.newImageFont('base/font.png', ASCII))
end
