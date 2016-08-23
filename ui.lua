local atlas  = require 'atlas'
local net    = require 'net'
local orbis  = require 'orbis'
local _      = require 'Device'
local lg     = love.graphics
local lk     = love.keyboard
local lm     = love.mouse

local ASCII      = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]
local CHARS      = ASCII .. [[€]]
local UNITS      = 'EPTGMk'
local BASES      = {1.0e18, 1.0e15, 1.0e12, 1.0e9, 1.0e6, 1.0e3}
local MARGINX    = 78
local MARGINY    = 20
local BOX_MARGIN = 2

local cursor     = nil
local font       = nil

local mouseX     = 0
local mouseY     = 0
local inputOn    = false
local inputX     = 0
local inputY     = 0
local inputText  = ''
local caretTime  = 0.0

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

local ui         = {}

local Button     = {
  x      = 0,
  y      = 0,
  width  = 0,
  height = 0,
  text   = 'button',
  icon   = nil
}

function Button:draw()
  if self.icon then
    lg.setColor(255, 255, 255)
    lg.draw(atlas.image, self.icon, self.x, self.y)
  else
    lg.setColor(80, 70, 60)
    lg.rectangle('fill', self.x, self.y, self.width, self.height)
    lg.printf(self.text, self.x, self.y + 2, self.width, 'center')
  end
end

local function mouseInside(x, y, width, height)
  return x <= mouseX and mouseX < x + width and y <= mouseY and mouseY < y + height
end

local function unitNum(x)
  for i = 1, #UNITS do
    if x > BASES[i] then
      return string.format('%.3g %c', x / BASES[i], UNITS:byte(i))
    end
  end
  return string.format('%d ', x)
end

local function drawChance(x, quad, chance, critical)
  local t = math.min(chance / critical, 1.0)

  lg.setColor(math.min(64 + t * 512, 255), 192 - t * 64, 128)
  lg.draw(atlas.image, quad, x, atlas.HEIGHT - 16)
  lg.printf(string.format('%.2f %%', chance * 100.0), x + 15, atlas.HEIGHT - 11, 42, 'right')
end

local function drawBox()
  lg.setColor(80, 70, 60)
  lg.rectangle('fill', boxX - 4, boxY - 4, boxWidth + 8, boxHeight + 8)
  lg.setColor(0, 25, 20)
  lg.rectangle('fill', boxX, boxY, boxWidth, boxHeight)
end

local function drawDevice(device)
  local sprite = device.fx.sprite
  local x, y, width, height = 100, 100, 200, 100

  lg.setColor(20, 30, 20)
  lg.rectangle('fill', x, y, width, height)
  lg.setColor(255, 255, 255)
  lg.draw(atlas.image, sprite.quad, x - sprite.offsetX + 2 * atlas.DIM, y - sprite.offsetY + 3 * atlas.DIM)
  lg.print(device.name, x + 2, y + 2)
  lg.printf(device.description, x + 80, y + 20, 120, 'left')
end

local function drawInput()
  lg.setColor(255, 255, 255)
  lg.print(inputText .. (caretTime > 0.5 and '' or '|'), inputX, inputY)
end

local function setInput(x, y, initialText)
  if x then
    lk.setKeyRepeat(true)
    inputOn, inputX, inputY, inputText = true, x, y, (initialText or inputText)
  else
    lk.setKeyRepeat(false)
    inputOn = false
  end
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

  if text then
    setInput(100, 100)
  else
    setInput(false)
  end
end

function ui.keyPressed(key)
  if inputOn then
    caretTime = -0.25

    if key == 'backspace' then
      inputText = inputText:sub(1, -2)
    elseif key == 'return' then
      setInput(false)
    end
  elseif ui.text then
    if not ui.choices then
      ui.text = nil
    end
  end
end

function ui.textInput(char)
  if inputOn then
    local code = char:byte()

    for i = 1, #ASCII do
      if code == ASCII:byte(i) then
        inputText = inputText .. char
        break
      end
    end
  end
end

function ui.mousePressed(x, y)
  mouseX, mouseY = x, y

  if choiceY then
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
  local timeText  = string.format('Year %d Day %d %02d:%02d', net.year, net.day, hour, minute)
  local coresText = string.format('%s (%s) Cores', unitNum(net.cores), unitNum(net.freeCores))
  local moneyText = string.format('%s €', unitNum(net.money))

  lg.setColor(0, 0, 0, 128)
  lg.rectangle('fill', 0, 0, atlas.WIDTH, 13)
  lg.rectangle('fill', 0, atlas.HEIGHT - 13, atlas.WIDTH, 13)
  lg.setColor(128, 192, 255)
  lg.print(love.timer.getFPS(), atlas.WIDTH - 13, atlas.HEIGHT - 11)
  lg.printf(moneyText, 2, 2, 200, 'left')
  lg.printf(coresText, 80, 2, 200, 'right')
  lg.printf(timeText, atlas.WIDTH - 210, 2, 200, 'right')
  lg.draw(atlas.image, atlas.timeWarp[ui.active() and 1 or net.timeWarp], atlas.WIDTH - 7, 3)

  drawChance(0, atlas.discover, net.discover, 1.00)
  drawChance(110, atlas.public, net.chances.public, 0.20)
  drawChance(220, atlas.covert, net.chances.covert, 0.20)
  drawChance(330, atlas.science, net.chances.science, 0.20)

  -- drawDevice(orbis.Object.Switch)

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

  if inputOn then
    drawInput()
  end

  lg.setColor(255, 255, 255)
end

function ui.update(dt)
  caretTime = math.fmod(caretTime + dt, 1.0)
end

function ui.init()
  if lm.hasCursor() then
    cursor = lm.newCursor('gfx/cursor.png')
    lm.setCursor(cursor)
  end

  font = lg.newImageFont('gfx/font.png', CHARS, 1)
  lg.setFont(font)

  boxWidth   = atlas.WIDTH - 2 * MARGINX
  boxHeight  = atlas.HEIGHT - 2 * MARGINY
  textWidth  = boxWidth - 2 * BOX_MARGIN
  textHeight = font:getHeight() + font:getLineHeight()
end

return ui
