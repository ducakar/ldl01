local atlas = require 'atlas'
local net   = require 'net'
local orbis = require 'orbis'
local lg    = love.graphics
local lk    = love.keyboard
local lm    = love.mouse

local ASCII      = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]
local CHARS      = ASCII .. [[€]]
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

local buildCue   = nil

local ui         = {}

local function mouseInside(x, y, width, height)
  return x <= mouseX and mouseX < x + width and y <= mouseY and mouseY < y + height
end

local function unitNum(x)
  if x > 1.0e18 then
    return string.format('%.3g E', x / 1.0e18)
  elseif x > 1.0e15 then
    return string.format('%.3g P', x / 1.0e15)
  elseif x > 1.0e12 then
    return string.format('%.3g T', x / 1.0e12)
  elseif x > 1.0e9 then
    return string.format('%.3g G', x / 1.0e9)
  elseif x > 1.0e6 then
    return string.format('%.3g M', x / 1.0e6)
  elseif x > 1.0e3 then
    return string.format('%.3g k', x / 1.0e3)
  else
    return string.format('%d ', x)
  end
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
  return ui.text or buildCue
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
  end

  if key == ' ' then
    if ui.text and not ui.choices then
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

function ui.mousePressed(x, y, button)
  mouseX, mouseY = x, y

  if button then
    if choiceY then
      for i, _ in ipairs(ui.choices) do
        if mouseInside(boxX, choiceY + i * textHeight - 1, boxWidth, textHeight) then
          ui.show()
          ui.selection = i
          break
        end
      end
    elseif buildCue then
      if buildCue:canPlace() then
        buildCue:place()
        buildCue.building = 0.0
        buildCue = nil
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
  local statsText = string.format('%s (%s) Cores\n%s€', unitNum(net.cores), unitNum(net.freeCores), unitNum(net.money))

  lg.setColor(128, 192, 255)
  lg.printf(statsText, 2, 2, 200, 'left')
  lg.printf(timeText, atlas.WIDTH - 208, 2, 200, 'right')
  lg.draw(atlas.image, atlas.timeWarp[ui.active() and 1 or net.timeWarp], atlas.WIDTH - 11, 1)

  drawChance(0, atlas.discover, net.discover, 1.00)
  drawChance(110, atlas.public, net.chances.public, 0.20)
  drawChance(220, atlas.covert, net.chances.covert, 0.20)
  drawChance(330, atlas.science, net.chances.science, 0.20)

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

  if buildCue then
    local x, y   = math.floor(mouseX / atlas.DIM) + 1, math.floor(mouseY / atlas.DIM) + 1
    local sprite = buildCue.fx.sprite

    buildCue.field = orbis.field(x, y)

    if buildCue:canPlace(buildCue.field) then
      lg.setColor(128, 255, 128, 128)
    else
      lg.setColor(255, 0, 0, 128)
    end

    lg.draw(atlas.image, sprite.quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, sprite.offsetX, sprite.offsetY)
  end

  lg.setColor(255, 255, 255)
end

function ui.update(dt)
  caretTime = math.fmod(caretTime + dt, 1.0)
end

function ui.init()
  cursor     = lm.newCursor('gfx/cursor.png')
  font       = lg.newImageFont('gfx/font.png', CHARS)

  boxWidth   = atlas.WIDTH - 2 * MARGINX
  boxHeight  = atlas.HEIGHT - 2 * MARGINY
  textWidth  = boxWidth - 2 * BOX_MARGIN
  textHeight = font:getHeight() + font:getLineHeight()

  lm.setCursor(cursor)
  lg.setFont(font)
end

return ui
