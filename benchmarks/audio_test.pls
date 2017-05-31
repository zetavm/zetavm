var audio = import "core/audio";
var math = import "std/math/0";
var dev = audio.open_output_device(2);

for (var i = 0;;i = i + 1) 
{
    var samples = [1.0, 0.5];
    audio.queue_samples(dev, samples);
    print(audio.get_queue_size(dev));
}


