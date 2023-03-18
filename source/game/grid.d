module game.grid;

import raylib;

// @ todo : remove this and use the library implementation instead
struct Vector2 { 
    int x, y;
}

//  GameGrid:
//  store information about the game
//  grid structure, such as current
//  piece position and filled rows
//
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

    // used in drawing routine
    static const ushort squareSize  = 20;

    // allow adding a fade effect to fadding rows
    Color fadingColor;

    // actual grid which holds each square state
    State[gridRowSize][gridColSize] grid;
    alias grid this;
  
    // piece width/height in number of square
    static const pieceSquareSize = 4;
    Vector2 piecePosition;

    // ------------------------------
    // initialize game table with a 
    // blocking row at the end of the grid
    // and two columns at both sides
    // 
    void init()
    {
        for (int col = 0; col <= (gridColSize-1); col++)
        {
            for (int row = 0; row < gridRowSize; row++)
            {
                if (col == (gridColSize - 1))
                {
                    grid[col][row] = State.Block;
                    continue;
                }
                if (row == (gridRowSize - 1) || row == 0)
                {
                    grid[col][row] = State.Block;
                    continue;
                }

                grid[col][row] = State.Empty;
            }
        }
    }

    // ------------------------------
    // apply gravity effect over the piece
    //
    void moveVertical()
    {
        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        for (int col = y + pieceSquareSize; col >= y; col--)
        {
            for (int row = x; row < x + pieceSquareSize; row++)
            {
                if (col >= gridColSize || col < 0)
                {
                    continue;
                }

                if (row >= gridRowSize || row < 0)
                {
                    continue;
                }

                assert(row >= 0);
                assert(row < gridRowSize);

                if (grid[col][row] == State.Moving)
                {
                    grid[col+1][row] = State.Moving;
                    grid[col][row]   = State.Empty;
                }
            }
        }

        piecePosition.y++;
    }

    // -------------------------------
    // turn every colliding piece into filled blocks
    //
    void stopPiece()
    {
        const Vector2 offset = Vector2(
            piecePosition.x + pieceSquareSize,
            piecePosition.y + pieceSquareSize,
        );

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        for (int col = offset.y; col >= y; col--)
        {
            for (int row = x; row < offset.x; row++)
            {
                if (row >= gridRowSize || row < 0)
                {
                    continue;
                }

                if (col >= gridColSize)
                {
                    continue;
                }

                assert(row < gridRowSize);
                assert(col < gridColSize);

                if (grid[col][row] == State.Moving)
                {
                    grid[col][row] = State.Full;
                }
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition = Vector2(4, 17);
        testGrid.piecePosition = piecePosition;

        testGrid.grid[18][5] = State.Moving;

        testGrid.stopPiece();
        
        with(State)
        {
            assert(testGrid[18][5] == Full);
            assert(testGrid[19][5] == Block);
            assert(testGrid[18][6] == Empty);
            assert(testGrid[17][5] == Empty);
        }
    }
    
    // ------------------------------
    // check for any possible collision on the grid
    // and returns true if any have been found, false
    // otherwise
    //
    bool hasDetectedCollision()
    {
        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        for (int col = y; col < y + pieceSquareSize; col++)
        {
            for (int row = x; row < x + pieceSquareSize; row++)
            {
                if (row >= gridRowSize || row < 0)
                {
                    continue;
                }

                assert(row < gridRowSize);
                assert(row >= 0);
                
                with(State)
                {
                    int lowPiece            = grid[col+1][row];
                    bool isLowPieceBlocking =
                        lowPiece == Block || lowPiece == Full;

                    int current          = grid[col][row];
                    bool isCurrentMoving = current == Moving;

                    if (isCurrentMoving && isLowPieceBlocking)
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    unittest
    {
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition  = Vector2(4, 16);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
        
        with(State)
        {
        testGrid[18][5]        = Full;
        testGrid[y + 1][x + 1] = Moving;
        }

        bool isColliding = testGrid
            .hasDetectedCollision();

        assert(isColliding);
    }

    unittest
    {
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition  = Vector2(4, 17);
        testGrid.piecePosition = piecePosition;

        with(State)
        {
            testGrid[18][5] = Moving;
            assert(testGrid[19][5] == Block);
        }

        bool isColliding = testGrid
            .hasDetectedCollision();
        assert(isColliding);
    }

    unittest
    {
        GameGrid testGrid; 
        
        with(State)
        {
            testGrid[17][5] = Moving;
            assert(testGrid[18][5] == Empty);
        }

        bool isColliding = testGrid
            .hasDetectedCollision();
        assert(!isColliding);
    }

    // ------------------------------
    // turn every complete row into a 
    // fadding row
    //
    void markCompletion()
    {
    
        void markLineCompletion(int line)
        {
            for (int col = 1; col < (gridRowSize-1); col++)
            {
                grid[line][col] = State.Fading;
            }
        }
        for (int row = 1; row < (gridColSize - 1); row++)
        {
            bool hasFoundEmptySquare     = false;
            //bool hasFoundOnlyEmptySquare = true;

            for (int col = 1; col < gridRowSize; col++)
            {
                const auto current = grid[row][col];

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
                    markLineCompletion(row);
                }

                //if (current == State.Block && hasFoundOnlyEmptySquare)
                //    return;
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[18][col] = State.Full;
        }

        for (int col = 0; col < gridRowSize; col++)
        {
            assert(testGrid.grid[18][col] != State.Empty);
        }
        
        testGrid.grid[17][2] = State.Full;
        testGrid.grid[16][3] = State.Full;
        
        testGrid.markCompletion();

        // -- assertions --
        import std.format;

        for (int col = 1; col < (gridRowSize-1); col++)
        {
            const msg =
                format(">failed to assert colunm %d<", col);
            assert(testGrid.grid[18][col] == State.Fading, msg);
        }
        assert(testGrid.grid[17][2] == State.Full);
        assert(testGrid.grid[16][3] == State.Full);
    }

    void copyRow(int sourceRowIndex, int destRowIndex)
    {
        assert(sourceRowIndex >= 0);
        assert(destRowIndex   >= 0);

        for (auto count = 1; count < (gridRowSize-1); count++)
        {
            grid[destRowIndex][count] = grid[sourceRowIndex][count];
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize grid state -=-

        testGrid.grid[18][8] = State.Full;
        testGrid.grid[18][4] = State.Full;
        testGrid.grid[18][3] = State.Full;
        
        testGrid.grid[17][3] = State.Full;

        testGrid.grid[16][6] = State.Full;

        // -=- copy the row -=-

        testGrid.copyRow(16, 18);

        // -=- assertions -=-

        assert(testGrid.grid[18][8] == State.Empty);
        assert(testGrid.grid[18][4] == State.Empty);
        assert(testGrid.grid[18][3] == State.Empty);
        assert(testGrid.grid[18][6] == State.Full);

        assert(testGrid.grid[17][3] == State.Full);
        
    }
    
    void clearRow(int row)
    {
        for (auto count = 1; count < (gridRowSize-1); count++)
        {
            grid[row][count] = State.Empty;
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        // -=- initialize grid state -=-
        
        testGrid.grid[18][8] = State.Full;
        testGrid.grid[18][4] = State.Full;
        testGrid.grid[18][3] = State.Full;
        
        testGrid.grid[17][3] = State.Full;

        // -=- clear row -=-

        testGrid.clearRow(18);

        // -=- assertions -=-
        for (int count = 1; count < (gridRowSize-1); count++)
        {
            assert(testGrid.grid[18][count] == State.Empty);
        }

        assert(testGrid.grid[17][3] == State.Full);
        
    }

    bool isRowEmpty(uint row)
    {
        for (auto count = 0; count < (gridRowSize-1); count++)
        {
            const current = grid[row][count];
            if (current == State.Full || current == State.Fading)
            {
                return false;
            }
        }

        return true;
    }

    // ------------------------------
    // move rows based on map passed as
    // argument, with size delimited by
    // the limit parameter
    //
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

        testGrid.grid[18][1] = State.Full;
        testGrid.grid[17][2] = State.Full;
        testGrid.grid[16][3] = State.Full;
        testGrid.grid[15][4] = State.Full;
        testGrid.grid[14][5] = State.Full;
        testGrid.grid[13][6] = State.Full;
        testGrid.grid[12][7] = State.Full;
        testGrid.grid[11][8] = State.Full;

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

        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[18][col] = State.Fading;
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

        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[18][col] = State.Fading;
        }

        testGrid.grid[17][9] = State.Full;
        testGrid.grid[16][9] = State.Full;

        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[15][col] = State.Fading;
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
            for (auto count = (gridColSize-2); count > 0; count--)
            {
                clearRow(count);
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
        
        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[15][col] = State.Fading;
        }
        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[16][col] = State.Fading;
        }

        testGrid.grid[17][8] = State.Full;
        testGrid.grid[17][9] = State.Full;

        for (int col = 1; col < 11; col++)
        {
            testGrid.grid[18][col] = State.Fading;
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

        for (int col = 1; col < (GameGrid.gridRowSize - 1); col++)
        {
            testGrid.grid[18][col] = State.Fading;
        }
        for (int col = 1; col < (GameGrid.gridRowSize - 1); col++)
        {
            testGrid.grid[17][col] = State.Fading;
        }

        testGrid.removeFading();

        assert(testGrid.grid[18][4] == State.Empty);
        assert(testGrid.grid[18][3] == State.Empty);

        assert(testGrid.grid[17][4] == State.Empty);
        assert(testGrid.grid[17][8] == State.Empty);
    }
    
    bool canMoveHorizontally(const short direction)
    {
        Vector2 oppositeVertex;
        oppositeVertex.x = piecePosition.x + pieceSquareSize + direction;
        oppositeVertex.y = piecePosition.y + pieceSquareSize;

        for (auto col = piecePosition.y; col < oppositeVertex.y; col++)
        {
            for (auto row = piecePosition.x; row <= oppositeVertex.x; row++)
            {
                if (row >= gridRowSize || row < 0)
                {
                    continue;
                }

                if (row + direction < 0)
                {
                    continue;
                }

                if (row + direction >= gridRowSize)
                {
                    continue;
                }

                assert(row >= 0);
                assert(row + direction >= 0);
                assert(row < gridRowSize);

                const auto current = grid[col][row];
                const auto next    = grid[col][row + direction];
                const bool isNextBlocking =
                    next == State.Block || next == State.Full;

                if (isNextBlocking && current == State.Moving)
                {
                    return false;
                }
            }
        }
        return true;
    }

    unittest
    {
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition = Vector2(0, 4);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        with(State)
        {
            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 1] = Moving;
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 2] = Moving;

            assert(testGrid[y + 1][x] == Block);
            assert(testGrid[y + 2][x] == Block);
        }
        
        bool canMoveLeft = testGrid.canMoveHorizontally(-1);
        assert(!canMoveLeft);

        bool canMoveRight = testGrid.canMoveHorizontally(1);
        assert(canMoveRight);
    }

    unittest
    {
        // --- initialize test grid ---
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition = Vector2(5, 14);

        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        with(State)
        {
            for (int col = 1; col < (this.gridRowSize - 2); col++)
            {
                testGrid[18][col] = Full;
            }
            for (int row = 14; row < 18; row++)
            {
                testGrid[row][5] = Full;
            }

            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 1] = Moving;
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 2] = Moving;
        }

        bool canMoveLeft = testGrid.canMoveHorizontally(-1);
        assert(!canMoveLeft);

        bool canMoveRight = testGrid.canMoveHorizontally(1);
        assert(canMoveRight);
    }

    unittest
    {
        // --- initialize test grid ---
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition = Vector2(8, 14);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
        
        with(State)
        {
            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 1] = Moving;
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 2] = Moving;
        }

        bool canMoveLeft = testGrid.canMoveHorizontally(-1);
        assert(canMoveLeft);

        bool canMoveRight = testGrid.canMoveHorizontally(1);
        assert(!canMoveRight);
    }

    void moveHorizontal(int direction)
    {
        const x = piecePosition.x;
        const y = piecePosition.y;

        Vector2 opposite;
        opposite.x = x + GameGrid.pieceSquareSize + direction;
        opposite.y = y + GameGrid.pieceSquareSize;

        void moveLeft()
        {
            for (int col = y; col < opposite.y; col++)
            {
                for (int row = opposite.x + 1; row >= x; row--)
                {
                    if (row >= gridRowSize || row <= 1)
                    {
                        continue; 
                    }

                    assert(row < gridRowSize);

                    // @ todo
                    if (grid[col][row - 1] != State.Moving)
                    {
                        continue;
                    }

                    grid[col][row - 1] = State.Empty;
                    grid[col][row]     = State.Moving;
                }
            }
        }

        void moveRight()
        {
            assert(opposite.y     > 0);
            assert(opposite.x - 1 > 0);

            for (int col = y; col < opposite.y; col++)
            {
                for (auto row = x - 1; row <= opposite.x; row++)
                {
                    if (row + 1 >= gridRowSize || col < 0)
                    {
                        continue;
                    }

                    assert(col >= 0);
                    assert(row + 1 < gridRowSize);
                    
                    // @ todo
                    if (grid[col][row + 1] != State.Moving)
                    {
                        continue;
                    }

                    grid[col][row + 1] = State.Empty;
                    grid[col][row]     = State.Moving;
                }
            }
        }

        if (direction > 0)
        {
            moveLeft();
        } else {
            moveRight();
        }

        piecePosition.x += direction;
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition = Vector2(0, 4);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
        
        with(State)
        {
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 1] = Moving;
            testGrid[y + 2][x + 2] = Moving;
            testGrid[y + 2][x + 3] = Moving;

            testGrid.moveHorizontal(-1);

            assert(testGrid[y + 1][x + 1] == Moving);
            assert(testGrid[y + 2][x]     == Moving);
            assert(testGrid[y + 2][x + 1] == Moving);
            assert(testGrid[y + 2][x + 2] == Moving);
        }
    }


    unittest
    {
        GameGrid testGrid; 
        testGrid.init();

        Vector2 piecePosition = Vector2(5, 14);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
        
        with(State)
        {
            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 1] = Moving;
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 2] = Moving;

            testGrid.moveHorizontal(1);

            assert(testGrid[y + 1][x + 2] == Moving);
            assert(testGrid[y + 2][x + 2] == Moving);
            assert(testGrid[y + 1][x + 3] == Moving);
            assert(testGrid[y + 2][x + 3] == Moving);

            assert(testGrid.piecePosition.x == (x + 1));
        }
    }

    State[][] getPieceSlice()
    {
        int pieceSpaceHeight = pieceSquareSize;
        if (piecePosition.y + pieceSpaceHeight > GameGrid.gridColSize)
        {
            pieceSpaceHeight = GameGrid.gridColSize - piecePosition.y;
        }

        State[][] blocks = new State[][pieceSpaceHeight];

        int pieceSpaceWidth = piecePosition.x + pieceSquareSize;
        
        if (pieceSpaceWidth >= GameGrid.gridRowSize) 
        {
            for (auto counter = 0; counter < pieceSpaceHeight; counter++)
            {
                blocks[counter] = grid[piecePosition.y + counter][piecePosition.x .. $];
            }
        } else if (pieceSpaceWidth > pieceSquareSize) {
            for (auto counter = 0; counter < pieceSpaceHeight; counter++)
            {
                blocks[counter] = grid[piecePosition.y + counter][piecePosition.x .. pieceSpaceWidth];
            }
        } else {
            for (auto counter = 0; counter < pieceSpaceHeight; counter++)
            {
                blocks[counter] = grid[piecePosition.y + counter][0 .. pieceSpaceWidth];
            }
        }

        return blocks;
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition  = Vector2(5, 16);
        testGrid.piecePosition = piecePosition;
         
        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        with(State)
        {
            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 2] = Full;

            const auto pieceSpace = testGrid.getPieceSlice();

            assert(pieceSpace[1][1] == Moving);
            assert(pieceSpace[2][2] == Full);

            foreach (element; pieceSpace[3])
            {
                assert(element == Block);
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition  = Vector2(9, 16);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
         
        with(State)
        {
            testGrid[y][x]         = Moving;
            testGrid[y + 1][x + 1] = Full;

            const auto pieceSpace = testGrid.getPieceSlice();

            assert(pieceSpace[0][0] == Moving);
            assert(pieceSpace[1][1] == Full);

            foreach (row; pieceSpace)
            {
                assert(row[$ - 1] == Block);
                assert(row.length == 3);
            }
            
            foreach (element; pieceSpace[3])
            {
                assert(element == Block);
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition  = Vector2(-1, 16);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;

        with(State)
        {
            testGrid[y + 1][x + 2] = Moving;
            testGrid[y + 2][x + 3] = Full;

            const auto pieceSpace = testGrid.getPieceSlice();

            assert(pieceSpace[1][1] == Moving);
            assert(pieceSpace[2][2] == Full);

            foreach (row; pieceSpace)
            {
                assert(row[0] == Block);
                assert(row.length == 3);
            }
            
            foreach (element; pieceSpace[3])
            {
                assert(element == Block);
            }
        }
    }

    unittest
    {
        GameGrid testGrid;
        testGrid.init();

        Vector2 piecePosition  = Vector2(5, 16);
        testGrid.piecePosition = piecePosition;

        immutable x = piecePosition.x;
        immutable y = piecePosition.y;
         
        with(State)
        {
            testGrid[y + 1][x + 1] = Moving;
            testGrid[y + 2][x + 2] = Full;

            auto pieceSpace = testGrid.getPieceSlice();

            pieceSpace[1][2] = Moving;

            assert(testGrid[y + 1][x + 2] == Moving);
        }
    }

    void draw()
    {
        Vector2 offset;

        offset.x = 15 + (gridRowSize * squareSize / 2) - 50;
        offset.y = 15;

        const control = offset.x;

        void drawBlock(int state, int size , immutable Vector2 offset)
        {
            immutable x = offset.x;
            immutable y = offset.y;

            switch (state)
            {
            case State.Empty:
                DrawLine(
                    x + size, y, x + size, y + size, Colors.LIGHTGRAY
                );
                DrawLine(
                    x, y + size, x + size, y + size, Colors.LIGHTGRAY
                );
                DrawLine(
                    x, y, x, y + size, Colors.LIGHTGRAY
                );
                DrawLine(
                    x, y, x + size, y, Colors.LIGHTGRAY
                );
            break;
            case State.Full:
                DrawRectangle(
                    x, y, size, size, Colors.GRAY
                );
            break;
            case State.Block:
                DrawRectangle(
                    x, y, size, size, Colors.DARKGRAY
                );
            break;
            case State.Moving:
                DrawRectangle(
                    x, y, size, size, Colors.LIME
                );
            break;
            case State.Fading:
                DrawRectangle(
                    x, y, size, size, fadingColor
                );
            break;
            default: assert(0);
            }
        }
    

        for (int col = 0; col < gridColSize; col++)
        {
            for (int row = 0; row < gridRowSize; row++)
            {
                drawBlock(grid[col][row], squareSize, offset);
                offset.x += squareSize;
            }

           offset.x  = control;
           offset.y += squareSize;
        }
    }
}
