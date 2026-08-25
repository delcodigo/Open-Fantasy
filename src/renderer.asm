extern glBindTexture
extern glTexSubImage2D
extern texture

global frameBuffer
global rendererUpdateFrameBuffer
global rendererDrawSquare
global rendererDrawSprite
global rendererDrawMacroSprite

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
; rendererDrawSquare(rdi: x, rsi: y, rdx: w, rcx: h)
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
  ret

; -------------------------------------------------------------
; rendererDrawSprite(rdi: x, rsi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
;
; -------------------------------------------------------------
rendererDrawSprite:
  push r12
  push r13
  push r14

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawSprite_verticalLoop:
  xor r8, r8

rendererDrawSprite_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r11d, byte [rdx + r10]

  xor r9, r9

rendererDrawSprite_line:
  mov eax, r11d
  shr eax, 6
  and eax, 0b11

  cmp eax, 0
  je rendererDrawSprite_skipRender

  mov eax, [rcx + rax * 4]

  mov r10, r8
  shl r10, 2
  add r10, rdi
  add r10, r9
  
  cmp r10, 0
  jl rendererDrawSprite_skipRender
  cmp r10, 255
  jg rendererDrawSprite_skipRender

  mov r10, rsi
  add r10, r14

  cmp r10, 0
  jl rendererDrawSprite_skipRender
  cmp r10, 239
  jg rendererDrawSprite_skipRender

  mov r10, r8
  shl r10, 2

  mov r12, rsi
  add r12, r14
  imul r12, 256
  add r12, rdi
  add r12, r10
  add r12, r9
  shl r12, 2

  mov dword [r13 + r12], eax

rendererDrawSprite_skipRender:
  shl r11d, 2

  inc r9
  cmp r9, 4
  jl rendererDrawSprite_line

  inc r8
  cmp r8, 2
  jl rendererDrawSprite_horizontalLoop

  inc r14
  cmp r14, 8
  jl rendererDrawSprite_verticalLoop

  pop r14
  pop r13
  pop r12
  ret

; -------------------------------------------------------------
; rendererDrawMacroSprite(rdi: x, rsi: y, rdx: macro_sprite, rcx: macro_palette)
;
; Draws 4 8x8 sprites ordered by top-left, top-right, bottom-left and bottom-right
; each sprite must have a correspondant palette associated wiht it
;
; -------------------------------------------------------------
rendererDrawMacroSprite:
  push r12
  push r13
  push r14
  push r15
  push rbx
  
  xor r15, r15
  xor r13, r13
  mov r12, rdx
  mov r14, rdi
  mov rbx, rcx

rendererDrawMacroSprite_loop:
  mov rdx, [r12 + r15 * 8]
  mov rcx, [rbx + r15 * 8]
  call rendererDrawSprite

  mov rdi, r14
  add rdi, 8
  
  inc r15

  inc r13
  cmp r13, 2
  jl rendererDrawMacroSprite_loop

  mov rdi, r14
  xor r13, r13
  add rsi, 8
  
  cmp r15, 4
  jl rendererDrawMacroSprite_loop

  pop rbx
  pop r15
  pop r14
  pop r13
  pop r12
  ret