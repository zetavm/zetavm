#language "lang/plush/0"

var audio = import "std/audio/0";

audio.sawOsc(0, 100);
audio.sawOsc(0.0f, 100.0f);
audio.sinOsc(0.0f, 100.0f);
audio.triOsc(0.0f, 100.0f);
audio.ADEnv(0.5f, 0.5f, 1.0f);

var C4 = audio.Note.get(71);
assert (C4:getPC() == 11);
assert (C4:getOctNo() == 4);

var A4 = audio.Note.get('A4');
assert (A4:getOctNo() == 4);
assert (A4:getFreq(0) == 440);
assert (A4:consonance(A4) > 0);

var G4 = audio.Note.get('G4');
assert (G4:getFreq(0) > 391 && G4:getFreq(0) < 392);
