local atlas = require 'atlas'
local net   = require 'net'

local pathFields     = {}
local internalColour = { 255, 255, 255 }
local externalColour = { 160, 160, 160 }

local orbis = {
  width     = 25,
  height    = 15,
  length    = 25 * 15,
  tiles     = {},
  externals = {},
  spaces    = {},
  objects   = {},
  devices   = {}
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
      orbis.tiles[i]     = tiles[i]
      orbis.externals[i] = tileTypes[tiles[i]].external
      orbis.spaces[i]    = tileTypes[tiles[i]].space
    end
  else
    for i = 1, orbis.length do
      orbis.tiles[i]     = 0
      orbis.externals[i] = true
      orbis.spaces[i]    = true
    end
  end
end

function orbis.write()
  return {
    tiles     = orbis.tiles,
    externals = orbis.externals,
    spaces    = orbis.spaces
  }
end

function orbis.init(o)
  if o then
    orbis.tiles     = o.tiles
    orbis.externals = o.externals
    orbis.spaces    = o.spaces
  else
    orbis.setTiles()
  end
end

function orbis.draw(batch)
  local colourFactor = 0.5 + math.min(0.5, math.max(-0.5, 0.7 * math.cos(net.time / 43200.0 * math.pi)))
  local fieldBase    = 0

  externalColour[1] = 255 + colourFactor * (100 - 255)
  externalColour[2] = 255 + colourFactor * (100 - 255)
  externalColour[3] = 255 + colourFactor * (140 - 255)

  for y = 1, orbis.height + 1 do
    for x = 1, orbis.width + 1 do
      if x <= orbis.width then
        local field = fieldBase + x
        local floor = orbis.tiles[field]

        if floor then
          local quad = atlas.FIELDS[floor].quads[1]

          if quad then
            local colour = orbis.externals[field] and externalColour or internalColour

            batch:setColor(colour[1], colour[2], colour[3])
            batch:add(quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM)
          end
        end
        -- if not orbis.spaces[field] then
        --   batch:add(atlas.cross, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM)
        -- end
      end
      if x <= orbis.width then
        local field  = fieldBase - orbis.width + x
        local object = orbis.objects[field]

        if object then
          local colour = orbis.externals[field] and externalColour or internalColour

          batch:setColor(colour[1], colour[2], colour[3])
          object:draw(batch)
        end
      end
      if 1 < x then
        local field = fieldBase -orbis.width + x - 1
        local wall  = orbis.tiles[field]

        if wall then
          local quad = atlas.FIELDS[wall].quads[2]

          if quad then
            local colour = orbis.externals[field] and externalColour or internalColour

            batch:setColor(colour[1], colour[2], colour[3])
            batch:add(quad, (x - 2) * atlas.DIM, (y - 2) * atlas.DIM, 0, 1, 1, 0, atlas.DIM)
          end
        end
      end
    end

    fieldBase = fieldBase + orbis.width
  end
end

function orbis.update(dt)
  for _, object in pairs(orbis.objects) do
    if object.update then
      object:update(dt)
    end
  end
end

return orbis
