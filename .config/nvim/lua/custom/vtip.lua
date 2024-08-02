function Vtip()
  local handle = io.popen 'curl -s -m 3 https://vtip.43z.one'

  if handle then
    local result = handle:read '*a'
    handle:close()
    print(result)
  end
end

Vtip()
