module game;

import raylib;
import game.grid;

class Game
{
    GameGrid grid;

    const lateralMovementTiming  = 5;
    auto  lateralMovementCounter = 0;

    int pieceGravityTiming      = 40;
    int gravityTime             = 0;
    const fastFallGravityTiming = 5;

    int respawnTiming    = 120;
    int spawnTimeCounter = 0;
    bool isPieceFalling  = true;

    const fadeTiming   = 40;
    auto  fadeCounter  = 0;
    bool isBlockFading = false;

    this()
    {
        grid.init();

        spawnPiece();
        
        // --- debug ---
       for (auto counter = 1; counter < 10; counter++)
       {
            grid.grid[18][counter] = grid.State.Full;
       }
       for (auto counter = 1; counter < 10; counter++)
       {
            grid.grid[17][counter] = grid.State.Full;
       }
       for (auto counter = 1; counter < 10; counter++)
       {
            grid.grid[16][counter] = grid.State.Full;
       }
       for (auto counter = 1; counter < 10; counter++)
       {
            grid.grid[15][counter] = grid.State.Full;
       }
    }

    void drawFrame()
    {
        ClearBackground(Colors.RAYWHITE);
        
        // +-- draw fps counter --+
        import std.format;
        import std.string;

        const auto text = toStringz(format("%d fps", GetFPS()));
        DrawText(text, 0, 0, 20, Colors.LIGHTGRAY);

        // +-- game grid --+
        grid.draw();
    }

    void update()
    {
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

        executeLateralMove();

        if (!isPieceFalling && isSpawnTimerOver)
        {
            spawnTimeCounter = 0;
            spawnPiece();

            isPieceFalling = true;
        }

        const isFastFallActive = IsKeyDown(KeyboardKey.KEY_DOWN);
        if (gravityTime >= pieceGravityTiming && !isFastFallActive)
        {
            gravityTime = 0;
        } else if (gravityTime >= fastFallGravityTiming && isFastFallActive)
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
        const bool leftKeyPressed  = IsKeyPressed(KeyboardKey.KEY_LEFT);
        const bool rightKeyPressed = IsKeyPressed(KeyboardKey.KEY_RIGHT);
        
        if (leftKeyPressed)
        {
            if (!grid.canMoveHorizontally(-1))
                return;

            grid.moveHorizontal(-1);
        } else if (rightKeyPressed)
        {
            if (!grid.canMoveHorizontally(1))
                return;

            grid.moveHorizontal(1);
        }

        /* if (leftKeyPressed) */
        /* { */
        /*     lateralMovementCounter += 1; */
        /* } else if (rightKeyPressed) */
        /* { */
        /*     lateralMovementCounter += 1; */
        /* } else { */
        /*     lateralMovementCounter = 0; */
        /* } */

        /* const bool isLateralMoveCounterTimeout = lateralMovementCounter > lateralMovementTiming; */
        /* if (isLateralMoveCounterTimeout && leftKeyPressed) { */
        /*     grid.moveHorizontal(-1); */
        /*     lateralMovementCounter = 0; */
        /* } else */
        /* if (isLateralMoveCounterTimeout && rightKeyPressed) { */
        /*     grid.moveHorizontal(1); */
        /*     lateralMovementCounter = 0; */
        /* } */
    }

    void spawnPiece()
    {
        const auto piecePosition = game.grid.Vector2(4, 0);
        grid.piecePosition = piecePosition;

        grid.grid[piecePosition.y][piecePosition.x + 1]     = GameGrid.State.Moving;
        grid.grid[piecePosition.y + 1][piecePosition.x + 1] = GameGrid.State.Moving;
        grid.grid[piecePosition.y + 2][piecePosition.x + 1] = GameGrid.State.Moving;
        grid.grid[piecePosition.y + 3][piecePosition.x + 1] = GameGrid.State.Moving;
    }
}

