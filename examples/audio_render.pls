#language "lang/plush/0"

var audio = import "core/audio/0";
var window = import "core/window/0";
var math = import "std/math/0";
var peval = import "std/peval/0";
var curry = peval.curry;
var curry2 = peval.curry2;
var curry3 = peval.curry3;

var dev = audio.open_output_device(1);

/// Produce sample a by sampling a function of time
var genSamples = function (sampleFun, numSeconds)
{
    var sampleRate = 44100;
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

    drawSound(samples);

    // Wait until the sound is done playing
    for (;;)
    {
        var queueSize = audio.get_queue_size(dev);
        if (queueSize == 0)
            break;
    }
};

var drawSound = function(samples)
{
    var width = 400;
    var height = 100;

    window.create_window("Sound Wave", width, height);

    print('drawing sound wave');

    var pixels = [];

    for (var y = 0; y < height; y += 1)
    {
        for (var x = 0; x < width; x += 1)
        {
            pixels:push(0);
            pixels:push(0);
            pixels:push(0);
        }
    }

    for (var i = 0; i < samples.length; i += 1)
    {
        var s = samples[i];
        s = math.min(s, 1.0f);
        s = math.max(s, -1.0f);

        var sy = math.floor((height - 1) * ((s + 1) / 2));
        var sx = math.floor(width * i / samples.length);

        var bufIdx = (3 * sy * width) + (3 * sx);
        pixels[bufIdx + 0] = 255;
        pixels[bufIdx + 1] = 255;
        pixels[bufIdx + 2] = 255;
    }

    print('done drawing');

    window.draw_pixels(pixels);

    // Wait until the user closes the window
    for (;;)
    {
        var result = window.process_events();
        if (result == false)
            break;
    }

    window.destroy_window();
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
