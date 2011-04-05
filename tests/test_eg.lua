require('luaunit')
require('arguments')
require('bio')
require('probes')

-- Test Bio
TestBio = {}
  function TestBio:test_ss_reverse_comp()
    r = bio.ss.reverse_comp("AATTC");
    assertEquals(type(r), 'string');
    assertEquals(r, "GAATT");
  end

  function TestBio:test_ss_reverse_n()
    r = bio.ss.reverse_comp("N");
    assertEquals(r, "N");
  end

TestProbes = {}
  function TestProbes:test_slide_over_read()
    -- Create a fake hash with one probe
    hp             = {};
    probe          = "AAAAAAAAAAAAAAANAAAAAAAAAAAAAAA";
    hp[probe]      = {};
    hp[probe].hits = nil;

    -- Check the read against the probe list
    read           = "AAAAAAAAAAAAAAAAAAAATAAAAAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(r, 1);
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 0);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 0);
    -- Let's add another read so 1 more hit
    read = "AAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 1);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 0);
    -- Let's have now an N in the middle of the probe
    read = "AAAAAAAAAAAAAAAAAAAANAAAAAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 1);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 1);
    -- One more hit, same allele
    read = "AAAAAAAAAAAAAAAAAAAATAAAAAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(hp[probe].hits["T"], 2);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 1);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 1);
  end

  function TestProbes:test_slide_over_read_RC()
    -- Create a fake hash with one probe
    hp = {};
    probe             = "AAAAAAAAAAAAAAANAAAAAAAAAAAAAAA";
    rc_probe          = "TTTTTTTTTTTTTTTNTTTTTTTTTTTTTTT"; 
    hp[probe]         = {};
    hp[rc_probe]      = {};
    hp[probe].hits    = nil;
    hp[rc_probe].hits = nil;

    -- Check the read against the probe list (positive strand)
    read = "AAAAAAAAAAAAAAAAAAAATAAAAAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(r, 1);
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 0);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 0);
    -- Now - strand 
    read = "AAATTTTTTTTTTTTTTTATTTTTTTTTTTTTTTAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(r, 1);
    -- It still should have 1 hit in the +
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 0);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 0);
    -- We should see the new hit in -
    assertEquals(hp[rc_probe].hits["T"], 0);
    assertEquals(hp[rc_probe].hits["A"], 1);
    assertEquals(hp[rc_probe].hits["C"], 0);
    assertEquals(hp[rc_probe].hits["G"], 0);
    assertEquals(hp[rc_probe].hits["N"], 0);
  end

  function TestProbes:test_slide_over_read_corner_case()
    hp = {};
    probe             = "AAAAAAAAAAAAAAANAAAAAAAAAAAAAAA";
    rc_probe          = "TTTTTTTTTTTTTTTNTTTTTTTTTTTTTTT"; 
    hp[probe]         = {};
    hp[rc_probe]      = {};
    hp[probe].hits    = nil;
    hp[rc_probe].hits = nil;

    -- The read is the same size of the probe
    read = "AAAAAAAAAAAAAAATAAAAAAAAAAAAAAA";
    r = probes.slide_over_read(read, hp);
    assertEquals(r, 1);
    assertEquals(hp[probe].hits["T"], 1);
    assertEquals(hp[probe].hits["A"], 0);
    assertEquals(hp[probe].hits["C"], 0);
    assertEquals(hp[probe].hits["G"], 0);
    assertEquals(hp[probe].hits["N"], 0);

    -- Same RC
    read = "TTTTTTTTTTTTTTTCTTTTTTTTTTTTTTT";
    r = probes.slide_over_read(read, hp);
    assertEquals(r, 1);
    assertEquals(hp[rc_probe].hits["T"], 0);
    assertEquals(hp[rc_probe].hits["A"], 0);
    assertEquals(hp[rc_probe].hits["C"], 1);
    assertEquals(hp[rc_probe].hits["G"], 0);
    assertEquals(hp[rc_probe].hits["N"], 0);
  end
 

-- Run tests
LuaUnit:run()
