require 'orbis'

Bot = {
  field = nil,
  dir   = 0,
  space = false,
  speed = 4.0,
  anim  = 0.0,
  path  = nil,
  task  = nil
}
Bot.__index = Bot

function Bot:new(o)
  o = o or {}
  return setmetatable(o, self)
end

function Bot:insert(field)
  self.field = field

  orbis.spaces[field] = self.space
  orbis.objects[field] = self
end

function Bot:remove()
  orbis.spaces[self.field] = true
  orbis.objects[self.field] = nil
end

function Bot:pos()
  local srcX, srcY = orbis:pos(self.field)

  if not self.path then
    return srcX, srcY
  else
    local destX, destY = orbis:pos(self.path[#self.path])
    return srcX + self.anim * (destX - srcX), srcY + self.anim * (destY - srcY)
  end
end

function Bot:destField()
  return self.path and self.path[1] or self.field
end

function Bot:moveDir()
  local delta = self.path[#self.path] - self.field
  return (delta == -1 and 2) or (delta == 1 and 3) or (delta < 0 and 1) or 0
end

function Bot:frame()
  if self.path or not self.task then
    return self.dir * 3 + ((self.anim < 0.167 and 1) or (self.anim < 0.500 and 2) or (self.anim < 0.833 and 3) or 1)
  else
    return (self.anim < 0.25 and 13) or (self.anim < 0.50 and 14) or (self.anim < 0.75 and 15) or 16
  end
end

function Bot:setPathTo(destField)
  if self.path then
    local srcField = self.path[#self.path]
    local oldDestField = self.path[1]

    orbis.spaces[oldDestField] = true
    orbis.spaces[self.field] = true

    self.path = orbis:findPath(srcField, destField, self.dir)

    orbis.spaces[self.field] = self.space

    if self.path then
      orbis.spaces[destField] = self.space
    else
      self.path = { srcField }
      orbis.spaces[srcField] = self.space
    end
  else
    self.path = orbis:findPath(self.field, destField, self.dir)

    if self.path then
      table.remove(self.path)

      if #self.path == 0 then
        self.path = nil
      else
        self.dir = self:moveDir()
        self.anim = 0.0
        self.task = nil

        orbis.spaces[destField] = self.space
      end
    end
  end
end

function Bot:setTask(task)
  if not self.path then
    self.task = task
  end
  return self.task
end

function Bot:update(dt)
  if self.path then
    self.anim = self.anim + self.speed * dt

    if self.anim > 1.0 then
      orbis.spaces[self.field] = true
      orbis.objects[self.field] = nil

      self.anim = self.anim - 1.0
      self.field = self.path[#self.path]

      orbis.spaces[self.field] = self.space
      orbis.objects[self.field] = self

      table.remove(self.path)

      if #self.path == 0 then
        self.dir = 0
        self.path = nil
      else
        self.dir = self:moveDir()
      end
    end
  elseif self.task then
    self.anim = self.anim + 2.0 * dt
    self.anim = self.anim > 1.0 and self.anim - 1.0 or self.anim
  end
end
