local stream = {}

local function write(value, indent)
  local t = type(value)

  if t == 'nil' or t == 'boolean' or t == 'number' then
    return tostring(value)
  elseif t == 'string' then
    return '"' .. value .. '"'
  elseif t == 'table' then
    local s = '{\n'

    for i, v in pairs(value) do
      local is, vs = write(i, ''), write(v, indent .. '  ')
      if is and vs then
        s = s .. indent .. '  [' .. is .. '] = ' .. vs .. (next(value, i) and ',\n' or '\n')
      end
    end
    return s .. indent .. '}'
  end
end

function stream.read(file)
  local buffer = love.filesystem.read(file)

  if buffer then
    return load(buffer, 'chunk', 't')()
  end
end

function stream.write(file, value)
  love.filesystem.write(file, 'return ' .. write(value, '') .. '\n')
end

return stream
