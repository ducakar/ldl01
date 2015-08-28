local pathFields = {}

orbis = {
  width   = 25,
  height  = 15,
  length  = 25 * 15,
  tiles   = {},
  objects = {},
  spaces  = {},
  devices = {},
  time    = 0,
  day     = 1,
}

local function pathStep(path, depth, field)
  if pathFields[field] == 0 then
    return { field }
  elseif not pathFields[field] or pathFields[field] <= depth then
    return path
  else
    pathFields[field] = depth

    if depth >= 64 then
      return path
    else
      local minPath    = nil
      local fieldDown  = field + orbis.width
      local fieldUp    = field - orbis.width
      local fieldRight = field + 1
      local fieldLeft  = field - 1

      if fieldDown <= orbis.length and orbis.spaces[fieldDown] then
        minPath = pathStep(minPath, depth + 1, fieldDown)
      end
      if 1 <= fieldUp and orbis.spaces[fieldUp] then
        minPath = pathStep(minPath, depth + 1, fieldUp)
      end
      if fieldRight <= orbis.length and orbis.spaces[fieldRight] then
        minPath = pathStep(minPath, depth + 1, fieldRight)
      end
      if 1 <= fieldLeft and orbis.spaces[fieldLeft] then
        minPath = pathStep(minPath, depth + 1, fieldLeft)
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

function orbis.field(x, y)
  return (y - 1) * orbis.width + x
end

function orbis.pos(field)
  return 1 + math.fmod(field - 1, orbis.width), 1 + math.floor((field - 1) / orbis.width)
end

function orbis.findPath(srcField, destField)
  if srcField == destField then
    return nil
  else
    for i = 1, orbis.length do
      pathFields[i] = 1024
    end
    pathFields[destField] = 0

    return pathStep(nil, 1, srcField)
  end
end

function orbis.setTiles(tiles, tileTypes)
  if tiles then
    assert(#tiles == orbis.length)

    for i = 1, orbis.length do
      orbis.tiles[i] = tiles[i]
      orbis.spaces[i] = tileTypes[tiles[i]].space
    end
  else
    for i = 1, orbis.length do
      orbis.tiles[i] = 0
      orbis.spaces[i] = true
    end
  end
end

function orbis.update(dt, timeWarp)
  orbis.time = orbis.time + timeWarp * dt

  if orbis.time > 86400 then
    orbis.time = orbis.time - 86400
    orbis.day = orbis.day + 1
  end

  for _, object in pairs(orbis.objects) do
    if object.update then
      object:update(dt)
    end
  end
end

function orbis.init()
  orbis.setTiles()
end
