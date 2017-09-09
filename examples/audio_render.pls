#language "lang/plush/0"

var audio = import "core/audio/0";
var window = import "core/window/0";
var math = import "std/math/0";
var peval = import "std/peval/0";
var curry = peval.curry;
var curry2 = peval.curry2;
var curry3 = peval.curry3;

var sampleRate = 44100;
var dev = audio.open_output_device(44100, 1);

/// Produce sample a by sampling a function of time
var genSamples = function (sampleFun, numSeconds)
{
    var numSamples = numSeconds * sampleRate;
    var samples = [];

    for (var i = 0; i < numSamples; i += 1)
    {
        var t = numSeconds * (1.0f * i / numSamples);

        //print(t);

        var s = sampleFun(t);
        samples:push(s);
    }

    return samples;
};

/// Sample a sound-generating function and play back the result
var playSound = function (sampleFun, numSeconds)
{
    // Generate samples to play back
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

var silent = function (t)
{
    return 0.0f;
};

/// Produces a saw wave of a given frequency
var saw = function (freq)
{
    var f = function (time, freq)
    {
        var pos = time * freq;
        var ipos = $f32_to_i32(pos);
        var rem = pos - ipos;
        return -1 + 2.0f * rem;
    };

    return curry(f, freq);
};

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

var add = function (f1, f2)
{
    var f = function (time, f1, f2)
    {
        return f1(time) + f2(time);
    };

    return curry2(f, f1, f2);
};

var repeat = function (interv, f)
{
    var rf = function (time, f, interv)
    {
        var tmod = math.fmod(time, interv);
        return f(tmod);
    };

    return curry2(rf, f, interv);
};

var seq = function (interv, funs)
{
    var cat = function (t, interv, f1, f2)
    {
        if (t < interv)
            return f1(t);

        return f2(t - interv);
    };

    var f = silent;

    for (var i = funs.length - 1; i >= 0; i -= 1)
    {
        //print('cat');
        f = curry3(cat, interv, funs[i], f);
    }

    return f;
};

var pluck = function (freq)
{
    return mul(
        saw(freq/2.0f),
        ADEnv(0.005f, 0.1f)
    );
};

var sampleFun = seq(
    0.2f,
    [
        pluck(600),
        pluck(800),
        pluck(1000),
        pluck(800)
    ]
);

playSound(sampleFun, 1.0f);
