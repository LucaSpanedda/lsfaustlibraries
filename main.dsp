// Luca Spanedda's Faust Libraries Test File
import("stdls.lib");
Voices = 16;
process =   par(i, Voices, primeNoise(i));