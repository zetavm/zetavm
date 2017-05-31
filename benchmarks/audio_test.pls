#language "lang/plush/0"

var audio = import "core/audio";
var math = import "std/math/0";
var dev = audio.open_output_device(2);

var sampleRate = 44100;
var bufSize = 16384;
var freq = 200;
var sinCoeff = freq * 2 * math.PI / sampleRate;

var genSamples = function ()
{
    var samples = [];

    for (var i = 0;; i = i + 1)
    {
        s = math.sin(i * sinCoeff);

        // Try to find a cutoff point that is near zero so the audio can loop
        if (i > bufSize && math.abs(s) < 0.002)
            break;

        samples:push(s);
    }

    return samples;
};

var samples = genSamples();

for (;;)
{
    var queueSize = audio.get_queue_size(dev);

    //print(queueSize);

    if (queueSize < 16384)
    {
        print(queueSize);
        audio.queue_samples(dev, samples);
    }
}
