local t_nc = { A="T", C="G", G="C", T="A", N="N"}

-- Reverse complement sequence space
local function ss_reverse_comp(sequence)
  local rs = string.reverse(sequence)

  return rs:gsub('.', t_nc)
end

bio = {
  ss = { reverse_comp = ss_reverse_comp, },
  cs = nil
}

