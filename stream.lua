local stream = {}

function stream.write(value)
  local t = type(value)

  if t == 'nil' or t == 'boolean' or t == 'number' then
    return tostring(value)
  elseif t == 'string' then
    return '"' .. value .. '"'
  elseif t == 'table' then
    local s = value.class and value.class .. ':new {' or '{'
    for i, v in pairs(value) do
      local is, vs = stream.write(i), stream.write(v)
      if is and vs then
        s = s .. ' [' .. is .. '] = ' .. vs .. (next(value, i) and ',' or ' ')
      end
    end
    return s .. '}'
  end
end

function stream.read(line)
  return load('return ' .. line, 'chunk', 't')()
end

return stream
