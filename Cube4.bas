'
'                             October 4, 1997
'
'        Here is an example of 3D rendering. This is the first 3D thing I
'  have made and it took me about a 2 days to make this. I took a lot of
'  time to add comments so you understand it. I have looked at some other
'  3D programs online and none of them are well documented and most are
'  written really sloppy so its hard to understand. I tried to make this
'  as easy to understand as possible.
'
'        I guess its not like a real 3D object. Just a bunch of dots that
'  make up a 3D cube, but thats about as good as it gets in QB. If you
'  are good at 3D and would like to give me a few tips please do. If you
'  know how to make a 3D sphere please let me know. Thanks!
'
'     You can e-mail me at: tf_software@geocities.com
'



Type PointType 'User type for 3D points
    X1 As Double 'X, Y, Z variables
    Y1 As Double
    Z1 As Double
    XG As Double 'X, Y, Z buffers for equations
    YG As Double
    ZG As Double
    C As Integer 'Color value
End Type
size = 50
Dim Points(size, size, size) As PointType '3 dimensional array.
Dim P As PointType '3 dimensional array.











'This is the array for the points
'that make up the 3D cube.
'Its really 7x7x7 (counting 0)
Pi! = 3.141593 'Variable for Pi
                   
'(Note the "!". This makes the variable a double because
'the default data type is Integer, you will see this in
'more variables.)

'Go ahead and change these if you want BUT
'make sure there is only 7 values.
'If you don't center it around 0 the WHOLE cube will
'spin around in 3D space.
'****Note: -3 to 3 IS 7 values. Be sure to count 0.****
st = -(size / 2)
ed = size / 2

For XS = st To ed '(X ranges from -3 to 3)
    For YS = st To ed '(Y ranges from -3 to 3)
        For ZS = st To ed '(Z ranges from -3 to 3)
            'This loop makes the points in a Cube shape
            Points(T1, T2, T3).XG = XS 'Sets X location
            Points(T1, T2, T3).YG = YS 'Sets Y location
            Points(T1, T2, T3).ZG = ZS 'Sets Z location

            Points(T1, T2, T3).C = T1 + 1 'This sets the points color
            T3 = T3 + 1
        Next ZS
        T2 = T2 + 1: T3 = 0
    Next YS
    T1 = T1 + 1: T2 = 0
Next XS 'End of the loop

'When rendering 3D objects calculating the
'cosine (COS) and sine(SIN) can really slow
'down the process. It will speed up the rendering
'if you precompute the COS and SIN and put them
'in an array as seen below:

 
 
'These 3 variables are the speed the object will rotate around each axis.
 
DX = 0.35
DY = .45
DZ = 0.25



Dim Shared a As Long
a = _NewImage(1023, 768, 256)
Screen a
'This is for smooth page-flipping animation.

Do 'Beginning of the rendering loop.



    For T1 = 0 To size 'These FOR/NEXT loops rotate all the points.
        For T2 = 0 To size
            For T3 = 0 To size

                'Each rotation is 2 equations
                'It uses YG, XG, or ZG in the equation instead of Y1, X1, or Z1.
                'This is because if it used Y1, X1, or Z1 it would use it again in
                'the next equation and then it would be a different value and the
                'calculations would be incorrect. After the two equations it updates
                'the YG, XG, or ZG variable.

                'Rotates object around X axis. Changes Y1 and Z1 values.

                e = pset3d(Points(T1, T2, T3), DX, DY, DZ)

                'As you can see here the ViewingDistance is 180.
                'You may notice that I have added something to the Z value. That is the
                'distance. I have also added 160 to X and 100 to Y. I did that so the
                'cube will be in the center of the screen.

            Next T3
        Next T2
    Next T1 'End of rotation loop.
    _Display
    Cls
    'see the cube.

Loop Until InKey$ <> "" 'End of rendering loop. Ends on key press.

'Well thats it! I hope this teaches you the basics of 3D programming!
'Not as confusing as you thought huh? Well if you are not getting something
'its probably because I explained it in a bad way. Just e-mail me what you
'are having trouble with and I will do my best to explain. My e-mail address
'is at the top of this file.
End

Function pset3d (o As PointType, dx, dy, dz)
    Dim p As PointType
    p = o
    p.Y1 = (p.YG * (Cos(_D2R(dx)))) - (p.ZG * (Sin(_D2R(dx))))
    p.Z1 = (p.YG * (Sin(_D2R(dx)))) + (p.ZG * (Cos(_D2R(dx))))
    p.YG = p.Y1: p.ZG = p.Z1

    'Rotates object around Y axis. Changes Z1 and X1 values.
    p.Z1 = (p.ZG * (Cos(_D2R(dy)))) - (p.XG * (Sin(_D2R(dy))))
    p.X1 = (p.ZG * (Sin(_D2R(dy)))) + (p.XG * (Cos(_D2R(dy))))
    p.XG = p.X1: p.ZG = p.Z1

    'Rotates object around Z axis. Changes X1 and Y1 values.
    p.X1 = (p.XG * (Cos(_D2R(dz)))) - (p.YG * (Sin(_D2R(dz))))
    p.Y1 = (p.XG * (Sin(_D2R(dz)))) + (p.YG * (Cos(_D2R(dz))))
    p.XG = p.X1: p.YG = p.Y1

    'Now that we have the X, Y, and Z values for all the points, how do we
    'draw them on a 2D screen? We have to convert them from mathmatical space
    'to a 2D plane(the screen). This is called a perspective projection and
    'is pretty simple. This is what you do:
    '  X = X * ViewingDistance / Z
    '  Y = Y * ViewingDistance / Z
    'We will add a few more things to the equation however.

    PSet (((p.X1 * 10)) + (_Width(d) / 2), ((p.Y1 * 10)) + (_Height(d) / 2)), p.C

    o = p
End Function
