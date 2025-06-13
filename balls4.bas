Type tcircle
    x As Single
    y As Single
    size As Integer
    xdir As Single
    ydir As Single
    circlecolor As _Unsigned Long
    mass As Single ' Added for mass-based collisions
End Type

Dim number As Integer
number = 1000
Dim balls(number) As tcircle
Dim x As Integer, y As Integer
Dim screenx, screeny As _Unsigned Integer
Dim nx As Single, ny As Single
Dim dx As Single, dy As Single, dist As Single, minDist As Single
Dim tx As Single, ty As Single
Dim dpTan1 As Single, dpTan2 As Single
Dim dpNorm1 As Single, dpNorm2 As Single
Dim vx1 As Single, vy1 As Single, vx2 As Single, vy2 As Single
Dim overlap As Single
screenx = 1024
screeny = 768
Screen _NewImage(screenx, screeny, 32)
Randomize Timer

For x = 1 To number
    balls(x).size = Int(Rnd * 10) + 1
    balls(x).x = Int(Rnd * (screenx - balls(x).size * 2)) + balls(x).size
    balls(x).y = Int(Rnd * (screeny - balls(x).size * 2)) + balls(x).size
    balls(x).xdir = (Rnd - 0.5) * 6
    balls(x).ydir = (Rnd - 0.5) * 6
    balls(x).circlecolor = _RGB(Int(Rnd * 255), Int(Rnd * 255), Int(Rnd * 255))
    balls(x).mass = balls(x).size * balls(x).size ' Mass proportional to size^2
Next x

Do
    Cls

    ' --- Move and bounce off walls ---
    For x = 1 To number
        balls(x).x = balls(x).x + balls(x).xdir
        balls(x).y = balls(x).y + balls(x).ydir

        If balls(x).x < balls(x).size Then
            balls(x).x = balls(x).size
            balls(x).xdir = -balls(x).xdir
        ElseIf balls(x).x > screenx - balls(x).size Then
            balls(x).x = screenx - balls(x).size
            balls(x).xdir = -balls(x).xdir
        End If

        If balls(x).y < balls(x).size Then
            balls(x).y = balls(x).size
            balls(x).ydir = -balls(x).ydir
        ElseIf balls(x).y > screeny - balls(x).size Then
            balls(x).y = screeny - balls(x).size
            balls(x).ydir = -balls(x).ydir
        End If
    Next x

    ' --- Ball-to-ball collision detection and realistic response ---
    For x = 1 To number - 1
        For y = x + 1 To number
            dx = balls(x).x - balls(y).x
            dy = balls(x).y - balls(y).y
            dist = Sqr(dx * dx + dy * dy)
            minDist = balls(x).size + balls(y).size

            If dist < minDist And dist > 0 Then
                ' Normal vector
                nx = dx / dist
                ny = dy / dist

                ' Tangent vector
                tx = -ny
                ty = nx

                ' Dot product tangent (unchanged in elastic collision)
                dpTan1 = balls(x).xdir * tx + balls(x).ydir * ty
                dpTan2 = balls(y).xdir * tx + balls(y).ydir * ty

                ' Dot product normal (use mass-based collision formula)
                dpNorm1 = balls(x).xdir * nx + balls(x).ydir * ny
                dpNorm2 = balls(y).xdir * nx + balls(y).ydir * ny

                ' Masses
                m1 = balls(x).mass
                m2 = balls(y).mass

                ' New normal velocities (1D elastic collision with masses)
                v1 = (dpNorm1 * (m1 - m2) + 2 * m2 * dpNorm2) / (m1 + m2)
                v2 = (dpNorm2 * (m2 - m1) + 2 * m1 * dpNorm1) / (m1 + m2)

                ' Update velocities
                vx1 = tx * dpTan1 + nx * v1
                vy1 = ty * dpTan1 + ny * v1
                vx2 = tx * dpTan2 + nx * v2
                vy2 = ty * dpTan2 + ny * v2

                balls(x).xdir = vx1
                balls(x).ydir = vy1
                balls(y).xdir = vx2
                balls(y).ydir = vy2

                ' Separate overlapping balls
                overlap = 0.5 * (minDist - dist)
                balls(x).x = balls(x).x + nx * overlap
                balls(x).y = balls(x).y + ny * overlap
                balls(y).x = balls(y).x - nx * overlap
                balls(y).y = balls(y).y - ny * overlap
            End If
        Next y
    Next x

    ' --- Second pass: re-clamp to screen bounds ---
    For x = 1 To number
        If balls(x).x < balls(x).size Then
            balls(x).x = balls(x).size
            balls(x).xdir = -balls(x).xdir
        ElseIf balls(x).x > screenx - balls(x).size Then
            balls(x).x = screenx - balls(x).size
            balls(x).xdir = -balls(x).xdir
        End If

        If balls(x).y < balls(x).size Then
            balls(x).y = balls(x).size
            balls(x).ydir = -balls(x).ydir
        ElseIf balls(x).y > screeny - balls(x).size Then
            balls(x).y = screeny - balls(x).size
            balls(x).ydir = -balls(x).ydir
        End If
    Next x

    ' --- Draw Balls ---
    For x = 1 To number
        Circle (balls(x).x, balls(x).y), balls(x).size, balls(x).circlecolor
        Paint (balls(x).x, balls(x).y), balls(x).circlecolor, balls(x).circlecolor
    Next x

    _Display
Loop Until _KeyDown(27)

System

