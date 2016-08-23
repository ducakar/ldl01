local atlas = require 'atlas'
local net   = require 'net'
local orbis = require 'orbis'
local la    = love.audio

local Bot = orbis.Object:new{
  class    = 'Bot',
  dir      = 0,
  speed    = 4.0,
  path     = nil,
  task     = false,
  anim     = 0.0,
  fx       = {
    frames = atlas.robot,
    step   = la.newSource(atlas.footstep)
  }
}
Bot.__index = Bot

local function moveDir(bot)
  local delta = bot.path[#bot.path] - bot.field
  return (delta == -1 and 3) or (delta == 1 and 2) or (delta < 0 and 1) or 0
end

function Bot:pos()
  local srcX, srcY = orbis.pos(self.field)

  if not self.path then
    return srcX, srcY
  else
    local destX, destY = orbis.pos(self.path[#self.path])
    return srcX + self.anim * (destX - srcX), srcY + self.anim * (destY - srcY)
  end
end

function Bot:setPathTo(destField)
  if orbis.spaces[destField] then
    if self.path then
      orbis.spaces[self.path[1]] = true

      self.path = orbis.findPath(self.path[#self.path], destField) or self.path

      orbis.spaces[self.path[1]] = false
    else
      self.path = orbis.findPath(self.field, destField)

      if self.path then
        table.remove(self.path)

        self.dir  = moveDir(self)
        self.task = false
        self.anim = 0.0

        orbis.spaces[self.field] = true
        orbis.spaces[destField] = false
      end
    end
  end
end

function Bot:place()
  orbis.objects[self.field] = self

  if self.path then
    orbis.spaces[self.path[1]] = false
  else
    orbis.spaces[self.field] = false
  end
end

function Bot:remove()
  orbis.objects[self.field] = nil
  orbis.spaces[self.field] = true

  self.field = 0
end

function Bot:draw(batch)
  local frame
  if self.path or not self.task then
    frame = ((self.anim < 0.167 and 1) or (self.anim < 0.500 and 5) or (self.anim < 0.833 and 9) or 1) + self.dir
  else
    frame = 13 + math.floor(self.anim * 4)
  end

  local x, y = self:pos()
  batch:add(self.fx.frames[frame], (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, 0, atlas.DIM)
end

function Bot:update(dt)
  if self.path then
    self.anim = self.anim + self.speed * dt

    if self.anim >= 1.0 then
      self.fx.step:stop()
      self.fx.step:play()

      orbis.objects[self.field] = nil

      self.field = self.path[#self.path]
      self.anim  = self.anim - 1.0
      table.remove(self.path)

      orbis.objects[self.field] = self

      if #self.path == 0 then
        self.dir  = 0
        self.anim = 0.0
        self.path = nil
        self.fx.step:stop()
      else
        self.dir = moveDir(self)
      end
    end
  else
    local device = orbis.devices[self.field]

    if device and device:active() then
      self.task = true
      self.anim = self.anim + 2.0 * dt
      self.anim = self.anim >= 1.0 and self.anim - 1.0 or self.anim

      if device.building then
        device.building = device.building + net.dt

        if device.building >= device.buildTime then
          device.building = nil
        end
      end
    else
      self.task = false
      self.anim = 0.0
    end
  end
end

orbis.Object.Bot = Bot
