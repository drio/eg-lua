-- Load probes
-- 1  100006955 rs4908018 TTTGTCTAAAACAAC CTTTCACTAGGCTCA C A
local function load_probes(args)
  local h               = {}
  local p               = 0; -- Number of probes
  local do_reverse_comp = bio.ss.reverse_comp

  for line in io.lines(args.probes_fn) do
    if p % cfg.print_lines == 0 then io.stderr:write("\rReading probes: ", p) end
    local chrm,pos,id,left,right,ref,var
      = line:match(string.rep('([^\t]+)\t', 6)..'([^\t]+)')

    local probe = left .. "N" .. right
    local rc_probe = do_reverse_comp(probe)
    h[probe] = {
      chrm = chrm,
      pos  = pos,
      id   = id,
      ref  = ref,
      var  = var,
      neg  = false
    }
    h[rc_probe] = { neg  = true; } -- probe comes from the negative strand
    p = p + 1
  end
  io.stderr:write("\rReading probes: ", p , "\n")

  return h
end

--[[
Given a read and a probe list(table) slides a window (size of the probes)
to look for perfect matches. If there is a hit, it saves it in the table.
Example:
Assuming a probe table with only:
  pl = { "CCGTT"  = {} }
and a read:
  AACCGTTAA
This function slide a window of 5 characters across the read string:
  AACCG 
   ACCGT
    CCGTT --> HIT! save the hit for that probe -> pl["CCGTT"] = { ... , G = 1, ... }
     CGTTA
      GTTAA
In this case, ps = 5; fs = 2 (user configurable parameters)
--]]
local function slide_over_read(read, pl)
  local i        = 1
  local ps       = cfg.probe_size
  local fs       = cfg.flank_size
  local n_hits   = 0
  local tmp      = #read + 1

  while ps + i <= tmp do -- while the window is within the size of the read
    local t        = read:sub(i, ps+i-1)
    local sub_read = t:sub(1, fs) .. "N" .. t:sub(fs+2)
    local look_up  = pl[sub_read]
    if look_up then -- We have a probe with that sequence
      local nt_value = read:sub(i, ps+i-1):sub(fs+1, fs+1) 
      if not look_up.hits then -- No previous hits
        look_up.hits = {A=0, C=0, G=0, T=0, N=0}
      end
      look_up.hits[nt_value] = look_up.hits[nt_value] + 1
      n_hits = n_hits + 1
    end
    i = i + 1
  end
  return n_hits
end

-- Screen reads against the probes
local function screen_reads(args, probes)
  local i = 0
  --local name = nil
  local seq  = nil
  local n_hits = 0
  local find_hits = slide_over_read

  for l in io.lines(args.reads_fn) do
    local tmp = l:find("%s"); -- Grab the first string on the line
    if l:byte(1) == 62 then -- ">"
      i = i + 1
      --name = (tmp and l:sub(2, tmp-1)) or l:sub(2)
      if i % cfg.print_lines == 0 then io.stderr:write("\rProcessing reads: ", i, "|", n_hits) end
    else
      n_hits = n_hits + find_hits(l, probes)
    end
  end
  io.stderr:write("\rProcessing reads: ", i, "|", n_hits, "\n")
end

probes = {
  load_probes     = load_probes,
  slide_over_read = slide_over_read,
  screen_reads    = screen_reads
}
