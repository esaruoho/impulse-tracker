
        .386P

Segment                 DriverHeader PARA Public 'Code' Use16
                        Assume CS:Driver, DS:Nothing

;***** Driver Header *******

include drhead.inc

EndS

Segment                 Driver PARA Public 'Code' Use16
                        Assume CS:Driver, DS:Nothing

ORG 0
StartDriver:

include vtable.inc

;********  Required ProcedureTable *************

include reqproc.inc

;***********************************************

PNPSERIALID     EQU     0FFFFFFFFh
PNPVENDORID     EQU     80719304h

MMT_MAXENTRIES  EQU     64
MMT_MAXSIZE     EQU     3*MMT_MAXENTRIES

ST97Message     DB      "Sound Track 97 PnP Detected", 13
;                DB      "Port ", 0FDh, "Xh, IRQ ", 0FDh, "D, ", 0FDh, "Dk RAM", 0
                DB      "Port ", 0FDh, "Xh, ", 0FDh, "D Voices, ", 0FDh, "Dk", 0

StatusLine      DB      "FreeST  ", 0FDh, "Dk", 0

MMTData         DW      MMT_MAXSIZE Dup (0)

IRQData                 Label   Word
        DW      20h,  1111111111111110b ; IRQ 0
        DW      24h,  1111111111111101b ; IRQ 1
        DW      28h,  1111110111111011b ; IRQ 2
        DW      2Ch,  1111111111110111b ; IRQ 3
        DW      30h,  1111111111101111b ; IRQ 4
        DW      34h,  1111111111011111b ; IRQ 5
        DW      38h,  1111111110111111b ; IRQ 6
        DW      3Ch,  1111111101111111b ; IRQ 7
        DW      1C0h, 1111111011111011b ; IRQ 8
        DW      1C4h, 1111110111111011b ; IRQ 9
        DW      1C8h, 1111101111111011b ; IRQ 10
        DW      1CCh, 1111011111111011b ; IRQ 11
        DW      1D0h, 1110111111111011b ; IRQ 12
        DW      1D4h, 1101111111111011b ; IRQ 13
        DW      1D8h, 1011111111111011b ; IRQ 14
        DW      1DCh, 0111111111111011b ; IRQ 15

; ÄÄ EmptyFunction ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            EmptyFunction Far

                Xor     AX, AX
                StC
                Ret

EndP            EmptyFunction

; ÄÄ ST97InString ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97InString            ; ES:DI points to deposit point.
                                        ; EAX = memory address
                                        ; CX = count

                ClI

                Mov     BL, 2           ; Ctrl=RD_MEM, Data=Memory Address
                Call    ST97OutDWord

                Mov     DX, CS:BasePort ; Length
                Mov     AX, CX
                Call    ST97SendByte

                Mov     AL, AH
                Call    ST97SendByte

ST97InString1:
                Call    ST97InByte
                Cmp     AL, 0ABh
                JE      ST97InStringError
                Cmp     AL, 0ACh
                JNE     ST97InString1

ST97InString2:
                Inc     DX
                Inc     DX

                Rep     InsW

                ClC
                StI
                Ret

ST97InStringError:
                StC
                StI
                Ret

EndP            ST97InString

; ÄÄ ST97ReceiveByte ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97ReceiveByte         ; Returns AL

                Push    DX
                Mov     DX, CS:BasePort
                Inc     DX

ST97ReceiveByte1:
                In      AL, DX
                Test    AL, AL
                JS      ST97ReceiveByte1

                Dec     DX
                In      AL, DX
                Pop     DX

                Ret

EndP            ST97ReceiveByte

; ÄÄ ST97InByte ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97InByte     ; Returns AL

                Jmp     ST97ReceiveByte

EndP            ST97InByte

; ÄÄ ST97InWord ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97InWord     ; Returns AX

                ClI

                Call    ST97ReceiveByte
                Mov     AL, AH

                Call    ST97ReceiveByte
                XChg    AL, AH

                StI

                Ret

EndP            ST97InWord

; ÄÄ ST97InDWord ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97InDWord     ; Returns EAX

                ClI

                Call    ST97ReceiveByte
                RoR     EAX, 8

                Call    ST97ReceiveByte
                RoR     EAX, 8

                Call    ST97ReceiveByte
                RoR     EAX, 8

                Call    ST97ReceiveByte
                RoR     EAX, 8

                StI
                Ret

EndP            ST97InDWord

; ÄÄ ST97SendByte ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97SendByte    ; DX = port, AL = data

                Push    AX
                Push    DX
                Mov     DX, CS:BasePort
                Inc     DX

ST97SendByte1:
                In      AL, DX
                Test    AL, 40h
                JNZ     ST97SendByte1

                Pop     DX
                Pop     AX

                Out     DX, AL

                Ret

EndP            ST97SendByte

; ÄÄ ST97OutByte ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97OutByte     ; AL = data, AH = command, destroys AX

                ClI
                Push    DX

                Mov     DX, CS:BasePort
                Inc     DX

                XChg    AH, AL
                Call    ST97SendByte

                Dec     DX

                Mov     AL, AH
                Call    ST97SendByte

                Pop     DX
                StI

                Ret

EndP            ST97OutByte

; ÄÄ ST97OutWord ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97OutWord     ; AX = data, BL = command, destroys AX

                ClI
                Push    DX
                Push    AX

                Mov     DX, CS:BasePort
                Mov     AL, BL
                Inc     DX
                Call    ST97SendByte

                Pop     AX
                Dec     DX
                Call    ST97SendByte

                Mov     AL, AH
                Call    ST97SendByte

                Pop     DX
                StI

                Ret

EndP            ST97OutWord

; ÄÄ ST97OutDWord ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ST97OutDWord    ; EAX = data, BL = command

                ClI
                Push    DX
                Push    AX

                Mov     DX, CS:BasePort
                Mov     AL, BL
                Inc     DX
                Call    ST97SendByte

                Pop     AX
                Dec     DX
                Call    ST97SendByte

                ShR     EAX, 8
                Call    ST97SendByte

                ShR     EAX, 8
                Call    ST97SendByte

                ShR     EAX, 8
                Call    ST97SendByte

                Pop     DX
                StI

                Ret

EndP            ST97OutDWord

; ÄÄ DetectCard ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Returns carry set if error, else carry clear. Has to setup internal vars
; (eg. appropriate IRQ/DMA whatever).
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PnP_SerialID            DD      0
PnP_VendorID            DD      0
PnP_ReadPort            DW      0
PnP_CSN                 DB      0
PnP_CardFound           DB      0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ResetUART              ; Given DX = Port

                ClI

                Inc     DX

                Mov     AL, 0FFh        ; Reset!
                Out     DX, AL
                Out     DX, AL          ; Two resets required to ensure it'll work

                Xor     CX, CX

ResetUART2:
                In      AL, DX
                Test    AL, 80h
                JNZ     ResetUART3

                Dec     DX
                In      AL, DX
                Inc     DX
                Cmp     AL, 0FEh
                JE      ResetUART4

ResetUART3:
                Loop    ResetUART2

ResetUARTError:
                StI
                StC
                Ret

ResetUART4:                    ; Now to shove it into 'intelligent' mode.
                Xor     CX, CX

ResetUART5:
                In      AL, DX
                Test    AL, 40h
                LoopNZ  ResetUART5
                JNZ     ResetUARTError

                Mov     AL, 3Fh         ; Intelligent mode!
                Out     DX, AL

ResetUART6:
                Xor     CX, CX

ResetUART7:
                In      AL, DX
                Test    AL, 80h
                JNZ     ResetUART8

                Dec     DX
                In      AL, DX
                Inc     DX
                Cmp     AL, 0FEh
                JE      ResetUART9

ResetUART8:
                Loop    ResetUART7
                Jmp     ResetUARTError

ResetUART9:
                StI
                ClC
                Ret

EndP            ResetUART

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            PnP_Delay
                Assume DS:Driver

                Push    AX CX

                Mov     CX, 180h
PnP_Delay1:
                In      AL, 21h
                Loop    PnP_Delay1

                Pop     CX AX
                Ret

EndP            PnP_Delay

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            PnP_WriteData

                Mov     DX, 279h
                Out     DX, AL

                Mov     AL, AH
                Mov     DH, 0Ah
                Out     DX, AL
                Ret

EndP            PnP_WriteData

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            PnP_ReadData

                Mov     DX, 279h
                Out     DX, AL

                Mov     DX, PnP_ReadPort
                In      AL, DX

                Ret

EndP            PnP_ReadData

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            PnP_Isolate

                Mov     AX, 402h
                Call    Pnp_WriteData   ; Reset CSNs

PnP_IsolateNextCard:
                Mov     AX, 0003h
                Call    PnP_WriteData   ; Wake[0]

                Mov     AX, PnP_ReadPort
                ShL     AX, 6
                Xor     AL, AL
                Call    PnP_WriteData   ; Set Read Data port.

                Call    PnP_Delay
                Call    PnP_Delay
                Call    PnP_Delay
                Call    PnP_Delay

                Mov     AL, 1           ; Serial Isolation
                Mov     DX, 279h
                Out     DX, AL

                Call    PnP_Delay
                Call    PnP_Delay
                Call    PnP_Delay
                Call    PnP_Delay

                Mov     BL, 6Ah
                Mov     CX, 64
                Mov     DX, PnP_ReadPort

                ClI

PnP_Isolate1:
                ShR     PnP_SerialID, 1
                RCR     PnP_VendorID, 1

                Mov     BH, BL
                ShR     BH, 1
                Xor     BH, BL
                ShR     BX, 1
                                
                In      AL, DX
                Mov     AH, AL
                Call    PnP_Delay
                In      AL, DX
                Call    PnP_Delay

                Cmp     AX, 55AAh
                JNE     PnP_Isolate2

                Xor     BL, 80h
                Or      PnP_SerialID, 80000000h

PnP_Isolate2:
                Dec     CX
                JNZ     PnP_Isolate1

                Mov     CX, 8
                Xor     BH, BH

PnP_Isolate3:
                ShR     BH, 1

                In      AL, DX
                Mov     AH, AL
                Call    PnP_Delay
                In      AL, DX
                Call    PnP_Delay
                Cmp     AX, 55AAh
                JNE     PnP_Isolate4

                Or      BH, 80h

PnP_Isolate4:
                Dec     CX
                JNZ     PnP_Isolate3

                StI

                Cmp     BL, BH                  ; Matching Checksum?
                JNE     PnP_IsolateFinished

                                ; assign CSN
                Inc     PnP_CSN

                Mov     AL, 6
                MOv     AH, PnP_CSN
                Call    PnP_WriteData

                Cmp     PnP_VendorID, PNPVENDORID
                JNE     PnP_IsolateNextCard
                Cmp     PnP_SerialID, PNPSERIALID
                JNE     PnP_IsolateNextCard

                Mov     AL, 3
                Call    PnP_WriteData
                Mov     AX, 307h        ; LDN 3
                Call    PnP_WriteData

                Mov     AL, 60h
                Call    PnP_ReadData
                Mov     AH, AL
                Mov     AL, 61h
                Call    PnP_ReadData    ; AX = address.
                Cmp     BasePort, 0FFFFh
                JE      PnPBasePortOK

                Cmp     BasePort, AX
                JNE     PnP_IsolateNextCard

PnPBasePortOK:
                Mov     BasePort, AX

                Mov     AL, 70h
                Call    PnP_ReadData    ; AL[3:0] = IRQ
                And     AX, 15
                JZ      PnP_IsolateNextCard
                Mov     IRQ, AX

                Mov     Pnp_CardFound, 1
                Jmp     PnP_IsolateNextCard

PnP_IsolateFinished:
                Mov     AL, PnP_CSN
                ShL     AL, 1
                Or      AL, PnP_CardFound

                Ret

EndP            PnP_Isolate

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            DetectCard Far          ; returns carry clear if succcesful

                Mov     BasePort, 330h
                Mov     DX, BasePort
                Call    ResetUART

; Find memory mapping table
                Mov     AX, 300h        ; Ctrl 3 (GET_MMT), Data 0
                Call    ST97OutByte
                Call    ST97InDWord

                Push    CS
                Pop     ES
                Mov     CX, MMT_MAXSIZE
                Mov     DI, Offset MMTData
                Call    ST97InString

PnP_DetectEnd:                  ;  Return PnP to wait for key state
                Mov     EAX, 'Jeff'

                Ret

EndP            DetectCard
                Assume DS:Nothing

;ÄÄ InitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Sets up any memory required for output
; Initiates output
;
; Parameters: AX = Number of Channels
;
; If successful, returns:
;   Carry flag clear
;   DS:SI = pointer to text to display
;      AX = parameter 1 in text
;      BX = parameter 2 in text
;      CX = parameter 3 in text
;      DX = parameter 4 in text
;      DI = parameter 5 in text
;
; If unsuccessful, returns:
;   Carry flag set
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            InitSound Far

                Push    CS
                Pop     DS
                        Assume DS:Driver

                Mov     SI, Offset ST97Message
Comment ~
                Mov     AX, BasePort
                Mov     BX, IRQ
                Mov     ECX, DWord Ptr [MMTData+2]
                ShR     ECX, 9
~
                Xor     BX, BX
                Mov     AX, 5100h       ; Cntrl = GET_VOI, Data = 0
                Call    ST97OutByte
                Call    ST97InByte
                Mov     BL, AL
                Mov     AX, BasePort
                Mov     ECX, DWord Ptr [MMTData+2]
                ShR     ECX, 9

                ClC
                Ret

EndP            InitSound
                Assume DS:Nothing

;ÄÄ ReInitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Reinitialises sound output
; Initiates sound output
;
; Parameters: AX = number of channels.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ReInitSound Far

                Ret

EndP            ReInitSound

;ÄÄ UnInitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Stops sound output, releases any memory used by driver
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            UnInitSound Far

                Mov     DX, CS:BasePort
                Inc     DX
                Mov     AL, 0FFh
                Out     DX, AL

                Ret

EndP            UnInitSound

;ÄÄ Poll ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; This procedure is called as often as possible by IT.EXE
; AX = Playmode (0 for nothing in particular, 1 = pattern, 2 = song)
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Poll Far

                Ret

EndP            Poll

;ÄÄ SetTempo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: BX = tempo
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetTempo Far

                Ret

EndP            SetTempo

;ÄÄ SetMixVolume ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: AX = MixVolume
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetMixVolume Far

                Ret

EndP            SetMixVolume

;ÄÄ SetStereo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: AL = Stereo on/off, 0 = off.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetStereo Far

                Ret

EndP            SetStereo

;ÄÄ LoadSample ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: AX = sample to load (0 based)
;             DS:SI points to sample header
;             ES:0 points to first sample
;
; Returns: **Carry set if NO error**
;          **Carry clear if error**
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            LoadSample Far

                StC
                Ret

EndP            LoadSample

;ÄÄ ReleaseSample ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: AX = sample to release (1 based)
;             DS:SI points to sample header
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ReleaseSample Far

                Ret

EndP            ReleaseSample

;ÄÄ ResetMemory ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Frees all on-board memory
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ResetMemory Far

                Ret

EndP            ResetMemory

;ÄÄ GetStatus ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Returns text to show on status line, AX = display parameter
;  Carry set if not to show anything.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            GetStatus Far

                Push    CS
                Pop     DS
                        Assume DS:Driver

                Mov     SI, Offset MMTData+6
                Xor     EAX, EAX

GetStatus1:
                Mov     CX, [SI]
                Add     SI, 6

                Cmp     CX, -1
                JE      GetStatus2

                Cmp     CX, 1
                JA      GetStatus1
                JB      GetStatus1

                Add     EAX, [SI+2]
                Sub     EAX, [SI-4]
                Jmp     GetStatus1

GetStatus2:
                Mov     SI, Offset StatusLine
                ShR     EAX, 9

                ClC
                Ret

EndP            GetStatus
                Assume DS:Nothing

;ÄÄ SoundCardScreen ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Function to have driver interactive part of program
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SoundCardScreen Far

                Xor     AX, AX
                StC
                Ret

EndP            SoundCardScreen

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            GetVariable Far

                Ret

EndP            GetVariable

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetVariable Far

                Ret

EndP            SetVariable

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

EndDriver:

;********  Provided Variable Table *************

MaxNumberOfChannels     DW      64      ; Maximum number of channels the
                                        ; driver can handle.
StopAfterPlay           DW      0
DefaultChannels         DW      64

                        DW      5 Dup (0)

;********  Provided Procedure Table *************

ProvidedTableStart:

        DW      Offset DetectCard

        DW      Offset InitSound        ; Playing related
        DW      Offset ReinitSound
        DW      Offset UninitSound

        DW      Offset Poll

        DW      Offset SetTempo         ; Sound variable related
        DW      Offset SetMixVolume
        DW      Offset SetStereo

        DW      Offset LoadSample       ; Sample related
        DW      Offset ReleaseSample
        DW      Offset ResetMemory
        DW      Offset GetStatus        ; Returns string to show on status line

        DW      Offset SoundCardScreen  ; Sound card 'screen'

        DW      Offset GetVariable      ; For interface
        DW      Offset SetVariable

ProvidedTableEnd:
        DW      32-(ProvidedTableEnd-ProvidedTableStart)/2 Dup (0)

EndS

End
