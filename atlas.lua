local lg = love.graphics
local ls = love.sound

local atlas = {
  WIDTH  = 320,
  HEIGHT = 180,
  DIM    = 16,
  FIELDS = {
    [00] = {
      -- grass
      layers   = {0, nil},
      space    = true,
      external = true
    },
    [01] = {
      -- grass-obstructed
      layers   = {0, nil},
      space    = false,
      external = true
    },
    [02] = {
      -- grass + fence-H
      layers   = {0, 3},
      space    = false,
      external = true
    },
    [03] = {
      -- grass + fence-HL
      layers   = {0, 4},
      space    = false,
      external = true
    },
    [04] = {
      -- grass + fence-HR
      layers   = {0, 5},
      space    = false,
      external = true
    },
    [05] = {
      -- grass + fence-VL
      layers   = {0, 6},
      space    = false,
      external = true
    },
    [06] = {
      -- grass + fence-VR
      layers   = {0, 7},
      space    = false,
      external = true
    },
    [07] = {
      -- road-plain
      layers   = {3, nil},
      space    = true,
      external = true
    },
    [08] = {
      -- road-dash
      layers   = {4, nil},
      space    = true,
      external = true
    },
    [10] = {
      -- snow
      layers   = {1, nil},
      space    = true,
      external = true
    },
    [11] = {
      -- snow-obstructed
      layers   = {1, nil},
      space    = false,
      external = true
    },
    [20] = {
      -- moon
      layers   = {1, nil},
      space    = true,
      external = true
    },
    [21] = {
      -- moon-obstructed
      layers   = {1, nil},
      space    = false,
      external = true
    },
    [70] = {
      -- floor-concrete
      layers   = {5, nil},
      space    = true,
      external = false
    },
    [71] = {
      -- wall-bricks
      layers   = {nil, 0},
      space    = false,
      external = false
    },
    [80] = {
      -- floor-dirt
      layers   = {6, nil},
      space    = true,
      external = false
    },
    [81] = {
      -- wall-concrete
      layers   = {nil, 1},
      space    = false,
      external = false
    },
    [90] = {
      -- floor-hitech
      layers   = {7, nil},
      space    = true,
      external = false
    },
    [91] = {
      -- wall-hitech
      layers   = {nil, 2},
      space    = false,
      external = false
    }
  }
}

local imageWidth  = 0
local imageHeight = 0

local function quad(x, y, width, height)
  return lg.newQuad(x, y, width, height, imageWidth, imageHeight)
end

local function tile(x, y, width, height)
  return quad(x * atlas.DIM, y * atlas.DIM, width * atlas.DIM, height * atlas.DIM)
end

local function sprite(x, y, width, height, offsetX, offsetY)
  return {
    quad    = tile(x, y, width, height),
    offsetX = (offsetX or 0) * atlas.DIM,
    offsetY = (offsetY or 0) * atlas.DIM
  }
end

local function sound(name)
  return ls.newSoundData(string.format('sfx/%s.ogg', name))
end

local function generateLand()
  local w, h = atlas.earthDay:getDimensions()
  local data = atlas.earthDay:getData()

  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local r, g, b = data:getPixel(x, y)
      local isLand = b - 1.0 * g - 2.0 * r < 0.1 * 255

      if isLand then
        data:setPixel(x, y, 255, 255, 255, 255)
      else
        data:setPixel(x, y, 0, 0, 0, 255)
      end
    end
  end

  return lg.newImage(data)
end

function atlas.init()
  atlas.earth      = lg.newShader('gfx/earth.frag')
  atlas.earthDay   = lg.newImage('gfx/earthDay.jpg')
  atlas.earthNight = lg.newImage('gfx/earthNight.jpg')
  atlas.earthLand  = generateLand()
  atlas.image      = lg.newImage('gfx/atlas.png')

  atlas.earth:send('nightImage', atlas.earthNight)

  imageWidth, imageHeight = atlas.image:getDimensions()

  for _, field in pairs(atlas.FIELDS) do
    local floor = field.layers[1]
    local wall  = field.layers[2]

    field.quads = {}

    if floor then
      field.quads[1] = tile(4, floor, 1, 1)
    end
    if wall then
      field.quads[2] = tile(5 + math.floor(wall / 4), math.fmod(wall, 4) * 2, 1, 2)
    end
  end

  atlas.robot = {
    tile(0, 0, 1, 2), tile(1, 0, 1, 2), tile(2, 0, 1, 2), tile(3, 0, 1, 2),
    tile(0, 2, 1, 2), tile(1, 2, 1, 2), tile(2, 2, 1, 2), tile(3, 2, 1, 2),
    tile(0, 4, 1, 2), tile(1, 4, 1, 2), tile(2, 4, 1, 2), tile(3, 4, 1, 2),
    tile(0, 6, 1, 2), tile(1, 6, 1, 2), tile(2, 6, 1, 2), tile(3, 6, 1, 2)
  }

  atlas.toolbox  = tile(9, 0, 1, 1)
  atlas.terminal = sprite(10, 0, 3, 3, 1, 2)
  atlas.server   = sprite( 9, 3, 3, 2, 1, 1)
  atlas.switch   = sprite(12, 3, 2, 2, 1, 1)
  atlas.warning  = sprite( 9, 1, 1, 2, 0, 1)
  atlas.panel    = sprite(13, 0, 1, 3, 0, 2)
  atlas.timeWarp = {
    quad(15 * atlas.DIM + 0, 0, 5, 7),
    quad(15 * atlas.DIM + 5, 0, 5, 7),
    quad(15 * atlas.DIM + 10, 0, 5, 7),
    quad(15 * atlas.DIM + 0, 7, 5, 7),
    quad(15 * atlas.DIM + 5, 7, 5, 7)
  }

  atlas.discover = tile(14, 0, 1, 1)
  atlas.public   = tile(14, 1, 1, 1)
  atlas.covert   = tile(14, 2, 1, 1)
  atlas.science  = tile(14, 3, 1, 1)

  atlas.destroy  = tile(14, 5, 1, 1)

  atlas.base     = tile(15, 5, 1, 1)
  atlas.center   = tile(15, 6, 1, 1)
  atlas.dest     = tile(15, 7, 1, 1)

  atlas.footstep = sound('footstep')
  atlas.building = sound('event')
end

return atlas
