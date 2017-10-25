#language "lang/plush/0"

// Import the random package
var random = import "std/random/0";

var rng = random.newRNG(31337);
var grng = random.globalRNG;

var cardValues = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"];

var cardSuits = ["Hearts", "Clubs", "Diamonds", "Spades"];

var card = function()
{
   return grng:select(cardValues) + " of " + grng:select(cardSuits);
};

print("Trying random ints in the full range using rng:fullInt():");
// Generate 10 random integers
for (var i = 0; i < 10; i += 1)
{
    output(rng:fullInt());
    output(" ");
}

print("\nTrying dice using rng:int(1, 6):");
// Generate 10 integers in [1, 6]
for (var i = 0; i < 30; i += 1)
{
    output(rng:int(1,6));
    output(" ");
}

print("\nTrying random floats using rng:float(10, 12):");
// Generate a float in [10,12[
for (var i = 0; i < 10; i += 1)
{
    output(rng:float(10,12));
    output(" ");
}

print("\nTrying indices using rng:index(5):");
// Generate 10 integers in [1, 5[
for (var i = 0; i < 10; i += 1)
{
    output(rng:index(5));
    output(" ");
}

print("\nDrawing some cards:");
// Generate 8 cards as strings, each with a random number/face value and suit
for (var i = 0; i < 7; i += 1)
{
    output(card());
    output(", ");
}
output(card());

var rng1 = random.newRNG(1234567);
var rng2 = random.newRNG(1234567);

for (var i = 0; i < 500; i += 1)
{
    assert(rng1:fullInt() == rng2:fullInt(), "Identical seeds must not produce different sequences.");
}

for (var i = 0; i < 500; i += 1)
{
    assert(rng1:smallFloat() == rng2:smallFloat(), "Identical seeds must not produce different sequences.");
}

print("\nDone with random number generation.");
