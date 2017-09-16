#language "lang/plush/0"

var audio = import "core/audio/0";
var math = import "std/math/0";
var string = import "std/string/0";

// Audio output sample rate
var sampleRate = 44100;

// Audio output buffer size
var bufSize = 16384;

/**
Generate audio samples to play back
*/
var genSamples = function (bufSize)
{
    var samples = [];

    // Sine wave frequency
    var freq = 300;
    var sinCoeff = freq * 2 * math.PI / sampleRate;

    for (var i = 0;; i = i + 1)
    {
        s = math.sin(i * sinCoeff);

        // Find a cutoff point that is near zero so the audio can loop
        if (i > bufSize && math.abs(s) < 0.002f)
            break;

        samples:push(s);
    }

    return samples;
};

/**
Main function, called when the program is run
*/
exports.main = function (args)
{
    // Minimum number of samples queued for playback
    var minQueueSize = 4400;
    if (args.length == 2)
    {
        minQueueSize = string.parseInt(args[1], 10);
        assert (minQueueSize > 2048 && minQueueSize < 65536);
    }
    print(string.format('minQueueSize={}', [minQueueSize]));

    // Number of iterations to test for
    var numItrs = math.INT32_MAX;
    if (args.length == 3)
    {
        numItrs = string.parseInt(args[2], 10);
    }

    // Open a mono (single-channel) audio device
    var dev = audio.open_output_device(44100, 1);

    // Generate a series of samples
    var samples = genSamples(minQueueSize);
    print(string.format('samples.length={}', [samples.length]));

    for (var itrCount = 0; itrCount < numItrs;)
    {
        var queueSize = audio.get_queue_size(dev);

        if (queueSize < minQueueSize)
        {
            audio.queue_samples(dev, samples);

            var newQueueSz = audio.get_queue_size(dev);
            output(queueSize);
            output(' => ');
            print(newQueueSz);

            itrCount += 1;
        }
    }

    return 0;
};
