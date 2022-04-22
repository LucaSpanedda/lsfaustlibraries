// FAUST standard library
import("stdfaust.lib");
// SPANEDDA standard library
import("SpaneddaSIG.lib");

process = SIG.Trainpulse(100) <: SIG.SAH(_,no.noise), _;