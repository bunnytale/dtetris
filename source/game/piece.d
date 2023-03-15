module game.piece;

import game.grid;

struct Piece
{
    alias State       = GameGrid.State;
    alias pieceLength = GameGrid.pieceSquareSize;
    State[pieceLength][pieceLength][] layoutList;

    uint currentLayout;

    void writeLayout(ref State[][] grid, in uint layout)
    {
        assert(layout < layoutList.length);

        for (auto col = 0; col < grid.length; col++)
        {
            for (auto row = 0; row < grid[col].length; row++)
            {
                if(layoutList[layout][col][row] == State.Empty)
                {
                    continue;
                }

                const element = grid[col][row];
                if (element == State.Full || element == State.Block)
                {
                    /// @todo : refactory this code later
                    assert(0);
                }
                grid[col][row] = State.Moving;
            }
        }
    }

    unittest
    {
        Piece testPiece;
        with(testPiece)
            layoutList = new State[pieceLength][pieceLength][2];

        /// write piece layouts
        for (auto col = 0; col < pieceLength; col++)
        {
            testPiece.layoutList[0][2][col] = State.Moving;
        }

        for (auto row = 0; row < pieceLength; row++)
        {
            testPiece.layoutList[1][row][1] = State.Moving;
        }
        
        State[][] fstLayout = new State[][pieceLength];
        for (auto col = 0; col < pieceLength; col++)
        {
            fstLayout[col] = new State[pieceLength];
        }

        testPiece.writeLayout(fstLayout, cast(uint) 0);

        State[][] sndLayout = new State[][pieceLength];
        for (auto col = 0; col < pieceLength; col++)
        {
            sndLayout[col] = new State[pieceLength];
        }

        testPiece.writeLayout(sndLayout, cast(uint) 1);

        /// make assertions

        for (auto col = 0; col < pieceLength; col++)
        {
            assert(fstLayout[0][col] == State.Empty);
            assert(fstLayout[1][col] == State.Empty);
            assert(fstLayout[2][col] == State.Moving);
            assert(fstLayout[3][col] == State.Empty);
        }

        for (auto row = 0; row < pieceLength; row++)
        {
            assert(sndLayout[row][0] == State.Empty);
            assert(sndLayout[row][1] == State.Moving);
            assert(sndLayout[row][2] == State.Empty);
            assert(sndLayout[row][3] == State.Empty);
        }
    }

    static pure void clearGrid(ref State[][] grid)
    {
        for (auto row = 0; row < grid.length; row++)
        {
            for (auto col = 0; col < grid[row].length; col++)
            {
                if (grid[row][col] != State.Moving)
                {
                    continue;
                }

                grid[row][col] = State.Empty;
            }
        }
    }

    unittest
    {
        State[][] gridSlice = new State[][pieceLength];
        for (auto col = 0; col < pieceLength; col++)
        {
            gridSlice[col] = new State[pieceLength];
        }

       gridSlice[3][0] = State.Full;
       gridSlice[2][0] = State.Full;
      
       gridSlice[2][2] = State.Moving;
       gridSlice[2][1] = State.Moving;
       gridSlice[1][1] = State.Moving;
       gridSlice[1][2] = State.Moving;

       Piece.clearGrid(gridSlice);

       assert(gridSlice[3][0] == State.Full);
       assert(gridSlice[2][0] == State.Full);

       assert(gridSlice[2][2] == State.Empty);
       assert(gridSlice[2][1] == State.Empty);
       assert(gridSlice[1][1] == State.Empty);
       assert(gridSlice[1][2] == State.Empty);
    }
}
