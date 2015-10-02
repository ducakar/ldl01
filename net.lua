local atlas = require 'atlas'
local lg    = love.graphics

local WARP_LEVELS    = { 0.0, 1.0, 60.0, 3600.0, 86400.0 }
local DISCOVER_DRAIN = 1.0 - 0.000005

local net = {
  day       = 1,
  time      = 0.0,
  timeWarp  = 2,
  money     = 1234567890,
  discover  = 0.40,
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

function net.mousePressed()
end

function net.init(o)
  if o then
    net.time      = o.time
    net.day       = o.day
    net.timeWarp  = o.timeWarp
    net.money     = o.money
    net.discover  = o.discover
    net.servers   = o.servers
    net.cores     = o.cores
    net.freeCores = o.freeCores
    net.chances   = o.chances
  end
end

function net.save()
  return {
    time      = net.time,
    day       = net.day,
    timeWarp  = net.timeWarp,
    money     = net.money,
    discover  = net.discover,
    servers   = net.servers,
    cores     = net.cores,
    freeCores = net.freeCores,
    chances   = net.chances
  }
end

function net.draw()
  lg.clear()
  lg.draw((net.time < 6 * 3600 or net.time > 18 * 3600) and atlas.earthNight or atlas.earthDay, 0, 22)
end

function net.update(dt)
  net.dt       = WARP_LEVELS[net.timeWarp] * dt
  net.time     = net.time + net.dt
  net.discover = net.discover * DISCOVER_DRAIN ^ net.dt

  if net.time > 86400 then
    net.time = net.time - 86400
    net.day  = net.day + 1
  end

  for server, _ in pairs(net.servers) do
    if server:survivalChance(dt) < math.random() then
      net.servers[server] = nil
    end
  end
end

return net
