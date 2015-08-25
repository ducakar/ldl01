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

orbis = {
  width = 16,
  height = 12,
  length = 16 * 12,
  spaces = {},
  props = {
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
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  },
  objects = {}
}

function orbis:field(x, y)
  return (y - 1) * self.width + x
end

function orbis:pos(field)
  return math.fmod(field - 1, self.width) + 1, math.floor((field - 1) / self.width + 1.0)
end

function orbis:pathStep(fields, path, depth, field)
  if fields[field] == 0 then
    return { field }
  elseif fields[field] and fields[field] <= depth then
    return path
  else
    fields[field] = depth

    if depth >= 32 then
      return path
    else
      local minPath    = nil
      local fieldLeft  = field - 1
      local fieldRight = field + 1
      local fieldUp    = field - self.width
      local fieldDown  = field + self.width

      if fieldLeft < 1 or not self.spaces[fieldLeft] then
        fieldLeft = nil
      end
      if self.length < fieldRight or not self.spaces[fieldRight] then
        fieldRight = nil
      end
      if fieldUp < 1 or not self.spaces[fieldUp] then
        fieldUp = nil
      end
      if self.length < fieldDown or not self.spaces[fieldDown] then
        fieldDown = nil
      end

      if fieldLeft and fieldUp then
        local fieldLeftUp = field - 1 - self.width

        if fieldLeftUp >= 1 and self.spaces[fieldLeftUp] then
          minPath = self:pathStep(fields, minPath, depth + 2, fieldLeftUp)
        end
      end

      if fieldLeft and fieldDown then
        local fieldLeftRight = field - 1 + self.width

        if fieldLeftRight <= self.length and self.spaces[fieldLeftRight] then
          minPath = self:pathStep(fields, minPath, depth + 2, fieldLeftRight)
        end
      end

      if fieldRight and fieldUp then
        local fieldRightUp = field + 1 - self.width

        if fieldRightUp >= 1 and self.spaces[fieldRightUp] then
          minPath = self:pathStep(fields, minPath, depth + 2, fieldRightUp)
        end
      end

      if fieldRight and fieldDown then
        local fieldRightDown = field + 1 + self.width

        if fieldRightDown <= self.length and self.spaces[fieldRightDown] then
          minPath = self:pathStep(fields, minPath, depth + 2, fieldRightDown)
        end
      end

      if fieldLeft then
        minPath = self:pathStep(fields, minPath, depth + 1, fieldLeft)
      end
      if fieldRight then
        minPath = self:pathStep(fields, minPath, depth + 1, fieldRight)
      end
      if fieldUp then
        minPath = self:pathStep(fields, minPath, depth + 1, fieldUp)
      end
      if fieldDown then
        minPath = self:pathStep(fields, minPath, depth + 1, fieldDown)
      end

      if not minPath or (path and #path <= #minPath) then
        return path
      else
        table.insert(minPath, field)
        return minPath
      end
    end
  end
end

function orbis:findPath(srcField, destField)
  local fields = {}
  fields[destField] = 0
  return self:pathStep(fields, nil, 1, srcField)
end

function orbis:update(dt)
  for _, object in pairs(orbis.objects) do
    if object.update then
      object:update(dt)
    end
  end
end

function orbis:init()
  for i = 1, self.length do
    self.spaces[i] = FIELDS[self.props[i]].space
  end
end
