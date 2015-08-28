require 'orbis'
require 'atlas'

Bot = {
  field = 0,
  dir   = 0,
  speed = 4.0,
  path  = nil,
  task  = false,
  anim  = 0.0,
  fx    = {}
}
Bot.__index = Bot

local function moveDir(bot)
  local delta = bot.path[#bot.path] - bot.field
  return (delta == -1 and 3) or (delta == 1 and 2) or (delta < 0 and 1) or 0
end

function Bot:init()
  self.fx = {
    step   = love.audio.newSource(atlas.step),
    frames = atlas.robot
  }
end

function Bot:new(o)
  o = o or {}
  return setmetatable(o, self)
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
  if self.path then
    local srcField = self.path[#self.path]
    local oldDestField = self.path[1]

    orbis.spaces[oldDestField] = true

    self.path = orbis.findPath(srcField, destField)

    if self.path then
      orbis.spaces[destField] = false
    else
      self.path = { srcField }
      orbis.spaces[srcField] = false
    end
  else
    self.path = orbis.findPath(self.field, destField)

    if self.path then
      table.remove(self.path)

      self.dir = moveDir(self)
      self.task = false
      self.anim = 0.0

      orbis.spaces[self.field] = true
      orbis.spaces[destField] = false
    end
  end
end

function Bot:place(field)
  assert(orbis.spaces[field])

  self.field = field

  orbis.objects[field] = self
  orbis.spaces[field] = false
end

function Bot:remove()
  orbis.objects[self.field] = nil
  orbis.spaces[self.field] = true

  self.field = 0
end

function Bot:draw(batch)
  local frame
  if self.path or not self.task then
    frame = self.dir * 3 + ((self.anim < 0.167 and 1) or (self.anim < 0.500 and 2) or (self.anim < 0.833 and 3) or 1)
  else
    frame = 13 + math.floor(self.anim * 4)
  end

  local ox, oy = self:pos()
  batch:add(self.fx.frames[frame], (ox - 1) * DIM, (oy - 1) * DIM, 0, 1, 1, 0, DIM)
end

function Bot:update(dt)
  if self.path then
    self.anim = self.anim + self.speed * dt

    if self.anim >= 1.0 then
      self.fx.step:play()

      orbis.objects[self.field] = nil

      self.field = self.path[#self.path]
      self.anim = self.anim - 1.0
      table.remove(self.path)

      orbis.objects[self.field] = self

      if #self.path == 0 then
        self.dir = 0
        self.anim = 0.0
        self.path = nil
      else
        self.dir = moveDir(self)
      end
    end
  elseif orbis.devices[self.field] then
    self.task = true
    self.anim = self.anim + 2.0 * dt
    self.anim = self.anim > 1.0 and self.anim - 1.0 or self.anim
  else
    self.task = false
    self.anim = 0.0
  end
end
