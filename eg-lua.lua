#!/usr/bin/env lua

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

-- Load probes
-- 1	100006955	rs4908018	TTTGTCTAAAACAAC	CTTTCACTAGGCTCA	C	A
local function load_probes(args)
  local tmp = {}
  local h = {}
  local p = 0;
  local probe = nil;

  for line in io.lines(args.probes_fn) do
    if p % cfg.print_lines == 0 then io.stderr:write("\rReading probes: ", p) end
    local i = 1;
    for field in line:gmatch("[^\t]+") do
      tmp[i] = field;
      i = i + 1;
    end
    probe         = tmp[4] .. "N" .. tmp[5];
    h[probe]      = {}
    h[probe].line = line 
    h[probe].hits= {A=0, C=0, G=0, T=0, N=0};
    p = p + 1;
  end
  io.stderr:write("\rReading probes: ", p, "\n");

  return h;
end

-- Screen reads against the probes
local function screen_reads(args, probes)
  local i = 0;
  local name = nil;
  local seq  = nil;

  for l in io.lines(args.reads_fn) do
    local tmp = l:find("%s"); -- Grab the first string on the line
    if l:byte(1) == 62 or l:byte(1) == 64 then -- ">" || "@"
      i = i + 1;
      name = (tmp and l:sub(2, tmp-1)) or l:sub(2);
      if i % cfg.print_lines == 0 then io.stderr:write("\rProcessing reads: ", i) end
    else 
      seq = l;
    end
  end
  io.stderr:write("\rProcessing reads: ", i, "\n");
end

-- Given a read and a probe list(table) slides a window (size of the probes)
-- to look for perfect matches. If there is a hit, it saves it in the table.
local function slide_over_read(read, pl)
  local i      = 1;
  local slice  = nil;
  local ps     = cfg.probe_size;
  local fs     = cfg.flank_size;
  local n_hits = 0;

  print("--> Read: ", read);
  while ps + i <= #read do -- while the window is within the size of the read
    sub_read = read:sub(i, ps+i-1);
    nt_value = sub_read:sub(fs+1, fs+1);
    sub_read = sub_read:sub(1, fs) .. "N" .. sub_read:sub(fs+2);
    print(sub_read);
    print("NT: ", nt_value);
    if pl[sub_read] then -- We have a probe with that sequence
      pl[sub_read].hits[nt_value] = pl[sub_read].hits[nt_value] + 1;
      n_hits = n_hits + 1
    end
    i = i + 1
  end
  io.stderr:write("Number of hits: ", n_hits, "\n");
end

print("probe_size:", cfg.probe_size);  
local args = load_arguments(arg);
local probes = load_probes(args);
screen_reads(args, probes);

print("---------");
local test_probe = "TTATCATTCCCTTCCNGATCACCTCTACCAG";
print("test_probe should be", test_probe);  
print(probes["TTATCATTCCCTTCCNGATCACCTCTACCAG"].line);
io.stderr:write("Done.", "\n")
--                         TTATCATTCCCTTCCNGATCACCTCTACCAG
print(slide_over_read("AAAATTATCATTCCCTTCCAGATCACCTCTACCAGAAAA", probes))
