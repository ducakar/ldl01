require 'orbis'

DIM  = 16
DIMY = 32

local lg = love.graphics

atlas = {}

function atlas:init(imagePath)
  self.image = lg.newImage('gfx/atlas.png')
  self.image:setFilter('nearest', 'nearest')

  local imageWidth, imageHeight = self.image:getDimensions()

  self.robot = {
    {
      lg.newQuad(0 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)
    },
    {
      lg.newQuad(1 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)
    },
    {
      lg.newQuad(2 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)
    },
    {
      lg.newQuad(3 * DIM, 0, DIM, DIMY, imageWidth, imageHeight)
    }
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
end
