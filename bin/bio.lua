-- Reverse complement sequence space
local function ss_reverse_comp(sequence)
  local t  = { A="T", C="G", G="C", T="A", N="N"};
  local rs = string.reverse(sequence);
  local rc = "";

  for i = 1, #sequence do
    c  = rs:sub(i,i);
    rc = rc .. t[c];
  end
  return rc;
end

bio = {
  ss = { reverse_comp = ss_reverse_comp, },
  cs = nil
}
