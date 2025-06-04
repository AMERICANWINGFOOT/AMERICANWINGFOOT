$Debug
Const LANDER_HEIGHT = 14
Screen _NewImage(800, 600, 32)
_Title "LUNAR LANDING"

Const PI = 3.14159265358979
Const NUM_STARS = 100
Dim Shared StarX(1 To NUM_STARS) As Single
Dim Shared StarY(1 To NUM_STARS) As Single

Dim Shared terrainOffset As Single
Dim Shared I(0 To 900) As Integer
Dim Shared X As Single, Y As Single
Dim Shared CX As Single, CY As Single
Dim Shared FUEL As Single
Dim Shared MAKE As Integer, TRY As Integer
Dim A$
Type HighScoreEntry
    Name As String * 20
    Score As Integer
End Type

Dim Shared HighScores(1 To 10) As HighScoreEntry

Randomize Timer

Main

Sub Main
    Do
        InitializeGame
        GenerateTerrain
        GameLoop
        Dim terrainX As Integer
        terrainX = Int(X + terrainOffset)
        Print "CY:"; CY; " CX:"; CX; " Flat:"; CheckLanding(X); " Terrain Height:"; I(terrainX); " Y+LH:"; Y + LANDER_HEIGHT
        If Y + LANDER_HEIGHT >= I(terrainX) Then
            If CY <= 2.5 And Abs(CX) <= 2.5 And CheckLanding(X) Then
                MAKE = MAKE + 1
                TRY = TRY + 1
                DisplayGameOver "Successful landing!"
            Else
                TRY = TRY + 1
                Explosion X, Y
                DisplayGameOver "You crashed!"
            End If
        End If
    Loop
End Sub

Sub InitializeGame
    If _FileExists("scores.txt") Then
        Open "scores.txt" For Binary As #1
        Get #1, , HighScores()
        Close #1
    Else
        For i = 1 To 10
            HighScores(i).Name = "PLAYER"
            HighScores(i).Score = 0
        Next
        Open "scores.txt" For Binary As #1
        Put #1, , HighScores()
        Close #1
    End If

    Cls
    Print "LUNAR LANDING"
    Print "Press any key to begin."
    _Display
    While InKey$ = "": Wend
    Input "Need instructions [Y/N] (DEF=N)? ", A$
    If A$ = "" Then A$ = "N"
    If UCase$(A$) = "Y" Then Instructions
    Cls
    FUEL = 500
    For i = 1 To NUM_STARS
        StarX(i) = Rnd * 1600
        StarY(i) = Rnd * 300
    Next
End Sub

Sub GenerateTerrain
    I(0) = Int(Rnd * 200) + 300
    For i = 1 To 900
        I(i) = I(i - 1) + (Rnd * 6) - 3
        If Rnd > 0.85 Then I(i) = I(i) + (Rnd * 14) - 7
        If I(i) < 200 Then I(i) = I(i) + 7
        If I(i) > 400 Then I(i) = I(i) - 7
    Next i
    Dim stepSize As Integer
    stepSize = Int(Rnd * 20) + 50
    For i = 0 To 880 Step stepSize
        For j = 1 To stepSize - 1
            If i + j <= 900 Then I(i + j) = I(i)
        Next j
    Next i
    Dim flatCount As Integer
    For i = 1 To 899
        If I(i - 1) = I(i) And I(i + 1) = I(i) Then flatCount = flatCount + 1
    Next
    Print "Flat points: "; flatCount
End Sub

Sub GameLoop
    X = 400
    Y = 50
    CX = Rnd * 10 - 5
    CY = Rnd * 2 + MAKE + 1
    terrainOffset = Int(Rnd * (900 - 800))
    Do
        Cls
        DrawStars
        DrawTerrain
        DrawCraft X, Y
        Print "FUEL: "; FUEL; "   LANDINGS: "; MAKE; "   ATTEMPTS: "; TRY
        Print "Speed V:"; Mid$(Str$(CY), 1, 5); "  H:"; Mid$(Str$(Abs(CX)), 1, 5)
        Print "CX:"; CX; " terrainOffset:"; terrainOffset
        If FUEL < 50 Then Print , , "Fuel is low!"
        Line (700, 20)-(700 + FUEL * 0.5, 35), _RGB(0, 255, 0), BF
        Line (700, 20)-(950, 35), _RGB(255, 255, 255), B
        _Display
        _Limit 10
        KINPUT = _KeyHit
        Select Case KINPUT
            Case 18432 ' Up
                If FUEL >= 5 Then CY = CY - .5: FUEL = FUEL - 5
            Case 20480 ' Down
                If FUEL >= 3 Then CY = CY + .5: FUEL = FUEL - 3
            Case 19200 ' Left
                If FUEL >= 2 Then CX = CX - .5: FUEL = FUEL - 2
            Case 19712 ' Right
                If FUEL >= 2 Then CX = CX + .5: FUEL = FUEL - 2
        End Select
        CX = CX * 0.98
        terrainOffset = terrainOffset + CX * 0.5
        If terrainOffset < 0 Then terrainOffset = 0
        If terrainOffset > 800 Then terrainOffset = 800
        Y = Y + CY
        CY = CY + 0.1
        If FUEL < 0 Then FUEL = 0
        If FUEL <= 0 And Y + LANDER_HEIGHT >= I(Int(X + terrainOffset)) Then Exit Do
    Loop Until Y + LANDER_HEIGHT >= I(Int(X + terrainOffset))
End Sub

Sub DrawTerrain
    Dim col As _Unsigned Long
    For i = 1 To 798
        Dim terrainX As Integer
        terrainX = Int(i + terrainOffset)
        If terrainX >= 0 And terrainX < 899 Then
            If terrainX > 0 And terrainX < 899 And I(terrainX - 1) = I(terrainX) And I(terrainX + 1) = I(terrainX) Then
                col = _RGB(0, 255, 0)
            Else
                col = _RGB(255 - (I(terrainX) - 200) \ 2, 255 - (I(terrainX) - 200) \ 2, 255)
            End If
            If terrainX + 1 <= 899 Then
                Line (i, I(terrainX))-(i + 1, I(terrainX + 1)), col
            End If
        End If
    Next i
End Sub

Sub DrawCraft (x As Single, y As Single)
    ' Descent stage (boxy base, like Apollo LM)
    Line (x - 10, y - 8)-(x + 10, y - 8), _RGB(200, 200, 200)
    Line (x - 10, y - 8)-(x - 12, y), _RGB(200, 200, 200)
    Line (x + 10, y - 8)-(x + 12, y), _RGB(200, 200, 200)
    Line (x - 12, y)-(x + 12, y), _RGB(200, 200, 200)
    Line (x - 10, y - 8)-(x + 10, y), _RGB(180, 180, 180), BF

    ' Ascent stage (cockpit-like module)
    Line (x - 6, y - 12)-(x + 6, y - 12), _RGB(150, 150, 255)
    Line (x - 6, y - 12)-(x - 6, y - 8), _RGB(150, 150, 255)
    Line (x + 6, y - 12)-(x + 6, y - 8), _RGB(150, 150, 255)
    Line (x - 6, y - 8)-(x + 6, y - 8), _RGB(150, 150, 255)

    ' Landing legs (color changes if hard landing)
    Dim legColor As _Unsigned Long
    If CY > 2 Then legColor = _RGB(255, 100, 100) Else legColor = _RGB(160, 160, 160)
    Line (x - 12, y)-(x - 18, y + 14), legColor
    Line (x - 12, y)-(x - 16, y + 14), legColor
    Line (x + 12, y)-(x + 18, y + 14), legColor
    Line (x + 12, y)-(x + 16, y + 14), legColor
    Line (x - 20, y + 14)-(x - 16, y + 14), legColor
    Line (x + 16, y + 14)-(x + 20, y + 14), legColor

    ' Ladder
    Line (x - 10, y - 8)-(x - 10, y), _RGB(200, 200, 200)
    For i = -6 To -2 Step 2
        Line (x - 11, y + i)-(x - 9, y + i), _RGB(200, 200, 200)
    Next

    ' Gold foil accents
    Line (x - 10, y - 8)-(x - 12, y - 4), _RGB(255, 215, 0)
    Line (x + 10, y - 8)-(x + 12, y - 4), _RGB(255, 215, 0)

    ' Thruster
    If _KeyDown(18432) Then
        Dim flameLen As Single
        flameLen = 12 + Rnd * 2
        Line (x - 4, y)-(x - 6, y + flameLen), _RGB(255, 100, 0)
        Line (x + 4, y)-(x + 6, y + flameLen), _RGB(255, 100, 0)
        Line (x, y)-(x, y + flameLen + 2), _RGB(255, 150, 0)
        Line (x - 6, y + flameLen)-(x + 6, y + flameLen), _RGB(255, 100, 0)
        Circle (x, y + 2), 2, _RGB(200, 100, 0)
    End If

    ' Antenna
    Line (x, y - 12)-(x, y - 16), _RGB(200, 200, 200)
    Circle (x, y - 16), 1, _RGB(200, 200, 200)
End Sub

Function CheckLanding (screenX As Integer)
    Dim terrainX As Integer
    terrainX = Int(screenX + terrainOffset)
    If terrainX > 0 And terrainX < 899 Then
        If I(terrainX - 1) = I(terrainX) And I(terrainX + 1) = I(terrainX) Then
            CheckLanding = -1
        Else
            CheckLanding = 0
        End If
    Else
        CheckLanding = 0
    End If
End Function

Sub Instructions
    Cls
    Print "LUNAR LANDING"
    Print
    Print "Use the arrow keys to control your lander:"
    Print "UP: Thrust upward"
    Print "DOWN: Increase descent"
    Print "LEFT / RIGHT: Move horizontally"
    Print
    Print "Land gently on flat ground with:"
    Print "- Vertical speed < 2.5"
    Print "- Horizontal speed < 2.5"
    Print
    Print "Fuel is limited. Manage it carefully!"
    Print
    Input "Press RETURN to continue..."; A$
End Sub

Sub DisplayGameOver (message As String)
    Cls
    Dim score As Integer
    score = FUEL * 10 + (2.5 - Abs(CX)) * 100 + (2.5 - CY) * 100
    If message = "You crashed!" Then score = 0
    ' Save high score
    For i = 1 To 10
        If score > HighScores(i).Score Then
            For j = 10 To i + 1 Step -1
                HighScores(j) = HighScores(j - 1)
            Next
            HighScores(i).Name = InputName$
            HighScores(i).Score = score
            Open "scores.txt" For Binary As #1
            Put #1, , HighScores()
            Close #1
            Exit For
        End If
    Next
    Locate 12, 30: Print message
    Locate 13, 30: Print "Score: "; score
    Locate 14, 30: Print "Press any key to continue..."
    _Display
    While InKey$ = "": Wend
End Sub

Function InputName$
    Dim pname As String
    Locate 15, 30: Input "Enter your name: ", pname
    If pname = "" Then pname = "PLAYER"
    InputName$ = Left$(pname, 20)
End Function

Sub Explosion (x As Single, y As Single)
    For i = 1 To 20
        Circle (x + Rnd * 30 - 15, y + Rnd * 30 - 15), Rnd * 6 + 3, _RGB(255, Rnd * 255, 0)
        _Display
        _Delay 1 / 30
    Next i
End Sub

Sub DrawStars
    Dim i As Integer
    For i = 1 To NUM_STARS
        Dim sx As Single
        sx = StarX(i) - terrainOffset * 0.2
        If sx < 0 Then sx = sx + 1600
        If sx >= 0 And sx <= 799 Then
            PSet (sx, StarY(i)), _RGB(255, 255, 255)
        End If
    Next
End Sub

