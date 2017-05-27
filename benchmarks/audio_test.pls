var audio = import "core/audio";
var math = import "std/math";
var dev = audio.open_output_device(audio.STEREO);

audio.play(dev);

for (var i = 0;;i = i + 1) 
{
    var samples = [0, 10000000];
    audio.queue_samples(dev, samples);
    print(audio.get_queue_size(dev));
}


