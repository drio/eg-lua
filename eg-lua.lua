#!/usr/bin/env lua

-- Some config parameters
local cfg = {};
cfg.print_lines = 100000;
cfg.usage       = "Usage: " .. arg[0] .. " <probes_file> <reads_file>\n"
cfg.flank_size  = 15;
cfg.probe_size  = (cfg.flank_size * 2) + 1;

-- test_input_parameters
local function load_arguments(arg)
  local args = { probes_fn=nil, reads_fn=nil };
  local probes_fn = arg[1];
  local reads_fn = arg[2];
  if probes_fn == nil or reads_fn == nil then
    io.stderr:write(cfg.usage);
    os.exit(1); 
  end

  args.probes_fn = probes_fn
  args.reads_fn  = reads_fn
  return args
end

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

-- Load probes
-- 1	100006955	rs4908018	TTTGTCTAAAACAAC	CTTTCACTAGGCTCA	C	A
local function load_probes(args)
  local tmp             = {nil, nil, nil, nil, nil, nil, nil}; -- fields in line
  local h               = {};
  local p               = 0; -- Number of probes
  local probe           = nil;
  local rc_probe        = nil;
  local do_reverse_comp = ss_reverse_comp;

  for line in io.lines(args.probes_fn) do
    if p % cfg.print_lines == 0 then io.stderr:write("\rReading probes: ", p) end
    local i = 1;
    for field in line:gmatch("[^\t]+") do
      tmp[i] = field;
      i = i + 1;
    end
    probe            = tmp[4] .. "N" .. tmp[5];
    rc_probe         = do_reverse_comp(probe);
    h[probe]         = {}
    h[rc_probe]      = {} 
    h[probe].chrm    = tmp[1]; h[probe].pos = tmp[2]
    h[probe].id      = tmp[3]; h[probe].ref = tmp[6];
    h[probe].var     = tmp[7]; 
    h[probe].hits    = nil; 
    h[probe].neg     = false;
    h[rc_probe].hits = nil;  -- Don't add probe information when rc (save mem)
    h[rc_probe].neg  = true; -- probe comes from the negative strand
      
    p = p + 1;
  end
  io.stderr:write("\rReading probes: ", p , "\n");

  return h;
end

-- Given a read and a probe list(table) slides a window (size of the probes)
-- to look for perfect matches. If there is a hit, it saves it in the table.
local function slide_over_read(read, pl)
    local i      = 1;
    local slice  = nil;
    local ps     = cfg.probe_size;
    local fs     = cfg.flank_size;
    local n_hits = 0;

    while ps + i <= #read+1 do -- while the window is within the size of the read
      sub_read = read:sub(i, ps+i-1);
      nt_value = sub_read:sub(fs+1, fs+1);
      sub_read = sub_read:sub(1, fs) .. "N" .. sub_read:sub(fs+2);
      if pl[sub_read] then -- We have a probe with that sequence
        if pl[sub_read].hits then -- We have hits for that probe already
          pl[sub_read].hits[nt_value] = pl[sub_read].hits[nt_value] + 1;
        else
          pl[sub_read].hits = {A=0, C=0, G=0, T=0, N=0};
          pl[sub_read].hits[nt_value] = 1;
        end
        n_hits = n_hits + 1
      end
      i = i + 1
    end
    return n_hits;
end

-- Screen reads against the probes
local function screen_reads(args, probes)
  local i = 0;
  local name = nil;
  local seq  = nil;
  local n_hits = 0;
  local find_hits = slide_over_read

  for l in io.lines(args.reads_fn) do
    local tmp = l:find("%s"); -- Grab the first string on the line
    if l:byte(1) == 62 or l:byte(1) == 64 then -- ">" || "@"
      i = i + 1;
      name = (tmp and l:sub(2, tmp-1)) or l:sub(2);
      if i % cfg.print_lines == 0 then io.stderr:write("\rProcessing reads: ", i, "|", n_hits) end
    else
      n_hits = n_hits + find_hits(l, probes);
    end
  end
  io.stderr:write("\rProcessing reads: ", i, "|", n_hits, "\n");
end

-- Dumps the allele counting per each probe
local function show_results(probes)
  local do_reverse_comp = ss_reverse_comp;

  for k,v in pairs(probes) do -- Iterate over the probes
    if not v.processed then
      if v.hits then -- If we have hits, report them
        local info     = nil;
        local h_pos    = nil; -- hits positive strand
        local h_neg    = nil; -- hits negative strand
        local rc_probe = do_reverse_comp(k);
        local output   = "";
        local no_hits  = {A=0, C=0, G=0, T=0, N=0};

        if v.neg then -- If probe comes from - strand
          info  = probes[rc_probe];
          h_neg = v.hits;
          h_pos = probes[rc_probe].hits or no_hits;
        else
          info  = v
          h_pos = v.hits;
          h_neg = probes[rc_probe].hits or no_hits;
        end 
      
        -- Make sure we don't process RC probe again
        probes[rc_probe].processed = true;

        assert(h_pos, "h_pos cannot be nil.");
        assert(h_neg, "h_neg cannot be nil.");
        -- probe info
        output =
        string.format("%s,%s,%s,%s,%s,",
          info.chrm, info.pos, info.id, info.ref, info.var) ..
        -- hits positive strand
        string.format("%s,%s,%s,%s,%s,",
          h_pos.A, h_pos.C, h_pos.G, h_pos.T, h_pos.N) ..
        -- hits negative strand
        string.format("%s,%s,%s,%s,%s,",
          h_neg.A, h_neg.C, h_neg.G, h_neg.T, h_neg.N) ..
        -- hits positive + negative strand
        string.format("%s,%s,%s,%s,%s\n",
          h_pos.A + h_neg.A, 
          h_pos.C + h_neg.C,
          h_pos.G + h_neg.G, 
          h_pos.T + h_neg.T, 
          h_pos.N + h_neg.N);

        io.stdout:write(output); 
      end
    end
  end  
end

-------
-- MAIN
-------
io.stderr:write("probe_size:", cfg.probe_size);  
local args = load_arguments(arg);
local probes = load_probes(args);
screen_reads(args, probes);
show_results(probes)

--[[
print("---------");
local test_probe = "TTATCATTCCCTTCCNGATCACCTCTACCAG";
print("test_probe should be", test_probe);  
print(probes["TTATCATTCCCTTCCNGATCACCTCTACCAG"].id);
io.stderr:write("Done.", "\n")
--]]
--                         TTATCATTCCCTTCCNGATCACCTCTACCAG
-- print(slide_over_read("AAAATTATCATTCCCTTCCAGATCACCTCTACCAGAAAA", probes));
