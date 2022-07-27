Declare Dynamic Library "asi64"
    Function ASIGetNumOfConnectedCameras& ()
    Function ASIGetCameraProperty& (ByVal c As _Offset, Byval index As Integer)
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
    SupportedBins As String * 66
    SupportedVideoFormat As String * 34
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
Dim a As info


Dim index As Integer

index = ASIGetNumOfConnectedCameras& - 1
Print ASIGetCameraProperty(_Offset(a), index)

Print "name "; a.cname
Print "id "; a.CameraID
Print "max height "; a.MaxHeight
Print "max width "; a.MaxWidth
Print "is color "; a.IsColorCam
Print "bayer pattern "; bpattern(a.BayerPattern)
Print "bins "; a.SupportedBins
Print "video f "; a.SupportedVideoFormat

Print "pixel size "; a.PixelSize
Print a.MechanicalShutter
Print a.ST4Port
Print a.IsCoolerCam
Print a.IsUSB3Host
Print a.IsUSB3Camera
Print "unused "; a.Unused

Sleep

x = Len(a.SupportedBins)
For l = 1 To x Step 4
    b = Asc(Mid$(a.SupportedBins, l, l))
    If b Then Print b; "x"; b
    Rem _Delay (.5)
Next l

Print "------------------------------------------"
x = Len(a.SupportedVideoFormat)
l = 3
Do

    Print img(Asc(Mid$(a.SupportedVideoFormat, l, l)))
    Print Asc(Mid$(a.SupportedVideoFormat, l, 4))
    l = l + 4

    _Delay (.5)

Loop While (Asc(Mid$(a.SupportedVideoFormat, l, l)) <> 255)


















