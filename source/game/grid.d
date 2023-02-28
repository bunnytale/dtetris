module game.grid;

import raylib;

struct Vector2 { int x, y; }

struct GameGrid
{
    static enum State
    {
        Empty = 0,
        Full,
        Block,
        Moving,
        Fading,
    }

    static const ushort gridRowSize = 12;
    static const ushort gridColSize = 20;

    static const ushort squareSize   = 20;

    Color fadingColor;

    int[gridRowSize][gridColSize] grid;

    void init()
    {
        for (int colCounter = 0; colCounter <= (gridColSize-1); colCounter++)
        {
            for (int rowCounter = 0; rowCounter < gridRowSize; rowCounter++)
            {
                if (colCounter == (gridColSize - 1) || rowCounter == (gridRowSize - 1) || rowCounter == 0)
                {
                    grid[colCounter][rowCounter] = State.Block;
                } else {
                    grid[colCounter][rowCounter] = State.Empty;
                }
            }
        }
    }

    void move()
    {
        for (int colCounter = (gridColSize-1); colCounter >= 0; colCounter--)
        {
            for (int rowCounter = 0; rowCounter < gridRowSize; rowCounter++)
            {
               if (grid[colCounter][rowCounter] == State.Moving)
               {
                    grid[colCounter+1][rowCounter] = State.Moving;
                    grid[colCounter][rowCounter]   = State.Empty;
               }
            }

        }
    }

    void stopPiece()
    {
        for (int colCounter = 0; colCounter < (gridColSize-1); colCounter++)
        {
            for (int rowCounter = 0; rowCounter < gridRowSize; rowCounter++)
            {
                if (grid[colCounter][rowCounter] == State.Moving)
                {
                    grid[colCounter][rowCounter] = State.Full;
                }
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        testGrid.grid[18][5] = State.Moving;

        testGrid.stopPiece();
        
        assert(testGrid.grid[18][5] == State.Full);
        assert(testGrid.grid[19][5] == State.Block);
        assert(testGrid.grid[18][6] == State.Empty);
        assert(testGrid.grid[17][5] == State.Empty);
    }

    bool hasDetectedCollision()
    {
        for (int colCounter = (gridColSize-1); colCounter >= 1; colCounter--)
        {
            for (int rowCounter = 0; rowCounter < gridRowSize; rowCounter++)
            {
                bool is_upper_square_moving = grid[colCounter-1][rowCounter] == State.Moving;

                int current              = grid[colCounter][rowCounter];
                bool is_current_blocking = current == State.Full || current == State.Block;

                if (is_upper_square_moving && is_current_blocking)
                {
                    return true;
                }
            }
        }

        return false;
    }

    unittest
    {
        GameGrid test_grid; 
        
        test_grid.grid[18][5] = State.Full;
        test_grid.grid[17][5] = State.Moving;

        bool hasDetectedCollision = test_grid.hasDetectedCollision();
        assert(hasDetectedCollision);
    }

    unittest
    {
        GameGrid test_grid; 
        test_grid.init();

        test_grid.grid[18][5] = State.Moving;

        assert(test_grid.grid[19][5] == State.Block);

        bool hasDetectedCollision = test_grid.hasDetectedCollision();
        assert(hasDetectedCollision);
    }

    unittest
    {
        GameGrid test_grid; 
        
        test_grid.grid[17][5] = State.Moving;

        bool hasDetectedCollision = test_grid.hasDetectedCollision();
        assert(!hasDetectedCollision);
    }

    void markCompletion()
    {
    
        void markLineCompletion(int line)
        {
            for (int colCounter = 1; colCounter < (gridRowSize-1); colCounter++)
            {
                grid[line][colCounter] = State.Fading;
            }
        }
        for (int rowCounter = 1; rowCounter < (gridColSize - 1); rowCounter++)
        {
            bool hasFoundEmptySquare     = false;
            //bool hasFoundOnlyEmptySquare = true;

            for (int colCounter = 1; colCounter < gridRowSize; colCounter++)
            {
                const auto current = grid[rowCounter][colCounter];

                //if (current == State.Full && hasFoundOnlyEmptySquare)
                //{
                //    hasFoundOnlyEmptySquare = false;
                //}

                if (current == State.Empty)
                {
                    hasFoundEmptySquare = true;
                }

                if ((current == State.Block) && !hasFoundEmptySquare)
                {
                    markLineCompletion(rowCounter);
                }

                //if (current == State.Block && hasFoundOnlyEmptySquare)
                //    return;
            }
        }
    }

    unittest
    {
        GameGrid test_grid;
        test_grid.init();

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            test_grid.grid[18][colCounter] = State.Full;
        }

        for (int colCounter = 0; colCounter < GameGrid.gridRowSize; colCounter++)
        {
            assert(test_grid.grid[18][colCounter] != State.Empty);
        }
        
        test_grid.grid[17][2] = State.Full;
        test_grid.grid[16][3] = State.Full;
        
        test_grid.markCompletion();

        // -- assertions --
        import std.format;

        for (int colCounter = 1; colCounter < (GameGrid.gridRowSize-1); colCounter++)
        {
            const msg = format(">failed to assert colunm %d<", colCounter);
            assert(test_grid.grid[18][colCounter] == State.Fading, msg);
        }
        assert(test_grid.grid[17][2] == State.Full);
        assert(test_grid.grid[16][3] == State.Full);
    }

    void copyRow(int sourceRowIndex, int destRowIndex)
    {
        assert(sourceRowIndex >= 0);
        assert(destRowIndex   >= 0);

        for (auto counter = 1; counter < (GameGrid.gridRowSize-1); counter++)
        {
            grid[destRowIndex][counter] = grid[sourceRowIndex][counter];
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize grid state -=-

        testGrid.grid[18][8] = GameGrid.State.Full;
        testGrid.grid[18][4] = GameGrid.State.Full;
        testGrid.grid[18][3] = GameGrid.State.Full;
        
        testGrid.grid[17][3] = GameGrid.State.Full;

        testGrid.grid[16][6] = GameGrid.State.Full;

        // -=- copy the row -=-

        testGrid.copyRow(16, 18);

        // -=- assertions -=-

        assert(testGrid.grid[18][8] == GameGrid.State.Empty);
        assert(testGrid.grid[18][4] == GameGrid.State.Empty);
        assert(testGrid.grid[18][3] == GameGrid.State.Empty);
        assert(testGrid.grid[18][6] == GameGrid.State.Full);

        assert(testGrid.grid[17][3] == GameGrid.State.Full);
        
    }
    
    void clearRow(int row)
    {
        for (auto counter = 1; counter < (GameGrid.gridRowSize-1); counter++)
        {
            grid[row][counter] = State.Empty;
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize grid state -=-
        
        testGrid.grid[18][8] = GameGrid.State.Full;
        testGrid.grid[18][4] = GameGrid.State.Full;
        testGrid.grid[18][3] = GameGrid.State.Full;
        
        testGrid.grid[17][3] = GameGrid.State.Full;

        // -=- clear row -=-

        testGrid.clearRow(18);

        // -=- assertions -=-

        for (int counter = 1; counter < (GameGrid.gridRowSize-1); counter++)
        {
            assert(testGrid.grid[18][counter] == GameGrid.State.Empty);
        }

        assert(testGrid.grid[17][3] == GameGrid.State.Full);
        
    }

    bool isRowEmpty(uint row)
    {
        for (auto counter = 0; counter < (gridRowSize-1); counter++)
        {
            const current = grid[row][counter];
            if (current == GameGrid.State.Full || current == GameGrid.State.Fading)
            {
                return false;
            }
        }

        return true;
    }

    private void applyPermutations(ushort[gridColSize] permutations, uint limit)
    {
        int lastLine = 0;
        for (auto counter = 0; counter < limit; counter++)
        {
            const sourceRow = (gridColSize-2) - counter;
            const destRow   = (gridColSize-2) - permutations[counter];
            
            assert(grid[sourceRow][1] != State.Block);
            assert(grid[destRow][1]   != State.Block);

            assert(!isRowEmpty(sourceRow));

            copyRow(sourceRow, destRow);

            assert(grid[sourceRow] == grid[destRow]);
            lastLine = permutations[counter];
        }

        int clearCounter = 1;
        while ((lastLine + clearCounter) < limit)
        {
            const rowToClear = (gridColSize-2) - (lastLine + clearCounter);
            clearRow(rowToClear);
            clearCounter++;
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize game grid -=-

        testGrid.grid[18][1] = GameGrid.State.Full;
        testGrid.grid[17][2] = GameGrid.State.Full;
        testGrid.grid[16][3] = GameGrid.State.Full;
        testGrid.grid[15][4] = GameGrid.State.Full;
        testGrid.grid[14][5] = GameGrid.State.Full;
        testGrid.grid[13][6] = GameGrid.State.Full;
        testGrid.grid[12][7] = GameGrid.State.Full;
        testGrid.grid[11][8] = GameGrid.State.Full;

        // -=- call method -=-

        ushort[GameGrid.gridColSize] permutations = [
            0, 1, 2, 2, 3, 4, 5, 6, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
        ];
        testGrid.applyPermutations(permutations, 8);

        assert(testGrid.grid[18][1] == GameGrid.State.Full);
        assert(testGrid.grid[16][4] == GameGrid.State.Full);
        assert(testGrid.grid[15][5] == GameGrid.State.Full);
        assert(testGrid.grid[13][7] == GameGrid.State.Full);

        assert(testGrid.grid[11][8] == GameGrid.State.Empty);
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize game grid -=-

        testGrid.grid[18][1] = GameGrid.State.Full;
        testGrid.grid[17][2] = GameGrid.State.Full;
        testGrid.grid[16][3] = GameGrid.State.Full;
        testGrid.grid[15][4] = GameGrid.State.Full;
        testGrid.grid[14][8] = GameGrid.State.Full;

        // -=- call method -=-

        ushort[GameGrid.gridColSize] permutations = [
            0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
        ];
        testGrid.applyPermutations(permutations, 5);
        

        assert(testGrid.grid[18][1] == GameGrid.State.Empty);
        assert(testGrid.grid[18][2] == GameGrid.State.Full);
        assert(testGrid.grid[17][8] == GameGrid.State.Full);
        assert(testGrid.grid[14][8] == GameGrid.State.Empty);
    }

    private ushort firstEmptyRow()
    {
        for (ushort counter = (GameGrid.gridColSize - 2); counter >= 0; counter--)
        {
            if (!isRowEmpty(counter)) 
            {
                continue;
            }

            return counter;
        }

        assert(false);
    }
    
    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[18][colCounter] = State.Fading;
        }
        testGrid.grid[17][9] = State.Full;
        testGrid.grid[16][9] = State.Full;

        const firstEmptyLine = testGrid.firstEmptyRow();
        assert(firstEmptyLine == 15);
    }

    private ushort[gridColSize] fadingDeletionRowPermutations()
    {
        ushort[gridColSize] permutations;

        ushort fadingRows = 0;
        const firstEmptyRow = firstEmptyRow();
        for (ushort  counter = (GameGrid.gridColSize - 2); counter > firstEmptyRow; counter--)
        {
            import std.conv;

            int invertedCounter = GameGrid.gridColSize - 2 - counter;
            permutations[invertedCounter] = to!ushort(invertedCounter - fadingRows);

            if (grid[counter][1] == State.Fading)
            {
                fadingRows++;
            }
        }

        return permutations;
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[18][colCounter] = State.Fading;
        }

        testGrid.grid[17][9] = State.Full;
        testGrid.grid[16][9] = State.Full;

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[15][colCounter] = State.Fading;
        }

        testGrid.grid[14][9] = State.Full;

        const permutation = testGrid.fadingDeletionRowPermutations();

        const expectedPermutation = [
            0, 0, 1, 2, 2, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ];
        assert(permutation == expectedPermutation);
    }

    bool completedAllRows()
    {
        const auto firstEmptyLine = firstEmptyRow();

        for (auto counter = (GameGrid.gridColSize-2); counter > firstEmptyRow; counter--)
        {
            if (grid[counter][1] != State.Fading)
            {
                return false;
            }
        }
        return true;
    }

    void removeFading()
    {
        if (completedAllRows())
        {
            for (auto counter = (GameGrid.gridColSize-2); counter > 0; counter--)
            {
                clearRow(counter);
            }
        }

        const auto firstEmptyLine = firstEmptyRow();
        const auto permutations   = fadingDeletionRowPermutations();

        applyPermutations(permutations, ((gridColSize-2)-firstEmptyLine));
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // --- full grid ---
        testGrid.grid[14][1] = State.Full;
        testGrid.grid[14][2] = State.Full;
        testGrid.grid[14][8] = State.Full;
        
        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[15][colCounter] = State.Fading;
        }
        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[16][colCounter] = State.Fading;
        }

        testGrid.grid[17][8] = State.Full;
        testGrid.grid[17][9] = State.Full;

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            testGrid.grid[18][colCounter] = State.Fading;
        }

        // --- remove fading lines --- 

       testGrid.removeFading();
       
       // --- do assertions ---

       assert(testGrid.grid[18][8] == State.Full);
       assert(testGrid.grid[18][9] == State.Full);

       assert(testGrid.grid[17][1] == State.Full);
       assert(testGrid.grid[17][2] == State.Full);
       assert(testGrid.grid[17][8] == State.Full);
    }
       
    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        for (int colCounter = 1; colCounter < (GameGrid.gridRowSize - 1); colCounter++)
        {
            testGrid.grid[18][colCounter] = State.Fading;
        }
        for (int colCounter = 1; colCounter < (GameGrid.gridRowSize - 1); colCounter++)
        {
            testGrid.grid[17][colCounter] = State.Fading;
        }

        testGrid.removeFading();

        assert(testGrid.grid[18][4] == State.Empty);
        assert(testGrid.grid[18][3] == State.Empty);

        assert(testGrid.grid[17][4] == State.Empty);
        assert(testGrid.grid[17][8] == State.Empty);
    }

    void draw()
    {
        Vector2 offset;

        offset.x = 15 + (gridRowSize * squareSize / 2) - 50;
        offset.y = 15;

        const control = offset.x;

        void draw_block(int state, int size , Vector2 offset)
        {
          switch (state)
          {
          case State.Empty:
            DrawLine(offset.x + squareSize, offset.y, offset.x + squareSize, offset.y + squareSize, Colors.LIGHTGRAY);
            DrawLine(offset.x, offset.y + squareSize, offset.x + squareSize, offset.y + squareSize, Colors.LIGHTGRAY);
            DrawLine(offset.x, offset.y, offset.x, offset.y + squareSize, Colors.LIGHTGRAY);
            DrawLine(offset.x, offset.y, offset.x + squareSize, offset.y, Colors.LIGHTGRAY);
            break;
          case State.Full:
            DrawRectangle(offset.x, offset.y, squareSize, squareSize, Colors.GRAY);
            break;
          case State.Block:
            DrawRectangle(offset.x, offset.y, squareSize, squareSize, Colors.DARKGRAY);
            break;
          case State.Moving:
            DrawRectangle(offset.x, offset.y, squareSize, squareSize, Colors.LIME);
            break;
          case State.Fading:
            DrawRectangle(offset.x, offset.y, squareSize, squareSize, fadingColor);
            break;
          default: assert(0);
          }
        }

        for (int colCounter = 0; colCounter < gridColSize; colCounter++)
        {
            for (int rowCounter = 0; rowCounter < gridRowSize; rowCounter++)
            {
                draw_block(grid[colCounter][rowCounter], squareSize, offset);
                offset.x += squareSize;
            }

           offset.x  = control;
           offset.y += squareSize;
        }
    }
}
