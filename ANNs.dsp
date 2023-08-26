// Import the standard Faust Libraries
import("stdfaust.lib");
// https://simonhutchinson.com/2022/05/11/music-and-synthesis-with-a-single-neuron/

// Onepole
onePoleTPT(cf, x) = loop ~ _ : ! , si.bus(3)
    with {
        g = tan(cf * ma.PI * ma.T);
        G = g / (1.0 + g);
        loop(s) = u , lp , hp , ap
            with {
            v = (x - s) * G; u = v + lp; lp = v + s; hp = x - lp; ap = lp - hp;
            };
    };

// Lowpass  TPT
LPTPT(cf, x) = onePoleTPT(cf, x) : (_ , ! , !);
// Highpass TPT
HPTPT(cf, x) = onePoleTPT(cf, x) : (! , _ , !);
// Allpass TPT
APTPT(cf, x) = onePoleTPT(cf, x) : (!, !, _);

// DC Blocker
dcblocker(zero, pole, x) = x : dcblockerout
            with{
                onezero =  _ <: _, mem : _,* (zero) : -;
                onepole = + ~ * (pole);
                dcblockerout = _ : onezero : onepole;
            };

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
multinoise(N) = par(i, N, noise(ba.take(i + 1, Primes)))
with{
    Primes = component("prime_numbers.dsp").primes;
};

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

// Random Signal
randomSig(i, minSec, maxSec) = 
    modSAH(minSec, maxSec, noise(ba.take(i + 1, Primes))) : ba.line(maxSec * ma.SR)
with{
    Primes = component("prime_numbers.dsp").primes;
};

// Weights of the Neurons with Auto-Modulated SAH 
neuronWeights(N, minSec, maxSec) = par(i, N, randomSig(i, minSec, maxSec)) : par(i, N, abs);
//process = neuronWeights(8, 6, 4);

// Vectorial Operations
vecOp(vectorsList, op) =
    vectorsList : seq(i, vecDim - 1, vecOp2D , vecBus(vecDim - 2 - i))
with{
    vecBus(0) = par(i, vecLen, 0 : !);
    vecBus(dim) = par(i, dim, si.bus(vecLen));
    vecOp2D = ro.interleave(vecLen, 2) : par(i, vecLen, op);
    vecDim = outputs(vectorsList) / vecLen;
    vecLen = outputs(ba.take(1, vectorsList));
};

// Neuron 
neuron(N, minSec, maxSec) = neuronFunction ~ _ 
with{
    fbFunction(x) = x * randomSig(110, minSec, maxSec);
    noiseFunction = LPTPT(2000, noise(18617)) * randomSig(120, minSec, maxSec);
    biasFunction = randomSig(100, minSec, maxSec);
    activationFunction(x) = x : ma.tanh : dcblocker(1, .995) : ma.tanh;
    wightsFunction = par(i, N, randomSig(i, minSec, maxSec)) : par(i, N, abs);
    neuronWeights = vecOp((si.bus(N), wightsFunction), *);
    neuronFunction(x) = neuronWeights :> 
        (_ + biasFunction + (x : fbFunction) + noiseFunction) : activationFunction;
};

// Oscs Bank
oscs(N) = par(i, N, os.osc(100 + (i * 30)));

// Neuron Mixer
neuronMixer(N, minSec, maxSec) = oscs(N) : neuron(N, 6, 4);

process = neuronMixer(8, 6, 4) <: si.bus(2);