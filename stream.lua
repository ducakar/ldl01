local lf = love.filesystem

local stream = {}

local function write(value, indent)
  local t = type(value)

  if t == 'nil' or t == 'boolean' or t == 'number' then
    return tostring(value)
  elseif t == 'string' then
    return string.format("'%s'", value)
  elseif t == 'table' then
    local s = '{\n'

    for i, v in pairs(value) do
      local is, vs = write(i, ''), write(v, indent .. '  ')
      if is and vs then
        s = string.format('%s%s  [%s] = %s', s, indent, is, vs) .. (next(value, i) and ',\n' or '\n')
      end
    end
    return string.format('%s%s}', s, indent)
  end
end

function stream.read(file)
  local buffer = lf.read(file)

  if buffer then
    local chunk = load(buffer, 'chunk', 't')

    if chunk then
      return chunk()
    end
  end
end

function stream.write(file, value)
  lf.write(file, 'return ' .. write(value, '') .. '\n')
end

return stream
