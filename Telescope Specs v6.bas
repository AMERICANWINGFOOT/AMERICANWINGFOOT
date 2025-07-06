' ===============================
' Astrophotography Calculator
' Refactored for Modular Updates
' ===============================

Cls

' === Main Program ===
LoadLastSpecs lastAperture, lastFRatio, lastMagFactor

InputTelescopeSpecs lastAperture, lastFRatio, lastMagFactor, aperture, f_ratio, magFactor

cameraChoice = SelectCamera

SetCameraSpecs cameraChoice, sensorWidth, sensorHeight, pixelSize, resWidth, resHeight

focalLength = f_ratio * aperture * magFactor
FOV_H = (3438 * sensorWidth) / focalLength
FOV_V = (3438 * sensorHeight) / focalLength
pixelScale = (206.265 * pixelSize) / focalLength

DrawFOV FOV_H, FOV_V

PrintResults aperture, f_ratio, magFactor, focalLength, cameraChoice, sensorWidth, sensorHeight, pixelSize, resWidth, resHeight, FOV_H, FOV_V, pixelScale

EnhanceResults aperture, f_ratio, magFactor, sensorWidth, sensorHeight, resWidth, resHeight, pixelSize, focalLength, pixelScale, FOV_H, FOV_V

SaveLastSpecs aperture, f_ratio, magFactor

Print
Print "Press any key to exit..."
Sleep
End

' === SUBS AND FUNCTIONS ===

Sub LoadLastSpecs (lastAperture, lastFRatio, lastMagFactor)
    lastAperture = 203
    lastFRatio = 4.7
    lastMagFactor = 1

    If _FileExists("LastSpecs.txt") Then
        Open "LastSpecs.txt" For Input As #1
        Input #1, lastAperture, lastFRatio, lastMagFactor
        Close #1
    End If
End Sub

Sub InputTelescopeSpecs (lastAperture, lastFRatio, lastMagFactor, aperture, f_ratio, magFactor)
    Do
        Print "Enter Telescope Aperture (mm, default "; lastAperture; "): ";
        Input "", a$
        If a$ = "" Then aperture = lastAperture Else aperture = Val(a$)
        If aperture <= 0 Then Print "Please enter a positive number!"
    Loop Until aperture > 0

    Do
        Print "Enter Focal Ratio (f/, default "; lastFRatio; "): ";
        Input "", f$
        If f$ = "" Then f_ratio = lastFRatio Else f_ratio = Val(f$)
        If f_ratio <= 0 Then Print "Please enter a positive number!"
    Loop Until f_ratio > 0

    Do
        Print "Enter Barlow/Reducer Factor (1 for none, default "; lastMagFactor; "): ";
        Input "", m$
        If m$ = "" Then magFactor = lastMagFactor Else magFactor = Val(m$)
        If magFactor <= 0 Then Print "Please enter a positive number!"
    Loop Until magFactor > 0
End Sub

Function SelectCamera ()
    Print
    Print "Select a camera (enter number, or 0 for custom specs):"
    Print "1. ZWO ASI1600MM Pro (16MP, 3.8µm, 17.7x13.4mm)"
    Print "2. ZWO ASI2600MM Pro (26MP, 3.76µm, 23.5x15.7mm)"
    Print "3. ZWO ASI183MM Pro (20MP, 2.4µm, 13.2x8.8mm)"
    Print "4. ZWO ASI294MM Pro (11.7MP, 4.63µm, 19.1x13.0mm)"
    Print "5. ZWO ASI130MM (1.3MP, 5.2µm, 6.66x5.32mm)"
    Print "6. ZWO ASI174MM (2.3MP, 5.86µm, 11.3x7.1mm)"
    Print "7. ZWO ASI6200MM Pro (61MP, 3.76µm, 36.0x24.0mm)"
    Print "8. ZWO ASI533MM Pro (9MP, 3.76µm, 11.3x11.3mm)"
    Print "9. QHY268M (26MP, 3.76µm, 23.5x15.7mm)"
    Print "0. Custom Camera"

    Do
        Input "", choice$



        If Val(choice$) < 0 Or Val(choice$) > 9 Or Int(Val(choice$)) <> Val(choice$) Then
            Print "Please enter a number between 0 and 9!"
        End If
    Loop Until Val(choice$) >= 0 And Val(choice$) <= 9 And Int(Val(choice$)) = Val(choice$)
    SelectCamera = Val(choice$)
End Function

Sub SetCameraSpecs (choice, sensorWidth, sensorHeight, pixelSize, resWidth, resHeight)
    Select Case choice
        Case 1: sensorWidth = 17.7: sensorHeight = 13.4: pixelSize = 3.8: resWidth = 4656: resHeight = 3520
        Case 2: sensorWidth = 23.5: sensorHeight = 15.7: pixelSize = 3.76: resWidth = 6248: resHeight = 4176
        Case 3: sensorWidth = 13.2: sensorHeight = 8.8: pixelSize = 2.4: resWidth = 5496: resHeight = 3672
        Case 4: sensorWidth = 19.1: sensorHeight = 13: pixelSize = 4.63: resWidth = 4144: resHeight = 2822
        Case 5: sensorWidth = 6.66: sensorHeight = 5.32: pixelSize = 5.2: resWidth = 1280: resHeight = 1024
        Case 6: sensorWidth = 11.3: sensorHeight = 7.1: pixelSize = 5.86: resWidth = 1936: resHeight = 1216
        Case 7: sensorWidth = 36.0: sensorHeight = 24.0: pixelSize = 3.76: resWidth = 9576: resHeight = 6388
        Case 8: sensorWidth = 11.3: sensorHeight = 11.3: pixelSize = 3.76: resWidth = 3008: resHeight = 3008
        Case 9: sensorWidth = 23.5: sensorHeight = 15.7: pixelSize = 3.76: resWidth = 6280: resHeight = 4210
        Case Else
            Do
                Print "Enter Sensor Width (mm, default 11.3): ";
                Input "", s$
                If s$ = "" Then sensorWidth = 11.3 Else sensorWidth = Val(s$)
                If sensorWidth <= 0 Then Print "Please enter a positive number!"
            Loop Until sensorWidth > 0
            Do
                Print "Enter Sensor Height (mm, default 7.1): ";
                Input "", h$
                If h$ = "" Then sensorHeight = 7.1 Else sensorHeight = Val(h$)
                If sensorHeight <= 0 Then Print "Please enter a positive number!"
            Loop Until sensorHeight > 0
            Do
                Print "Enter Pixel Size (µm, default 5.86): ";
                Input "", p$
                If p$ = "" Then pixelSize = 5.86 Else pixelSize = Val(p$)
                If pixelSize <= 0 Then Print "Please enter a positive number!"
            Loop Until pixelSize > 0
            Do
                Print "Enter Resolution Width (px, default 1936): ";
                Input "", rw$
                If rw$ = "" Then resWidth = 1936 Else resWidth = Val(rw$)
                If resWidth <= 0 Or Int(resWidth) <> resWidth Then Print "Please enter a positive integer!"
            Loop Until resWidth > 0 And Int(resWidth) = resWidth
            Do
                Print "Enter Resolution Height (px, default 1216): ";
                Input "", rh$
                If rh$ = "" Then resHeight = 1216 Else resHeight = Val(rh$)
                If resHeight <= 0 Or Int(resHeight) <> resHeight Then Print "Please enter a positive integer!"
            Loop Until resHeight > 0 And Int(resHeight) = resHeight
    End Select
End Sub

Sub DrawFOV (FOV_H, FOV_V)
    maxX = _DesktopWidth
    maxY = _DesktopHeight
    w = 800: h = 600
    If w > maxX * 0.9 Then w = maxX * 0.9
    If h > maxY * 0.9 Then h = maxY * 0.9
    Screen _NewImage(w, h, 256)

    Cls
    scale = 10
    If FOV_H * scale > w * 0.8 Or FOV_V * scale > h * 0.8 Then
        scale = Min(w * 0.8 / FOV_H, h * 0.8 / FOV_V)
    End If

    cx = w / 2: cy = h / 2
    Line (cx - FOV_H * scale / 2, cy - FOV_V * scale / 2)-(cx + FOV_H * scale / 2, cy + FOV_V * scale / 2), 15, B

    moonR = 15 * scale
    Circle (cx, cy), moonR, 15
    Paint (cx, cy), 15, 15

    Locate 1, 1: Print "Field of View: "; Int(FOV_H * 100 + 0.5) / 100; " x "; Int(FOV_V * 100 + 0.5) / 100; " arcmin"
    Locate 2, 1: Print "Moon: ~30 arcmin diameter"
    Locate 3, 1: Print "Press any key..."
    Sleep
    Screen 0: Cls
End Sub

Sub PrintResults (aperture, f_ratio, magFactor, focalLength, choice, sW, sH, pSize, rW, rH, FOV_H, FOV_V, pixelScale)
    Print "Telescope Specs:"
    Print "Aperture: "; aperture; " mm"
    Print "Focal Ratio: f/"; f_ratio
    Print "Barlow/Reducer: "; magFactor
    Print "Effective Focal Length: "; focalLength; " mm"

    Print: Print "Camera Specs:"
    If choice = 0 Then Print "Camera: Custom" Else Print "Camera: Predefined #" + Str$(choice)
    Print "Sensor: "; sW; "mm x "; sH; "mm"
    Print "Resolution: "; rW; " x "; rH
    Print "Pixel Size: "; pSize; " µm"

    Print: Print "Field of View:"
    Print "Horizontal: "; FOV_H; " arcmin"
    Print "Vertical: "; FOV_V; " arcmin"
    Print "Pixel Scale: "; pixelScale; " arcsec/pixel"

    If pixelScale < 1 Then Print "Status: Oversampled"
    If pixelScale >= 1 And pixelScale <= 2 Then Print "Status: Well-sampled"
    If pixelScale > 2 Then Print "Status: Undersampled"

    If FOV_H > 30 And FOV_V > 30 Then Print "Moon: Fits" Else Print "Moon: Partially fits"

    Print: Print "Suggested Exposure:"
    If pixelScale < 1 Then Print "Planetary: 0.01-0.1s, high gain, stack thousands"
    If pixelScale >= 1 Then Print "Deep Sky: 30-300s, low gain, stack 10-50 frames"
End Sub

Sub SaveLastSpecs (aperture, f_ratio, magFactor)
    Open "LastSpecs.txt" For Output As #1
    Print #1, aperture, f_ratio, magFactor
    Close #1
End Sub

Function Min (a, b)
    If a < b Then Min = a Else Min = b
End Function

Sub EnhanceResults (aperture, f_ratio, magFactor, sW, sH, rW, rH, pSize, focalLength, pixelScale, FOV_H, FOV_V)
    resH = rW * pixelScale
    resV = rH * pixelScale
    Print: Print "Total Resolution: "; resH; " x "; resV; " arcsec"

    Open "AstroSpecs.txt" For Append As #1
    Print #1, "===== Session ====="
    Print #1, "Date: "; Date$; " Time: "; Time$
    Print #1, "Aperture: "; aperture
    Print #1, "Focal Ratio: "; f_ratio
    Print #1, "Barlow/Reducer: "; magFactor
    Print #1, "Focal Length: "; focalLength
    Print #1, "Sensor: "; sW; " x "; sH
    Print #1, "Resolution: "; rW; " x "; rH
    Print #1, "Pixel Size: "; pSize
    Print #1, "FOV: "; FOV_H; " x "; FOV_V
    Print #1, "Pixel Scale: "; pixelScale
    Print #1, "Total Resolution: "; resH; " x "; resV
    Print #1, "==================="
    Close #1

    Print "Session saved to AstroSpecs.txt"
End Sub

