#language "lang/plush/0"

exports.main = function (args)
{
    assert (args.length == 3);
    assert (args[1] == 'foo');
    assert (args[2] == 'bar');
    return 0;
};
