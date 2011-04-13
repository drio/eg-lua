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

-- Some config parameters (Defaults)
cfg = {};
cfg.print_lines    = 100000;
cfg.usage          = "Usage: " .. arg[0] .. " <probes_file> <reads_file>\n"
cfg.flank_size     = 15;
cfg.probe_size     = (cfg.flank_size * 2) + 1;
cfg.profile_probes = false;
cfg.profile_reads  = false;

arguments = {
  load_them = load_arguments;
}
