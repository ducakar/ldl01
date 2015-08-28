local lg = love.graphics
local ls = love.sound

DIM = 16

atlas = {}

local DIMY  = 32

function atlas.init(imagePath)
  atlas.image = lg.newImage('gfx/atlas.png')
  local imageWidth, imageHeight = atlas.image:getDimensions()

  atlas.robot = {
    lg.newQuad(0 * DIM, 0 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * DIM, 1 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * DIM, 2 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * DIM, 0 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * DIM, 1 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * DIM, 2 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * DIM, 0 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * DIM, 1 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * DIM, 2 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * DIM, 0 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * DIM, 1 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * DIM, 2 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(0 * DIM, 3 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(1 * DIM, 3 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(2 * DIM, 3 * DIMY, DIM, DIMY, imageWidth, imageHeight),
    lg.newQuad(3 * DIM, 3 * DIMY, DIM, DIMY, imageWidth, imageHeight)
  }

  for _, field in ipairs(FIELDS) do
    field.quads = {}

    if field.layers[1] ~= 0 then
      field.quads[1] = lg.newQuad(4 * DIM, -DIM + field.layers[1] * DIM, DIM, DIM, imageWidth, imageHeight)
    end
    if field.layers[2] ~= 0 then
      field.quads[2] = lg.newQuad(5 * DIM, -DIMY + field.layers[2] * DIMY, DIM, DIMY, imageWidth, imageHeight)
    end
  end

  atlas.cross = lg.newQuad(7 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)

  atlas.step = ls.newSoundData('sfx/footstep1.wav')
end
