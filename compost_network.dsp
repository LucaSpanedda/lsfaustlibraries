// Import the WKR Library
import("compost_library.lib");

// N = voices, M = network inputs.
N = 4;  M = 3;
W(0) = si.vecOp((si.bus(N * M), 
    par(i, N * M, ba.if((i >= 0) & (i < N), .9, .05))), *);
W(1) = si.vecOp((si.bus(N * M), 
    par(i, N * M, ba.if((i >= N) & (i < (N * 2)), .9, .05))), *);
W(2) = si.vecOp((si.bus(N * M), 
    par(i, N * M, ba.if((i >= (N * 2)) & (i < (N * 3)), .9, .05))), *);
Compost_Network(x,y,z,w) = ((W(0) : FDNBP(N, M), (x,y,z,w) :> si.bus(4)), 
                            (W(1) : FDNAP(N, M), (x,y,z,w) :> si.bus(4)), 
                            (W(2) : FDNGN(N, M), (x,y,z,w) :> si.bus(4))) ~ 
                            (si.bus(N * M) <: si.bus(N * M * M))
with{
    FDN =   component("compost_bioagents.dsp").FDN;
    FDNBP = component("compost_bioagents.dsp").FDNBP;
    FDNAP = component("compost_bioagents.dsp").FDNAP;
    FDNGN = component("compost_bioagents.dsp").FDNGN;
    FDNG2 = component("compost_bioagents.dsp").FDNG2;
};

process = Compost_Network;