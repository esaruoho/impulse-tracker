;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Vesa Module                                                                 ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ Functions provided:                                                         ³
;³   DetectVESA                                                                ³
;³   SetVESAMode                                                               ³
;³                                                                             ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ DetectVESA                                                                  ³
;³  - No parameters required                                                   ³
;³  - Detects the presence of a VESA driver                                    ³
;³  - Returns carry SET if no VESA driver found                                ³
;³  - Returns carry CLEAR if VESA driver found                                 ³
;³  - All registers preserved                                                  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ SetVESAMode                                                                 ³
;³  - Requires AX = VESA Mode                                                  ³
;³  - Returns carry SET if VESA Mode isn't supported                           ³
;³  - Returns carry CLEAR if VESA mode change OK                               ³
;³  - All registers preserved                                                  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ VESAGetInfo                                                                 ³
;³  - Requires AX = VESA Mode to get information on                            ³
;³  - Returns carry SET if VESA Mode isn't supported                           ³
;³  - Returns carry clear if information is OK                                 ³
;³  - Returns ES:DI to Table, all other registers preserved                    ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                        Jumps
                        .386P

include switch.inc

IF SPECTRUMANALYSER

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Externals                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Globals                                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

Segment                 Vesa BYTE Public 'Code' USE16
                        Assume CS:Vesa, DS:Nothing

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Variables                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VESAInformationTable    Label
VESASignature           DB      4 Dup (0)
VESAVersion             DW      0
VESAOEMStringPrt        DD      0
VESACapabilities        DD      0
VESAVideoModePtr        DD      0
VESATotalMemory         DW      0
                        DB      256-($-VESAInformationTable) Dup(0)

VESAModeInformationTable Label
                        DB      256-($-VESAModeInformationTable) Dup (0)

ModeInformationStructure        Struc
        ModeAtributes           DW      ?
        WindowAAtributes        DB      ?
        WindowBAttributes       DB      ?
        WindowGranularity       DW      ?
        WindowSize              DW      ?
        WindowASegment          DW      ?
        WindowBSegment          DW      ?
        WindowFunction          DD      ?
        BytesPerScanLine        DW      ?

        XResolution             DW      ?
        YResolution             DW      ?
        XCharacterSize          DB      ?
        YCharacterSize          DB      ?
        NumberOfPlanes          DB      ?
        BitsPerPixel            DB      ?
        NumberOfBanks           DB      ?
        MemoryModel             DB      ?
        BankSize                DB      ?
        NumberOfImagePages      DB      ?
        Reserved                DB      ?

        RedMaskSize             DB      ?
        RedFieldPosition        DB      ?
        GreenMaskSize           DB      ?
        GreenFieldPosition      DB      ?
        BlueMaskSize            DB      ?
        BlueFieldPosition       DB      ?
        RSVDMaskSize            DB      ?
        DirectColourModeInfo    DB      ?

ModeInformationStructure        EndS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Functions                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Proc            VESA_Detect Far
Public          VESA_Detect

                PushA
                Push    ES

                Mov     AX, 4F00h
                Push    CS
                Pop     ES
                Mov     DI, Offset VESAInformationTable
                Int     10h

                Cmp     AX, 4Fh
                JNE     DetectVESA1
                Cmp     [DWord Ptr ES:DI], "ASEV"       ; 'VESA' identification
                JNE     DetectVESA1

                DB      85h

DetectVESA1:
                StC

                Pop     ES
                PopA
                Ret

EndP            VESA_Detect

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            VESA_SetMode Far
Public          VESA_SetMode

                PushA
                Push    DS
                Push    ES

                Call    VESA_GetInfo
                JC      VESA_SetMode3

                Mov     BX, AX
                Mov     AX, 4F02h       ; Set Mode
                Int     10h
                Cmp     AX, 4Fh
                JE      VESA_SetMode3

                StC

VESA_SetMode3:
                Pop     ES
                Pop     DS
                PopA

                Mov     CX, [VESAModeInformationTable.XResolution]
                Mov     DX, [VESAModeInformationTable.YResolution]

                Ret

EndP            VESA_SetMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            VESA_GetInfo
Public          VESA_GetInfo

                Push    AX
                Push    CX

                Mov     CX, AX

                Push    CS
                Pop     ES
                Mov     DI, Offset VESAModeInformationTable
                Mov     AX, 4F01h
                Int     10h

                Cmp     AX, 4Fh
                JE      VESA_GetInfo1

                StC

VESA_GetInfo1:
                Pop     CX
                Pop     AX

                Ret

EndP            VESA_GetInfo

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            VESA_SetBlock Far       ; Gives access to a 64kb block
Public          VESA_SetBlock           ; Given AX = block number.

                PushA
                Push    AX

                Mov     AX, 64
                Xor     DX, DX
                Div     Word Ptr [VESAModeInformationTable.WindowGranularity]
                Mov     DX, AX
                Pop     AX
                Mul     DX
                Mov     DX, AX
                Xor     BX, BX
                Call    DWord Ptr [VESAModeInformationTable.WindowFunction]

                PopA
                Ret

EndP            VESA_SetBlock

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

EndS

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

ENDIF

End
