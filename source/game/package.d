module game;

import raylib;

import game.grid: GameGrid, Vector2;
import game.piece: PieceGenStrategy, Piece;
import game.piece_generator;

class Game
{
    GameGrid grid;
    Piece currentPiece;

    bool isGameRunning;

    const lateralMoveTiming  = 5;
    auto  lateralMoveCounter = 0;

    int pieceFallTiming  = 40;
    int gravityTime      = 0;
    const fastFallTiming = 5;

    int respawnTiming    = 120;
    int spawnTimeCounter = 0;
    bool isPieceFalling  = true;

    const fadeTiming   = 40;
    auto  fadeCounter  = 0;
    bool isBlockFading = false;

    PieceGenStrategy generator;

    this()
    {
        grid.init();

        isGameRunning = true;

        initPieceGen(generator);
        spawnPiece();
    }

    void initPieceGen(out PieceGenStrategy pieceGen)
    {
        import std.random;

        /// @ todo : write code to get random seed from system
        immutable seed = 666;
        const auto rand = Random(seed);

        pieceGen = new PieceGenerator(rand);
    }

    void drawFrame()
    {
        ClearBackground(Colors.RAYWHITE);
        
        // +-- draw fps counter --+
        import std.format;
        import std.string;

        const auto text =
            toStringz(format("%d fps", GetFPS()));
        DrawText(text, 0, 0, 20, Colors.LIGHTGRAY);

        // +-- game grid --+
        grid.draw();
        
        if (isGameRunning)
        {
            return;
        }

        DrawText("GAME OVER!", 50, 50, 40, Colors.BLACK);
    }

    void update()
    {
        if (!isGameRunning)
        {
            return;
        }

        if (isBlockFading)
        {
            fadeCounter++;
        }

        if (isBlockFading && fadeCounter > fadeTiming)
        {
            isBlockFading = false;
            fadeCounter   = 0;
            
            grid.removeFading();
        }
        
        bool isSpawnTimerOver = spawnTimeCounter >= respawnTiming;
        if (!isPieceFalling && !isSpawnTimerOver)
        {
            spawnTimeCounter++;
            return;
        }

        const isTurnPressed = IsKeyPressed(KeyboardKey.KEY_UP);
        if(isTurnPressed)
        {
          turnPiece();
        }


        executeLateralMove();

        if (!isPieceFalling && isSpawnTimerOver)
        {
            spawnTimeCounter = 0;
            spawnPiece();

            isPieceFalling = true;
        }

        const isFastFallActive = IsKeyDown(KeyboardKey.KEY_DOWN);
        if (gravityTime >= pieceFallTiming && !isFastFallActive)
        {
            gravityTime = 0;
        } else if (gravityTime >= fastFallTiming && isFastFallActive)
        {
            gravityTime = 0;
        } else {
            gravityTime++;
            return;
        }

        if (grid.hasDetectedCollision())
        {
            grid.stopPiece();
            grid.markCompletion();

            isPieceFalling = false;
            isBlockFading  = true;
        }

        grid.moveVertical();
    }

    void executeLateralMove()
    {
        const bool isLeftPressed  =
            IsKeyPressed(KeyboardKey.KEY_LEFT);
        const bool isRightPressed =
            IsKeyPressed(KeyboardKey.KEY_RIGHT);
        
        if (isLeftPressed)
        {
            if (!grid.canMoveHorizontally(-1))
                return;

            grid.moveHorizontal(-1);
        } else if (isRightPressed)
        {
            if (!grid.canMoveHorizontally(1))
                return;

            grid.moveHorizontal(1);
        }
    }

    void turnPiece()
    {
        auto slices = grid.getPieceSlice();
        Piece.clearGrid(slices);

        const newLayout =
           (currentPiece.currentLayout + 1) % currentPiece.layoutList.length;

        if (!currentPiece.canWriteLayout(slices, newLayout))
        {
            currentPiece.currentLayout = newLayout;
        }
        
        currentPiece.writeLayout(slices, currentPiece.currentLayout);
    }

    void spawnPiece()
    {
        const auto piecePosition = Vector2(4, 0);
        grid.piecePosition = piecePosition;

        currentPiece = generator.getRandomPiece();

        auto slices = grid.getPieceSlice();
        if (currentPiece.canWriteLayout(slices, 0))
        {
            isGameRunning = false;
            return; 
        }

        currentPiece.writeLayout(slices, 0); 
    }
}

