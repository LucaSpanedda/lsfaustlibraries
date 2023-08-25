// Import the standard Faust Libraries
import("stdfaust.lib");
// https://simonhutchinson.com/2022/05/11/music-and-synthesis-with-a-single-neuron/


// binary selector 0 - 1
selector(sel, x, y) = ( x * (1 - sel) + y * (sel) );
// SAH
SAH(ph, y) = \(FB1).( selector( ph : \(x).(x < x') + 1 - 1'', FB1, y ) )~ _ <: trigger;
range(slowestTsec, fastestTsec, x) = (1/slowestTsec) + (x * (1/fastestTsec));
trigger(x, y) = y * (1 - (x == x')); 
//process = os.osc(100) * (hslider("bias", 0, -10, 10, .001) : equal); 
probabilityTrig(slowT, fastT) = \(FB2).(os.phasor(1, range(slowT, fastT, FB2)), abs(no.noise) : SAH)~ _;
process = probabilityTrig(.1, .001); // : ba.line(200);

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
multinoise(N) = par(i, N, noise(ba.take(i + 1, primes)));

// ba.line(1000);
neuron(N) = ma.tanh( 
        par(i, N, _ * si.smoo(hslider("%i G", 1, 0, 10, .001))) :> _ + 
            si.smoo(hslider("bias", 0, -10, 10, .001)));
oscs(N) = par(i, N, os.osc(100 + (i * 30)));
//process = oscs(8) : neuron(8);