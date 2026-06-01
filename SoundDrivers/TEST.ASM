
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

; ÄÄ Variables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

TestDriverMsg   DB      "Test Driver", 13
                DB      "(No sound output)", 0
TestReinitMsg   DB      "Test driver: Reinitialise received", 0
Filler          DB      8039 Dup (0)

; ÄÄ EmptyFunction ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            EmptyFunction Far

                Xor     AX, AX
                StC
                Ret

EndP            EmptyFunction

; ÄÄ DetectCard ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Returns carry set if error, else carry clear. Has to setup internal vars
; (eg. appropriate IRQ/DMA whatever).
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            DetectCard Far

                Mov     EAX, 'Jeff'
                ClC
                Ret

EndP            DetectCard

;ÄÄ InitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Sets up any memory required for output
; Initiates output
;
; Parameters: AX = Number of Channels
;
; If sucessful, returns:
;   Carry flag clear
;   DS:SI = pointer to text to display
;      AX = parameter 1 in text
;      BX = parameter 2 in text
;      CX = parameter 3 in text
;      DX = parameter 4 in text
;      DI = parameter 5 in text
;
; If unsucessful, returns:
;   Carry flag set
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            InitSound Far

                Push    CS
                Pop     DS

                Mov     SI, Offset TestDriverMsg

                ClC
                Ret

EndP            InitSound

;ÄÄ ReInitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Reinitialises sound output
; Initiates sound output
;
; Parameters: AX = number of channels.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ReInitSound Far

                Push    CS
                Pop     DS
                Mov     SI, Offset TestReinitMsg
                Mov     BX, 200
                Call    SetInfoLine

                Ret

EndP            ReInitSound

;ÄÄ UnInitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Stops sound output, releases any memory used by driver
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            UnInitSound Far

                Ret

EndP            UnInitSound

;ÄÄ Poll ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; This procedure is called as often as possible by IT.EXE
; AX = Playmode (0 for nothing in particular, 1 = pattern, 2 = song)
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Poll Far

                Call    SaveEMSPageFrame
                Call    Update
                Call    RestoreEMSPageFrame

                Ret

EndP            Poll

;ÄÄ SetTempo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: AX = tempo
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
; Parameters: AX = sample to load
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
; Parameters: AX = sample to release
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

                StC
                Ret

EndP            GetStatus

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

MaxNumberOfChannels     DW      0FFFFh  ; Maximum number of channels the
                                        ; driver can handle.
                        DW      0       ; Stop after play flag.
DefaultChannels         DW      64
                        DW      0       ; Flags, MIDI, Hiqual, Waveform
                        DW      4 Dup (0)

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
