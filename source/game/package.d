module game;

import raylib;
import game.grid;

class Game
{
    GameGrid grid;

    int pieceGravityTiming = 40;
    int gravityTime        = 0;

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
        if (!isPieceFalling && isSpawnTimerOver)
        {
            spawnTimeCounter = 0;
            
            spawnPiece();
        }

        if (gravityTime == pieceGravityTiming)
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

    void spawnPiece()
    {
        isPieceFalling = true;

        grid.grid[2][10] = grid.State.Moving;
    }
}

