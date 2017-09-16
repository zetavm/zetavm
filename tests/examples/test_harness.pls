#language "lang/plush/0"

/**
This is a test harness that replaces core libraries with shims/mocks.
This is used to automatically test example programs (found under /examples)
without creating a window or producing audio output. We do not test that
the output of the example programs is valid, but we can at least verify
that they run without producing compile errors or exceptions.
*/

try
{
    var vm = import "core/vm/0";
    var window = import "core/window/0";
    var audio = import "core/audio/0";
}
catch (e)
{
    // core/window and core/audio will fail to import if sdl2 is missing
    print("not configured with SDL2, skipping test");
    return;
}

var windowCreated = false;
var getEventCounter = 0;

window.create_window = function (name, width, height)
{
    windowCreated = true;
};

window.draw_bitmap = function (handle, bitmap)
{
};

window.get_next_event = function (handle)
{
    if (getEventCounter > 50)
        return { type: 'quit' };

    getEventCounter += 1;

    return false;
};

window.destroy_window = function (handle)
{
};

var audioCreated = false;
var queueSamplesCounter = 0;
var numSamples = 0;

audio.open_output_device = function (rate, channels)
{
    audioCreated = true;
};

audio.queue_samples = function (dev, samples)
{
    numSamples += samples.length;
    queueSamplesCounter += 1;
};

audio.get_queue_size = function (dev)
{
    numSamples = numSamples >> 1;
    return numSamples;
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var progName = args[1];

    var prog = vm.import(progName);

    if ('main' in prog)
    {
        if (prog.main.params.length == 0)
            prog.main();
        else if (progName:endsWith("audio_test.pls"))
            prog.main([progName, "4000", "4"]);
        else if (progName:endsWith("zeta_logo.pls"))
            prog.main([progName, "64"]);
        else
            assert (false, "unknown program");
    }

    assert (
        !windowCreated || getEventCounter > 0,
        "get_next_event was never called"
    );

    assert (
        !audioCreated || queueSamplesCounter > 0,
        "queue_samples was never called"
    );

    return 0;
};
