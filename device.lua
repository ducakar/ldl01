-- require 'orbis'

local FIELDMASK_OFFSETS = {
  { -2, -2 }, { -1, -2 }, { 0, -2 }, { 1, -2 }, { 2, -2 },
  { -2, -2 }, { -1, -2 }, { 0, -2 }, { 1, -1 }, { 2, -1 },
  { -2, -2 }, { -1, -2 }, { 0, -2 }, { 1, 0 }, { 2, 0 },
  { -2, -2 }, { -1, -2 }, { 0, -2 }, { 1, 1 }, { 2, 1 },
  { -2, -2 }, { -1, -2 }, { 0, -2 }, { 1, 2 }, { 2, 2 }
}

Device = {
  field = 0,
  fieldMask = {
    0, 0, 0, 0, 0,
    0, 0, 0, 2, 0,
    0, 1, 1, 1, 0,
    0, 1, 1, 1, 0,
    0, 0, 0, 0, 0
  }
}
Device.__index = Device

function checkPlacement(device, centralField)
  local centreX, centreY = orbis.pos(centralField)

  for y = -2, 2 do
    for x = -2, 2 do
      local field = centralField + y * orbis.width + x
      local value = device.fieldMask[(y + 2) * 5 + x + 3]

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

function Device:new(o)
  o = o or {}
  return setmetatable(o, self)
end

function Device:pos()
  return orbis.pos(self.field)
end

function Device:frame()
  return 1
end

function Device:place(centralField)
  assert(checkPlacement(self, centralField))

  self.field = centralField

  orbis.objects[centralField] = self

  for y = -2, 2 do
    for x = -2, 2 do
      local field = centralField + y * orbis.width + x
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
