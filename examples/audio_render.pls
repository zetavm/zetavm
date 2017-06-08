#language "lang/plush/0"

var audio = import "core/audio";
var math = import "std/math/0";
var peval = import "std/peval";
var curry = peval.curry;
var dev = audio.open_output_device(1);

var genSamples = function (sampleFun, numSeconds)
{
    var sampleRate = 44100;
    var numSamples = numSeconds * sampleRate;
    var samples = [];

    for (var i = 0; i < numSamples; i += 1)
    {
        var t = numSeconds * (1.0 * i / numSamples);

        print(t);

        var s = sampleFun(t);
        samples:push(s);
    }

    return samples;
};

var playSound = function (sampleFun, numSeconds)
{
    var samples = genSamples(sampleFun, numSeconds);
    audio.queue_samples(dev, samples);

    // Wait until the sound is done playing
    for (;;)
    {
        var queueSize = audio.get_queue_size(dev);
        if (queueSize == 0)
            break;
    }
};

// TODO: move to peval package
var curry2 = function (f, x, y)
{
    return curry(f, curry(f, y), x);
};

/// Produces a sine wave of a given frequency
var sine = function (time, freq)
{
    return math.sin(time * freq * 2 * math.PI);
};

// TODO: saw wave

/// Attack-decay envelope
var ADEnv = function (time, attack, decay)
{
    if (time < attack)
    {
        return time / attack;
    }

    time = time - attack;

    if (time < decay)
    {
        return 1 - (time / decay);
    }

    return 0;
};

// TODO: mul function

var sampleFun = curry(sine, 300);










playSound(sampleFun, 1.5);
