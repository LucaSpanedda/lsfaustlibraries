// my standard library
import("stdls.lib");
                          
process = va.oscbank(va.buttoncounter(8),hslider("Freq",440,0,1024,1),0) <: _,_;