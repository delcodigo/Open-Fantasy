extern glBindTexture
extern glTexSubImage2D
extern texture

global frameBuffer
global rendererUpdateFrameBuffer
global rendererDrawSquare

section .bss
  frameBuffer resb 245760

section .data
  pixelX dq 0

section .note.GNU-stack noalloc noexec nowrite progbits

section .text

; -------------------------------------------------------------
; rendererUpdateFrameBuffer()
;
; Updates the screen texture with the frameBuffer contents
;
; -------------------------------------------------------------
rendererUpdateFrameBuffer:
  sub rsp, 8

  mov edi, 0xDE1
  mov esi, [rel texture]
  call glBindTexture

  mov edi, 0xDE1
  xor esi, esi
  xor edx, edx
  xor ecx, ecx
  mov r8d, 256
  mov r9d, 240

  sub rsp, 32

  mov qword [rsp], 0x1908
  mov qword [rsp + 8], 0x1401

  lea rax, [rel frameBuffer]
  mov qword [rsp + 16], rax

  call glTexSubImage2D

  add rsp, 32

  add rsp, 8
  ret

; -------------------------------------------------------------
; rendererUpdateFrameBuffer(rdi: x, rsi: y, rdx: w, rcx: h)
;
; Draws a red square of width rdx and height rcx at rdi,rsi
;
; -------------------------------------------------------------
rendererDrawSquare:
  push r12

  xor r8, r8
rendererDrawSquare_horizontalLoop:
  xor r9, r9
rendererDrawSquare_verticalLoop:
  mov r12, r9
  add r12, rsi
  imul r12, 256
  add r12, r8
  add r12, rdi
  shl r12, 2
  lea rax, [rel frameBuffer]
  mov byte [rax + r12], 255

  inc r9
  cmp r9, rcx
  jl rendererDrawSquare_verticalLoop

  inc r8
  cmp r8, rdx
  jl rendererDrawSquare_horizontalLoop

  pop r12