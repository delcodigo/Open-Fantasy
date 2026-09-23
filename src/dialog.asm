%include "src/constants.inc"

extern uiDrawDialogBox
extern uiDrawNextArrow
extern textDraw

extern playerSM
extern playerY

extern cameraY

extern inputMap

global dialogOpen
global dialogRender
global dialogUpdate
global dialogIsActive

section .bss
  dialogIsActive resb 1
  dialogY resb 1
  dialogOffset resb 1
  dialogPage resb 1
  dialogTextIndex resb 1
  dialogSM resb 1
  dialogNPFI resb 1
  dialogText resb 145
  dialogBoxHeight resb 1
  dialogReference resq 1

section .text

; -------------------------------------------------------------
; rdi: ptrDialog
; -------------------------------------------------------------
dialogOpen:
  mov byte [rel dialogIsActive], 1
  mov byte [rel dialogOffset], 1
  mov byte [rel dialogPage], 0
  mov byte [rel dialogSM], DIALOG_SM_OPENING
  mov byte [rel dialogTextIndex], 0
  mov byte [rel dialogNPFI], 30
  mov byte [rel dialogBoxHeight], 8
  mov qword [rel dialogReference], rdi

  mov r8d, [rel playerY]
  sub r8d, [rel cameraY]
  sar r8d, 16
  cmp r8d, 120
  jl dialogOpen_playerAbove
  mov byte [rel dialogY], 16
  jmp dialogClearText
dialogOpen_playerAbove:
  mov byte [rel dialogY], 168
  jmp dialogClearText

; -------------------------------------------------------------
dialogClearText:
  mov byte [rel dialogTextIndex], 0

  lea rdi, [rel dialogText]
  xor eax, eax
  mov ecx, 145
  rep stosb
  ret

; -------------------------------------------------------------
dialogUpdateTypewritterEffect:
  cmp byte [rel dialogSM], DIALOG_SM_TYPING
  jnz dialogUpdateTypewritterEffect_return

  mov rdi, [rel dialogReference]
  movzx r8d, byte [rel dialogOffset]
  add rdi, r8
  lea rsi, [rel dialogText]
  movzx edx, byte [rel dialogTextIndex]
  add rsi, rdx

  xor r8, r8
dialogUpdateTypewritterEffect_loop:
  movzx ecx, byte [rdi + rdx]
  mov byte [rsi], cl
  inc rsi

  inc dl
  mov byte [rel dialogTextIndex], dl

  test ecx, ecx
  jz dialogUpdateTypewritterEffect_done

  inc r8
  cmp r8, DIALOG_SPEED
  jl dialogUpdateTypewritterEffect_loop
  ret

dialogUpdateTypewritterEffect_done:
  mov byte [rel dialogSM], DIALOG_SM_COMPLETED

dialogUpdateTypewritterEffect_return:
  ret

; -------------------------------------------------------------
dialogUpdateFillPage:
  mov rdi, [rel dialogReference]
  lea rsi, [rel dialogText]

  movzx ecx, byte [rel dialogOffset]
  movzx edx, byte [rel dialogTextIndex]

  add rdi, rcx
  add rdi, rdx
  add rsi, rdx

dialogUpdateFillPage_loop:
  movzx r8d, byte [rdi]
  mov byte [rsi], r8b

  inc rdi
  inc rsi

  cmp r8b, 0
  jz dialogUpdateFillPage_return
  jmp dialogUpdateFillPage_loop

dialogUpdateFillPage_return:
  mov byte [rel dialogSM], DIALOG_SM_COMPLETED
  jmp dialogUpdateNextPage_return

; -------------------------------------------------------------
dialogUpdateNextPage:
  sub rsp, 8
  xor rax, rax

  cmp byte [rel inputMap + KEY_E], 1
  jnz dialogUpdateNextPage_return
  mov byte [rel inputMap + KEY_E], 2

  cmp byte [rel dialogSM], DIALOG_SM_TYPING
  jz dialogUpdateFillPage

  mov r8, qword [rel dialogReference]
  movzx r9d, byte [r8]
  add byte [rel dialogPage], 1
  cmp byte [rel dialogPage], r9b
  jz dialogUpdateNextPage_noMorePages
  movzx r10d, byte [rel dialogOffset]

dialogUpdateNextPage_lookForOffset:
  movzx r11d, byte [r8 + r10]
  test r11d, r11d
  jz dialogUpdateNextPage_newOffsetFound

  inc r10d
  jmp dialogUpdateNextPage_lookForOffset

dialogUpdateNextPage_newOffsetFound:
  inc r10d
  mov byte [rel dialogOffset], r10b
  mov byte [rel dialogSM], DIALOG_SM_TYPING
  mov byte [rel dialogNPFI], 30
  call dialogClearText
  jmp dialogUpdateNextPage_return

dialogUpdateNextPage_noMorePages:
  mov byte [rel dialogIsActive], 0
  mov qword [rel dialogReference], 0

  mov byte [rel playerSM], CHARACTER_SM_IDLE

  mov rax, 1

dialogUpdateNextPage_return:
  add rsp, 8
  ret

; -------------------------------------------------------------
dialogUpdateOpeningBox:
  add byte [rel dialogBoxHeight], DIALOG_OPENING_SPEED
  cmp byte [rel dialogBoxHeight], DIALOG_BOX_HEIGHT
  jl dialogUpdateOpeningBox_return

  mov byte [rel dialogSM], DIALOG_SM_TYPING
  mov byte [rel dialogBoxHeight], DIALOG_BOX_HEIGHT

dialogUpdateOpeningBox_return:
  add rsp, 8
  ret

; -------------------------------------------------------------
dialogUpdate:
  sub rsp, 8

  xor rax, rax

  cmp byte [rel dialogIsActive], 1
  jnz dialogUpdate_return

  cmp byte [rel dialogSM], DIALOG_SM_OPENING
  jz dialogUpdateOpeningBox

  call dialogUpdateTypewritterEffect
  call dialogUpdateNextPage

  cmp byte [rel dialogSM], DIALOG_SM_TYPING
  jz dialogUpdate_return
  
  dec byte [rel dialogNPFI]
  cmp byte [rel dialogNPFI], 0
  jge dialogUpdate_return
  mov byte [rel dialogNPFI], 60

dialogUpdate_return:
  add rsp, 8
  ret

; -------------------------------------------------------------
dialogRender:
  sub rsp, 8

  cmp byte [rel dialogIsActive], 1
  jnz dialogRender_return

  movzx edi, byte [rel dialogY]
  movzx esi, byte [rel dialogBoxHeight]
  call uiDrawDialogBox

  cmp byte [rel dialogSM], DIALOG_SM_OPENING
  jz dialogRender_return

  mov edi, 24
  movzx esi, byte [rel dialogY]
  add esi, 8

  lea rdx, [rel dialogText]
  call textDraw

  cmp byte [rel dialogSM], DIALOG_SM_COMPLETED
  jnz dialogRender_return
  cmp byte [rel dialogNPFI], 30
  jg dialogRender_return

  mov edi, 216
  movzx esi, byte [rel dialogY]
  add esi, 48
  call uiDrawNextArrow

dialogRender_return:
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits