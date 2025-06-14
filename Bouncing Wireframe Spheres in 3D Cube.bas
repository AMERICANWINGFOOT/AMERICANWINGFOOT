Screen _NewImage(1024, 768, 32)
_FullScreen
_Title "Bouncing Wireframe Spheres in 3D Cube with Grid"

' === CONFIGURATION ===
Const Pi = 3.14159265
Const NumSpheres = 100
Const Segments = 20
Const Radius = 50
Const WorldSize = 800
Const ScreenCX = 512
Const ScreenCY = 384
Const CamZ = -1000
Const Scale = 700
Const FPS = 60

Dim Shared colorLine As Long: colorLine = _RGB32(0, 255, 255)
Dim Shared gridColor As Long: gridColor = _RGB32(255, 255, 255)

Type Sphere
    x As Single
    y As Single
    z As Single
    dx As Single
    dy As Single
    dz As Single
    angle As Single
End Type

Dim Shared balls(1 To NumSpheres) As Sphere
Dim Shared sx(0 To Segments + 1, 0 To Segments + 1) As Integer
Dim Shared sy(0 To Segments + 1, 0 To Segments + 1) As Integer

gridColor = _RGB32(255, 0, 0)
' === INITIALIZE SPHERES ===
Randomize Timer
For b = 1 To NumSpheres
    balls(b).x = Rnd * WorldSize * 2 - WorldSize
    balls(b).y = Rnd * WorldSize * 2 - WorldSize
    balls(b).z = Rnd * WorldSize * 2 - WorldSize + 600
    balls(b).dx = (Rnd - 0.5) * 6
    balls(b).dy = (Rnd - 0.5) * 6
    balls(b).dz = (Rnd - 0.5) * 6
    balls(b).angle = Rnd * 2 * Pi
Next

' === MAIN LOOP ===
Do
    Cls


    ' Move and handle collisions for each sphere
    For b = 1 To NumSpheres
        balls(b).x = balls(b).x + balls(b).dx
        balls(b).y = balls(b).y + balls(b).dy
        balls(b).z = balls(b).z + balls(b).dz

        ' Boundary collisions
        If balls(b).x > WorldSize - Radius Or balls(b).x < -WorldSize + Radius Then balls(b).dx = -balls(b).dx
        If balls(b).y > WorldSize - Radius Or balls(b).y < -WorldSize + Radius Then balls(b).dy = -balls(b).dy
        If balls(b).z > WorldSize - Radius + 600 Or balls(b).z < -WorldSize + Radius + 600 Then balls(b).dz = -balls(b).dz

        ' Sphere-to-sphere collisions
        For b2 = b + 1 To NumSpheres
            Dim dx As Single, dy As Single, dz As Single
            dx = balls(b2).x - balls(b).x
            dy = balls(b2).y - balls(b).y
            dz = balls(b2).z - balls(b).z
            Dim distance As Single
            distance = Sqr(dx * dx + dy * dy + dz * dz)

            If distance < 2 * Radius And distance > 0 Then
                ' Normalize collision vector
                dx = dx / distance
                dy = dy / distance
                dz = dz / distance

                ' Relative velocity
                Dim rvx As Single, rvy As Single, rvz As Single
                rvx = balls(b2).dx - balls(b).dx
                rvy = balls(b2).dy - balls(b).dy
                rvz = balls(b2).dz - balls(b).dz

                ' Dot product for velocity along collision normal
                Dim vColl As Single
                vColl = rvx * dx + rvy * dy + rvz * dz

                ' Elastic collision response (assuming equal mass)
                If vColl < 0 Then ' Only resolve if spheres are moving toward each other
                    balls(b).dx = balls(b).dx + vColl * dx
                    balls(b).dy = balls(b).dy + vColl * dy
                    balls(b).dz = balls(b).dz + vColl * dz
                    balls(b2).dx = balls(b2).dx - vColl * dx
                    balls(b2).dy = balls(b2).dy - vColl * dy
                    balls(b2).dz = balls(b2).dz - vColl * dz

                    ' Adjust positions to prevent overlap
                    Dim overlap As Single
                    overlap = (2 * Radius - distance) / 2
                    balls(b).x = balls(b).x - overlap * dx
                    balls(b).y = balls(b).y - overlap * dy
                    balls(b).z = balls(b).z - overlap * dz
                    balls(b2).x = balls(b2).x + overlap * dx
                    balls(b2).y = balls(b2).y + overlap * dy
                    balls(b2).z = balls(b2).z + overlap * dz
                End If
            End If
        Next

        balls(b).angle = balls(b).angle + 0.02

        ' Build and project vertices
        For i = 0 To Segments
            Dim phi As Single: phi = Pi * i / Segments
            For j = 0 To Segments
                Dim theta As Single: theta = 2 * Pi * j / Segments

                Dim lx As Single, ly As Single, lz As Single
                lx = Radius * Sin(phi) * Cos(theta)
                ly = Radius * Sin(phi) * Sin(theta)
                lz = Radius * Cos(phi)

                Dim rx As Single, ry As Single, rz As Single
                rx = lx * Cos(balls(b).angle) - lz * Sin(balls(b).angle)
                rz = lx * Sin(balls(b).angle) + lz * Cos(balls(b).angle)
                ry = ly

                Dim wx As Single, wy As Single, wz As Single
                wx = rx + balls(b).x
                wy = ry + balls(b).y
                wz = rz + balls(b).z

                If wz - CamZ > 1 Then
                    sx(i, j) = ScreenCX + (wx * Scale) / (wz - CamZ)
                    sy(i, j) = ScreenCY + (wy * Scale) / (wz - CamZ)
                Else
                    sx(i, j) = -1: sy(i, j) = -1
                End If
            Next
            sx(i, Segments + 1) = sx(i, 0)
            sy(i, Segments + 1) = sy(i, 0)
        Next

        ' Draw wireframe
        For i = 0 To Segments - 1
            For j = 0 To Segments
                If sx(i, j) >= 0 Then
                    Line (sx(i, j), sy(i, j))-(sx(i, j + 1), sy(i, j + 1)), colorLine
                    If sy(i + 1, j) >= 0 Then
                        Line (sx(i, j), sy(i, j))-(sx(i + 1, j), sy(i + 1, j)), colorLine
                    End If
                End If
            Next
        Next
    Next

    _Display
    Rem _Limit FPS
Loop Until _KeyDown(27)

' === 3D -> 2D Projection Sub ===
Sub ProjectPoint (x As Single, y As Single, z As Single, projX As Integer, projY As Integer)
    If z - CamZ > 1 Then
        projX = ScreenCX + (x * Scale) / (z - CamZ)
        projY = ScreenCY + (y * Scale) / (z - CamZ)
    Else
        projX = -1
        projY = -1
    End If
End Sub

Sub grid ()
    ' === XY plane at Z = 600 - WorldSize ===
    For i = -WorldSize To WorldSize Step 100
        ' Vertical grid lines (parallel to Y)
        ProjectPoint i, -WorldSize, 600 - WorldSize, p1x, p1y
        ProjectPoint i, WorldSize, 600 - WorldSize, p2x, p2y
        If p1x >= 0 And p2x >= 0 Then Line (p1x, p1y)-(p2x, p2y), gridColor

        ' Horizontal grid lines (parallel to X)
        ProjectPoint -WorldSize, i, 600 - WorldSize, p1x, p1y
        ProjectPoint WorldSize, i, 600 - WorldSize, p2x, p2y
        If p1x >= 0 And p2x >= 0 Then Line (p1x, p1y)-(p2x, p2y), gridColor
    Next

    ' === XZ plane at Y = -WorldSize ===
    For i = -WorldSize To WorldSize Step 100
        ' Vertical grid lines (parallel to Z)
        ProjectPoint i, -WorldSize, 600 - WorldSize, p1x, p1y
        ProjectPoint i, -WorldSize, 600 + WorldSize, p2x, p2y
        If p1x >= 0 And p2x >= 0 Then Line (p1x, p1y)-(p2x, p2y), gridColor

        ' Horizontal grid lines (parallel to X)
        ProjectPoint -WorldSize, -WorldSize, 600 + i, p1x, p1y
        ProjectPoint WorldSize, -WorldSize, 600 + i, p2x, p2y
        If p1x >= 0 And p2x >= 0 Then Line (p1x, p1y)-(p2x, p2y), gridColor
    Next
End Sub

