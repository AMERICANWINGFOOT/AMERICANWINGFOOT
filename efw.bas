Rem A SIMPLE PROGRAM TO CONTROL A ZWO FILTER WHEEL IN QB64 WILL NEED FILE EFW_filter.DLL FROM ZWO
_Title "AMERICAN WINGFOOT"

Declare Dynamic Library "EFW64"
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
Dim Shared fsize As Long
Dim Shared foff&, fon&, powerb&

Rem COLORS FOR FILTERS AND OFF BUTTON

foff& = _RGB32(100, 0, 0)
fon& = _RGB32(0, 0, 100)
powerb& = _RGB32(255, 255, 255)

Data "IR ","SII ","HA ","HB ","NEBULA ","NEODYMIUM ","NEBULA ","DARK "

openwheel
main
closefilter

Rem -----------------------------------------------------------------------

Sub main
    Do
        Do While _MouseInput '      Check the mouse status
            If _MouseButton(1) < 0 Then checklocation _MouseX, _MouseY: Rem LOOP UNTIL LEFT MOUSE BUTTON HIT
        Loop
    Loop Until InKey$ = Chr$(27): Rem ESC KEY TO END LOOP
End Sub

Rem -------------------------------------------------------------------

Sub checklocation (x, y)
    For l = 1 To info.slotNum
        a = circlel(l).x - x
        b = circlel(l).y - y
        If a < fsize And a > -(fsize) And b < fsize And b > -(fsize) Then If l <> (flocation) Then setfilter (l)
    Next l
    a = circlel(9).x - x
    b = circlel(9).y - y
    If a < fsize And a > -(fsize) And b < fsize And b > -(fsize) Then If l <> (flocation) Then closefilter

End Sub

Rem ----------------------------------------------------------------------

Sub setfilter (f)
    _PrintString (1, 80), "             "
    scircle circlel(flocation).x, circlel(flocation).y, fsize, foff&
    errortrap (EFWSetPosition(info.ID, f - 1)): Rem START FILTER MOVING
    Do
        Sleep 1
    Loop While (EFWSetPosition(info.ID, f - 1)): Rem LOOP UNTIL FILTER STOPS MOVING
    scircle circlel(f).x, circlel(f).y, fsize, fon&
    _PrintString (1, 80), filtername$(f) + "#" + Str$(f)
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
    index = EFWGetNum - 1
    If index < 0 Then Print "NO EFW": End
    errortrap (EFWGetID(index, _Offset(info.ID)))
    errortrap (EFWOpen(info.ID))
    errortrap (EFWGetProperty(info.ID, _Offset(info)))
    getfilter
    setdisplay
End Sub

Rem----------------------------------------------------------------------------------

Sub setdisplay
    For X = 1 To 8
        Read filtername$(X)
    Next X
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
    pb: Rem CREAT POWER BUTTON
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
    h = _Height(screenhandle&) - fzize - 20
    w = _Width(screenhandle&) - fsize - 10
    Circle (w, h), fsize, powerb&, ToRadian(120), ToRadian(45), 1
    Line (w, h)-(w, h * .85), powerb&
End Sub

Rem -------------------------------------------------------------------------------------

Function ToRadian (angle)
    Dim p As Double
    p = 3.14159265
    ToRadian = (p / 180.0) * angle
End Function

Rem --------------------------------------------------------------------------------------------

Sub closefilter
    setfilter (info.slotNum): Rem set filter to last filter befor closing location used for dark frame filter most of the time
    errortrap (EFWClose(FILTER.ID))
    System
End Sub

Rem --------------------------------------------------------------------------------------------

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



