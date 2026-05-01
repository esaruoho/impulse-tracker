;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Global Key Handler                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                        Jumps

include switch.inc
include network.inc

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Externals                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Segment         Pattern BYTE Public 'Code'
                Extrn   LastInstrument:Byte
                Extrn   Order:Word
                Extrn   MaxRow:Word
                Extrn   NumberOfRows:Word
                Extrn   PatternNumber:Word
EndS

Segment         Inst BYTE Public 'Code'
                Extrn   SampleNumber:Byte
                Extrn   InstrumentScreen:Word
EndS

Segment         Object1 BYTE Public 'Data'
EndS

                Extrn   D_InitLoadModule:Far
                Extrn   D_InitLoadSamples:Far
                Extrn   D_InitLoadInstruments:Far
                Extrn   Display_SelectDisplayList:Far

                Extrn   M_Object1List:Far

                Extrn   I_ClearTables:Far

                Extrn   Music_GetInstrumentMode:Far
                Extrn   Music_GetPlayMode:Far
                Extrn   Music_PlayPattern:Far
                Extrn   Music_PlaySong:Far
                Extrn   Music_Stop:Far
                Extrn   Music_ToggleChannel:Far
                Extrn   Music_GetSlaveChannelInformationTable:Far
                Extrn   Music_IncreaseSpeed:Far
                Extrn   Music_DecreaseSpeed:Far
                Extrn   Music_IncreaseVolume:Far
                Extrn   Music_DecreaseVolume:Far
                Extrn   Music_GetSongSegment:Far
                Extrn   Music_GetDriverScreen:Far

                Extrn   SetInfoLine:Far

                Extrn   PE_GetCurrentPattern:Far
                Extrn   PE_SetPatternModified:far

                Extrn   O1_InstrumentListGeneral:Far
                Extrn   O1_InstrumentListVolume:Far
                Extrn   O1_InstrumentListPanning:Far
                Extrn   O1_InstrumentListPitch:Far

                Extrn   O1_KeyboardList:Far
                Extrn   O1_LoadSampleList:Far
                Extrn   O1_OrderPanningList:Far
                Extrn   O1_PatternEditList:Far
                Extrn   O1_PEConfigList:Far
                Extrn   O1_SampleList:Far
                Extrn   O1_LoadModuleList:Far
                Extrn   O1_ViewInstrumentLibrary:Far
                Extrn   O1_SaveModuleList:Far
                Extrn   O1_LoadInstrumentList:Far
                Extrn   O1_MessageList:Far
                Extrn   O1_OrderVolumeList:Far
                Extrn   O1_DisplayList:Far
                Extrn   I_DrawWaveForm:Far
                Extrn   S_DefineSmallNumbers:Far
                Extrn   S_SaveScreen:Far, S_RestoreScreen:Far
                Extrn   RestoreMouse:Far, RestoreMouseGraphics:Far
                Extrn   D_ClearFileSpecifier:Far
                Extrn   O1_ConfigureITList:Far
                Extrn   O1_ViewSampleLibrary:Far
                Extrn   O1_ConfigurePaletteList:Far
                Extrn   O1_MIDIScreen:Far
                Extrn   O1_TimerList:Far
                Extrn   I_MapEnvelope:Far
                Extrn   NewCharacterSet:Far
                Extrn   S_GetDestination:Far
                Extrn   S_DefineHiASCII:Far

IF MEMORYDEBUG
                Extrn   O1_DebugList:Far
ENDIF

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Globals                                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Global  Glbl_Ctrl_F1:Far
                Global  Glbl_Ctrl_F3:Far
                Global  Glbl_Ctrl_F4:Far
                Global  Glbl_Ctrl_F5:Far
                Global  Glbl_Ctrl_F12:Far
                Global  Glbl_F2:Far
                Global  Glbl_F3:Far
                Global  Glbl_F4:Far
                Global  Glbl_F4_2:Far
                Global  Glbl_F5:Far
                Global  Glbl_F6:Far
                Global  Glbl_Shift_F1:Far
                Global  Glbl_Shift_F6:Far
                Global  Glbl_Shift_F9:Far
                Global  Glbl_F8:Far
                Global  Glbl_F9:Far
                Global  Glbl_F10:Far
                Global  Glbl_F11:Far
                Global  Glbl_F12:Far
                Global  Glbl_Alt_F1:Far
                Global  Glbl_Alt_F2:Far
                Global  Glbl_Alt_F3:Far
                Global  Glbl_Alt_F4:Far
                Global  Glbl_Alt_F5:Far
                Global  Glbl_Alt_F6:Far
                Global  Glbl_Alt_F7:Far
                Global  Glbl_Alt_F8:Far
                Global  Glbl_LeftBrace:Far
                Global  Glbl_RightBrace:Far
                Global  Glbl_LeftSquareBracket:Far
                Global  Glbl_RightSquareBracket:Far
                Global  Glbl_LoadSample:Far
                Global  Glbl_LoadInstrument:Far
                Global  Glbl_GetHeaderMode:Far
                Global  Glbl_SetCurrentMode:Far
                Global  Glbl_GetCurrentMode:Far
                Global  Glbl_SaveMode:Far
                Global  Glbl_RestoreMode:Far

IF TIMERSCREEN
                Global  Glbl_TimerScreen:Far
ENDIF

                Global  CurrentMode:Byte

                Public  Glbl_F2_2
                Public  Glbl_F11_2

IF MEMORYDEBUG
                Global  Glbl_Debug:Far
ENDIF
                Global  Glbl_DriverScreen:Far


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

Segment                 Glbl BYTE Public 'Code'
                        Assume CS:Glbl, DS:Nothing

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Variables                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SLAVECHANNELSIZE        EQU     128

CurrentMode             DB      0               ; 2 = Pattern edit
                                                ; 3 = Sample list
                                                ; 4 = Instrument list
                                                ; 5 = Info list
                                                ; 6 = configure pattern edit
                                                ; 9 = load list
                                                ; 10 = save list
                                                ; 11 = order/panning list
                                                ; 12 = configure IT list
                                                ; 13 = load sample list.
                                                ; 14 = palette config list.
                                                ; 15 = load instrument list
                                                ; 16 = message list
                                                ; 21 = order/volume list
                                                ; 22 = debug
                                                ; 23 = timer
                                                ; 24 = Network screen
                                                ; 31 = MIDI list
                                                ; 1 = Keyboard list
                                                ; 0 = Nothing in particular :)
                                                ; 100 = Driver Screen
                                                ; 200 = Full screen display
                                                ; 201 = VGA display

CurrentMode2    DB      0
CurrentList     DW      0
CurrentListSegment DW   0

TempoSetMsg     DB      "Tempo set to ", 0FDh, "D beats per minute", 0
SpeedSetMsg     DB      "Speed set to ", 0FDh, "D frames per row", 0
VolumeSetMsg    DB      "Global Volume set to ", 0FDh, "D", 0

InstrumentScreenTable   Label
        DW      Offset O1_InstrumentListGeneral
        DW      Offset O1_InstrumentListVolume
        DW      Offset O1_InstrumentListPanning
        DW      Offset O1_InstrumentListPitch

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Functions                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Proc            Glbl_F2 Far

                Call    Glbl_SampleToInstrument
                Cmp     CS:CurrentMode, 2

                JE      Glbl_F2_1

Glbl_F2_2:
                Call    S_DefineSmallNumbers

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 2

                Mov     DX, Offset O1_PatternEditList

                Ret

Glbl_F2_1:
                Mov     CS:CurrentMode, 6

                Mov     AX, Pattern
                Mov     DS, AX
                        Assume DS:Pattern

                Mov     AX, MaxRow
                Inc     AX
                Mov     NumberOfRows, AX

                Mov     DI, Offset O1_PEConfigList
                Mov     CX, 0FFFFh
                Call    M_Object1List
                Call    PE_SetPatternModified

                Mov     AX, Pattern
                Mov     DS, AX
                        Assume DS:Pattern

                Mov     BX, NumberOfRows
                Dec     BX
                Mov     MaxRow, BX

IF NETWORKENABLED
                Call    Network_GetSendQueue
                JZ      Glbl_F2_Network

                Mov     AX, NETWORK_SETPATTERNLENGTH*100h ; Destination ALL
                StosW
                Mov     AH, BL
                Mov     AL, [Byte Ptr PatternNumber]
                StosW

Glbl_F2_Network:
                Call    Network_FinishedSendQueue
ENDIF
                Mov     CS:CurrentMode, 2

                Mov     AX, 1
                Ret

EndP            Glbl_F2
                Assume DS:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F3 Far

                Call    Glbl_InstrumentToSample ; translate F4 -> F3 cursor

                Call    I_DrawWaveForm

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 3

                Mov     DX, Offset O1_SampleList
                Ret

EndP            Glbl_F3

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F4 Far

                                        ; Init SampleNumber
                Call    Glbl_SampleToInstrument

                Mov     AX, Pattern
                Mov     DS, AX
                        Assume DS:Pattern

                Mov     BL, LastInstrument
                And     BL, BL
                JNZ     Glbl_F4_1

                Mov     LastInstrument, 1

Glbl_F4_1:
                Mov     AX, Inst
                Mov     DS, AX
                        Assume DS:Inst
                Mov     SampleNumber, BL

Proc            Glbl_F4_2 Far

                Call    I_MapEnvelope

                Mov     DI, InstrumentScreen
                Add     DI, DI
                Mov     DX, [DI+InstrumentScreenTable]

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 4

                Ret

EndP            Glbl_F4_2

EndP            Glbl_F4
                Assume DS:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F5 Far

                Cmp     CS:CurrentMode, 5
                JE      Glbl_F5_1

                Call    S_DefineSmallNumbers

                Call    Music_GetPlayMode
                Test    AX, AX
                JNZ     Glbl_F5_4

                Call    Music_GetSlaveChannelInformationTable

Glbl_F5_3:
                Test    Byte Ptr [SI], 1
                JNZ     Glbl_F5_4

                Add     SI, SLAVECHANNELSIZE
                Loop    Glbl_F5_3

                Call    I_ClearTables

                Xor     AX, AX
                Call    Music_PlaySong

Glbl_F5_4:
                Jmp     Display_SelectDisplayList

Glbl_F5_1:
                Call    Music_GetPlayMode
                And     AX, AX
                JNZ     Glbl_F5_2

                Call    I_ClearTables

                Xor     AX, AX
                Call    Music_PlaySong

Glbl_F5_2:
                Mov     AX, 1
                Ret

EndP            Glbl_F5

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F6 Far

                Call    I_ClearTables

                Call    PE_GetCurrentPattern
                Xor     CX, CX
                Call    Music_PlayPattern

                Mov     AX, 1
                Ret

EndP            Glbl_F6

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_LoadSample Far

                Call    D_InitLoadSamples

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 13

                Mov     DX, Offset O1_LoadSampleList
                Ret

EndP            Glbl_LoadSample

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_LoadInstrument Far

                Call    D_InitLoadInstruments

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 15

                Mov     DX, Offset O1_LoadInstrumentList
                Ret

EndP            Glbl_LoadInstrument

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Shift_F1 Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 31

                Mov     DX, Offset O1_MIDIScreen
                Ret

EndP            Glbl_Shift_F1

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Shift_F9 Far

                Call    S_DefineHIASCII

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 16

                Mov     DX, Offset O1_MessageList
                Ret

EndP            Glbl_Shift_F9

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Shift_F6 Far

                Call    I_ClearTables

                Mov     AX, Pattern
                Mov     DS, AX
                        Assume DS:Pattern
                Mov     AX, Order

                Call    Music_PlaySong

                Mov     AX, 1
                Ret

EndP            Glbl_Shift_F6
                Assume DS:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F8 Far

                Call    Music_Stop

                Mov     AX, 1
                Ret

EndP            Glbl_F8

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F9 Far

                Call    D_InitLoadModule

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 9

                Mov     DX, Offset O1_LoadModuleList

                Mov     DS, CX
                Mov     BX, DX
                Mov     Word Ptr [BX], 12

                Ret

EndP            Glbl_F9

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F10 Far

                Call    D_InitLoadModule

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 10

                Mov     DX, Offset O1_SaveModuleList

                Mov     DS, CX
                Mov     BX, DX
                Mov     Word Ptr [BX], 15

                Call    D_ClearFileSpecifier

                Ret

EndP            Glbl_F10

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F11 Far

                Cmp     CS:CurrentMode, 11
                JE      Glbl_F11_1

Glbl_F11_2:
                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     DX, Offset O1_OrderPanningList

                Mov     CS:CurrentMode, 11
                Ret

Glbl_F11_1:
                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     DX, Offset O1_OrderPanningList

                Mov     CS:CurrentMode, 21
                Mov     DX, Offset O1_OrderVolumeList
                Ret

EndP            Glbl_F11

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_F12 Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 12

                Mov     DX, Offset O1_ConfigureITList
                Ret

EndP            Glbl_F12

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Ctrl_F1 Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 1

                Mov     DX, Offset O1_KeyboardList
                Ret

EndP            Glbl_Ctrl_F1

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Ctrl_F3 Far

                Call    D_InitLoadSamples

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 13

                Mov     DX, Offset O1_ViewSampleLibrary
                Ret

EndP            Glbl_Ctrl_F3

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Ctrl_F4 Far

                Call    D_InitLoadInstruments

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 15

                Mov     DX, Offset O1_ViewInstrumentLibrary
                Ret

EndP            Glbl_Ctrl_F4

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Ctrl_F5 Far

                Call    I_ClearTables

                Xor     AX, AX
                Call    Music_PlaySong

                Mov     AX, 1
                Ret

EndP            Glbl_Ctrl_F5

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Ctrl_F12 Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 14

                Mov     DX, Offset O1_ConfigurePaletteList

                Ret

EndP            Glbl_Ctrl_F12

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_GetHeaderMode Far

                Push    DS
                Mov     AX, Pattern
                Mov     DS, AX
                        Assume DS:Pattern
                Mov     AL, LastInstrument
                Pop     DS

                Xor     AH, AH

                Cmp     CS:CurrentMode, 3               ; Sample list
                JE      Glbl_GetHeaderMode1

                Cmp     CS:CurrentMode, 13              ; Sample load list
                JE      Glbl_GetHeaderMode1

                Cmp     CS:CurrentMode, 4
                JE      Glbl_GetHeaderMode2

                Call    Music_GetInstrumentMode

Glbl_GetHeaderMode1:
                Ret

Glbl_GetHeaderMode2:
                Push    DS
                Push    AX

                Mov     AX, Inst
                Mov     DS, AX
                        Assume DS:Inst

                Pop     AX
                Mov     AL, SampleNumber

                Pop     DS
                Ret

EndP            Glbl_GetHeaderMode
                Assume DS:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_SetCurrentMode Far

                Mov     CS:CurrentMode, AL

                Ret

EndP            Glbl_SetCurrentMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_GetCurrentMode Far         ; Returns AL

                Mov     AL, CS:CurrentMode

                Ret

EndP            Glbl_GetCurrentMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F1 Far

                Mov     AX, 0
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F1

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F2 Far

                Mov     AX, 1
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F2

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F3 Far

                Mov     AX, 2
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F3

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F4 Far

                Mov     AX, 3
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F4

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F5 Far

                Mov     AX, 4
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F5

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F6 Far

                Mov     AX, 5
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F6

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F7 Far

                Mov     AX, 6
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F7

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_Alt_F8 Far

                Mov     AX, 7
                Call    Music_ToggleChannel

                Mov     AX, 1
                Ret

EndP            Glbl_Alt_F8

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_LeftBrace Far

                Push    CS
                Pop     DS

                Call    Music_IncreaseSpeed
                Mov     SI, Offset SpeedSetMsg
                Call    SetInfoLine

                Mov     AX, 1
                Ret

EndP            Glbl_LeftBrace

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_RightBrace Far

                Push    CS
                Pop     DS

                Call    Music_DecreaseSpeed
                Mov     SI, Offset SpeedSetMsg
                Call    SetInfoLine

                Mov     AX, 1
                Ret

EndP            Glbl_RightBrace

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_LeftSquareBracket Far

                Push    CS
                Pop     DS

                Call    Music_DecreaseVolume

                Mov     SI, Offset VolumeSetMsg
                Call    SetInfoLine

                Mov     AX, 1
                Ret

EndP            Glbl_LeftSquareBracket

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_RightSquareBracket Far

                Push    CS
                Pop     DS

                Call    Music_IncreaseVolume

                Mov     SI, Offset VolumeSetMsg
                Call    SetInfoLine

                Mov     AX, 1
                Ret

EndP            Glbl_RightSquareBracket

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_SaveMode Far

;                Call    S_GetDestination
;                Mov     AX, 0B800h
;                Mov     ES, AX
;                Call    RestoreMouse

                Call    S_SaveScreen

                Mov     AL, CurrentMode
                Mov     CurrentMode2, AL

                Mov     BP, SP
                Mov     AX, [BP+16]
                Mov     CurrentList, AX
                Mov     AX, [BP+18]
                Mov     CurrentListSegment, AX
                Mov     CurrentMode, 0

                Ret

EndP            Glbl_SaveMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_RestoreMode Far

;                Call    NewCharacterSet

                Call    S_RestoreScreen

                Mov     AL, CurrentMode2
                Mov     CurrentMode, AL

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, CurrentListSegment
                Mov     DX, CurrentList

                Ret

EndP            Glbl_RestoreMode

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

IF MEMORYDEBUG

Proc            Glbl_Debug Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 22

                Mov     DX, Offset O1_DebugList
                Ret

EndP            Glbl_Debug

ENDIF

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_SampleToInstrument

                Cmp     CS:CurrentMode, 3
                JNE     Glbl_SampleToInstrument1

                Call    Music_GetSongSegment
                Mov     DS, AX
                        Assume DS:Nothing

                Test    Byte Ptr [DS:2Ch], 4
                JZ      Glbl_SampleToInstrument1

                Mov     AX, Pattern
                Mov     ES, AX
                        Assume ES:Pattern

                Mov     AH, ES:LastInstrument
                Mov     BX, [DS:64712]  ; Offset of first instrument

                                        ; Search for sample in tables.
                Mov     DX, 99

Glbl_SampleToInstrument2:
                Push    BX

                Add     BX, 41h         ; To note/sample tables
                Mov     CX, 120

Glbl_SampleToInstrument4:
                Cmp     [BX], AH
                JE      Glbl_SampleToInstrument3
                Add     BX, 2
                Loop    Glbl_SampleToInstrument4

                Pop     BX
                Add     BX, 554         ; Length of instrument
                Dec     DX
                JNZ     Glbl_SampleToInstrument2

                Ret

Glbl_SampleToInstrument3:
                Pop     BX

                Mov     AL, 100
                Sub     AL, DL
                Mov     ES:LastInstrument, AL

Glbl_SampleToInstrument1:
                Ret

EndP            Glbl_SampleToInstrument
                Assume ES:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Glbl_InstrumentToSample - F4 -> F3 cursor translation
;
; Mirror of Glbl_SampleToInstrument: when transitioning from F4 (instrument
; list, CurrentMode == 4) into F3 (sample list) WITH instrument mode active,
; translate LastInstrument from the F4 cursor's instrument number to the
; sample that instrument plays for note 60 (C-5). That makes F3 land on the
; sample the user actually cares about instead of blindly mirroring slot N.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_InstrumentToSample

                Cmp     CS:CurrentMode, 4       ; only when coming from F4
                JNE     Glbl_InstrumentToSample1

                Call    Music_GetSongSegment
                Mov     DS, AX
                        Assume DS:Nothing

                Test    Byte Ptr [DS:2Ch], 4    ; only in instrument mode
                JZ      Glbl_InstrumentToSample1

                Mov     AX, Pattern
                Mov     ES, AX
                        Assume ES:Pattern

                Mov     AL, ES:LastInstrument   ; 1-based instrument number
                Test    AL, AL
                JZ      Glbl_InstrumentToSample1
                Cmp     AL, 99                  ; bounds check
                JA      Glbl_InstrumentToSample1

                Push    BX
                Push    CX
                Push    DX

                ; Compute base of instrument N: [DS:64712] + (N-1)*554
                Xor     BH, BH
                Mov     BL, AL
                Dec     BX                      ; 0-based
                Mov     AX, 554
                Mul     BX                      ; AX = (N-1)*554
                Add     AX, [DS:64712]          ; AX = instrument N base
                Add     AX, 41h                 ; +65 = first note's sample byte
                Mov     BX, AX

                ; Try note 60 first (most common pitch); if that's empty,
                ; scan all 120 notes for the first non-zero entry.
                Mov     AL, [DS:BX+60*2]
                Test    AL, AL
                JNZ     Glbl_InstrumentToSample2

                Mov     CX, 120
Glbl_InstrumentToSample3:
                Mov     AL, [DS:BX]
                Test    AL, AL
                JNZ     Glbl_InstrumentToSample2
                Add     BX, 2
                Loop    Glbl_InstrumentToSample3
                ; All 120 entries are zero -- instrument has no sample mapped.
                Pop     DX
                Pop     CX
                Pop     BX
                Jmp     Glbl_InstrumentToSample1

Glbl_InstrumentToSample2:
                ; AL = sample number; bounds-check it too
                Cmp     AL, 99
                JA      Glbl_InstrumentToSample4
                Mov     ES:LastInstrument, AL
Glbl_InstrumentToSample4:
                Pop     DX
                Pop     CX
                Pop     BX

Glbl_InstrumentToSample1:
                Ret

EndP            Glbl_InstrumentToSample
                Assume ES:Nothing

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

IF TIMERSCREEN

Proc            Glbl_TimerScreen Far

                Mov     AX, 5
                Mov     SI, 1
                Mov     CX, Object1
                Mov     CS:CurrentMode, 23

                Mov     DX, Offset O1_TimerList
                Ret

EndP            Glbl_TimerScreen

ENDIF

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc            Glbl_DriverScreen Far

                Call    Music_GetDriverScreen
                JC      Glbl_DriverScreen1

                Mov     CurrentMode, 100

Glbl_DriverScreen1:
                Ret

EndP            Glbl_DriverScreen

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

EndS

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

End
