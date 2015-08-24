require 'orbis'

atlas = {}

function atlas:init(imagePath)
  self.image = lg.newImage(imagePath)
  self.image:setFilter('nearest', 'nearest')

  local imageWidth, imageHeight = self.image:getDimensions()

  self.robot = {
    {
      lg.newQuad( 0, 0, 16, 32, imageWidth, imageHeight)
    },
    {
      lg.newQuad(16, 0, 16, 32, imageWidth, imageHeight)
    },
    {
      lg.newQuad(32, 0, 16, 32, imageWidth, imageHeight)
    },
    {
      lg.newQuad(48, 0, 16, 32, imageWidth, imageHeight)
    }
  }

  for _, field in ipairs(FIELDS) do
    field.quads = {}

    for i = 1, 2 do
      local value = field.layers[i]
      if value ~= 0 then
        field.quads[i] = lg.newQuad(48 + i * 16, -32 + value * 32, 16, 32, imageWidth, imageHeight)
      end
    end
  end
end
