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
  dialogReference resq 1

section .text

; -------------------------------------------------------------
; rdi: ptrDialog
; -------------------------------------------------------------
dialogOpen:
  mov byte [rel dialogIsActive], 1
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
  call textDraw

dialogRender_return:
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits