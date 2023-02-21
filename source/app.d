import raylib;

import game: Game;

void main()
{
    validateRaylibBinding();
    InitWindow(800, 600, "hello, Raylib-d!");
    SetTargetFPS(60);

    auto mainGame = new Game;

    while (!WindowShouldClose())
    {
        BeginDrawing();

        mainGame.update();
        mainGame.drawFrame();

        EndDrawing();
    }
}
