' QB64 Raycasting Maze Game - Corrected
$Resize:Stretch
' Constants for maze dimensions
Const MAZE_WIDTH = 10 * 4
Const MAZE_HEIGHT = 10 * 4
Dim Shared mini&
mini& = _NewImage(800, 600, 32)
' Constants for screen dimensions
Const SCREEN_WIDTH = 1024
Const SCREEN_HEIGHT = 768
Const MINIMAP_SIZE = 10
Const MINIMAP_TILE = 4

' Constants for raycasting
Const FOV = 3.1415926535 / 3 ' 60-degree field of view
Const MAX_DEPTH = 10 ' Maximum ray distance
Const PI = 3.1415926535

' Global/shared variables
Dim Shared playerX As Single, playerY As Single
Dim Shared playerAngle As Single
Dim Shared maze(1 To MAZE_WIDTH, 1 To MAZE_HEIGHT) As Integer
Dim Shared gameOver As Integer
Dim Shared MMD As _Byte
MMD = 1
' Set up graphics screen
Dim screenHandle As Long
screenHandle = _NewImage(SCREEN_WIDTH, SCREEN_HEIGHT, 32)
If screenHandle = 0 Then
    Print "Error: Failed to initialize graphics screen!"
    End
End If
Screen screenHandle
_Dest screenHandle

Call Main

' Initialize the maze with DFS for solvability
Sub InitMaze
    Randomize Timer
    Dim x As Integer, y As Integer
    Dim stackX(1 To MAZE_WIDTH * MAZE_HEIGHT) As Integer
    Dim stackY(1 To MAZE_WIDTH * MAZE_HEIGHT) As Integer
    Dim stackTop As Integer
    Dim neighbors(1 To 4, 1 To 2) As Integer
    Dim nCount As Integer

    ' Initialize maze with walls
    For x = 1 To MAZE_WIDTH
        For y = 1 To MAZE_HEIGHT
            maze(x, y) = 1
        Next y
    Next x

    ' Start at (1,1)
    playerX = 1.5
    playerY = 1.5
    maze(1, 1) = 0
    stackX(1) = 1
    stackY(1) = 1
    stackTop = 1

    ' DFS maze generation
    While stackTop > 0
        x = stackX(stackTop)
        y = stackY(stackTop)
        stackTop = stackTop - 1

        ' Get neighbors
        nCount = 0
        If x > 2 Then
            If maze(x - 2, y) = 1 Then
                nCount = nCount + 1
                neighbors(nCount, 1) = x - 2
                neighbors(nCount, 2) = y
            End If
        End If
        If x < MAZE_WIDTH - 1 Then
            If maze(x + 2, y) = 1 Then
                nCount = nCount + 1
                neighbors(nCount, 1) = x + 2
                neighbors(nCount, 2) = y
            End If
        End If
        If y > 2 Then
            If maze(x, y - 2) = 1 Then
                nCount = nCount + 1
                neighbors(nCount, 1) = x
                neighbors(nCount, 2) = y - 2
            End If
        End If
        If y < MAZE_HEIGHT - 1 Then
            If maze(x, y + 2) = 1 Then
                nCount = nCount + 1
                neighbors(nCount, 1) = x
                neighbors(nCount, 2) = y + 2
            End If
        End If

        ' Pick a random neighbor
        If nCount > 0 Then
            Dim pick As Integer
            pick = Int(Rnd * nCount) + 1
            Dim nx As Integer, ny As Integer
            nx = neighbors(pick, 1)
            ny = neighbors(pick, 2)

            ' Connect cells
            maze((x + nx) \ 2, (y + ny) \ 2) = 0
            maze(nx, ny) = 0

            ' Push back current cell and new cell
            stackTop = stackTop + 1
            stackX(stackTop) = x
            stackY(stackTop) = y
            stackTop = stackTop + 1
            stackX(stackTop) = nx
            stackY(stackTop) = ny
        End If
    Wend

    ' Ensure exit is a path
    maze(MAZE_WIDTH, MAZE_HEIGHT) = 0
    playerAngle = 0
End Sub

' Draw the scene using raycasting
Sub DrawScene
    _Display
    Cls
    Dim x As Integer

    For x = 0 To SCREEN_WIDTH - 1
        Dim rayAngle As Single
        rayAngle = playerAngle - FOV / 2 + (x / (SCREEN_WIDTH - 1)) * FOV

        Dim distance As Single
        Dim hitWall As Integer
        Dim mapX As Integer, mapY As Integer
        Dim rayX As Single, rayY As Single
        Dim side As Integer

        ' DDA setup
        Dim deltaDistX As Single, deltaDistY As Single
        Dim sideDistX As Single, sideDistY As Single
        Dim stepX As Integer, stepY As Integer
        Dim rayDirX As Single, rayDirY As Single

        rayDirX = Cos(rayAngle)
        rayDirY = Sin(rayAngle)

        If Abs(rayDirX) < 0.0001 Then rayDirX = Sgn(rayDirX) * 0.0001
        If Abs(rayDirY) < 0.0001 Then rayDirY = Sgn(rayDirY) * 0.0001

        mapX = Int(playerX)
        mapY = Int(playerY)

        deltaDistX = Abs(1 / rayDirX)
        deltaDistY = Abs(1 / rayDirY)

        If rayDirX < 0 Then
            stepX = -1
            sideDistX = (playerX - mapX) * deltaDistX
        Else
            stepX = 1
            sideDistX = (mapX + 1 - playerX) * deltaDistX
        End If

        If rayDirY < 0 Then
            stepY = -1
            sideDistY = (playerY - mapY) * deltaDistY
        Else
            stepY = 1
            sideDistY = (mapY + 1 - playerY) * deltaDistY
        End If

        hitWall = 0
        Dim steps As Integer: steps = 0
        Const MAX_STEPS = 200

        ' DDA loop: only calculate distance AFTER hit
        While hitWall = 0 And steps < MAX_STEPS
            steps = steps + 1
            If sideDistX < sideDistY Then
                sideDistX = sideDistX + deltaDistX
                mapX = mapX + stepX
                side = 1
            Else
                sideDistY = sideDistY + deltaDistY
                mapY = mapY + stepY
                side = 0
            End If

            If mapX < 1 Or mapX > MAZE_WIDTH Or mapY < 1 Or mapY > MAZE_HEIGHT Then
                hitWall = 1
                Exit While
            End If

            If maze(mapX, mapY) = 1 Then
                hitWall = 1
            End If
        Wend

        ' Now calculate accurate distance
        If side = 1 Then
            distance = (mapX - playerX + (1 - stepX) / 2) / rayDirX
        Else
            distance = (mapY - playerY + (1 - stepY) / 2) / rayDirY
        End If

        rayX = playerX + rayDirX * distance
        rayY = playerY + rayDirY * distance

        If hitWall Then
            ' Remove fish-eye effect
            distance = distance * Cos(rayAngle - playerAngle)
            If distance > MAX_DEPTH Then distance = MAX_DEPTH

            Dim wallHeight As Integer
            If distance > 0 Then
                wallHeight = (SCREEN_HEIGHT / (distance + 0.01))
            Else
                wallHeight = SCREEN_HEIGHT
            End If
            If wallHeight > SCREEN_HEIGHT Then wallHeight = SCREEN_HEIGHT

            Dim top As Integer, bottom As Integer
            top = (SCREEN_HEIGHT - wallHeight) / 2
            bottom = top + wallHeight
            If top < 0 Then top = 0
            If bottom > SCREEN_HEIGHT Then bottom = SCREEN_HEIGHT

            ' Smoothed shading: no sharp drop-offs
            Dim shade As Integer
            shade = 255 / (1 + distance * 0.4)
            If shade < 60 Then shade = 60

            If mapX = MAZE_WIDTH And mapY = MAZE_HEIGHT Then
                Line (x, top)-(x + 1, bottom), _RGB(0, shade, 0), BF
            ElseIf side = 0 Then
                Line (x, top)-(x + 1, bottom), _RGB(shade, shade / 2, shade / 2), BF
            Else
                Line (x, top)-(x + 1, bottom), _RGB(shade / 2, shade / 2, shade), BF
            End If

            ' Sky and floor
            Line (x, 0)-(x + 1, top), _RGB(50, 50, 100), BF
            Line (x, bottom)-(x + 1, SCREEN_HEIGHT), _RGB(50, 100, 50), BF
        End If
    Next x

    Rem If MMD Then GoTo over

    ' Draw minimap
    _Dest mini&
    For x = 1 To MAZE_WIDTH
        Dim y As Integer
        For y = 1 To MAZE_HEIGHT
            If maze(x, y) = 1 Then
                Line (x * MINIMAP_TILE, y * MINIMAP_TILE)-((x + 1) * MINIMAP_TILE - 1, (y + 1) * MINIMAP_TILE - 1), _RGB(0, 0, 255), BF
            Else
                Line (x * MINIMAP_TILE, y * MINIMAP_TILE)-((x + 1) * MINIMAP_TILE - 1, (y + 1) * MINIMAP_TILE - 1), _RGB(255, 255, 255), BF
            End If
        Next y
    Next x

    ' Draw player and exit
    Circle (playerX * MINIMAP_TILE, playerY * MINIMAP_TILE), 2, _RGB(255, 0, 0)
    Circle (MAZE_WIDTH * MINIMAP_TILE, MAZE_HEIGHT * MINIMAP_TILE), 2, _RGB(0, 255, 0)
    _ClipboardImage = mini&
    Rem over:
    _Dest screenHandle
    _Display
End Sub
' Move the player
Sub MovePlayer (moveSpeed As Single, rotSpeed As Single)
    Dim newX As Single, newY As Single
    Dim Keyboard As Long

    Keyboard = _KeyHit
    Select Case Keyboard
        Case 18432 ' Move forward
            newX = playerX + Cos(playerAngle) * moveSpeed
            newY = playerY + Sin(playerAngle) * moveSpeed
            If IsValidMove(newX, newY) Then
                playerX = newX
                playerY = newY
            End If
        Case 20480 ' Move backward
            newX = playerX - Cos(playerAngle) * moveSpeed
            newY = playerY - Sin(playerAngle) * moveSpeed
            If IsValidMove(newX, newY) Then
                playerX = newX
                playerY = newY
            End If
        Case 19200 ' Rotate left
            playerAngle = playerAngle - rotSpeed
            If playerAngle < 0 Then playerAngle = playerAngle + 2 * PI
        Case 100306 ' mini map display
            If MMD = 1 Then MMD = 0 Else MMD = 1
        Case 19712 ' Rotate right
            playerAngle = playerAngle + rotSpeed
            If playerAngle > 2 * PI Then playerAngle = playerAngle - 2 * PI
        Case 27 ' ESC to quit
            System: gameOver = 1
    End Select
End Sub

' Check if a move is valid (no wall collision)
Function IsValidMove (x As Single, y As Single)
    Dim mapX As Integer, mapY As Integer
    mapX = Int(x)
    mapY = Int(y)
    ' Add small buffer to prevent clipping
    If x < 0.2 Or x > MAZE_WIDTH - 0.2 Or y < 0.2 Or y > MAZE_HEIGHT - 0.2 Then
        IsValidMove = 0
        Exit Function
    End If
    If mapX >= 1 And mapX <= MAZE_WIDTH And mapY >= 1 And mapY <= MAZE_HEIGHT Then
        If maze(mapX, mapY) = 0 Then
            IsValidMove = -1 ' True
        Else
            IsValidMove = 0 ' False
        End If
    Else
        IsValidMove = 0 ' Out of bounds
    End If
End Function

' Main game loop
Sub Main
    InitMaze

    Do While Not gameOver
        DrawScene
        MovePlayer 0.1, 0.05 ' Move speed, rotation speed

        ' Check for win condition
        If Int(playerX) = MAZE_WIDTH And Int(playerY) = MAZE_HEIGHT Then
            Rem _Display
            Rem Cls
            Locate 10, 20
            Print "Congratulations! You escaped the maze!"
            gameOver = 1
            _Delay 3
        End If

        Rem _Limit 60 ' Cap at 60 FPS
    Loop
End Sub

