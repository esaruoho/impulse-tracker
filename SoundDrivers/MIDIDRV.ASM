;
; MIDI MPU401 Driver for Impulse Tracker.
; Accepts MIDI Input, does MIDI output, but does NOT handle samples at all.
;

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

OldIRQHandler           DD      0
MIDIUpdateTimer         DW      0
MIDIUpdateCount         DW      0
MIDIUpdateFlag          DB      0
MIDIDriverMsg           DB      "MPU401 or compatible detected", 13
                        DB      "Address ", 0FDh, "Xh", 0
MIDIReinitMsg           DB      "MPU401 reinitialised", 0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            ResetUART               ; Given DX = port.

                ClI

                Inc     DX

                Xor     CX, CX

ResetUART1:
                In      AL, DX
                Test    AL, 40h
                LoopNZ  ResetUART1
                JNZ     ResetUARTFailed

                Mov     AL, 0FFh
                Out     DX, AL

                Xor     CX, CX

ResetUART2:
                In      AL, DX
                Test    AL, 80h
                LoopNZ  ResetUART2
                JNZ     ResetUARTFailed

                Dec     DX
                In      AL, DX
                Inc     DX
                Cmp     AL, 0FEh
                JNE     ResetUART2

                Dec     DX

                DB      85h

ResetUARTFailed:
                StC
                Ret

EndP            ResetUART

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetUARTMode

                Mov     DX, CS:BasePort
                Inc     DX

                Xor     CX, CX

SetUARTMode1:
                In      AL, DX
                Test    AL, 40h
                LoopNZ  SetUARTMode1
                JNZ     SetUARTModeFailed

                Mov     AL, 3Fh
                Out     DX, AL

                Xor     CX, CX

SetUARTMode2:
                In      AL, DX
                Test    AL, 80h
                LoopNZ  SetUARTMode2
                JNZ     SetUARTModeFailed

                Dec     DX
                In      AL, DX
                Inc     DX
                Cmp     AL, 0FEh
                JNE     SetUARTMode2
                Dec     DX

                DB      85h

SetUARTModeFailed:
                StC
                StI
                Ret

EndP            SetUARTMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            UARTOut         ; AL = byte out

                Push    CX
                Push    DX
                Mov     DX, CS:Baseport

                Push    AX
                Xor     CX, CX
                Inc     DX

UARTOut1:
                In      AL, DX
                Test    AL, 40h
                LoopNZ  UARTOut1

                Pop     AX
                JNZ     UARTOutEnd

                Dec     DX
                Out     DX, AL

UARTOutEnd:
                Pop     DX
                Pop     CX

                Ret

EndP            UARTOut

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

InterpretState  DB      0

Proc            SendUARTOut Far ; Local interpreter activated with 0F0h 0F0h.

                Mov     AH, CS:InterpretState
                Cmp     AH, 2
                JB      SendUARTOut1
                JE      SendUARTOutStateInc

                Mov     CS:InterpretState, 0

SendUARTOut4:
                Ret

SendUARTOut1:
                Cmp     AL, 0F0h
                JNE     SendUARTOut2

SendUARTOutStateInc:
                Inc     CS:InterpretState
                Ret

SendUARTOut2:
                Test    AH, AH
                JZ      SendUARTOutEnd

                Push    AX
                Mov     AL, 0F0h
                Call    UARTOut
                Pop     AX
                Mov     CS:InterpretState, 0

SendUARTOutEnd:
                Call    UARTOut
                Ret

EndP            SendUARTOut

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            MIDIIRQHandler

                PushAD

                Mov     AX, MIDIUpdateTimer
                Add     MIDIUpdateCount, AX
                JC      MIDIIRQHandler1

                Mov     AL, 20h
                Out     20h, AL
                Jmp     MIDIIRQHandler2

MIDIIRQHandler1:
                PushF
                Call    [OldIRQHandler]

MIDIIRQHandler2:
                Xor     MIDIUpdateFlag, 1
                JZ      MIDIIRQHandlerEnd

                Push    DS
                Push    ES

                ClD

                Call    SaveEMSPageFrame
                Call    Update          ; Returns DS:SI, CX

; Have to clear any sample channels playing.
; Kill any active channel

MIDIIRQHandler3:
                Test    Byte Ptr [SI], 1        ; Channel on?
                JZ      MIDIIRQHandler4

                Mov     Word Ptr [SI], 0

                Test    Byte Ptr [SI+3Ah], 80h
                JNZ     MIDIIRQHandler4

                Mov     BX, [SI+38h]
                And     Byte Ptr [BX], Not 4    ; Signify channel off

MIDIIRQHandler4:
                Add     SI, 128
                Dec     CX
                JNZ     MIDIIRQHandler3

                Call    RestoreEMSPageFrame

                Pop     ES
                Pop     DS

MIDIIRQHandlerEnd:
                PopAD
                IRet

EndP            MIDIIRQHandler

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetIRQ

                Mov     AL, 34h
                Out     43h, AL

                Xor     AX, AX
                Mov     ES, AX
                Mov     AX, CS
                ShL     EAX, 16
                Mov     AX, Offset MIDIIRQHandler
                Mov     [ES:20h], EAX

                Ret

EndP            SetIRQ

; ÄÄ DetectCard ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Returns carry set if error, else carry clear. Has to setup internal vars
; (eg. appropriate IRQ/DMA whatever).
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            DetectCard Far

                Mov     DX, CS:BasePort
                Cmp     DX, 0FFFFh
                JNE     DetectCard1

                Mov     DX, 330h
                Call    ResetUART
                JNC     DetectCard2

                Mov     DX, 300h

DetectCard1:
                Call    ResetUART

DetectCard2:
                Mov     CS:BasePort, DX
                Mov     EAX, 'Jeff'
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
                        Assume DS:Driver

                Xor     AX, AX
                Mov     ES, AX
                Mov     EAX, [ES:20h]
                Mov     OldIRQHandler, EAX
                Call    SetIRQ

                Call    SetUARTMode

                Mov     SI, Offset MIDIDriverMsg
                Mov     AX, BasePort

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

                Push    CS
                Pop     DS
                        Assume DS:Driver

                Mov     SI, Offset MIDIReinitMsg
                Mov     BX, 40
                Call    SetInfoLine

                Mov     DX, BasePort
                Call    ResetUART

                Call    SetIRQ
                Call    SetUARTMode

                Ret

EndP            ReInitSound
                Assume DS:Nothing

;ÄÄ UnInitSound ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Stops sound output, releases any memory used by driver
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            UnInitSound Far

                Mov     DX, CS:BasePort
                Call    ResetUART
                StI

                Xor     AX, AX
                Mov     ES, AX
                Mov     EAX, CS:OldIRQHandler
                Mov     [ES:20h], EAX

                Xor     AL, AL
                Out     40h, AL         ; Timer IRQ.
                Out     40h, AL

                Ret

EndP            UnInitSound

;ÄÄ Poll ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; This procedure is called as often as possible by IT.EXE
; AX = Playmode (0 for nothing in particular, 1 = pattern, 2 = song)
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Poll Far

                ClI

                Call    [UARTBufferEmpty]
                JC      Poll1

PollEnd:
                StI
                Ret

Poll1:
                Mov     DX, BasePort
                Inc     DX

                In      AL, DX
                Test    AL, AL
                JS      PollEnd

                Dec     DX
                In      AL, DX

                Call    [CS:UARTSend]
                Jmp     Poll

EndP            Poll

;ÄÄ SetTempo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Parameters: BX = tempo
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            SetTempo Far

                Push    AX
                Push    BX
                Push    DX

                                        ; Frames per second = 2 * (0.4*Tempo)
                Mov     AX, 0C214h
                Mov     DX, 16h         ; Ticks = (1193181/(2*0.4))/Tempo
                Div     BX

                                        ; AX contains counter.
                Mov     CS:MIDIUpdateTimer, AX

                Out     40h, AL         ; Timer IRQ.
                Mov     AL, AH
                Out     40h, AL

SetTempo2:
                Pop     DX
                Pop     BX
                Pop     AX
                Ret

EndP            SetTempo

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

EndDriver:

;********  Provided Variable Table *************

MaxNumberOfChannels     DW      64      ; Maximum number of channels the
                                        ; driver can handle.
StopAfterPlay           DW      0
DefaultChannels         DW      64
DriverFlags             DW      1       ; Handles MIDI Output

                        DW      4 Dup (0)

;********  Provided Procedure Table *************

ProvidedTableStart:

        DW      Offset DetectCard

        DW      Offset InitSound        ; Playing related
        DW      Offset ReinitSound
        DW      Offset UninitSound

        DW      Offset Poll

        DW      Offset SetTempo         ; Sound variable related
        DW      Offset SoundCardScreen  ; SetMixVolume
        DW      Offset SoundCardScreen  ; SetStereo

        DW      Offset SoundCardScreen  ; LoadSample
        DW      Offset SoundCardScreen  ; ReleaseSample
        DW      Offset SoundCardScreen  ; ResetMemory

        DW      Offset SoundCardScreen  ; GetStatus
        DW      Offset SoundCardScreen  ; SoundCardScreen
        DW      Offset SoundCardScreen  ; GetVariable
        DW      Offset SoundCardScreen  ; SetVariable

        DW      Offset SendUARTOut

ProvidedTableEnd:
        DW      32-(ProvidedTableEnd-ProvidedTableStart)/2 Dup (0)

EndS

End
