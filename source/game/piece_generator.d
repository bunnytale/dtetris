module game.piece_generator;

import std.random;

// -----------------------------------
// generate pieces randomically
// 
class PieceGenerator
{
    enum PieceShape
    {
        I = 1,
        J,
        L,
        T,
        Z,
        O,
        S,
    }

    immutable defaultSeed = 42;
    Random generator;

    this(Random randomGen)
    {
        generator = randomGen;
    }
    this()
    {
        generator = Random(defaultSeed);
    }
    
    auto generatePieceShape()
    {
        return generator.uniform!PieceShape();
    }
}

unittest
{
    immutable seed  = 5;
    const generator = Random(seed);

    PieceGenerator gen = new PieceGenerator(generator);
    
    alias PieceShape = PieceGenerator.PieceShape;
    with(PieceGenerator.PieceShape)
    {
        PieceShape[] expectedResults = [L, Z, Z, I];

        for (auto count = 0; count < expectedResults.length; count++)
        {
            auto result = gen.generatePieceShape();
            assert(result == expectedResults[count]);
        }
    }
}
