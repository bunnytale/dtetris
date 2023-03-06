import raylib;

import game: Game;

void main()
{
    validateRaylibBinding();
    InitWindow(800, 600, "tetris");
    SetTargetFPS(60);

    auto mainGame = new Game;

    while (!WindowShouldClose())
    {
        mainGame.update();

        BeginDrawing();
        mainGame.drawFrame();

        EndDrawing();
    }
}
