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
local buildCue       = nil

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

local function posFromScreen(x, y)
  return math.floor(x / atlas.DIM) + 1, math.floor(y / atlas.DIM) + 1
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

function orbis.Object:new(o)
  o = o or {}
  o.class = o.class or self.class
  return setmetatable(o, self)
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

function orbis.buildCue(class)
  if class then
    buildCue = orbis.Object[class]:new()
    buildCue.building = buildCue.buildTime and 0.0
  else
    buildCue = nil
  end
end

function orbis.mousePressed(x, y, button)
  if buildCue then
    if button == 'r' then
      buildCue = nil
    elseif buildCue:canPlace() then
      buildCue:place()
      buildCue = nil
    end
  else
    orbis.actor:setPathTo(orbis.field(posFromScreen(x, y)))
  end
end

function orbis.mouseMoved(x, y)
  if buildCue then
    buildCue.field = orbis.field(posFromScreen(x, y))
  end
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

function orbis.save()
  return {
    map     = orbis.map,
    objects = orbis.objects,
    actor   = orbis.actor and orbis.actor.field
  }
end

function orbis.draw()
  externalColour[1] = 100 + net.light * 155
  externalColour[2] = 100 + net.light * 155
  externalColour[3] = 140 + net.light * 115

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
          local alpha  = object.building and 64 + 191 * (object.building / object.buildTime) or 255

          objectsBatch:setColor(colour[1], colour[2], colour[3], alpha)
          object:draw(objectsBatch)
        end

        objField = objField + 1
      end
      if x ~= 0 then
        local device = orbis.devices[wallField]
        local wall   = orbis.tiles[wallField]
        local quad   = atlas.FIELDS[wall].quads[2]

        if device and device.building then
          local colour = orbis.externals[objField] and externalColour or internalColour

          objectsBatch:setColor(colour[1], colour[2], colour[3], 255)
          objectsBatch:add(atlas.toolbox, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, 0, 0)
        elseif quad then
          local colour = orbis.externals[wallField] and externalColour or internalColour

          objectsBatch:setColor(colour[1], colour[2], colour[3])
          objectsBatch:add(quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, 0, atlas.DIM)
        end

        wallField = wallField + 1
      end
    end
  end

  lg.draw(objectsBatch)
  objectsBatch:clear()

  if buildCue then
    local x, y   = buildCue:pos()
    local sprite = buildCue.fx.sprite

    if buildCue:canPlace(buildCue.field) then
      lg.setColor(128, 255, 128, 128)
    else
      lg.setColor(255, 0, 0, 128)
    end

    lg.draw(atlas.image, sprite.quad, (x - 1) * atlas.DIM, (y - 1) * atlas.DIM, 0, 1, 1, sprite.offsetX, sprite.offsetY)
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
