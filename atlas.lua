require 'orbis'

local lg = love.graphics

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

    for i = 1, 2 do
      local value = field.layers[i]
      if value ~= 0 then
        field.quads[i] = lg.newQuad(3 * DIM + i * DIM, -DIMY + value * DIMY, DIM, DIMY, imageWidth, imageHeight)
      end
    end
  end

  atlas.cross = lg.newQuad(7 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)
end
