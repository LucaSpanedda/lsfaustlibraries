// Import the WKR Library
import("compost_library.lib");


// N = voices, M = network inputs.
FDNBP(N, M) = si.bus(N * M) :> si.bus(N) : hadamard : 
    (netInsx : netNorm : netDCof : netLimt) ~ (hadamard : agnt)
with{
    hadamardnorm = 1.0 / sqrt(N); // norm for hadamard
    hadamardcoeff = par(i, N, hadamardnorm); // norm par
    hadamard = vecOp((ro.hadamard(N) , hadamardcoeff), *);
    netInsx = vecOp((si.bus(N) , si.bus(N)), +); // ins + fbs
    netNorm = par(i, N, RMSNorm(10, 10, .1, 10)); // norm + del
    netLimt = par(i, N, lookaheadLimiter(.8)); // signal limit
    agnt =  par(i, N, BPSVF(1, 200 + (i * 200))); // agents
    netDCof = par(i, N, dcblocker); // dc blockers
};
//process = FDNBP(4, 3);

FDNAP(N, M) = si.bus(N * M) :> si.bus(N) : hadamard : 
    (netInsx : netNorm : netDCof : netLimt) ~ (hadamard : agnt)
with{
    hadamardnorm = 1.0 / sqrt(N); // norm for hadamard
    hadamardcoeff = par(i, N, hadamardnorm); // norm par
    hadamard = vecOp((ro.hadamard(N) , hadamardcoeff), *);
    netInsx = vecOp((si.bus(N) , si.bus(N)), +); // ins + fbs
    netNorm = par(i, N, RMSNorm(10, 10, .1, 10)); // norm + del
    netLimt = par(i, N, lookaheadLimiter(.8)); // signal limit
    agnt =  apfLattice(N, 10, 10, 400, 5, .5); // agents
    netDCof = par(i, N, dcblocker); // dc blockers
};
//process = FDNAP(4, 3); 

FDNGN(N, M) = si.bus(N * M) :> si.bus(N) : hadamard : 
    (netInsx : netNorm : netDCof : netLimt) ~ (hadamard : agnt)
with{
    hadamardnorm = 1.0 / sqrt(N); // norm for hadamard
    hadamardcoeff = par(i, N, hadamardnorm); // norm par
    hadamard = vecOp((ro.hadamard(N) , hadamardcoeff), *);
    netInsx = vecOp((si.bus(N) , si.bus(N)), +); // ins + fbs
    netNorm = par(i, N, RMSNorm(10, 10, .1, 10)); // norm + del
    netLimt = par(i, N, lookaheadLimiter(.8)); // signal limit
    agnt =  par(i, N, 
        timeStretcher(30, 30, 1, 1, 1, 0, .5, 10000, (i+1))); // agents
    netDCof = par(i, N, dcblocker); // dc blockers
};
//process = FDNGN(4, 3); 

FDNG2(N, M) = si.bus(N * M) :> si.bus(N) : hadamard : 
    (netInsx : netNorm : netDCof : netLimt) ~ (hadamard : agnt)
with{
    hadamardnorm = 1.0 / sqrt(N); // norm for hadamard
    hadamardcoeff = par(i, N, hadamardnorm); // norm par
    hadamard = vecOp((ro.hadamard(N) , hadamardcoeff), *);
    netInsx = vecOp((si.bus(N) , si.bus(N)), +); // ins + fbs
    netNorm = par(i, N, RMSNorm(10, 10, .1, 10)); // norm + del
    netLimt = par(i, N, lookaheadLimiter(.8)); // signal limit
    agnt =  par(i, N, hgroup("Granulators", 
                    granular_sampling((i+1), 10, 2))); // agents
    netDCof = par(i, N, dcblocker); // dc blockers
};
//process = FDNGN2(4, 3); 