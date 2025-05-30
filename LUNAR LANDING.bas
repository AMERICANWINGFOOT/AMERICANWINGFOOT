' Lunar Lander Game Template for QB64 (Updated & Optimized)
Const LANDER_HEIGHT = 14 ' Total height from center to bottom of feet
Screen _NewImage(800, 600, 32) ' Set screen resolution to 800x600 with 32-bit color
_Title "LUNAR LANDING"

Const PI = 3.14159265358979

Dim Shared I(800) As Integer ' Array for terrain data
Dim Shared X As Single, Y As Single ' Position of the craft
Dim Shared CX As Single, CY As Single ' Velocity of the craft
Dim Shared FUEL As Single ' Fuel amount
Dim Shared MAKE As Integer, TRY As Integer ' Successful landings and attempts
Dim A$ ' User input string

Randomize Timer
Main ' Start the game

Sub Main
    Do
        InitializeGame
        GenerateTerrain
        GameLoop
        If Y + LANDER_HEIGHT > 590 Then ' off screen bottom
            TRY = TRY + 1
            DisplayGameOver "You crashed!"
            Sleep 2
        ElseIf CY <= 1.5 And Abs(CX) <= 1.5 And CheckLanding(Int(X)) And Y + LANDER_HEIGHT >= I(Int(X)) Then
            ' Successful landing
            MAKE = MAKE + 1
            TRY = TRY + 1
            DisplayGameOver "Successful landing!"
            Sleep 2
        Else ' Crashed
            TRY = TRY + 1
            DisplayGameOver "You crashed!"
            Sleep 2
        End If
    Loop
End Sub

Sub InitializeGame
    Cls
    Print "LUNAR LANDING"
    Print "Press any key to begin."
    _Display
    While InKey$ = ""
    Wend

    Input "Need instructions [Y/N] (DEF=N)? ", A$
    If A$ = "" Then A$ = "N"
    If UCase$(A$) = "Y" Then Instructions

    Cls
    TRY = 0
    MAKE = 0
    FUEL = 500
End Sub

Sub GenerateTerrain
    I(0) = Int(Rnd * 200) + 300 ' Random starting point for terrain

    For i = 1 To 799
        I(i) = I(i - 1) + (Rnd * 6) - 3
        If Rnd > 0.85 Then I(i) = I(i) + (Rnd * 14) - 7
        If I(i) < 200 Then
            I(i) = I(i) + 7
        ElseIf I(i) >= 400 Then
            I(i) = I(i) - 7
        End If
    Next i

    ' Smooth the terrain using a larger step size for bigger flat zones
    Dim stepSize As Integer
    stepSize = Int(Rnd * 20) + 30
    For i = 0 To 780 Step stepSize
        For j = 1 To stepSize - 1
            If i + j <= 799 Then I(i + j) = I(i)
        Next j
    Next i
End Sub

Sub GameLoop
    X = Int(Rnd * 800) ' Random starting position for the craft
    Y = 50 ' Initial height of the craft
    CX = (Rnd * 10 - 5) ' Horizontal velocity of the craft
    CY = Rnd * 3 + MAKE + 1 ' Vertical velocity of the craft

    Do
        Cls
        DrawTerrain
        DrawCraft X, Y
        Print "FUEL: "; FUEL; "   IN: "; MAKE; "   ATTEMPTS: "; TRY
        If FUEL < 50 Then Print , , "Fuel is low!"; ' Fuel warning
        _Display
        _Limit 60 ' Smooth gameplay (60 FPS)

        KINPUT = _KeyHit
        _Delay (.1)
        Select Case KINPUT
            Case 18432 ' Up arrow
                If FUEL >= 5 Then
                    CY = CY - .5
                    FUEL = FUEL - 5
                End If
            Case 20480 ' Down arrow
                If FUEL >= 3 Then
                    CY = CY + .5
                    FUEL = FUEL - 3
                End If
            Case 19200 ' Left arrow
                If FUEL >= 2 Then
                    CX = CX - .5
                    FUEL = FUEL - 2
                End If
            Case 19712 ' Right arrow
                If FUEL >= 2 Then
                    CX = CX + .5
                    FUEL = FUEL - 2
                End If
        End Select

        X = X + CX
        Y = Y + CY
        CY = CY + 0.1 ' Gravity

        If FUEL < 0 Then FUEL = 0
        If FUEL <= 0 Then
            CY = CY + 0.1 ' Continue applying gravity only
        End If
    Loop Until X < 0 Or X > 800 Or Y + LANDER_HEIGHT >= I(Int(X)) Or (Y + LANDER_HEIGHT >= I(Int(X)) And CheckLanding(Int(X)))

End Sub

Sub DrawTerrain
    Line (0, 599)-(799, 300), , B ' Background line to separate sky and ground
    For i = 0 To 798
        Line (i, I(i))-(i + 1, I(i + 1)), _RGB(255, 255, 255)
    Next i
End Sub

Sub DrawCraft (x As Single, y As Single)
    ' Body centered at (x, y - 5)
    Line (x - 5, y - 10)-(x + 5, y), _RGB(200, 200, 200), BF

    ' Legs go from body corners down to feet
    Line (x - 5, y)-(x - 10, y + 7), _RGB(180, 180, 180)
    Line (x + 5, y)-(x + 10, y + 7), _RGB(180, 180, 180)

    ' Antenna
    Line (x, y - 10)-(x, y - 17), _RGB(255, 255, 0)
    Circle (x, y - 19), 1, _RGB(255, 255, 0)

    ' Thrust flame when pressing up
    If _KeyDown(18432) Then
        Line (x - 2, y + 1)-(x + 2, y + 7), _RGB(255, 100, 0), BF
    End If
End Sub

Function CheckLanding (x As Integer)
    If x > 0 And x < 799 Then
        If I(x - 1) = I(x) And I(x + 1) = I(x) Then
            CheckLanding = -1 ' True: flat
        Else
            CheckLanding = 0 ' Not flat
        End If
    Else
        CheckLanding = 0 ' Out of bounds
    End If
End Function

Sub Instructions
    Cls
    Print "This is a simple lunar landing game."
    Print "Use the arrow keys to control the rocket:"
    Print "Up arrow: Increase upward thrust"
    Print "Down arrow: Increase downward thrust"
    Print "Left arrow: Increase leftward thrust"
    Print "Right arrow: Increase rightward thrust"
    Print
    Print "The goal is to land on a flat part of the landscape."
    Print "Thrust is cumulative, so pressing an arrow key increases thrust in that direction."
    Print
    Print "Fuel decreases with each use of thrust. Be careful not to run out of fuel."
    Print "The game gets harder with each successful landing."
    Print
    Print "Press RETURN to continue..."
    Input A$
End Sub

Sub DisplayGameOver (message As String)
    Cls
    Locate 12, 30
    Print message
    Locate 14, 30
    Print "Press any key to continue...";
    _Display
    While InKey$ = ""
    Wend
End Sub


