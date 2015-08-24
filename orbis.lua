require 'common'

FIELDS = {
  {
    layers = { 1, 0 },
    space = true
  },
  {
    layers = { 1, 1 },
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
    2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
    2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
    2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
    2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
    2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
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
  print(depth, field, self.spaces[field], fields[field])

  if depth > 2 or field < 1 or field > self.length or not self.spaces[field] then
    return path
  elseif fields[field] == 0 then
    return { field }
  elseif not fields[field] or fields[field] > depth then
    local minPath = nil

    fields[field] = depth

    minPath = self:pathStep(fields, minPath, depth + 1, field - 1)
    minPath = self:pathStep(fields, minPath, depth + 1, field + 1)
    minPath = self:pathStep(fields, minPath, depth + 1, field - self.width)
    minPath = self:pathStep(fields, minPath, depth + 1, field + self.width)

    if not minPath or (path and #path <= #minPath) then
      return path
    else
      table.insert(minPath, field)
      return minPath
    end
  end
end

function orbis:findPath(srcField, destField)
  print('---', srcField, destField)
  local fields = {}
  fields[srcField] = 0
  return self:pathStep(fields, nil, 1, destField)
end

function orbis:draw(batch)
  for y = 1, self.height do
    for x = 1, self.width do
      local field  = (y - 1) * self.width + x
      local quads  = FIELDS[self.props[field]].quads
      local object = self.objects[field - self.width]
      local px, py = x * DIM, y * DIM

      if quads[1] then
        batch:add(quads[1], px, py, 0, 1, 1, 0, DIM)
      end
      if object then
        local ox, oy = object:pos()
        batch:add(atlas.robot[object.dir][1], ox * DIM, oy * DIM, 0, 1, 1, 0, DIM)
      end
      if quads[2] then
        batch:add(quads[2], px, py, 0, 1, 1, 0, DIM)
      end
    end
  end
end

function orbis:update(dt)
  for _, object in ipairs(self.objects) do
    if object.update then
      object:update(dt)
    end
  end

  for _, bot in ipairs(self.bots) do
    if bot.update then
      bot:update(dt)
    end
  end
end

function orbis:init()
  for i = 1, self.length do
    self.spaces[i] = FIELDS[self.props[i]].space
  end
end
