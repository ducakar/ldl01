require 'orbis'

Bot = {
  field = nil,
  x     = nil,
  y     = nil,
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

function Bot:insert(x, y)
  self.field = orbis:field(x, y)
  self.x, self.y = x, y

  orbis.spaces[self.field] = self.space
  orbis.objects[self.field] = self
end

function Bot:remove()
  orbis.spaces[self.field] = true
  orbis.objects[self.field] = nil
end

function Bot:pos()
  if not self.path then
    return self.x, self.y
  else
    local x, y = orbis:pos(self.path[1])
    return self.x + self.move * (x - self.x), self.y + self.move * (y - self.y)
  end
end

function Bot:destField()
  return self.path and self.path[#self.path] or self.field
end

function Bot:setPathTo(destField)
  if self.path then
    local srcField = self.path[1]
    local oldDestField = self.path[#self.path]

    orbis.spaces[oldDestField] = true
    orbis.spaces[self.field] = self.space -- Just in case if oldDestField == self.field

    self.path = orbis:findPath(srcField, destField)

    if self.path then
      table.insert(self.path, 1, srcField)
      orbis.spaces[destField] = self.space
    else
      self.path = { srcField }
      orbis.spaces[srcField] = self.space
    end
  else
    self.path = orbis:findPath(self.field, destField)

    if self.path then
      orbis.spaces[destField] = self.space
    end
  end
end

function Bot:update(dt)
  if self.path then
    if self.move == 0.0 then
      local dField = self.path[1] - self.field
      self.dir = (dField == -1 and 4) or (dField == 1 and 3) or (dField < 0 and 1) or 2
    end

    self.move = self.move + self.speed * dt

    if self.move > 1.0 then
      orbis.spaces[self.field] = true
      orbis.objects[self.field] = nil

      self.move = self.move - 1.0
      self.field = self.path[1]
      self.x, self.y = orbis:pos(self.field)

      orbis.spaces[self.field] = self.space
      orbis.objects[self.field] = self

      table.remove(self.path, 1)

      if #self.path == 0 then
        self.move = 0.0
        self.path = nil
      end
    end
  end
end
