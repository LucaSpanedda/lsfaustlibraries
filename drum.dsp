// import Standard Faust library
import("stdfaust.lib");
noise(i_list) = 
            lcg ~ _ : (_ / m)
with{
            a = 18446744073709551557; c = 12345; m = 2 ^ 31;
            lcg(seed) = ((a * seed + c) + (initSeed - initSeed') % m);
            initSeed = ba.take((i_list + 1), (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37));
};
rndmclock = ba.sAndH(os.phasor(1, hslider("clock [style:knob]", 8, 0, 15, .001))
            : \(x).(x < x'), 
            abs(noise(10))) : si.smoo;
clock =     os.phasor(1,  hslider("clock [style:knob]", 8, 0, 15, .001)
            + rndmclock * hslider("randm [style:knob]", 1, 0, 15, .001)) : \(x).(x < x');
rndm(i) =   ba.sAndH(clock, abs(noise(i))) : si.smoo;
kik(i) =    ((os.phasor(1, rndm(i) * 10)) + 
            (abs(noise(i)) * .001 * rndm(i))) ^ - (1 + rndm(i)) : cos : _ 
            * (clock : + ~ _ * 
            hslider("decay [style:knob]", .996, .99, .9999, .0001)) : _ * rndm(i);
process =   hgroup("drum", kik(1), kik(2));