local function slide_over_read(read, pl)
  local i      = 1
  local ps     = 7 
  local fs     = 3
  local n_hits = 0

  print("READ: " .. read .. " : " .. #read)
  while ps + i <= #read+1 do -- while the window is within the size of the read
    sub_read = read:sub(i, ps+i-1)
    nt_value = sub_read:sub(fs+1, fs+1)
    sub_read = sub_read:sub(1, fs) .. "N" .. sub_read:sub(fs+2)
    print("Trying: " .. sub_read .. " -- " .. i .. " while: " .. ps + i .. " | " .. #read+1)
    if pl[sub_read] then -- We have a probe with that sequence
      if not pl[sub_read].hits then -- No previous hits
        pl[sub_read].hits = {A=0, C=0, G=0, T=0, N=0}
      end
      pl[sub_read].hits[nt_value] = pl[sub_read].hits[nt_value] + 1
      n_hits = n_hits + 1
    end
    i = i + 1
  end
  return n_hits
end

-- Main
probes = {}
probes["123N567"] = {}
read = "123A56789"
print("hits: " .. slide_over_read(read, probes))
print("--> " .. probes["123N567"].hits["A"])
print("---------------")

probes["345N789"] = {}
read = "12345T789"
print("hits: " .. slide_over_read(read, probes))
print("--> " .. probes["345N789"].hits["T"])
