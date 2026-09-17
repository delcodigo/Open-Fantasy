%include "src/constants.inc"

extern uiDrawDialogBox
extern textDraw

extern playerSM
extern playerY

extern cameraY

extern inputMap

global dialogOpen
global dialogRender
global dialogUpdate

section .bss
  dialogIsActive resb 1
  dialogY resb 1
  dialogOffset resb 1
  dialogPage resb 1
  dialogReference resq 1

section .text

; -------------------------------------------------------------
; rdi: ptrDialog
; -------------------------------------------------------------
dialogOpen:
  mov byte [rel dialogIsActive], 1
  mov byte [rel dialogOffset], 1
  mov byte [rel dialogPage], 0
  mov qword [rel dialogReference], rdi

  mov r8d, [rel playerY]
  sub r8d, [rel cameraY]
  sar r8d, 16
  cmp r8d, 120
  jl dialogOpen_playerAbove
  mov byte [rel dialogY], 16
  ret
dialogOpen_playerAbove:
  mov byte [rel dialogY], 144
  ret

; -------------------------------------------------------------
dialogUpdate:
  xor rax, rax

  cmp byte [rel dialogIsActive], 1
  jnz dialogUpdate_return

  cmp byte [rel inputMap + KEY_E], 1
  jnz dialogUpdate_return
  mov byte [rel inputMap + KEY_E], 2

  mov r8, qword [rel dialogReference]
  movzx r9d, byte [r8]
  add byte [rel dialogPage], 1
  cmp byte [rel dialogPage], r9b
  jz dialogUpdate_noMorePages
  movzx r10d, byte [rel dialogOffset]

dialogUpdate_lookForOffset:
  movzx r11d, byte [r8 + r10]
  test r11d, r11d
  jz dialogUpdate_newOffsetFound

  inc r10d
  jmp dialogUpdate_lookForOffset

dialogUpdate_newOffsetFound:
  inc r10d
  mov byte [rel dialogOffset], r10b
  jmp dialogUpdate_return

dialogUpdate_noMorePages:
  mov byte [rel dialogIsActive], 0
  mov qword [rel dialogReference], 0

  mov byte [rel playerSM], CHARACTER_SM_IDLE

  mov rax, 1

dialogUpdate_return:
  ret

; -------------------------------------------------------------
dialogRender:
  sub rsp, 8

  cmp byte [rel dialogIsActive], 1
  jnz dialogRender_return

  movzx edi, byte [rel dialogY]
  call uiDrawDialogBox

  mov edi, 24
  movzx esi, byte [rel dialogY]
  add esi, 8

  mov rdx, [rel dialogReference]
  movzx r8d, byte [rel dialogOffset]
  add rdx, r8

  call textDraw

dialogRender_return:
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits