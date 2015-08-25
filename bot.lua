require 'orbis'

Bot = {
  field = nil,
  dir   = 1,
  space = false,
  speed = 4.0,
  move  = 0.0,
  path  = nil
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
    return srcX + self.move * (destX - srcX), srcY + self.move * (destY - srcY)
  end
end

function Bot:destField()
  return self.path and self.path[1] or self.field
end

function Bot:moveDir()
  local delta = self.path[#self.path] - self.field
  return (delta == -1 and 3) or (delta == 1 and 4) or (delta < 0 and 2) or 1
end

function Bot:setPathTo(destField)
  if self.path then
    local srcField = self.path[#self.path]
    local oldDestField = self.path[1]

    orbis.spaces[oldDestField] = true
    orbis.spaces[self.field] = true

    self.path = orbis:findPath(srcField, destField)

    orbis.spaces[self.field] = self.space

    if self.path then
      orbis.spaces[destField] = self.space
    else
      self.path = { srcField }
      orbis.spaces[srcField] = self.space
    end
  else
    self.path = orbis:findPath(self.field, destField)

    if self.path then
      table.remove(self.path)

      if #self.path == 0 then
        self.path = nil
      else
        orbis.spaces[destField] = self.space
        self.dir = self:moveDir()
      end
    end
  end
end

function Bot:update(dt)
  if self.path then
    self.move = self.move + self.speed * dt

    if self.move > 1.0 then
      orbis.spaces[self.field] = true
      orbis.objects[self.field] = nil

      self.move = self.move - 1.0
      self.field = self.path[#self.path]

      orbis.spaces[self.field] = self.space
      orbis.objects[self.field] = self

      table.remove(self.path)

      if #self.path == 0 then
        self.dir = 1
        self.move = 0.0
        self.path = nil
      else
        self.dir = self:moveDir()
      end
    end
  end
end
