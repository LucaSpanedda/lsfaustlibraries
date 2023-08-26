// Import the standard Faust Libraries
import("stdfaust.lib");
// https://simonhutchinson.com/2022/05/11/music-and-synthesis-with-a-single-neuron/


// binary selector 0 - 1
selector(sel, x, y) = ( x * (1 - sel) + y * (sel));

// phasor with module
phasor(f) = (f : + ~ _ % ma.SR) / ma.SR;

// pseudo-random noise with linear congruential generator (LCG)
noise(initSeed) = LCG ~ _ : (_ / m)
with{
    // initSeed = an initial seed value
    a = 18446744073709551557; // a large prime number, 
        // such as 18446744073709551557
    c = 12345; // a small prime number, such as 12345
    m = 2 ^ 31; // 2.1 billion
    // linear_congruential_generator
    LCG(seed) = ((a * seed + c) + (initSeed - initSeed') % m);
};

// multinoise
multinoise(N) = par(i, N, noise(ba.take(i + 1, primes)));


// SAH with Feedback in FrequencyModulation
modSAH(minSec, maxSec, y) = out ~ _
with{
    ph(f, modf) = (f + modf : + ~ _ % ma.SR) / ma.SR;
    trigger(x) = x < x';
    minT = 1 / minSec;
    maxT = 1 / maxSec;
    iniTrig = 1 - 1';
    out(x) = (minT, abs(x * (maxT - minT))) : ph : trigger : (_ + iniTrig, x, y) : selector; //_ <: trigger;
};

// MOD Metro
randomMetro(minSec, maxSec, initSeed) = out
with{
    equalTrigger(x) = x * (1 - (x == x')); 
    out = noise(initSeed) : modSAH(minSec, maxSec) : equalTrigger;
};
process = randomMetro(1, .1, 12458923), randomMetro(1, .1, 22458923);

// ba.line(1000);
neuron(N) = ma.tanh( 
        par(i, N, _ * si.smoo(hslider("%i G", 1, 0, 10, .001))) :> _ + 
            si.smoo(hslider("bias", 0, -10, 10, .001)));
oscs(N) = par(i, N, os.osc(100 + (i * 30)));
//process = oscs(8) : neuron(8);