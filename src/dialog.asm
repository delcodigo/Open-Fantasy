%include "src/constants.inc"

extern uiDrawDialogBox
extern textDraw

extern playerSM

extern inputMap

global dialogOpen
global dialogRender
global dialogUpdate

section .bss
  dialogIsActive resb 1
  dialogReference resq 1

section .text

; -------------------------------------------------------------
; rdi: ptrDialog
; -------------------------------------------------------------
dialogOpen:
  mov byte [rel dialogIsActive], 1
  mov qword [rel dialogReference], rdi
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

  call uiDrawDialogBox

  mov edi, 24
  mov esi, 24
  mov rdx, [rel dialogReference]
  call textDraw

dialogRender_return:
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits