FIELDS = {
  {
    layers = { 1, 0 },
    space = true
  },
  {
    layers = { 0, 1 },
    space = false
  }
}

PROPS = {
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 2, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 1, 2, 1, 2,
  2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
}

orbis = {
  width   = 16,
  height  = 12,
  length  = 16 * 12,
  spaces  = {},
  props   = {},
  devices = {},
  objects = {},
  time    = 0,
  day     = 1,
}

local pathFields = {}

function orbis:field(x, y)
  return (y - 1) * self.width + x
end

function orbis:pos(field)
  return math.fmod(field - 1, self.width) + 1, math.floor((field - 1) / self.width + 1.0)
end

function orbis:pathStep(path, depth, field)
  if pathFields[field] == 0 then
    return { field }
  elseif not pathFields[field] or pathFields[field] <= depth then
    return path
  else
    pathFields[field] = depth

    if depth >= 32 then
      return path
    else
      local minPath    = nil
      local fieldUp    = field - self.width
      local fieldDown  = field + self.width
      local fieldLeft  = field - 1
      local fieldRight = field + 1

      if 1 <= fieldUp and self.spaces[fieldUp] then
        minPath = self:pathStep(minPath, depth + 1, fieldUp)
      end
      if fieldDown <= self.length and self.spaces[fieldDown] then
        minPath = self:pathStep(minPath, depth + 1, fieldDown)
      end
      if 1 <= fieldLeft and self.spaces[fieldLeft] then
        minPath = self:pathStep(minPath, depth + 1, fieldLeft)
      end
      if fieldRight <= self.length and self.spaces[fieldRight] then
        minPath = self:pathStep(minPath, depth + 1, fieldRight)
      end

      if not minPath or (path and #path <= #minPath + 1) then
        return path
      else
        table.insert(minPath, field)
        return minPath
      end
    end
  end
end

function orbis:findPath(srcField, destField, dir)
  for i = 1, self.length do
    pathFields[i] = 1024
  end
  pathFields[destField] = 0

  return self:pathStep(nil, 1, srcField, dir)
end

function orbis:update(dt)
  self.time = self.time + dt * 1

  if self.time > 86400 then
    self.time = self.time - 86400
    self.day = self.day + 1
  end

  for _, object in pairs(orbis.objects) do
    if object.update then
      object:update(dt)
    end
  end
end

function orbis:init()
  self.props = PROPS

  for i = 1, self.length do
    self.spaces[i] = FIELDS[self.props[i]].space
  end
end
