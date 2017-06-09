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
    return curry(curry(f, y), x);
};

// TODO: saw wave

/// Produces a sine wave of a given frequency
var sine = function (freq)
{
    var f = function (time, freq)
    {
        return math.sin(time * freq * 2 * math.PI);
    };

    return curry(f, freq);
};

/// Attack-decay envelope
var ADEnv = function (attack, decay)
{
    var f = function (time, attack, decay)
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

    return curry2(f, attack, decay);
};

var mul = function (f1, f2)
{
    var f = function (time, f1, f2)
    {
        return f1(time) * f2(time);
    };

    return curry2(f, f1, f2);
};

var repeat = function (mod, f)
{
    var rf = function (time, f, mod)
    {
        var quot = time / mod;
        var tquot = $f32_to_i32(quot);
        var fmod = time - tquot * mod;
        return f(fmod);
    };

    return curry2(rf, f, mod);
};

var sampleFun = repeat(
    0.22,
    mul(
        sine(600),
        ADEnv(0.02, 0.1)
    )
);










playSound(sampleFun, 1.0);
