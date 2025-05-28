' === Enigma-Like Cipher in QB64PE ===

DECLARE FUNCTION EncryptCharacter$ (ch$)

' Define the alphabet string and rotors
Dim Shared alphabet$
Dim Shared r1$, r2$, r3$, rf$
Dim Shared rotorPos(2) As Integer

alphabet$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
r1$ = "BDFHJLCPRTXVZNYEIWGAKMUSQO1234567890 "
r2$ = "AJDKSIRUXBLHWTMCQGZNPYFVOE9876543210 "
r3$ = "EKMFLGDQVZNTOWYHXUSPAIBRCJ5647382910 "
rf$ = "YRUHQSLDPXNGOKMIEBFZCWVJAT0123456789 "

' === Main Program ===
Cls
Dim message As String, ch As String * 1

Print "Enter initial rotor positions (0-374rt ):"
Input "Rotor 1: ", rotorPos(0)
Input "Rotor 2: ", rotorPos(1)
Input "Rotor 3: ", rotorPos(2)

For i = 0 To 2
    rotorPos(i) = rotorPos(i) Mod 37
Next

Input "Enter message to encrypt: ", message
message = UCase$(message)

Print "Encrypted output: ";
For i = 1 To Len(message)
    ch = Mid$(message, i, 1)
    Print EncryptCharacter$(ch);
Next
Print

' === Encrypt a single character ===
Function EncryptCharacter$ (ch$)
    Dim idx As Integer
    idx = InStr(alphabet$, ch$) - 1
    If idx < 0 Then EncryptCharacter$ = ch$: Exit Function

    ' Step rotors
    rotorPos(0) = (rotorPos(0) + 1) Mod 37
    If rotorPos(0) = 0 Then
        rotorPos(1) = (rotorPos(1) + 1) Mod 37
        If rotorPos(1) = 0 Then
            rotorPos(2) = (rotorPos(2) + 1) Mod 37
        End If
    End If

    ' Pass through rotors
    idx = (InStr(alphabet$, Mid$(r1$, (idx + rotorPos(0)) Mod 37 + 1, 1)) - 1 - rotorPos(0) + 37) Mod 37
    idx = (InStr(alphabet$, Mid$(r2$, (idx + rotorPos(1)) Mod 37 + 1, 1)) - 1 - rotorPos(1) + 37) Mod 37
    idx = (InStr(alphabet$, Mid$(r3$, (idx + rotorPos(2)) Mod 37 + 1, 1)) - 1 - rotorPos(2) + 37) Mod 37

    ' Reflector
    idx = InStr(alphabet$, Mid$(rf$, idx + 1, 1)) - 1

    ' Pass back through rotors (reverse)
    idx = (InStr(r3$, Mid$(alphabet$, (idx + rotorPos(2)) Mod 37 + 1, 1)) - 1 - rotorPos(2) + 37) Mod 37
    idx = (InStr(r2$, Mid$(alphabet$, (idx + rotorPos(1)) Mod 37 + 1, 1)) - 1 - rotorPos(1) + 37) Mod 37
    idx = (InStr(r1$, Mid$(alphabet$, (idx + rotorPos(0)) Mod 37 + 1, 1)) - 1 - rotorPos(0) + 37) Mod 37

    EncryptCharacter$ = Mid$(alphabet$, idx + 1, 1)
End Function

