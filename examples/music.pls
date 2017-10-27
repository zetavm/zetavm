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

var genNotes = function (numNotes)
{
    var rootNote = Note.get('A4');
    var curNote = rootNote;

    var notes = [];

    for (; notes.length < numNotes;)
    {
        print(curNote:toString());
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

var notes = genNotes(16);

var dev = audio.AudioOut.new(44100, 1);
var filter = audio.Filter.new();
var delay = audio.Delay.new(5000);

var duration = 6;

var synthFn = function (time)
{
    idx = math.floor(notes.length * time / duration);
    var note = notes[idx];
    var freq = note:getFreq(0);

    var time = math.fmod(time, duration / notes.length);

    var env = audio.ADEnv(time, 0.01f, 0.25f);
    var v = audio.sawOsc(time, freq) * env;

    v = filter:apply(v, 0.6f, 0.0f);

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
