;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
;ï¿½ Main Module                                                                 ï¿½
;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

                        Jumps
                        .386

include switch.inc

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
;ï¿½ Externals                                                                   ï¿½
;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

Segment         Object1 BYTE Public 'Data' USE16
EndS


                Extrn   F_DrawStringInput:Far
                Extrn   F_PreStringInput:Far
                Extrn   F_PostStringInput:Far
                Extrn   F_Nothing:Far
                Extrn   F_DrawBoxObject:Far
                Extrn   F_DrawTextObject:Far
                Extrn   F_PostExitObject:Far
                Extrn   F_SetDirectMode:Far
                Extrn   F_CharacterDefinitions:Far
                Extrn   F_DrawButtonObject:Far
                Extrn   F_PreButtonObject:Far
                Extrn   F_PostButtonObject:Far
                Extrn   F_CallFarFunction:Far
                Extrn   F_DrawThumbBar:Far
                Extrn   F_DrawScalableThumbBar:Far
                Extrn   F_PreThumbBar:Far
                Extrn   F_PreScalableThumbBar:Far
                Extrn   F_PostThumbBar:Far
                Extrn   F_PostScalableThumbBar:Far
                Extrn   F_DrawInfoLine:Far
                Extrn   F_CallFarPreFunction:Far
                Extrn   F_CallFarPostFunction:Far
                Extrn   F_DrawToggle:Far
                Extrn   F_PreToggle:Far
                Extrn   F_PostToggle:Far

                Extrn   F_Draw5Num:Far
                Extrn   F_Pre5Num:Far
                Extrn   F_Post5Num:Far

                Extrn   F_Draw3Num:Far
                Extrn   F_Pre3Num:Far
                Extrn   F_Post3Num:Far

                Extrn   Glbl_TutorialHandler:Far

                Extrn   H_SetHelpContext:Far

                Extrn   K_GetKey:Far
                Extrn   K_InitKeyBoard:Far
                Extrn   K_UnInitKeyBoard:Far
                Extrn   K_IsKeyWaiting:Far
                Extrn   K_IsAnyKeyDown:Far
                Extrn   K_PollRightShiftTap:Far
                Extrn   Music_BatchRenderPatterns:Far
                Extrn   D_DumpAllSamplesWAV:Far
                Extrn   Quit_NoConfirm:Far
                Extrn   SetInfoLine:Far         ; confirming the screen grab
                                                ; the grab lands in the Quicksave
                                                ; folder, not in whatever directory
                                                ; the loader last wandered into
                Extrn   D_SaveCwd:Far
                Extrn   D_RestoreCwd:Far
                Extrn   D_GotoRenderDirectory:Far

                Extrn   PE_DrawOrderList:Far
                Extrn   PE_PreOrderList:Far
                Extrn   PE_PostOrderList:Far

                Extrn   S_Set80x25Mode:Far
                Extrn   S_SetPalette:Far
                Extrn   S_RedefineCharacters:Far
                Extrn   S_DrawBox:Far
                Extrn   S_ClearScreen:Far
                Extrn   S_UpdateScreen:Far

;                Extrn   MouseDirectEnable:Far, MouseDirectDisable:Far
                Extrn   MouseSaveEvents:Far, MouseRestoreEvents:Far
                Extrn   MouseInput:Far, MouseClearEvents:Far
                Extrn   GetKeyboardLock:Far, MIDIBufferEmpty:Far

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
;ï¿½ Globals                                                                     ï¿½
;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

                Global  M_FunctionDivider:Far
                Global  M_FunctionHandler:Far
                Global  M_Object1List:Far
                Global  M_Object1ListDefault:Far
                Global  M_ScreenGrabKey:Far
                Public  ReleaseTimeSlice
                                                ; headless batch flags, set by the
                                                ; command line in IT.ASM
                                                ; FEATURE-CARD >> features/headless-batch-render.feature
                Public  BatchRenderFlag
                Public  BatchRenderPattern
                Public  BatchDumpFlag
                                                ; headless screenshotter
                                                ; FEATURE-CARD >> features/headless-screenshot.feature
                Public  ScreenGrabFlag
                Public  ScreenGrabKeys
                Public  ScreenGrabCount

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

Segment                 Main DWORD Public 'Code' USE16
                        Assume CS:Main, DS:Nothing

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
;ï¿½ Variables                                                                   ï¿½
;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

DrawObjectList          Label   DWord
                        DD      DWord Ptr F_DrawBoxObject       ; 0
                        DD      DWord Ptr F_DrawTextObject      ; 1
                        DD      DWord Ptr F_DrawButtonObject    ; 2
                        DD      DWord Ptr F_Nothing     ; Empty obj number, 3
                        DD      DWord Ptr F_Nothing             ; 4
                        DD      DWord Ptr F_SetDirectMode       ; 5
                        DD      DWord Ptr F_CharacterDefinitions ; 6
                        DD      DWord Ptr F_Nothing     ; Empty obj number 7
                        DD      DWord Ptr F_CallFarFunction     ; 8
                        DD      DWord Ptr F_DrawThumbBar        ; 9
                        DD      DWord Ptr F_DrawInfoLine        ; 10
                        DD      DWord Ptr H_SetHelpContext      ; 11
                        DD      DWord Ptr PE_DrawOrderList      ; 12
                        DD      DWord Ptr F_Draw3Num            ; 13
                        DD      DWord Ptr F_DrawScalableThumbBar ; 14
                        DD      DWord Ptr F_CallFarFunction     ; 15
                        DD      DWord Ptr F_DrawStringInput     ; 16
                        DD      DWord Ptr F_DrawToggle          ; 17
                        DD      DWord Ptr F_Draw5Num            ; 18


PreFunctionList         Label   DWord
                        DD      DWord Ptr F_Nothing             ; 0
                        DD      DWord Ptr F_Nothing             ; 1
                        DD      DWord Ptr F_PreButtonObject     ; 2
                        DD      DWord Ptr F_Nothing             ; 3
                        DD      DWord Ptr F_Nothing             ; 4
                        DD      DWord Ptr F_Nothing             ; 5
                        DD      DWord Ptr F_Nothing             ; 6
                        DD      DWord Ptr F_Nothing             ; 7
                        DD      DWord Ptr F_Nothing             ; 8
                        DD      DWord Ptr F_PreThumbBar         ; 9
                        DD      DWord Ptr F_Nothing             ; 10
                        DD      DWord Ptr F_Nothing             ; 11
                        DD      DWord Ptr PE_PreOrderList       ; 12
                        DD      DWord Ptr F_Pre3Num             ; 13
                        DD      DWord Ptr F_PreScalableThumbBar ; 14
                        DD      DWord Ptr F_CallFarPreFunction  ; 15
                        DD      DWord Ptr F_PreStringInput      ; 16
                        DD      DWord Ptr F_PreToggle           ; 17
                        DD      DWord Ptr F_Pre5Num             ; 18

PostFunctionList        Label   DWord
                        DD      DWord Ptr F_Nothing             ; 0
                        DD      DWord Ptr F_Nothing             ; 1
                        DD      DWord Ptr F_PostButtonObject    ; 2
                        DD      DWord Ptr F_Nothing             ; 3
                        DD      DWord Ptr F_PostExitObject      ; 4
                        DD      DWord Ptr F_Nothing             ; 5
                        DD      DWord Ptr F_Nothing             ; 6
                        DD      DWord Ptr F_Nothing             ; 7
                        DD      DWord Ptr F_Nothing             ; 8
                        DD      DWord Ptr F_PostThumbBar        ; 9
                        DD      DWord Ptr F_Nothing             ; 10
                        DD      DWord Ptr F_Nothing             ; 11
                        DD      DWord Ptr PE_PostOrderList      ; 12
                        DD      DWord Ptr F_Post3Num            ; 13
                        DD      DWord Ptr F_PostScalableThumbBar ; 14
                        DD      DWord Ptr F_CallFarPostFunction ; 15
                        DD      DWord Ptr F_PostStringInput     ; 16
                        DD      DWord Ptr F_PostToggle          ; 17
                        DD      DWord Ptr F_Post5Num            ; 18

GlobalKeyList           DD      ?
ReleaseTimeSlice        DB      0
BatchRenderFlag         DB      0       ; 1 = render then quit  (cmdline /O)
BatchRenderPattern      DW      0FFFFh  ;     0FFFFh = every pattern with data
BatchDumpFlag           DB      0       ; 1 = dump samples then quit (cmdline /U)
ScreenGrabFlag          DB      0       ; 1 = grab the screen then quit (cmdline /G)
ScreenGrabKeys          DW      0, 0, 0, 0
                                        ; up to four key words to send before the
                                        ; grab, so a page behind a dialog is reachable
                                        ; (e.g. Enter to clear the sound-card notice,
                                        ; then the key for the page you want)
ScreenGrabCount         DB      0       ; how many were given on the command line
ScreenGrabNext          DB      0       ; how many have been sent
ScreenGrabWait          DB      0       ; idle passes left to settle before grabbing
                                        ; SCR-nn.TXT, nn counting up from 01 so a
                                        ; run of grabs does not overwrite itself.
                                        ; 8.3 names only -- "scr-midiscr.txt" is 11
                                        ; characters before the dot and DOS would
                                        ; mangle it.
ScreenGrabName          DB      "SCR-01.TXT", 0
SCREENGRABDIGITS        EQU     Offset ScreenGrabName + 4
ScreenGrabRow           DB      80 Dup (' '), 13, 10
SCREENGRABROWLEN        EQU     82      ; 80 columns + CRLF. Was "$ - ScreenGrabRow"
                                        ; with the message strings defined in between,
                                        ; so every captured row carried both messages.
ScreenGrabOK            DB      0
ScreenGrabOKMsg         DB      "Screen written to Quicksave folder as SCR-nn.TXT", 0
ScreenGrabFailMsg       DB      "Screen grab FAILED (check the Quicksave folder in F12)", 0

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
;ï¿½ Functions                                                                   ï¿½
;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

; M_ScreenGrab -- write the 80x50 text screen to SCREEN.TXT in the current
; directory: one line per row, characters only (attributes dropped -- this is for
; reading a layout, not reproducing colours).
;
; Reads video memory at B800:0000 directly, the same primitive the fork's VRAM debug
; markers use. IT draws through its own buffer but blits to VRAM, so by the time the
; idle list has run the text is really there. All registers preserved.
; FEATURE-CARD >> features/headless-screenshot.feature
; Shift-Alt-Y from any screen: write SCREEN.TXT and carry on. Same grabber the /G
; switch uses, so what the operator captures interactively and what a headless run
; captures are the same bytes. The pattern editor binds Shift-Alt-Y to its own
; halve+tile op via 2222h -- this is 1515h, which was unbound everywhere.
; FEATURE-CARD >> features/headless-screenshot.feature
Proc            M_ScreenGrabKey Far

                Call    M_ScreenGrab

                                                ; Say so. Without this the key looked
                                                ; like it had done nothing at all --
                                                ; the file appeared on the share but
                                                ; the person pressing it had no way to
                                                ; know, which is the same class of
                                                ; problem as a batch export that only
                                                ; reports when it finishes.
                Push    DS
                Push    CS
                Pop     DS
                        Assume DS:Main
                Mov     SI, Offset ScreenGrabOKMsg
                Cmp     Byte Ptr [ScreenGrabOK], 0
                JNE     M_SGK_Say
                Mov     SI, Offset ScreenGrabFailMsg
M_SGK_Say:
                Call    SetInfoLine
                Pop     DS
                        Assume DS:Nothing

                Mov     AX, 1
                Ret
EndP            M_ScreenGrabKey

;-------------------------------------------------------------------------------

Proc            M_ScreenGrab Near

                PushF
                PushAD
                Push    DS
                Push    ES

                Push    CS
                Pop     DS
                        Assume DS:Main

                Mov     Byte Ptr [ScreenGrabOK], 0

                                                ; Go where the operator can actually
                                                ; get at it. IT's cwd follows the file
                                                ; browser around, so a relative create
                                                ; can land anywhere -- the first grab
                                                ; from the real machine went somewhere
                                                ; nobody could find.
                Call    D_SaveCwd
                Call    D_GotoRenderDirectory

                Mov     DX, Offset ScreenGrabName
                Mov     AH, 3Ch                 ; create / truncate
                Xor     CX, CX
                Int     21h
                JC      M_SG_Done
                Mov     BP, AX                  ; BP = file handle
                Mov     Byte Ptr [ScreenGrabOK], 1

                Xor     SI, SI                  ; SI = VRAM offset
                Mov     BL, 50                  ; rows to go

M_SG_Row:
                Push    BX
                Mov     DI, Offset ScreenGrabRow
                Mov     CX, 80
                Mov     AX, 0B800h
                Mov     ES, AX

M_SG_Cell:
                Mov     AL, [ES:SI]             ; character byte
                Add     SI, 2                   ; step over the attribute
                Test    AL, AL                  ; a NUL would truncate the line
                JNZ     M_SG_Store
                Mov     AL, ' '
M_SG_Store:
                Mov     [DI], AL
                Inc     DI
                Loop    M_SG_Cell

                Mov     BX, BP                  ; write the row + CRLF
                Mov     CX, SCREENGRABROWLEN
                Mov     DX, Offset ScreenGrabRow
                Mov     AH, 40h
                Int     21h

                Pop     BX
                Dec     BL
                JNZ     M_SG_Row

                Mov     BX, BP
                Mov     AH, 3Eh
                Int     21h

                                                ; bump nn for the next grab
                Inc     Byte Ptr [SCREENGRABDIGITS+1]
                Cmp     Byte Ptr [SCREENGRABDIGITS+1], '9'
                JBE     M_SG_Rolled
                Mov     Byte Ptr [SCREENGRABDIGITS+1], '0'
                Inc     Byte Ptr [SCREENGRABDIGITS]
                Cmp     Byte Ptr [SCREENGRABDIGITS], '9'
                JBE     M_SG_Rolled
                Mov     Word Ptr [SCREENGRABDIGITS], '10'   ; wrap back to 01
M_SG_Rolled:

M_SG_Done:
                Call    D_RestoreCwd
                Pop     ES
                Pop     DS
                PopAD
                PopF
                Ret
                        Assume DS:Nothing
EndP            M_ScreenGrab

;-------------------------------------------------------------------------------

Proc            M_FunctionDivider Far           ; Given DS:SI points to list
                                                ; Carry set if none found
                Push    BX

M_FunctionDivider1:                             ; 0 = Direct comparison
                                                ; 1 = Key comparison
                                                ; 2 = Alt, 3 = Ctrl, 4 = Shift
                                                ; 5 = capital key comparison
                                                ; 6 = MIDI message
                LodsB
                Test    AL, AL
                JS      M_FunctionDivider4      ; End of list

                Mov     BX, CX
                JZ      M_FunctionDivider2      ; If AL = 0

                Cmp     AL, 2
                JE      M_FunctionDivider8
                JB      M_FunctionDivider5

                Cmp     AL, 4
                JB      M_FunctionDivider18
                JE      M_FunctionDivider10     ; If AL = 4

                Cmp     AL, 6
                JB      M_FunctionDividerCAPS

M_FunctionDividerMIDI:
                Test    CL, CL
                JNZ     M_FunctionDivider9
                Mov     BX, CX
                And     BX, 0F000h
                Jmp     M_FunctionDividerCheck

M_FunctionDividerCAPS:
                Mov     BX, DX
                Cmp     BX, 'a'
                JB      M_FunctionDivider6
                Cmp     BX, 'z'
                JA      M_FunctionDivider9

                Sub     BL, 32

M_FunctionDivider6:
                Cmp     BX, 'A'
                JB      M_FunctionDivider9
                Cmp     BX, 'Z'
                JA      M_FunctionDivider9
                Jmp     M_FunctionDivider2

M_FunctionDivider5:
                Mov     BX, DX                  ; If al = 1...
                Jmp     M_FunctionDivider2

M_FunctionDivider8:
                Test    CH, 60h
                JZ      M_FunctionDivider9

                And     BX, 1FFh
                Jmp     M_FunctionDivider2

M_FunctionDivider18:
                Test    CH, 18h                 ; Ctrl
                JZ      M_FunctionDivider9
                And     BX, 1FFh

                Jmp     M_FunctionDivider2

M_FunctionDivider10:
                Test    CH, 6
                JZ      M_FunctionDivider9
                And     BX, 1FFh

M_FunctionDivider2:
                Test    CL, CL
                JZ      M_FunctionDivider9

M_FunctionDividerCheck:
                LodsW
                Cmp     AX, BX
                JE      M_FunctionDivider3

                LodsW
                Jmp     M_FunctionDivider1

M_FunctionDivider9:
                LodsW
                LodsW
                Jmp     M_FunctionDivider1

M_FunctionDivider3:
                DB      85h     ; ClC
M_FunctionDivider4:             ;
                StC             ;

                Pop     BX

                Ret

EndP            M_FunctionDivider

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

Proc            M_FunctionHandler Far
                ARG     ObjectList:DWord

                Push    BP
                Mov     BP, SP

                Call    MouseSaveEvents

M_FunctionHandler1:                             ; Draw all objects in list
                Call    GetKeyboardLock
                Cmp     AL, 2
                JE      MouseInput1

                Call    MouseClearEvents

                LDS     SI, ObjectList          ; DS:SI points to object list
                Add     SI, 6                   ; Skip pass list header
                Xor     AX, AX

M_FunctionHandler2:
                Cmp     Word Ptr [SI], 0        ; DS:SI points to an offset of
                JE      M_FunctionHandler4      ;  an object

M_FunctionHandler3:
                Push    AX                      ; AX = object number
                Push    DS
                Push    SI
                Push    BP

                LES     DI, ObjectList          ; ES:DI points to object list
                Mov     SI, [SI]                ; DS:SI points to object
                Mov     BX, [SI]                ; BX = object type
                Mov     CL, 2
                ShL     BX, CL

                Call    DWord Ptr [DrawObjectList+BX]

                Pop     BP
                Pop     SI                      ; DS:SI Points to an offset of
                Pop     DS                      ;  an object
                Pop     AX
                Inc     AX
                Add     SI, 2                   ; Advance Pointer
                Jmp     M_FunctionHandler2      ; Next Object

M_FunctionHandler4:                             ; Call Prefunction for object
                LDS     SI, ObjectList          ; DS:SI points to object list
                Mov     AX, [SI]                ; AX = Active object number
                LEA     SI, [ESI+EAX*2+6]       ; Skip pas list header (+6)
                                                ; AX = object number

                Cmp     Word Ptr [SI], 0        ; if list doesn't point to
                JE      M_FunctionHandler21     ;  anything, don't call prefunc

M_FunctionHandler20:
                Mov     SI, [SI]                ; DS:SI points to object
                Mov     BX, [SI]                ; BX = object type
                ShL     BX, 2

                Push    BP
                Call    DWord Ptr [PreFunctionList+BX]
                Pop     BP

M_FunctionHandler21:

IF TUTORIAL
                Call    Glbl_TutorialHandler
ENDIF

                Call    S_UpdateScreen

M_FunctionHandler5:                             ; Input...
;                Call    K_IsAnyKeyDown
;                And     AL, AL
;                JNZ     M_KeyBoardInput1

MouseInput1:
                Call    MouseInput              ; returns 0 if nothing
                                                ; 1 if input (BX, CX, DX set)
                                                ; 2 if no input, but keyboard
                                                ;   locked
                Cmp     AX, 1
                JB      M_KeyBoardInput1
                JA      M_FunctionHandler6      ; IdleList
                                                ; Handle postobject, of
                                                ; object BX

                Mov     AX, DI
                Cmp     BX, 0FFFFh
                JE      M_FunctionHandler23

                LES     DI, ObjectList          ; ES:DI points to object list
                Push    ES
                Pop     DS

                Mov     [DI], BX                ; Object number in BX.
                LEA     BX, [EBX*2+EDI+6]       ; ES:BX points to offset of
                                                ; active object.

                Mov     SI, [BX]                ; DS:SI points to object

                Mov     SI, [SI]                ; SI = object type of active obj
                ShL     SI, 2

                Push    BP
                Call    DWord Ptr [PostFunctionList+SI]
                Pop     BP
                Jmp     M_FunctionHandler23

M_KeyBoardInput1:
                Call    MIDIBufferEmpty
                JAE     M_FunctionHandler8

                Call    K_IsKeyWaiting

                Test    AX, AX
                JNZ     M_FunctionHandler8

                ; --- headless screenshot, then quit ----------------------------
                ; Boot IT, optionally press ONE key to reach a screen, let it draw,
                ; write the text screen out as SCREEN.TXT, quit. That turns "is the
                ; layout right?" into something answerable from the build machine
                ; rather than a question only the person at the DOS box can answer.
                ; FEATURE-CARD >> features/headless-screenshot.feature
                Cmp     Byte Ptr CS:ScreenGrabFlag, 0
                JE      M_NoGrab

                Mov     AL, CS:ScreenGrabNext
                Cmp     AL, CS:ScreenGrabCount
                JAE     M_GrabSettle
                                                ; Send the next key through the
                                                ; dispatcher exactly as the right-shift
                                                ; tap does, then come back on a later
                                                ; idle pass, once it has been drawn.
                Inc     Byte Ptr CS:ScreenGrabNext
                Xor     AH, AH
                Add     AX, AX
                Mov     BX, AX
                Mov     CX, [CS:ScreenGrabKeys+BX]
                Mov     Byte Ptr CS:ScreenGrabWait, 6
                Mov     DX, CX
                Jmp     M_FunctionHandler9

M_GrabSettle:
                Cmp     Byte Ptr CS:ScreenGrabWait, 0
                JE      M_DoGrab
                Dec     Byte Ptr CS:ScreenGrabWait
                Jmp     M_NoGrab                ; let the idle list redraw first

M_DoGrab:
                Mov     Byte Ptr CS:ScreenGrabFlag, 0
                Call    M_ScreenGrab
                Jmp     Quit_NoConfirm

M_NoGrab:
                ; --- headless batch work, then quit ----------------------------
                ; Runs on the FIRST idle pass, which is the earliest moment that is
                ; safe: the sound driver is loaded (the render swaps it out for
                ; WAVDRV and back), the module named on the command line is loaded,
                ; and the screen is up. Doing it earlier in IT.ASM's startup would
                ; race all three. The flags are cleared before the work so a render
                ; that somehow re-enters the idle path cannot loop forever.
                ; FEATURE-CARD >> features/headless-batch-render.feature
                Cmp     Byte Ptr CS:BatchRenderFlag, 0
                JNE     M_RunBatch
                Cmp     Byte Ptr CS:BatchDumpFlag, 0
                JE      M_NoBatch

M_RunBatch:
                Cmp     Byte Ptr CS:BatchDumpFlag, 0
                JE      M_BatchNoDump
                Mov     Byte Ptr CS:BatchDumpFlag, 0
                Call    D_DumpAllSamplesWAV

M_BatchNoDump:
                Cmp     Byte Ptr CS:BatchRenderFlag, 0
                JE      M_BatchDone
                Mov     Byte Ptr CS:BatchRenderFlag, 0
                Mov     AX, CS:BatchRenderPattern
                Call    Music_BatchRenderPatterns

M_BatchDone:
                Jmp     Quit_NoConfirm          ; no "are you sure" prompt: there is
                                                ; nobody there to answer it

M_NoBatch:
                ; --- bare right-shift TAP -> dispatch as Scroll Lock -----------
                ; THIS is the idle path: no key is queued, so we are about to run
                ; the IdleList. A bare modifier never reaches the translate chain
                ; and so has no key word of its own -- but here we are already in
                ; the dispatcher, one instruction away from where K_GetKey's
                ; result is consumed, so a tap can just BE that result. Feed it
                ; Scroll Lock's word 146h, bound globally to PE_ScrollLockFollow
                ; (IT_OBJ1.ASM:3247), which enters the playing pattern with Follow
                ; on, and toggles Follow off when already in the pattern editor.
                ; So the tap is a second TRIGGER for an existing gesture, not a
                ; second implementation of it.
                ;
                ; Must stay the ONLY consumer of K_PollRightShiftTap: it reports a
                ; tap exactly once, so any second caller eats it first.
                ; features/right-shift-tap.feature
                Call    K_PollRightShiftTap
                Test    AX, AX
                JZ      M_KeyBoardInput_NoTap

                Mov     CX, 146h                ; as a code-0 keymap row sees it
                Mov     DX, CX                  ;   (full CX compare)
                Jmp     M_FunctionHandler9      ; exactly where K_GetKey returns to

M_KeyBoardInput_NoTap:
                                                ; Check for mouse info...

M_FunctionHandler6:                             ; IdleList
                Cmp     CS:ReleaseTimeSlice, 0
                JE      NoReleaseTimeSlice

                Mov     AX, 1680h
                Int     2Fh

NoReleaseTimeSlice:
;                StI

                LDS     SI, ObjectList          ; DS:SI points to object list
                Add     SI, 2                   ; DS:SI points to idle list

                Cmp     Word Ptr [SI], 0
                JE      M_FunctionHandler5      ; If Offset of IdleList = 0,
                                                ;  check for another key

M_FunctionHandler7:
                Mov     SI, [SI]
                Xor     BX, BX                  ; Clear flag.

M_FunctionHandler19:
                Cmp     Word Ptr [SI], 0
                JNE     M_FunctionHandler18

                Cmp     Word Ptr [SI+2], 0
                JE      M_FunctionHandler29

M_FunctionHandler18:
                Push    SI
                Push    BX
                Push    DS
                Push    BP

                Call    DWord Ptr [SI]

                Pop     BP
                Pop     DS
                Pop     BX

                Cmp     AX, 5
                JE      M_FunctionHandlerIdleCommand

                Pop     SI

                Add     SI, 4

                Or      BX, AX
                Jmp     M_FunctionHandler19

M_FunctionHandlerIdleCommand:
                Pop     AX              ; Pull off SI from the stack
                Mov     AX, DI
                Jmp     M_FunctionHandler10
;                Mov     SI, 1
;                Jmp     M_FunctionHandler16

M_FunctionHandler29:
                Test    BX, BX
                JZ      M_FunctionHandler5

                Jmp     M_FunctionHandler1

M_FunctionHandler8:
                Call    K_GetKey                ; CX = Keyboard Input Data
                                                ; DX = Translated Input Data
                                                ; else MIDI input if CL = 0

M_FunctionHandler9:
                LES     DI, ObjectList          ; ES:DI points to object list
                Push    ES
                Pop     DS

                Mov     BX, [DI]                ; BX = active object number
                LEA     BX, [EDI+EBX*2+6]       ; ES:BX points to offset of
                                                ;  active object.
                Xor     AX, AX

                Cmp     Word Ptr [BX], 0
                JE      M_FunctionHandler23

M_FunctionHandler22:
                Mov     SI, [BX]                ; DS:SI points to object

                Mov     SI, [SI]                ; SI = object type of active obj
                ShL     SI, 2

                Push    BP
                Call    DWord Ptr [PostFunctionList+SI]
                Pop     BP

M_FunctionHandler23:
                Push    DS
                Push    SI

                LDS     SI, ObjectList
                Add     SI, 4
                Mov     SI, [SI]
                Mov     Word Ptr CS:GlobalKeyList+2, DS
                Mov     Word Ptr CS:GlobalKeyList, SI

                Pop     SI
                Pop     DS

;                Xor     BX, BX                  ; Extra key list starts at 0

M_FunctionHandler10:
                Cmp     AX, 1
                JB      M_FunctionHandler11     ; If AX = 0
                JE      M_FunctionHandler1      ; Redraw screen if AX = 1

                Cmp     AX, 3
                JB      M_FunctionHandler4      ; Goto preobject if AX = 2
                JE      M_FunctionHandler5      ; Get next input

                Cmp     AX, 5                   ; New list
                JE      M_FunctionHandler16
                JA      M_FunctionHandler11     ; If > 5

                Call    MouseRestoreEvents

                Pop     BP
                Ret     4

M_FunctionHandler16:
                Mov     Word Ptr Offset ObjectList, DX
                Mov     Word Ptr Offset ObjectList+2, CX
                Mov     AX, SI

                Jmp     M_FunctionHandler10

M_FunctionHandler11:
                LDS     SI, CS:GlobalKeyList

                Cmp     Word Ptr [SI], 0
                JE      M_FunctionHandler4

M_FunctionHandler12:
                LodsB
                Mov     BX, DX
                Cmp     AL, 1
                JE      M_FunctionHandler13     ; Keycode compare (1)
                Mov     BX, CX
                JB      M_FunctionHandler13     ; Scancode compare (0)

                And     BX, 1FFh

                Cmp     AL, 3
                JB      M_FunctionHandlerAlt    ; Alt-keycode compare (2)
                JE      M_FunctionHandlerCtrl   ; Ctrl-keycode compare  (3)

                Cmp     AL, 5
                JB      M_FunctionHandlerForced ; Always call function (4)
                JE      M_FunctionHandlerNewListNear ; Chain to new list (5)

                Cmp     AL, 7
                JB      M_FunctionHandlerShift  ; Shift-keycode compare (6)
                JE      M_FunctionHandlerNewListFar  ; Chain to far list (7)

                Cmp     AL, 9
                JB      M_FunctionHandlerCapCheck ; Capitalised keycode (8)
                JE      M_FunctionHandlerMIDI   ; MIDI message (9)

;                Jmp     M_FunctionHandler1
                Jmp     M_FunctionHandler4      ; Undefined compare..
;                                                ; -> end of list

M_FunctionHandlerAlt:
                Test    CH, 60h
                JZ      M_FunctionHandler14
                Jmp     M_FunctionHandler13

M_FunctionHandlerCtrl:
                Test    CH, 18h
                JZ      M_FunctionHandler14
                Jmp     M_FunctionHandler13

M_FunctionHandlerShift:
                Test    CH, 6h
                JZ      M_FunctionHandler14
                Jmp     M_FunctionHandler13

M_FunctionHandlerNewListNear:
                LodsW
                Mov     Word Ptr CS:GlobalKeyList, AX
                Jmp     M_FunctionHandler11

M_FunctionHandlerNewListFar:
                LodsD
                Mov     CS:GlobalKeyList, EAX
                Jmp     M_FunctionHandler11

M_FunctionHandlerForced:
                LodsW
                Jmp     M_FunctionHandler26

M_FunctionHandlerCapCheck:                      ; Capital OK? (8)
                Mov     BX, DX
                Cmp     BX, 'A'
                JB      M_FunctionHandler14
                Cmp     BX, 'z'
                JA      M_FunctionHandler14
                Cmp     BX, 'a'
                JB      M_FunctionHandlerCapCheck1

                Sub     BL, 32

M_FunctionHandlerCapCheck1:
                Jmp     M_FunctionHandler13

M_FunctionHandlerMIDI:
                Test    CL, CL
                JNZ     M_FunctionHandler14
                Mov     BX, CX
                And     BX, 0F000h
                Jmp     M_FunctionHandlerCheck

M_FunctionHandler13:
                Test    CL, CL
                JZ      M_FunctionHandler14

M_FunctionHandlerCheck:
                LodsW
                Cmp     BX, AX
                JNE     M_FunctionHandler14

M_FunctionHandler26:
                LES     DI, ObjectList          ; ES:DI points to object list
                Push    BP
                Call    DWord Ptr [SI]
                Pop     BP
                Jmp     M_FunctionHandler15

M_FunctionHandler14:
                Xor     AX, AX

M_FunctionHandler15:
                Add     Word Ptr CS:GlobalKeyList, 7
                Jmp     M_FunctionHandler10

EndP            M_FunctionHandler

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

Proc            M_Object1ListDefault Far        ; Reqs: DI = offset of list

                Mov     CX, 0FFFFh

Proc            M_Object1List Far       ; Reqs.. CX = inital object.
                                        ; Reqs.. DI = offset of list

                Mov     AX, Object1
                Push    AX
                Mov     ES, AX
                Push    DI
                Cmp     CX, 0FFFFh
                JE      M_Object1List1

                Mov     Word Ptr [ES:DI], CX

M_Object1List1:
                Call    M_FunctionHandler

                Ret

EndP            M_Object1List
EndP            M_Object1ListDefault

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

EndS

;ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

End
