local lg = love.graphics
local ls = love.sound

local atlas = {
  WIDTH  = 512,
  HEIGHT = 288,
  DIM    = 16,
  FIELDS = {
    [01] = {
      layers   = { 0, nil },
      space    = true,
      external = true
    },
    [02] = {
      layers   = { 0, 3 },
      space    = false,
      external = true
    },
    [03] = {
      layers   = { 0, 4 },
      space    = false,
      external = true
    },
    [04] = {
      layers   = { 0, 5 },
      space    = false,
      external = true
    },
    [05] = {
      layers   = { 0, 6 },
      space    = false,
      external = true
    },
    [06] = {
      layers   = { 0, 7 },
      space    = false,
      external = true
    },
    [07] = {
      layers   = { 3, nil },
      space    = false,
      external = true
    },
    [08] = {
      layers   = { 4, nil },
      space    = false,
      external = true
    },
    [70] = {
      layers   = { 5, nil },
      space    = true,
      external = false
    },
    [71] = {
      layers   = { nil, 0 },
      space    = false,
      external = false
    },
    [80] = {
      layers   = { 6, nil },
      space    = true,
      external = false
    },
    [81] = {
      layers   = { nil, 1 },
      space    = false,
      external = false
    },
    [90] = {
      layers   = { 7, nil },
      space    = true,
      external = false
    },
    [91] = {
      layers   = { nil, 2 },
      space    = false,
      external = false
    }
  }
}

local imageWidth  = 0
local imageHeight = 0

local function quad(x, y, width, height)
  return lg.newQuad(x * atlas.DIM, y * atlas.DIM, width * atlas.DIM, height * atlas.DIM, imageWidth, imageHeight)
end

local function sprite(x, y, width, height, offsetX, offsetY)
  return {
    quad    = quad(x, y, width, height),
    offsetX = (offsetX or 0) * atlas.DIM,
    offsetY = (offsetY or 0) * atlas.DIM
  }
end

local function sound(name)
  return ls.newSoundData(string.format('sfx/%s.wav', name))
end

function atlas.init()
  atlas.image = lg.newImage('gfx/atlas.png')
  imageWidth, imageHeight = atlas.image:getDimensions()

  for _, field in pairs(atlas.FIELDS) do
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
    quad(0, 0, 1, 2), quad(0, 2, 1, 2), quad(0, 4, 1, 2),
    quad(1, 0, 1, 2), quad(1, 2, 1, 2), quad(1, 4, 1, 2),
    quad(2, 0, 1, 2), quad(2, 2, 1, 2), quad(2, 4, 1, 2),
    quad(3, 0, 1, 2), quad(3, 2, 1, 2), quad(3, 4, 1, 2),
    quad(0, 6, 1, 2), quad(1, 6, 1, 2), quad(2, 6, 1, 2), quad(3, 6, 1, 2)
  }

  atlas.terminal = sprite(0, 10, 3, 3, 1, 2)
  atlas.server   = sprite(0, 8, 3, 2, 1, 1)
  atlas.switch   = sprite(3, 8, 2, 2, 1, 1)
  atlas.warning  = sprite(4, 10, 1, 2, 0, 1)
  atlas.timeWarp = { quad(15, 0, 1, 1), quad(15, 1, 1, 1), quad(15, 2, 1, 1), quad(15, 3, 1, 1), quad(15, 4, 1, 1) }

  atlas.destroy  = quad(15, 12, 1, 1)
  atlas.build    = quad(15, 13, 1, 1)
  atlas.device   = quad(15, 14, 1, 1)
  atlas.dest     = quad(15, 15, 1, 1)

  atlas.step     = sound('footstep1')
end

return atlas
