#language "lang/plush/0"

var time = import "core/time/0";
var audio = import "std/audio/0";
var random = import "std/random/0";

var dev = audio.AudioOut.new(44100, 1);
var filter = audio.Filter.new();
var delay = audio.Delay.new(10000);

// Work in progress!

var synthFn = function (time, freq)
{
    var env = audio.ADEnv(time, 0.01f, 0.25f);
    var v = audio.sawOsc(time, freq) * env;

    v = filter:apply(v, 0.6f, 0.0f);

    //var v2 = delay:read();
    //v = v * 0.75f + v2 * 0.25f;
    //delay:write(v);

    return v;
};

var genFn = function (time)
{
    return synthFn(time, 200);
};






var rootNote = audio.Note.get('A4');
var curNote = rootNote;

//dev:playSamples(audio.genNote(synthFn, curNote, dev.sampleRate, 0.4f));

var rng = random.newRNG(31333);

for (var i = 0; i < 16; i += 1)
{
    //print(curNote);

    dev:playSamples(audio.genNote(synthFn, curNote, dev.sampleRate, 0.3f));

    for (;;)
    {
        var newNote = rootNote:offset(rng:index(12));

        if (newNote == curNote)
        {
            continue;
        }

        if (newNote:consonance(curNote) >= 1)
        {
            curNote = newNote;
            break;
        }
    }
}

//playSound(genNote(genFn, A4_NOTE_NO, 1));
