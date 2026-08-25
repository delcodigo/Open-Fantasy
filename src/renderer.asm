extern glBindTexture
extern glTexSubImage2D
extern texture

global frameBuffer
global rendererUpdateFrameBuffer

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

  mov rdi, [rel pixelX]
  shl rdi, 2
  lea rax, [rel frameBuffer]
  mov byte [rax + rdi], 255

  mov rdi, [rel pixelX]
  inc rdi
  mov qword [pixelX], rdi

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