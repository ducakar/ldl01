local atlas = require 'atlas'
local orbis = require 'orbis'

local Device = orbis.Object:new{
  field     = 0,
  fieldMask = nil,
  internal  = true,
  buildTime = nil,
  building  = nil,
  fx        = nil
}
Device.__index = Device

function Device:pos()
  return orbis.pos(self.field)
end

function Device:active()
  return self.building
end

function Device:canPlace()
  local centreX, centreY = orbis.pos(self.field)

  for y = -2, 2 do
    for x = -2, 2 do
      local field = self.field + y * orbis.width + x
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
  local x, y   = self:pos()
  local sprite = self.fx.sprite

  batch:add(sprite.quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, sprite.offsetX, sprite.offsetY)
end

local Terminal = Device:new{
  class = 'Terminal',
  fieldMask = {
    0, 3, 3, 3, 0,
    0, 1, 2, 1, 0,
    0, 1, 1, 1, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  },
  buildTime = 12 * 3600,
  fx = {
    sprite = atlas.terminal
  }
}
Terminal.__index = Terminal

function Terminal.active()
  return true
end

local Server = Device:new{
  class = 'Server',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 1, 1, 1, 0,
    0, 3, 2, 3, 0,
    0, 0, 0, 0, 0
  },
  buildTime = 8 * 3600,
  fx = {
    sprite = atlas.server
  }
}
Server.__index = Server

local Switch = Device:new{
  class = 'Switch',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 1, 1, 0, 0,
    0, 3, 2, 0, 0,
    0, 0, 0, 0, 0
  },
  buildTime = 16 * 3600,
  fx = {
    sprite = atlas.switch
  }
}
Switch.__index = Switch

local Warning = Device:new{
  class = 'Warning',
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 2, 0, 0,
    0, 0, 0, 0, 0
  },
  buildTime = 2 * 3600,
  internal = false,
  fx = {
    sprite = atlas.warning
  }
}
Warning.__index = Warning

orbis.Object.Terminal = Terminal
orbis.Object.Server   = Server
orbis.Object.Switch   = Switch
orbis.Object.Warning  = Warning
