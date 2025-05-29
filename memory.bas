' Define the dimensions of the image
Dim iwidth As Integer
Dim iheight As Integer
iwidth = 320
iheight = 200


Type var
    a As Integer
    b As String * 100
    c As Long
End Type

Dim v As var

v.a = 100
v.b = "test"
v.c = 100.001

' Create memory blocks for the image and the UDT

Dim m As _MEM
m = _Mem(v)
hImage = _NewImage(m.SIZE / 2 + 1, m.SIZE / 2 + 1, 256)
' Create a new 256-color image
Dim hImage As Long
Dim s As _MEM
s = _MemImage(hImage)



' Check if the image creation was successful
If hImage = 0 Then
    Print "Failed to create image."
Else
    Print "Image created successfully."
End If

' Set this image as the active screen for output
Screen hImage

' Ensure that the sizes are compatible
If m.SIZE > s.SIZE Then
    Print "Error: UDT size exceeds image size."
Else
    ' Copy data from UDT to image memory
    _MemCopy m, m.OFFSET, m.SIZE To s, s.OFFSET

    ' Optional: Print data from the UDT to verify
    Print "Data in UDT:"
    Print "a:", v.a
    Print "b:", Mid$(v.b, 1)
    Print "c:", v.c
End If

' Free memory blocks after usage (recommended)
_MemFree m
_MemFree s

