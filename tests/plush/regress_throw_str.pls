#language "lang/plush/0"

// This is a regression test to verify that uncaught exceptions that
// aren't objects are handled properly

throw "foobar";
