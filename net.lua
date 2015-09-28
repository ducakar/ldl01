local WARP_LEVELS = { 0.0, 1.0, 60.0, 3600.0, 86400.0 }

local net = {
  servers = {},
  time      = 0.0,
  day       = 1,
  timeWarp  = 2,
  cores     = 1200000,
  freeCores = 200000,
  money     = 1234567890
}

function net.init(o)
  if o then
    net.servers   = o.servers
    net.time      = o.time
    net.day       = o.day
    net.timeWarp  = o.timeWarp
    net.cores     = o.cores
    net.freeCores = o.freeCores
    net.money     = o.money
  end
end

function net.save()
  return {
    servers   = net.servers,
    time      = net.time,
    day       = net.day,
    timeWarp  = net.timeWarp,
    cores     = net.cores,
    freeCores = net.freeCores,
    money     = net.money
  }
end

function net.update(dt)
  net.dt   = WARP_LEVELS[net.timeWarp] * dt
  net.time = net.time + net.dt

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
