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

    static const gridRowSize = 12;
    static const gridColSize = 20;

    static const squareSize   = 20;

    Color fadingColor;;  

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

    void removeFading()
    {
        
        bool isRowEmpty(int row)
        {
            for (int colCounter = 0; colCounter < rowGridSize; colCounter++)
            {
                if (grid[row][colCounter] != State.Full && grid[row][colCounter] != State.Fading)
                {
                    return false; 
                }

            }

            return true;
        }
        ushort firstEmptyLine;
        for (counter = (rowGridSize-2); counter > 0; counter--)
        {
            if (isRowEmpty(counter))
            {
                firstEmptyLine = counter;
                break;
            }
        }

        ushort[gridColSize] permutation;  
        for (auto counter = 0; counter < ((gridColSize-1)-firstEmptyLine); counter++)
        {
            permutation[counter] = counter;
        }

        void decreaseRest(ref int[] value, ushort index, ushort limit)
        {
            for(int counter = index; counter < limit; counter++)
            {
                value[counter]--;
            }
        }
        for (int rowCounter = (GameGrid.gridColSize-1); rowCounter > firstEmptyLine; rowCounter--)
        {
            if (grid[rowCounter][1] == State.Fading)
            {
                decreaseRest(permutations, ((GameGrid.gridColSize-1) - rowCounter), firstEmptyLine);
            }
        }

        void applyPermutations(int[] permutations, int limit)
        {
            // @ todo
        }

    }


    unittest
    {
        GameGrid test_grid;
        test_grid.init();

        // --- full grid ---
        test_grid.grid[14][1] = State.Full;
        test_grid.grid[14][2] = State.Full;
        test_grid.grid[14][8] = State.Full;
        
        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            test_grid.grid[15][colCounter] = State.Fading;
        }
        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            test_grid.grid[16][colCounter] = State.Fading;
        }

        test_grid.grid[17][8] = State.Full;
        test_grid.grid[17][9] = State.Full;

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            test_grid.grid[18][colCounter] = State.Fading;
        }

        // --- remove fading lines --- 

       test_grid.removeFading();
       
       // --- do assertions ---

        for (int colCounter = 1; colCounter < 11; colCounter++)
        {
            assert(test_grid.grid[16][colCounter] == State.empty);
        }
        assert(test_grid.grid[17][1] == State.Full);
        assert(test_grid.grid[17][2] == State.Full);
        assert(test_grid.grid[17][8] == State.Full);
        assert(test_grid.grid[17][7] == State.Empty);

        assert(test_grid.grid[18][8] == State.Full);
        assert(test_grid.grid[18][9] == State.Full);
        assert(test_grid.grid[18][7] == State.Empty);

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
