local atlas = require 'atlas'
local net   = require 'net'
local lg    = love.graphics

local WIDTH          = 32
local HEIGHT         = 18

local pathFields     = {}
local internalColour = { 255, 255, 255 }
local externalColour = { 160, 160, 160 }
local internalsBatch = lg.newSpriteBatch(atlas.image, WIDTH * HEIGHT, 'static')
local externalsBatch = lg.newSpriteBatch(atlas.image, WIDTH * HEIGHT, 'static')
local objectsBatch   = lg.newSpriteBatch(atlas.image, WIDTH * HEIGHT, 'stream')

local orbis = {
  Object    = {
    field   = nil
  },
  width     = WIDTH,
  height    = HEIGHT,
  length    = WIDTH * HEIGHT,
  map       = nil,
  tiles     = {},
  externals = {},
  spaces    = {},
  objects   = {},
  devices   = {},
  triggers  = {},
  actor     = nil
}
orbis.Object.__index = orbis.Object

function orbis.Object:new(o)
  o = o or {}
  o.class = o.class or self.class
  return setmetatable(o, self)
end

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

function orbis.write()
  return {
    map     = orbis.map,
    objects = orbis.objects,
    actor   = orbis.actor and orbis.actor.field
  }
end

function orbis.init(o)
  local tiles = require(o.map)

  assert(#tiles == orbis.length)

  orbis.map = o.map

  for i = 1, orbis.length do
    orbis.tiles[i]     = tiles[i]
    orbis.externals[i] = atlas.FIELDS[tiles[i]].external
    orbis.spaces[i]    = atlas.FIELDS[tiles[i]].space
  end

  if o.objects then
    for _, obj in pairs(o.objects) do
      local newObj = orbis.Object[obj.class]:new(obj)

      newObj:place()

      if newObj.field == o.actor then
        orbis.actor = newObj
      end
    end
  end

  internalsBatch:clear()
  externalsBatch:clear()

  local fieldBase = 0

  for y = 1, orbis.height do
    for x = 1, orbis.width do
      local field = fieldBase + x
      local floor = orbis.tiles[field]

      if floor then
        local fieldInfo = atlas.FIELDS[floor]
        local quad      = fieldInfo.quads[1]

        if quad then
          local batch = fieldInfo.external and externalsBatch or internalsBatch

          batch:add(quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM)
        end
      end
    end

    fieldBase = fieldBase + orbis.width
  end
end

function orbis.draw()
  local colourFactor = 0.5 + math.min(0.5, math.max(-0.5, 0.7 * math.cos(net.time / 43200.0 * math.pi)))

  externalColour[1] = 255 + colourFactor * (100 - 255)
  externalColour[2] = 255 + colourFactor * (100 - 255)
  externalColour[3] = 255 + colourFactor * (140 - 255)

  lg.setColor(internalColour[1], internalColour[2], internalColour[3])
  lg.draw(internalsBatch)
  lg.setColor(externalColour[1], externalColour[2], externalColour[3])
  lg.draw(externalsBatch)

  if orbis.actor and orbis.actor.path then
    local x, y = orbis.pos(orbis.actor.path[1])

    objectsBatch:setColor(255, 255, 255)
    objectsBatch:add(atlas.dest, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM)
  end

  local objField  = 1
  local wallField = 1

  for y = 1, orbis.height do
    for x = 0, orbis.width do
      if x ~= orbis.width then
        local object = orbis.objects[objField]

        if object then
          local colour = orbis.externals[objField] and externalColour or internalColour

          objectsBatch:setColor(colour[1], colour[2], colour[3])
          object:draw(objectsBatch)
        end

        objField = objField + 1
      end
      if x ~= 0 then
        local wall = orbis.tiles[wallField]

        if wall then
          local quad = atlas.FIELDS[wall].quads[2]

          if quad then
            local colour = orbis.externals[wallField] and externalColour or internalColour

            objectsBatch:setColor(colour[1], colour[2], colour[3])
            objectsBatch:add(quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, 0, atlas.DIM)
          end
        end

        wallField = wallField + 1
      end
    end
  end

  lg.draw(objectsBatch)
  objectsBatch:clear()
end

function orbis.update(dt)
  for _, object in pairs(orbis.objects) do
    if object.update then
      object:update(dt)
    end
  end
end

return orbis
