local atlas = require 'atlas'
local orbis = require 'orbis'

local Device = {
  field = 0,
  fieldMask = {
    0, 0, 0, 0, 0,
    3, 3, 3, 2, 3,
    3, 1, 1, 1, 3,
    3, 3, 3, 3, 3,
    0, 0, 0, 0, 0
  },
  fx = nil
}
Device.__index = Device

function Device:new(o)
  o = o or {}
  o.fx = {
    sprite = atlas.server
  }
  return setmetatable(o, self)
end

function Device:pos()
  return orbis.pos(self.field)
end

function Device:canPlace(centralField)
  local centreX, centreY = orbis.pos(centralField)

  for y = -2, 2 do
    for x = -2, 2 do
      local field = centralField + y * orbis.width + x
      local value = self.fieldMask[(y + 2) * 5 + x + 3]

      if value ~= 0 then
        if centreX + x < 1 or orbis.width < centreX + x or centreY + y < 1 or orbis.height < centreY + y then
          return false
        end
        if not orbis.spaces[field] then
          return false
        end
      end
    end
  end
  return true
end

function Device:place()
  orbis.objects[self.field] = self

  for y = -2, 2 do
    for x = -2, 2 do
      local field = self.field + y * orbis.width + x
      local value = self.fieldMask[(y + 2) * 5 + x + 3]

      if value == 1 then
        orbis.spaces[field] = false
      elseif value == 2 then
        orbis.devices[field] = self
      end
    end
  end
end

function Device:remove()
  orbis.objects[self.field] = nil

  for y = -2, 2 do
    for x = -2, 2 do
      local field = self.field + y * orbis.width + x
      local value = self.fieldMask[(y + 2) * 5 + x + 3]

      if value == 1 then
        orbis.spaces[field] = true
      elseif value == 2 then
        orbis.devices[field] = nil
      end
    end
  end

  self.field = 0
end

function Device:draw(batch)
  local ox, oy = self:pos()
  local sprite = self.fx.sprite

  batch:add(sprite.quad, (ox - 1) * atlas.DIM, (oy - 1) * atlas.DIM, 0, 1, 1, sprite.offsetX, sprite.offsetY)
end

return Device
