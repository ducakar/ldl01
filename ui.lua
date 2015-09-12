local atlas = require 'atlas'
local net   = require 'net'
local lg    = love.graphics
local lm    = love.mouse
local lt    = love.timer

local ASCII      = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~€]]
local MARGINX    = 78
local MARGINY    = 20
local BOX_MARGIN = 2

local cursor     = nil
local font       = nil

local mouseX     = 0
local mouseY     = 0

local boxX       = MARGINX
local boxY       = MARGINY
local boxWidth   = nil
local boxHeight  = nil
local textX      = boxX + BOX_MARGIN
local textY      = boxY + BOX_MARGIN
local textWidth  = nil
local textHeight = nil
local choiceX    = textX + 8
local choiceY    = nil

local ui = {}

local function mouseInside(x, y, width, height)
  return x <= mouseX and mouseX < x + width and y <= mouseY and mouseY < y + height
end

local function unitNum(x)
  if x > 1.0e18 then
    return string.format('%.3gE', x / 1.0e18)
  elseif x > 1.0e15 then
    return string.format('%.3gP', x / 1.0e15)
  elseif x > 1.0e12 then
    return string.format('%.3gT', x / 1.0e12)
  elseif x > 1.0e9 then
    return string.format('%.3gG', x / 1.0e9)
  elseif x > 1.0e6 then
    return string.format('%.3gM', x / 1.0e6)
  elseif x > 1.0e3 then
    return string.format('%.3gk', x / 1.0e3)
  else
    return string.format('%d', x)
  end
end

local function drawBox()
  lg.setColor(80, 70, 60)
  lg.rectangle('fill', boxX - 4, boxY - 4, boxWidth + 8, boxHeight + 8)
  lg.setColor(0, 25, 20)
  lg.rectangle('fill', boxX, boxY, boxWidth, boxHeight)
end

function ui.active()
  return ui.text
end

function ui.show(text, choices)
  ui.text    = text
  ui.choices = choices

  if choices then
    local _, lines = font:getWrap(text, textWidth)
    choiceY = textY + lines * textHeight
  else
    choiceY = nil
  end
end

function ui.keyPressed(key)
  if key == ' ' then
    if ui.text and not ui.choices then
      ui.text = nil
    end
  end
end

function ui.mousePressed(x, y, button)
  mouseX, mouseY = x, y

  if choiceY and button == 'l' then
    for i, _ in ipairs(ui.choices) do
      if mouseInside(boxX, choiceY + i * textHeight - 1, boxWidth, textHeight) then
        ui.show()
        ui.selection = i
        break
      end
    end
  end
end

function ui.mouseMoved(x, y)
  mouseX, mouseY = x, y
end

function ui.draw()
  local hour      = math.floor(net.time / 3600)
  local minute    = math.floor(math.fmod(net.time, 3600) / 60)
  local timeText  = string.format('Day %d %02d:%02d', net.day, hour, minute)
  local statsText = string.format('%s (%s) Cores\n%s €', unitNum(net.cores), unitNum(net.freeCores), unitNum(net.money))

  lg.setColor(160, 220, 160)
  lg.printf(statsText, 2, 2, 200, 'left')
  lg.printf(timeText, atlas.WIDTH - 202, 2, 200, 'right')
  lg.draw(atlas.image, atlas.timeWarp[ui.active() and 1 or net.timeWarp], atlas.WIDTH - atlas.DIM, textHeight)
  lg.printf(string.format('%d FPS', lt.getFPS()), atlas.WIDTH - 102, 2 + textHeight + atlas.DIM, 100, 'right')

  if ui.text then
    drawBox()

    lg.setColor(160, 160, 160)
    lg.printf(ui.text, textX, textY, textWidth)

    if ui.choices then
      for i, text in ipairs(ui.choices) do
        local y = choiceY + i * textHeight - 1

        if mouseInside(boxX, y, boxWidth, textHeight) then
          lg.setColor(80, 255, 160)
        else
          lg.setColor(0, 160, 80)
        end

        lg.print(text, choiceX, y)
      end
    end
  end

  lg.setColor(255, 255, 255)
end

function ui.update()
end

function ui.init()
  cursor     = lm.newCursor('gfx/cursor.png')
  font       = lg.newImageFont('gfx/font.png', ASCII)

  boxWidth   = atlas.WIDTH - 2 * MARGINX
  boxHeight  = atlas.HEIGHT - 2 * MARGINY
  textWidth  = boxWidth - 2 * BOX_MARGIN
  textHeight = font:getHeight() + font:getLineHeight()

  lm.setCursor(cursor)
  lg.setFont(font)
end

return ui
