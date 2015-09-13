local atlas = require 'atlas'
local orbis = require 'orbis'

local Device = orbis.Object:new{
  field     = 0,
  fieldMask = nil,
  internal  = true,
  progress  = 1.0,
  fx        = nil
}
Device.__index = Device

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
        if not orbis.spaces[field] or orbis.devices[field] or (self.internal and orbis.externals[field]) then
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
        orbis.triggers[field] = self
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
        orbis.triggers[field] = nil
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

Device.Terminal = Device:new{
  class = 'Terminal',
  fieldMask = {
    0, 3, 3, 3, 0,
    0, 1, 2, 1, 0,
    0, 1, 1, 1, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  },
  fx = {
    sprite = atlas.terminal
  }
}
Device.Terminal.__index = Device.Terminal

Device.Server = Device:new{
  class = 'Server',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    3, 1, 1, 1, 3,
    3, 3, 3, 3, 3,
    0, 0, 0, 0, 0
  },
  fx = {
    sprite = atlas.server
  }
}
Device.Server.__index = Device.Server

Device.Switch = Device:new{
  class = 'Switch',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    3, 1, 1, 3, 0,
    3, 3, 3, 3, 0,
    0, 0, 0, 0, 0
  },
  fx = {
    sprite = atlas.switch
  }
}
Device.Switch.__index = Device.Switch

Device.Warning = Device:new{
  class = 'Warning',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 3, 3, 3, 0,
    0, 3, 1, 3, 0,
    0, 3, 3, 3, 0,
    0, 0, 0, 0, 0
  },
  internal = false,
  fx = {
    sprite = atlas.warning
  }
}
Device.Warning.__index = Device.Warning

orbis.Object.Terminal = Device.Terminal
orbis.Object.Server   = Device.Server
orbis.Object.Switch   = Device.Switch
orbis.Object.Warning  = Device.Warning

return Device
