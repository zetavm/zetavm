#language "lang/plush/0"

var string = import("std/string/0");
var Book = {year: "",};
Book.yearAsInt = function(self)
{
  return string.parseInt(self.year, 10);
};
var myBook = Book::{year: "Not an int"};
try { Book.yearAsInt(myBook); } catch (e) {}
print("Exception Handled Successfully");
try { myBook:yearAsInt(); } catch (e) {}
print("Control does not reach here");