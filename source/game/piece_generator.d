module game.piece_generator;

import game.grid;
import game.piece;

import std.random;

// -----------------------------------
// generate pieces randomically
//
class PieceGenerator : PieceGenStrategy
{
	enum PieceShape
	{
		I = 1, J, L, T, Z, O, S,
	}

	alias State  = GameGrid.State;
	alias length = GameGrid.pieceSquareSize;
	alias Grid   = State[length][length];
	void delegate(out Grid[] grid)[PieceShape] pieceConfig;

	immutable defaultSeed = 42;
	Random generator;

	this(Random randomGen)
	{
		generator = randomGen;
		setPieceConfig();
	}
	this()
	{
		generator = Random(defaultSeed);
		setPieceConfig();
	}

	private void setPieceConfig()
	{
		with(State)
		{
			pieceConfig[PieceShape.I] = (out Grid[] grid)
			{
				grid = new State[length][length][2];

				grid = [
					[
						[Empty, Moving, Empty, Empty],
						[Empty, Moving, Empty, Empty],
						[Empty, Moving, Empty, Empty],
						[Empty, Moving, Empty, Empty],
					],
					[
						[Empty,  Empty,  Empty,  Empty],
						[Empty,  Empty,  Empty,  Empty],
						[Moving, Moving, Moving, Moving],
						[Empty,  Empty,  Empty,  Empty],
					],
				];
			};

			pieceConfig[PieceShape.L] = (out Grid[] grid)
			{
				grid = new State[length][length][4];

				grid = [
					[
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Moving, Moving],
						[Empty, Moving, Empty,  Empty],
						[Empty, Empty,  Empty,  Empty],
					],
					[
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Empty,  Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Empty,  Empty,  Moving],
						[Empty, Moving, Moving, Moving],
						[Empty, Empty,  Empty,  Empty],
					],
				];
			};

			pieceConfig[PieceShape.J] = (out Grid[] grid)
			{
				grid = new State[length][length][4];

				grid = [
					[
						[Empty, Empty,  Moving, Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Moving, Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Moving, Moving],
						[Empty, Empty,  Empty,  Empty],
					],
					[
						[Empty, Moving, Moving, Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
					],
					[
						[Empty,  Empty,  Empty,  Empty],
						[Moving, Moving, Moving, Empty],
						[Empty,  Empty,  Moving, Empty],
						[Empty,  Empty,  Empty,  Empty],
					],
				];
			};

			pieceConfig[PieceShape.T] = (out Grid[] grid)
			{
				grid = new Grid[4];

				grid = [
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Moving, Moving, Moving],
						[Empty, Empty,  Empty,  Empty],
					],
					[
						[Empty, Empty, Empty,  Empty],
						[Empty, Empty, Moving, Empty],
						[Empty, Empty, Moving, Moving],
						[Empty, Empty, Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Moving, Moving],
						[Empty, Empty,  Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Moving, Empty],
					],
				];
			};

			pieceConfig[PieceShape.Z] = (out Grid[] grid)
			{
				grid = new Grid[2];

				grid = [
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Moving, Moving],
						[Empty, Empty,  Empty,  Empty],
					],
					[
						[Empty, Empty,  Empty, Empty],
						[Empty, Empty,  Moving, Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Moving, Empty, Empty],
					],
				];
			};

			pieceConfig[PieceShape.S] = (out Grid[] grid)
			{
				grid = new Grid[2];

				grid = [
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Empty,  Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Moving, Empty],
					],
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Empty,  Moving, Moving],
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Empty,  Empty],
					],
				];
			};

			pieceConfig[PieceShape.O] = (out Grid[] grid)
			{
				grid = new Grid[1];

				grid = [
					[
						[Empty, Empty,  Empty,  Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Moving, Moving, Empty],
						[Empty, Empty,  Empty,  Empty],
					]
				];
			};
		}
	}
    
    Piece getRandomPiece() =>
        buildPiece(this.generatePieceShape());

    auto buildPiece(in PieceShape shape)
    {
        Piece piece;
        pieceConfig[shape](piece.layoutList);

        return piece;
    }

	auto generatePieceShape() => generator
		.uniform!PieceShape();
}

unittest
{
    auto generator = new PieceGenerator();
    
    const shape = generator.PieceShape.L;
    auto piece = generator.buildPiece(shape);

    assert(piece.layoutList.length == 4);
    // @ todo : write better assertions
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
