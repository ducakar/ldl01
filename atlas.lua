local atlas = {
  WIDTH  = 416,
  HEIGHT = 240,
  DIM    = 16,
  FIELDS = {
    {
      layers = { 0, nil },
      space = true,
      external = true
    },
    {
      layers = { 0, 3 },
      space = false,
      external = true
    },
    {
      layers = { 0, 4 },
      space = false,
      external = true
    },
    {
      layers = { 0, 5 },
      space = false,
      external = true
    },
    {
      layers = { 0, 6 },
      space = false,
      external = true
    },
    {
      layers = { 0, 7 },
      space = false,
      external = true
    },
    {
      layers = { 1, nil },
      space = true,
      external = false
    },
    {
      layers = { nil, 0 },
      space = false,
      external = false
    },
    {
      layers = { nil, 1 },
      space = false,
      external = false
    }
  }
}

local imageWidth  = 0
local imageHeight = 0

local function quad(x, y, width, height)
  return love.graphics.newQuad(x * atlas.DIM, y * atlas.DIM, width * atlas.DIM, height * atlas.DIM,
                               imageWidth, imageHeight)
end

local function sprite(x, y, width, height, offsetX, offsetY)
  return {
    quad    = quad(x, y, width, height),
    offsetX = (offsetX or 0) * atlas.DIM,
    offsetY = (offsetY or 0) * atlas.DIM
  }
end

local function sound(name)
  return love.sound.newSoundData(string.format('sfx/%s.wav', name))
end

function atlas.init()
  atlas.image = love.graphics.newImage('gfx/atlas.png')
  imageWidth, imageHeight = atlas.image:getDimensions()

  for _, field in ipairs(atlas.FIELDS) do
    local floor = field.layers[1]
    local wall  = field.layers[2]

    field.quads = {}

    if floor then
      field.quads[1] = quad(4, floor, 1, 1)
    end
    if wall then
      field.quads[2] = quad(5 + math.floor(wall / 8), math.fmod(wall, 8) * 2, 1, 2)
    end
  end

  atlas.robot = {
    sprite(0, 0, 1, 2, 0, 1), sprite(0, 2, 1, 2, 0, 1), sprite(0, 4, 1, 2, 0, 1),
    sprite(1, 0, 1, 2, 0, 1), sprite(1, 2, 1, 2, 0, 1), sprite(1, 4, 1, 2, 0, 1),
    sprite(2, 0, 1, 2, 0, 1), sprite(2, 2, 1, 2, 0, 1), sprite(2, 4, 1, 2, 0, 1),
    sprite(3, 0, 1, 2, 0, 1), sprite(3, 2, 1, 2, 0, 1), sprite(3, 4, 1, 2, 0, 1),
    sprite(0, 6, 1, 2, 0, 1), sprite(1, 6, 1, 2, 0, 1), sprite(2, 6, 1, 2, 0, 1), sprite(3, 6, 1, 2, 0, 1)
  }

  atlas.server   = sprite(0, 8, 3, 2, 1, 1)
  atlas.switch   = sprite(3, 8, 2, 2, 1, 1)
  atlas.warning  = sprite(4, 10, 1, 2, 0, 1)
  atlas.timeWarp = { quad(15, 0, 1, 1), quad(15, 1, 1, 1), quad(15, 2, 1, 1), quad(15, 3, 1, 1), quad(15, 4, 1, 1) }
  atlas.cross    = quad(15, 15, 1, 1)

  atlas.step     = sound('footstep1')
end

return atlas
