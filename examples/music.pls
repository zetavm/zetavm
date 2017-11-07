#language "lang/plush/0"

//
// This is a work in progress!
//

var time = import "core/time/0";
var audio = import "std/audio/0";
var random = import "std/random/0";
var math = import "std/math/0";

var Note = audio.Note;
var rng = random.newRNG(31333);
var dev = audio.AudioOut.new(44100, 1);




var filter = audio.Filter.new();

var kickFn = function (time)
{
    var env = audio.ADEnv(time, 0.005f, 0.20f);

    var f = audio.eerp(time / 0.20f, 220, 80, 0.3f);
    var v = audio.sinOsc(time, f) * env;

    //v = filter:apply(v, 0.5f, 0);

    return v;
};

var snareFn = function (time)
{
    var env = audio.ADEnv(time, 0.005f, 0.10f);
    var f = audio.eerp(time / 0.20f, 220, 80, 0.15f);
    var v = audio.sinOsc(time, f) * env;



    var env = audio.ADEnv(time, 0.005f, 0.35f);
    var noise = rng:float(-1, 1);
    noise = filter:apply(noise, 0.75f, 0.1f) * env;

    v = 0.5f * noise + 0.5f * v;



    return v;
};

dev:playFn(kickFn, 0.4f);
dev:playFn(snareFn, 0.4f);
//dev:playFn(kickFn, 0.4f);
//dev:playFn(snareFn, 0.4f);

//return;









var genNotes = function (numNotes)
{
    var rootNote = Note.get('A3');
    var curNote = rootNote;

    var notes = [];

    for (; notes.length < numNotes;)
    {
        print(curNote);
        notes:push(curNote);

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

    return notes;
};

var notes = genNotes(8);
var duration = 1.6f;

var filter = audio.Filter.new();
var delay = audio.Delay.new(5000);

var synthFn = function (time)
{
    idx = math.floor(notes.length * time / duration);
    var note = notes[idx];
    var freq = note:getFreq(0);

    var time = math.fmod(time, duration / notes.length);

    var env = audio.ADEnv(time, 0.005f, 0.14f);
    var v = audio.triOsc(time, freq) * env;

    v = filter:apply(v, 0.7f, 0.1f);

    //var v2 = delay:read();
    //v = v * 0.5f + v2 * 0.5f;
    //delay:write(v);

    return v;
};

var startTime = time.get_time_millis();
var samples = audio.genSamples(synthFn, dev.sampleRate, duration);
var endTime = time.get_time_millis();

print('Audio generation time: {} ms':format([endTime - startTime]));

dev:playSamples(samples);
dev:playFn(function (time) { return 0.0f; }, 0.2f);
