-- Dumps the results of a probe using the old eg format:
-- Ref, Variant, other1, other2, N
local function dump_old_format(h_pos, h_neg, info)
  assert(h_pos, "h_pos cannot be nil.");
  assert(h_neg, "h_neg cannot be nil.");

  local rc = bio.ss.reverse_comp;
  -- Find what are the other alleles
  local tmp     = {A=0, T=0, C=0, G=0};
  local o1      = nil; -- the first other allele
  local o2      = nil; -- the second other allele
  tmp[info.ref] = 1; tmp[info.var] = 1;
  for k,v in pairs(tmp) do 
    if tmp[k] == 0 then
      if o1 then o2=k else o1=k end
    end
  end

  output =
    -- probe info
    string.format("%s,%s,%s,%s,%s,",
      info.chrm, info.pos, info.id, info.ref, info.var) ..
    -- hits positive strand ref, var
    string.format("%s,%s,%s,%s,%s,",
      h_pos[info.ref], h_pos[info.var], h_pos[o1], h_pos[o2] , h_pos.N) ..
    -- hits negative strand
    string.format("%s,%s,%s,%s,%s,", 
      h_neg[rc(info.ref)], h_neg[rc(info.var)], h_neg[rc(o1)], h_neg[rc(o2)] , h_neg.N) ..
    -- hits positive + negative strand
    string.format("%s,%s,%s,%s,%s\n",
      h_pos[info.ref] + h_neg[rc(info.ref)],
      h_pos[info.var] + h_neg[rc(info.var)],
      h_pos[o1] + h_neg[rc(o1)],
      h_pos[o2] + h_neg[rc(o2)],
      h_pos.N + h_neg.N);

  io.stdout:write(output); 
end

-- Dumps the results of a probe using A,C,G,T for the order
local function dump_probe_line_acgt(h_pos, h_neg, info)
  assert(h_pos, "h_pos cannot be nil.");
  assert(h_neg, "h_neg cannot be nil.");

  output =
    -- probe info
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

-- Dumps the allele counting per each probe
local function show_results(probes)
  local do_reverse_comp = bio.ss.reverse_comp;
  local dump_acgt = dump_probe_line_acgt;

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

        -- Different ways to dump the output
        --dump_probe_line_acgt(h_pos, h_neg, info);
        dump_old_format(h_pos, h_neg, info);
      end
    end
  end  
end

results = {
  show  = show_results
}
