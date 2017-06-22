#language "lang/plush/0"

print("Trying to import random...");
// Import the random package
var random = import "std/random/0";
print("Imported random!");
print("Trying to create an RNG...");
var rng = random.newRNG(123);
print("Created an RNG!");

print(rng:fullInt());

//print("Dice using rng:int(1, 6)");
//// Generate 15 integers in [1, 6]
//for (var i = 0; i < 15; i += 1)
//{
//    print(rng:int(1,6));
//}
//print("\nRandom floats using rng:float(10, 12)");
//// Generate a float in [10,12[
//for (var i = 0; i < 15; i += 1)
//{
//    print(rng:float(10,12));
//}
//print("\nIndices using rng:index(5)");
//// Generate 15 integers in [1, 6]
//for (var i = 0; i < 15; i += 1)
//{
//    print(rng:index(5));
//}
