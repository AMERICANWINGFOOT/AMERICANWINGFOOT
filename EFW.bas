_Title "AMERICAN WINGFOOT"

Declare Dynamic Library "d:\qb64\EFWfilter"
    Function EFWGetNum& ()
    Function EFWGetID& (ByVal index As Integer, Byval ID As _Offset)
    Function EFWGetProperty& (ByVal ID As Integer, Byval pInfo As _Offset)
    Function EFWOpen& (ByVal ID As Integer)
    Function EFWGetPosition& (ByVal ID As Integer, Byval pPosi As _Offset)
    Function EFWSetPosition& (ByVal ID As Integer, Byval Position As Integer)
    Function EFWClose& (ByVal ID As Integer)
End Declare


Type EFWINFO
    ID As Single
    Name As String * 64
    slotNum As Long
End Type

Type clocate
    x As Integer
    y As Integer
End Type

Dim Shared filtername$(10)
Dim Shared flocation As Integer
Dim Shared circlel(10) As clocate
Dim Shared info As EFWINFO
Dim Shared screenhandle&
Dim Shared fsize, h As Long
Dim Shared foff&, fon&, powerb&

foff& = _RGB32(100, 0, 0)
fon& = _RGB32(0, 0, 100)
powerb& = _RGB32(255, 255, 255)



Data "IR ","SII ","HA ","HB ","NEBULA ","NEODYMIUM ","NEBULA ","DARK"

For X = 1 To 8
    Read filtername$(X)
Next X

openwheel
setdisplay

Do
    Do While _MouseInput '      Check the mouse status
        If _MouseButton(1) < 0 Then checklocation _MouseX, _MouseY

    Loop
Loop Until InKey$ <> ""
System


Rem -------------------------------------------------------------------

Sub checklocation (x, y)
    For l = 1 To info.slotNum
        a = circlel(l).x - x
        b = circlel(l).y - y
        If a < fsize And a > -(fsize) And b < fsize And b > -(fsize) Then If l <> (flocation) Then setfilter (l)
    Next l
    a = circlel(9).x - x
    b = circlel(9).y - y
    If a < fsize And a > -(fsize) And b < fsize And b > -(fsize) Then If l <> (flocation) Then System
End Sub

Rem ----------------------------------------------------------------------

Sub setfilter (f)
    scircle circlel(flocation).x, circlel(flocation).y, fsize, foff&

    errortrap (EFWSetPosition(info.ID, f - 1))
    Do
        Sleep 1
    Loop While (EFWSetPosition(info.ID, f - 1))

    getfilter
    scircle circlel(f).x, circlel(f).y, fsize, fon&
    _PrintString (1, 80), "            "
    _PrintString (1, 80), filtername$(f) + Str$(f)
    getfilter
End Sub
Rem ----------------------------------------------------------------------

Sub getfilter ()
    Do
        Sleep 1
    Loop While (EFWGetPosition(info.ID, _Offset(flocation)))
    flocation = flocation + 1

End Sub

Rem---------------------------------------------------------------------

Sub openwheel ()
    If EFWGetNum - 1 < 0 Then Print "no efw": End
    index = EFWGetNum - 1
    errortrap (EFWOpen(info.ID))
    errortrap (EFWGetProperty(index, _Offset(info)))
    errortrap (EFWGetPosition(info.ID, _Offset(flocation)))
End Sub

Rem---------------------------------------------------------------------------

Sub errortrap (e)
    Select Case e
        Case 1: Print "EFW_ERROR_INVALID_INDEX"
        Case 2: Print "EFW_ERROR_INVALID_ID"
        Case 3: Print "EFW_ERROR_INVALID_VALUE"
        Case 4: Print "EFW_ERROR_CLOSED" Rem //not opened
        Case 5: Print "EFW_ERROR_REMOVED": Rem , //failed to find the filter wheel, maybe the filter wheel has been removed
        Case 6: Print "EFW_ERROR_MOVING" Rem ,//filter wheel is moving
        Case 7: Print "EFW_ERROR_GENERAL_ERROR": Rem,//other error
        Case 8: Print "EFW_ERROR_CLOSED"
    End Select
End Sub

Rem----------------------------------------------------------------------------------

Sub setdisplay
    getfilter
    l = 1
    screenhandle& = _NewImage(300, 100, 32)
    fsize = (_Width(screenhandle&) / info.slotNum) * .4
    h = _Height(screenhandle&) / 3
    Screen screenhandle&
    st = (_Width(screenhandle&) / info.slotNum) / 2
    For f = st To _Width(screenhandle&) Step _Width(screenhandle&) / info.slotNum
        scircle f, h, fsize, foff&
        circlel(l).x = f
        circlel(l).y = h
        l = l + 1
    Next f
    Rem scircle _Width(screenhandle&) - fsize, _Height(screenhandle&) - fsize, fsize, foff&
    pb
    circlel(9).x = _Width(screenhandle&) - fsize
    circlel(9).y = _Height(screenhandle&) - fsize



    setfilter (1)

End Sub


Rem---------------------------------------------------------------------------------

Sub scircle (x, y, d, c&)
    For nd = 1 To d Step .1
        Circle (x, y), nd, c&
    Next nd
End Sub
Rem -----------------------------------------------------------------------------------


Sub pb (): Rem MAKE OFF BUTTON
    h = _Height(screenhandle&)
    w = _Width(screenhandle&)

    fh = _FontHeight(_Font(screenhandle&))
    fw = _FontWidth(_Font(screenhandle&))
    Circle (w - fsize - 10, h - fsize - 10), fsize, powerb&, ToRadian(120), ToRadian(45), 1
    Line (w - fsize - 10, h - fsize - 10)-(w - fsize - 10, (h - fsize - 10) * .85), powerb&

End Sub
Rem -------------------------------------------------------------------------------------

Function ToRadian (angle)
    Dim p As Double
    p = 3.14159265
    ToRadian = (p / 180.0) * angle

End Function





