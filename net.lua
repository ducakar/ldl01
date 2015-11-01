local atlas  = require 'atlas'
local lg     = love.graphics

local WARP_LEVELS    = { 0.0, 1.0, 60.0, 60.0 ^ 2, 60.0 ^ 3 }
local DISCOVER_DRAIN = 1.0 - 0.000005
local EARTH_WIDTH    = atlas.WIDTH
local EARTH_HEIGHT   = atlas.HEIGHT - 36
local EARTH_OFFSET   = 13
local ICON_HALF      = atlas.DIM / 2

local buildCue = nil

local net = {
  timeWarp  = 2,
  time      = 0.0,
  year      = 1,
  day       = 1,
  money     = 1234567890,
  discover  = 0.40,
  location  = nil,
  light     = 1.0,
  servers   = {},
  cores     = 1200000,
  freeCores = 200000,
  chances   = {
    public  = 0.0,
    covert  = 0.0,
    science = 0.0
  },
  mapView   = false
}

local function position(location)
  local x = EARTH_WIDTH / 2 + location[1] / 360.0 * EARTH_WIDTH - atlas.DIM / 2
  local y = EARTH_HEIGHT / 2 - location[2] / 180.0 * EARTH_HEIGHT - atlas.DIM / 2 + EARTH_OFFSET
  return x, y
end

local function lightIntensity()
  -- Calculate the point (= normal) on the earth sphere from texture coordinates.
  local phi       = (net.location[1] + net.time / 240.0) / 180.0 * math.pi
  local theta     = net.location[2] / 180.0 * math.pi
  local normalX   = math.cos(phi) * math.cos(theta)
  local normalZ   = math.sin(theta)

  -- Calculate sun light vector tilt besed on the time of the year.
  local tilt      = math.cos(net.day / 365.25 * 2.0 * math.pi) * 0.4084
  local sunLightX = math.cos(tilt)
  local sunLightZ = math.sin(tilt)

  -- Light intensity.
  local dot       = sunLightX * normalX + sunLightZ * normalZ
  local intensity = math.min(math.max(0.5 - 2.0 * dot, 0.0), 1.0)

  return intensity
end

function net.mousePressed(x, y, button)
  if buildCue then
    if button == 'r' then
      buildCue = nil
    else
      y = y - EARTH_OFFSET

      lg.setColor(255, 0, 0, 128)

      if ICON_HALF <= x and x <= EARTH_WIDTH - ICON_HALF < x and ICON_HALF <= y and y <= EARTH_HEIGHT - ICON_HALF then
        lg.setColor(0, 255, 0, 128)
      end
    end
  end
end

function net.mouseMoved()
end

function net.buildCue()
  buildCue = nil
end

function net.init(o)
  if o then
    net.timeWarp  = o.timeWarp
    net.time      = o.time
    net.day       = o.day
    net.year      = o.year
    net.money     = o.money
    net.discover  = o.discover
    net.location  = o.location
    net.servers   = o.servers
    net.cores     = o.cores
    net.freeCores = o.freeCores
    net.chances   = o.chances
  end

  net.location = { 15, 45 }
  net.light    = lightIntensity()
end

function net.save()
  return {
    timeWarp  = net.timeWarp,
    time      = net.time,
    day       = net.day,
    year      = net.year,
    money     = net.money,
    discover  = net.discover,
    location  = net.location,
    servers   = net.servers,
    cores     = net.cores,
    freeCores = net.freeCores,
    chances   = net.chances
  }
end

function net.draw()
  lg.clear()
  lg.setShader(atlas.earth)
  atlas.earth:send('times', net.time, net.day)
  lg.draw(atlas.earthDay, 0, EARTH_OFFSET)
  lg.setShader()

  lg.draw(atlas.image, atlas.base, position(net.location))

  for _, server in pairs(net.servers) do
    lg.draw(atlas.image, atlas.center, position(server.location))
  end

  if buildCue then
    lg.draw(atlas.image, atlas.center, position(buildCue.location))
  end
end

function net.update(dt)
  net.dt       = WARP_LEVELS[net.timeWarp] * dt
  net.time     = net.time + net.dt
  net.discover = net.discover * DISCOVER_DRAIN ^ net.dt
  net.light    = lightIntensity()

  if net.time > 86400.0 then
    net.time = net.time - 86400.0
    net.day  = net.day + 1

    if net.day > 366 then
      net.day  = net.day - 366
      net.year = net.year + 1
    elseif net.day > 365 and math.fmod(net.year, 4) ~= 0 then
      net.day  = net.day - 365
      net.year = net.year + 1
    end
  end

  for _, server in pairs(net.servers) do
    if server:survivalChance(dt) < math.random() then
      net.servers[server] = nil
    end
  end
end

return net
