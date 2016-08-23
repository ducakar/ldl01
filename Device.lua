local atlas = require 'atlas'
local orbis = require 'orbis'

local Device = orbis.Object:new{
  device      = true,
  name        = nil,
  description = nil,
  internal    = true,
  buildTime   = nil,
  building    = nil,
  fx          = nil,
  fieldMask   = nil
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
  class       = 'Terminal',
  name        = 'Control terminal',
  description = 'Crucial device that enables map view, assigning tasks to CPUs and hacking internet servers.',
  buildTime   = 24 * 3600,
  fx          = {
    sprite    = atlas.terminal
  },
  fieldMask   = {
    0, 3, 3, 3, 0,
    0, 1, 2, 1, 0,
    0, 1, 1, 1, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  }
}
Terminal.__index = Terminal

function Terminal.active()
  return true
end

local Server = Device:new{
  class       = 'Server',
  name        = 'Server',
  description = 'Server rack. Components sold separately.',
  buildTime   = 8 * 3600,
  fx          = {
    sprite    = atlas.server
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 1, 1, 1, 0,
    0, 3, 2, 3, 0,
    0, 0, 0, 0, 0
  }
}
Server.__index = Server

local Switch = Device:new{
  class       = 'Switch',
  name        = 'Network switch',
  description = 'Improves computing performance of servers in your building. Additional upgrades further improve'
                .. ' efficiency.',
  buildTime   = 16 * 3600,
  fx          = {
    sprite    = atlas.switch
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 1, 1, 0, 0,
    0, 3, 2, 0, 0,
    0, 0, 0, 0, 0
  }
}
Switch.__index = Switch

local Warning = Device:new{
  class       = 'Warning',
  name        = 'Warning sign',
  description = 'A scary sign is a cheap but effective way for deterring nosey public from sniffing around.',
  buildTime   = 3 * 3600,
  internal    = false,
  fx          = {
    sprite    = atlas.warning
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 2, 0, 0,
    0, 0, 0, 0, 0
  }
}
Warning.__index = Warning

local Battery = Device:new{
  class       = 'Battery',
  name        = 'Battery pack.',
  description = '',
  buildTime   = 6 * 3600,
  internal    = true,
  fx          = {
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 1, 1, 0, 0,
    0, 3, 2, 0, 0,
    0, 0, 0, 0, 0
  }
}
Battery.__index = Battery

local Panel = Device:new{
  class       = 'Panel',
  name        = 'Solar panel',
  description = 'Generates a small amount of power during daytime. Additional batteries are required to provide power'
                .. ' through the night.',
  buildTime   = 12 * 3600,
  internal    = false,
  fx          = {
    sprite    = atlas.panel
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 2, 1, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  }
}
Panel.__index = Panel

local DieselGenerator = Device:new{
  class       = 'DieselGenerator',
  name        = 'Diesel Generator. Generates a moderate amount of power all the time. However, it is noisy and might'
                .. ' attract some ',
  description = '',
  buildTime   = 36 * 3600,
  internal    = true,
  fx          = {
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 1, 1, 1, 0,
    0, 1, 1, 1, 0,
    0, 1, 1, 1, 0,
    0, 3, 2, 3, 0
  }
}
DieselGenerator.__index = DieselGenerator

local FusionGenerator = Device:new{
  class       = 'FusionGenerator',
  name        = 'Fusion Generator',
  description = '',
  buildTime   = 120 * 3600,
  internal    = true,
  fx          = {
  },
  fieldMask   = {
    0, 0, 0, 0, 0,
    0, 1, 1, 1, 0,
    0, 1, 1, 1, 0,
    0, 1, 1, 1, 0,
    0, 3, 2, 3, 0
  }
}
FusionGenerator.__index = FusionGenerator

orbis.Object.Terminal        = Terminal
orbis.Object.Server          = Server
orbis.Object.Switch          = Switch
orbis.Object.Warning         = Warning
-- orbis.Object.Battery         = Battery
orbis.Object.Panel           = Panel
-- orbis.Object.DieselGenerator = DieselGenerator
-- orbis.Object.FusionGenerator = FusionGenerator
