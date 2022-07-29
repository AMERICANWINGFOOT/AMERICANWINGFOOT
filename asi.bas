
Declare Dynamic Library "asi64"
    Function ASIGetNumOfConnectedCameras& ()
    Function ASIGetCameraProperty& (ByVal c As _Offset, Byval index As Integer)
    Function ASIOpenCamera& (ByVal index As Integer)
    Function ASICloseCamera& (ByVal iCameraID As Integer)
    Function ASIStartExposure& (ByVal iCameraID As Integer)
    Function ASIStopExposure& (ByVal iCameraID As Integer)
    Function ASISetStartPos& (ByVal iCameraID As Integer, Byval iStartX As Integer, Byval iStartY As Integer)
    Function ASIGetDataAfterExp& (ByVal iCameraID As Integer, Byval pBuffer As _Offset, Byval lBuffSize As Long)
    Function ASIInitCamera& (ByVal iCameraID As Integer)
    Function ASIGetNumOfControls& (ByVal iCameraID As Integer, Byval piNumberOfControls As _Offset)
    Function ASIGetControlCaps& (ByVal iCameraID As Integer, Byval asiControlIndex As Integer, Byval pControlCaps As _Offset)
    Function ASIGetCameraMode (ByVal iCameraID As Integer, Byval mode As _Offset)
    Function ASISetCameraMode (ByVal iCameraID As Integer, Byval mode As Integer)
End Declare

Dim img(4) As String

img(0) = "ASI_IMG_RAW8"
img(1) = "ASI_IMG_RGB24"
img(2) = "ASI_IMG_RAW16"
img(3) = "ASI_IMG_Y8"

Dim bpattern(4) As String

bpattern(0) = "ASI_BAYER_RG"
bpattern(1) = "ASI_BAYER_BG"
bpattern(2) = "ASI_BAYER_GR"
bpattern(3) = "ASI_BAYER_GB"



Type info
    cname As String * 64
    CameraID As Long
    MaxHeight As Long
    MaxWidth As Long
    IsColorCam As Long
    BayerPattern As Long
    SupportedBins As String * 64
    SupportedVideoFormat As String * 36
    Rem buff As String * 4 Rem
    PixelSize As Double
    MechanicalShutter As Long
    ST4Port As Long
    IsCoolerCam As Long
    IsUSB3Host As Long
    IsUSB3Camera As Long
    ElecPerADU As Long
    BitDepth As Long
    IsTriggerCam As Long
    Unused As String * 16
End Type
Type CONTROLCAPS

    cName As String * 64
    Description As String * 128
    MaxValue As Long
    MinValue As Long
    DefaultValue As Long
    IsAutoSupported As Long
    IsWritable As Long
    ControlType As Long
    Unused As String * 32

End Type



Dim a As info
Dim b As CONTROLCAPS

Dim index, buffer As Integer

index = ASIGetNumOfConnectedCameras& - 1
e = ASIOpenCamera(index)
e = ASIGetCameraProperty(_Offset(a), index)

e = ASISetStartPos(a.CameraID, 0, 0)

Rem e = ASIInitCamera(a.CameraID)
e = ASIGetNumOfControls(a.CameraID, _Offset(buffer))

s& = _NewImage(1500, 1500, 256)
Screen s&
Dim m As _MEM

m = _MemNew(2621450)

lBuffSize& = 2621450
Rem Dim Shared pbuffer(2621450) As _Byte

m = _Mem(pbuffer)

ec = ASISetCameraMode(a.CameraID, 0)
ec = ASIStartExposure(a.CameraID)
Print "camera start", ec



For l = 1 To 60
    Sleep 1
    Print l
Next l
Print "go"

e = ASIStopExposure(a.CameraID)


e = ASIGetDataAfterExp(a.CameraID, m.OFFSET, lBuffSize&)
z = 0

e = ASICloseCamera(index)

End


x = Len(a.SupportedBins)
For l = 1 To x
    d = Asc(Mid$(a.SupportedBins, l, l))
    If d Then Print d; "x"; d
    Rem _Delay (.5)
Next l
Sleep
Print "------------------------------------------"
x = Len(a.SupportedVideoFormat)
l = 1
Do

    Print img(Asc(Mid$(a.SupportedVideoFormat, l, l))), l - 2
    Rem Print Asc(Mid$(a.SupportedVideoFormat, l, 4))
    l = l + 4

    _Delay (.5)

Loop While (Asc(Mid$(a.SupportedVideoFormat, l, l)) <> 255)

End



For x = 0 To buffer
    e = ASIGetControlCaps(a.CameraID, x, _Offset(b))

    Print b.cName
    Print b.Description
    Print b.MaxValue
    Print b.MinValue
    Print b.DefaultValue
    Print b.IsAutoSupported
    Print b.IsWritable
    Print b.ControlType
    Print

Next x



Print a.cname
Print a.CameraID
Print a.MaxHeight
Print a.MaxWidth
Print a.IsColorCam
Print a.BayerPattern
Print a.PixelSize
Print a.MechanicalShutter
Print a.ST4Port
Print a.IsCoolerCam
Print a.IsUSB3Host
Print a.ElecPerADU
Print a.BitDepth
Print a.IsTriggerCam














