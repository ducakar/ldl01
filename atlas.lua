local lg = love.graphics
local ls = love.sound

local atlas = {
  WIDTH  = 400,
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
      layers = { 0, 2 },
      space = false,
      external = true
    }
  }
}

local DIMY = 32

function atlas.init()
  atlas.image = lg.newImage('gfx/atlas.png')
  local imageWidth, imageHeight = atlas.image:getDimensions()

  atlas.robot = {
    lg.newQuad(0 * atlas.DIM, 0 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * atlas.DIM, 1 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * atlas.DIM, 2 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * atlas.DIM, 0 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * atlas.DIM, 1 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * atlas.DIM, 2 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * atlas.DIM, 0 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * atlas.DIM, 1 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * atlas.DIM, 2 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * atlas.DIM, 0 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * atlas.DIM, 1 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * atlas.DIM, 2 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * atlas.DIM, 3 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * atlas.DIM, 3 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * atlas.DIM, 3 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * atlas.DIM, 3 * DIMY, atlas.DIM, DIMY, imageWidth, imageHeight)
  }

  for _, field in ipairs(atlas.FIELDS) do
    local floor = field.layers[1]
    local wall = field.layers[2]

    field.quads = {}

    if floor then
      field.quads[1] = lg.newQuad(4 * atlas.DIM, floor * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight)
    end
    if wall then
      field.quads[2] = lg.newQuad((5 + math.floor(wall / 8)) * atlas.DIM, math.fmod(wall, 8) * DIMY, atlas.DIM, DIMY,
                                  imageWidth, imageHeight)
    end
  end

  atlas.timeWarp = {
    lg.newQuad(15 * atlas.DIM, 0 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight),
    lg.newQuad(15 * atlas.DIM, 1 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight),
    lg.newQuad(15 * atlas.DIM, 2 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight),
    lg.newQuad(15 * atlas.DIM, 3 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight),
    lg.newQuad(15 * atlas.DIM, 4 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight)
  }

  atlas.cross = lg.newQuad(15 * atlas.DIM, 15 * atlas.DIM, atlas.DIM, atlas.DIM, imageWidth, imageHeight)

  atlas.step = ls.newSoundData('sfx/footstep1.wav')
end

return atlas
