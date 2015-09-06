CPU = {
  Pentium = {
    name  = 'Pentium',
    mips  = 1,
    price = 20
  },
  Athlon  = {
    name  = 'Athlon',
    mips  = 3,
    price = 50
  },
  Itanium = {
    name  = 'Itanium',
    mips  = 6,
    price = 120
  },
  Core = {
    name  = 'Core',
    mips  = 8,
    price = 100
  },
  Cell = {
    name  = 'Cell',
    mips  = 25,
    price = 300
  },
  Wave = {
    name  = 'Wave',
    mips  = 50,
    price = 2000
  },
  Quant = {
    name  = 'Quant',
    mips  = 1000,
    price = 10000
  }
}

Server = {
  cpu      = nil,
  number   = 0,
  mips     = 0,
  enabled  = true,
  survival = 0.99
}
Server.__index = Server

function Server:new(o)
  o = o or {}
  return setmetatable(o, self)
end

function Server:setCPU(cpu, number)
  self.cpu    = cpu
  self.number = number
  self.mips   = number * cpu.mips
end

function Server:survivalChance(dt)
  return (self.enabled and 1.0 or 0.2) * self.survival ^ dt
end
