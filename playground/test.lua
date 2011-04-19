
local read = "123456789"
local i = 1
local ar = {}
local ps = 5
local fs = 2
local tc = table.concat
local pl = {}
pl["123N567"] = '1111'
pl["234N678"] = '2'

while i <= #read do 
  ar[i] = read:sub(i, i) 
  i = i + 1 
end

i = 1
print(read)
while i + ps < #ar do 
  local tmp = tc(ar, "", i,i+fs) .. "N" .. tc(ar, "", i+fs+2, i+ps+1)
  print("-> " .. tmp)
  if pl[tmp] then 
    local sub_read = tc(ar, "", i,i+fs) .. "N" .. tc(ar, "", i+fs+2, i+ps+1) 
    local nt_value = ar[i+fs+1]
    print("HIT: " .. sub_read .. " : " .. ar[i+fs+1])
  end
  i = i + 1
end


