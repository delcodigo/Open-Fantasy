extern rendererDrawOpaqueNoClip
extern rendererClearLineWithColor

global uiDrawDialogBox
global uiDrawNextArrow

section .rodata
  ui_box_pal dd 0xFF000000, 0xFFEBEBEB, 0xFFA2A2A2, 0xFF797979

  ui_boxtl:
    db 0b00000000, 0b00000000
    db 0b00000101, 0b01010101
    db 0b00011000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000

  ui_boxt:
    db 0b00000000, 0b00000000
    db 0b01010101, 0b01010101
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000

  ui_boxtr:
    db 0b00000000, 0b00000000
    db 0b01010101, 0b01010000
    db 0b00000000, 0b00100100
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000

  ui_boxml:
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000

  ui_boxmr:
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000

  ui_boxbl:
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00100000, 0b00000000
    db 0b00111000, 0b00000000
    db 0b00001111, 0b11111111
    db 0b00000000, 0b00000000

  ui_boxb:
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b11111111, 0b11111111
    db 0b00000000, 0b00000000

  ui_boxbr:
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00001000
    db 0b00000000, 0b00101100
    db 0b11111111, 0b11110000
    db 0b00000000, 0b00000000

  ui_nextPage:
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b00000000, 0b00000000
    db 0b11010101, 0b01010111
    db 0b00110101, 0b01011100
    db 0b00001101, 0b01110000
    db 0b00000011, 0b11000000

section .text

; -------------------------------------------------------------
; edi: baseY
; -------------------------------------------------------------
uiDrawDialogBox:
  sub rsp, 8
  push r12
  push r13

  mov r13d, edi

  mov edi, 16
  mov esi, r13d
  lea rdx, [rel ui_boxtl]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov edi, 232
  mov esi, r13d
  lea rdx, [rel ui_boxtr]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov edi, 16
  mov esi, r13d
  add esi, 48
  lea rdx, [rel ui_boxbl]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov edi, 232
  mov esi, r13d
  add esi, 48
  lea rdx, [rel ui_boxbr]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov r12d, 24
uiDrawDialogBox_horizontalBorderLoop:
  mov edi, r12d
  mov esi, r13d
  lea rdx, [rel ui_boxt]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov edi, r12d
  mov esi, r13d
  add esi, 48
  lea rdx, [rel ui_boxb]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  add r12d, 8
  cmp r12d, 232
  jl uiDrawDialogBox_horizontalBorderLoop

  mov r8d, r13d
  add r8d, 48

  mov r12d, 8
  add r12d, r13d
uiDrawDialogBox_verticalBorderLoop:
  mov edi, 16
  mov esi, r12d
  lea rdx, [rel ui_boxml]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov edi, 232
  mov esi, r12d
  lea rdx, [rel ui_boxmr]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  mov r8d, r13d
  add r8d, 48
  add r12d, 8
  cmp r12d, r8d
  jl uiDrawDialogBox_verticalBorderLoop

  mov r12d, 8
  add r12d, r13d
uiDrawDialogBox_centerBorderLoop:
  mov edi, 24
  mov esi, r12d
  mov edx, 208
  mov ecx, 0xFF000000
  call rendererClearLineWithColor

  mov r8d, r13d
  add r8d, 48
  inc r12d
  cmp r12d, r8d
  jl uiDrawDialogBox_centerBorderLoop

  pop r13
  pop r12
  add rsp, 8
  ret

; -------------------------------------------------------------
; edi: x, esi: y
; -------------------------------------------------------------
uiDrawNextArrow:
  sub rsp, 8

  lea rdx, [rel ui_nextPage]
  lea rcx, [rel ui_box_pal]
  call rendererDrawOpaqueNoClip

  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits