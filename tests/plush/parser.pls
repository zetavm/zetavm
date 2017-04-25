/// Test that the parsing of a string succeeds
var testParse = function (str)
{
    print(str);

    return parseString(str, "parser_test");

    /*
    try
    {
        return parseString(str, "parser_test");
    }

    catch (std::exception& e)
    {
        std::cout << e.what() << std::endl;
        exit(-1);
    }
    */
};

/*
/// Test that the parsing of a string fails
void testParseFail(std::string str)
{
    std::cout << str << std::endl;

    try
    {
        var unit = parseString(str, "parser_fail_test");
    }

    catch (ParseError e)
    {
        return;
    }

    std::cout << "parsing did not fail for: " << std::endl;
    std::cout << str << std::endl;
    exit(-1);
}
*/

/// Test that the parsing of a file succeeds
var testParseFile = function (fileName)
{
    print("parsing source file \"" + fileName + "\"");
    return parseFile(fileName);
};

/// Test the functionality of the parser
var testParser = function ()
{
    print("parser tests");

    // Identifiers
    testParse("foobar;");
    testParse("  foo_bar;  ");
    testParse("  foo_bar ; ");

    // Literals
    testParse("123;");
    testParse("'abc';");
    testParse("\"double-quoted string!\";");
    testParse("\"double-quoted string, 'hi'!\";");
    testParse("'hi'; // comment");
    testParse("'hi';");
    testParse("'new\\nline';");
    testParse("true;");
    testParse("false;");
    //testParseFail("'invalid\\iesc'");
    //testParseFail("'str' []");

    // Array literals
    testParse("[];");
    testParse("[1];");
    testParse("[1,a];");
    testParse("[1 , a];");
    testParse("[1,a, ];");
    testParse("[ 1,\na ];");
    //testParseFail("[,];");

    // Object literals
    testParse("var x = {x:3};");
    testParse("var x = {x:3,y:2};");
    testParse("var x = {x:3,y:2+z};");
    testParse("var x = {x:3,y:2+z,};");
    //testParseFail("var x = {,};");

    // Comments
    testParse("1; // comment");
    testParse("[ 1//comment\n,a ];");
    testParse("1 /* comment */ + x;");
    testParse("1 /* // comment */ + x;");
    //testParseFail("1; // comment\n#1");
    //testParseFail("1; /* */ */");

    // Unary and binary expressions
    testParse("-1;");
    testParse("-x + 2;");
    testParse("x + -1;");
    testParse("a + b;");
    testParse("a + b + c;");
    testParse("a + b - c;");
    testParse("a + b * c + d;");
    testParse("a || b || c;");
    testParse("a && b;");
    testParse("(a);");
    testParse("(b ) ;");
    testParse("(a + b);");
    testParse("(a + (b + c));");
    testParse("((a + b) + c);");
    testParse("(a + b) * (c + d);");
    //testParseFail("*a;");
    //testParseFail("a*;");
    //testParseFail("a # b;");
    //testParseFail("a +;");
    //testParseFail("a + b # c;");
    //testParseFail("(a;");
    //testParseFail("(a + b));");
    //testParseFail("((a + b);");

    // Member expression
    testParse("a.b;");
    testParse("a.b + c;");
    //testParseFail("a. b;");
    //testParseFail("a.'b';");

    // Array indexing
    testParse("a[0];");
    testParse("a[b];");
    testParse("a[b+2];");
    testParse("a[2*b+1];");
    //testParseFail("a[];");
    //testParseFail("a[0 1];");

    // If statement
    testParse("if (1) 2; ");
    testParse("if (1) return 2;");
    testParse("if (!x) return 1; else return 2;");
    testParse("if (x <= 2) return 0; ");
    testParse("if (x == 1) return 2; ");
    testParse("if (typeof x == 'string') return 2; ");
    testParse("if ('foo' in obj) return 1;");

    // For loop
    testParse("for (a; b; c) d;");
    testParse("for (a; b; c) continue;");
    testParse("for (a; b; c) break;");
    testParse("for (;;) d;");
    testParse("for (i = 0; i < 10; i = i + 1) x;");

    // Assignment
    testParse("x = 1;");
    testParse("x = -1;");
    testParse("a.b = x + y;");
    testParse("x = y = 1;");
    testParse("var x = 3;");
    testParse("x += 3;");
    //testParseFail("var");
    //testParseFail("let");
    //testParseFail("let x");
    //testParseFail("let x=");
    //testParseFail("var +");
    //testParseFail("var 3");

    // Call expressions
    testParse("a();");
    testParse("a(b);");
    testParse("a(b,c);");
    testParse("a(b,c+1);");
    testParse("a(b,c+1,);");
    testParse("x + a(b,c+1);");
    testParse("x + a(b,c+1) + y;");
    testParse("a(); b();");
    //testParseFail("a(b c+1);");

    // Package import
    testParse("var io = import 'core/io';");

    // Inline IR
    testParse("$add_i64(1, 2);");

    // Assert statement
    testParse("assert(x);");
    testParse("assert(x, 'foo');");
    //testParseFail("assert(x, 'foo', z);");

    // Function expression
    testParse("function () { return 0; }; ");
    testParse("function (x) {return x;};");
    testParse("function foo(x) { return x; };");
    testParse("function (x,y) { return x; };");
    testParse("function (x,y,) { return x; };");
    testParse("function (x,y) { return x+y; };");
    testParse("obj.method = function (this, x) { this.x = x; }; ");
    //testParseFail("function (x,y)");

    // Sequence/block expression
    testParse("{ 1; 2; }");
    testParse("function (x) { print(x); print(y); };");
    testParse("function (x) { var y = x + 1; print(y); };");
    //testParseFail("{ a, }");
    //testParseFail("{ a, b }");
    //testParseFail("function foo () { a, };");

    // Method calls
    testParse("o:foo();");
    testParse("o:foo(1,2);");
    testParse("x + o:foo(1,2);");
    //testParseFail("x + o:foo (1,2);");
    //testParseFail("x + o:foo (1,2);");
    //testParseFail("(o:foo)();");

    // There is no empty statement
    //testParseFail(";");

    // Regressions
    //testParseFail("'a' <'");

    // Now using plush parser package tests instead
    /*
    testParseFile("tests/plush/fib.pls");
    testParseFile("tests/plush/simple.pls");
    testParseFile("tests/plush/for_loop_break.pls");
    testParseFile("tests/plush/for_loop_cont.pls");
    testParseFile("tests/plush/fun_locals.pls");
    testParseFile("tests/plush/method_calls.pls");
    testParseFile("tests/plush/for_loop_sum.pls");
    testParseFile("tests/plush/array_push.pls");
    testParseFile("tests/plush/line_count.pls");
    testParseFile("tests/plush/obj_ext.pls");
    testParseFile("plush/runtime.pls");
    */
};

// Run the parser tests
testParser();
