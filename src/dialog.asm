extern uiDrawDialogBox
extern textDraw

global dialogOpen
global dialogRender

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