extern glBindTexture
extern glTexSubImage2D
extern glViewport

extern texture

extern warrior_ow_fd_tl
extern warrior_ow_pal_1
extern grass_tile_1
extern grass_tile
extern palette_indices
extern grass_pal
extern rendererDrawMap

global frameBuffer
global rendererUpdateFrameBuffer
global rendererDrawSprite
global rendererDrawMacroSprite
global rendererClearFrameBuffer
global rendererFrameBufferResizeCallback
global rendererDrawTile
global cameraX
global cameraY

section .bss
  frameBuffer resb 245760

section .data
  cameraX dd 0
  cameraY dd 0

section .text

; edi: window, esi: width, edx: height
rendererFrameBufferResizeCallback:
  mov r10d, esi
  mov r11d, edx

  mov r8d, esi
  shr r8d, 8

  mov eax, r11d
  xor edx, edx
  mov r9d, 240
  div r9d
  mov r9d, eax

  mov ecx, r8d
  cmp ecx, r9d
  jl rendererFrameBufferResizeCallback_xlessy
  mov ecx, r9d

rendererFrameBufferResizeCallback_xlessy:
  cmp ecx, 1
  jge rendererFrameBufferResizeCallback_scale1orMore
  mov ecx, 1

rendererFrameBufferResizeCallback_scale1orMore:
  mov r8d, ecx
  shl r8d, 8

  mov r9d, ecx
  imul r9d, 240

  sub r10d, r8d
  sar r10d, 1

  sub r11d, r9d
  sar r11d, 1

  mov edi, r10d
  mov esi, r11d
  mov edx, r8d
  mov ecx, r9d

  sub rsp, 8
  call glViewport
  add rsp, 8

  ret

rendererClearFrameBuffer:
  lea rdi, [rel frameBuffer]
  xor eax, eax
  mov ecx, 245760 / 8
  rep stosq
  ret

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
; rendererDrawSprite(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
;
; -------------------------------------------------------------
rendererDrawSprite:
  push r12
  push r13
  push r14
  push r15

  movsxd rdi, edi
  movsxd rsi, esi

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawSprite_verticalLoop:
  xor r8, r8

rendererDrawSprite_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r15d, byte [rdx + r10]

  xor r9, r9

rendererDrawSprite_line:
  mov eax, r15d
  shr eax, 6
  and eax, 0b11

  cmp eax, 0
  je rendererDrawSprite_skipRender

  mov eax, [rcx + rax * 4]

  mov r10, r8
  shl r10, 2
  add r10, rdi
  add r10, r9
  movsxd r11, [rel cameraX]
  sar r11, 16
  sub r10, r11
  
  cmp r10, 0
  jl rendererDrawSprite_skipRender
  cmp r10, 255
  jg rendererDrawSprite_skipRender

  mov r10, rsi
  add r10, r14
  movsxd r11, [rel cameraY]
  sar r11, 16
  sub r10, r11

  cmp r10, 0
  jl rendererDrawSprite_skipRender
  cmp r10, 239
  jg rendererDrawSprite_skipRender

  mov r10, r8
  shl r10, 2

  movsxd r11, [rel cameraY]
  sar r11, 16
  mov r12, rsi
  add r12, r14
  sub r12, r11
  imul r12, 256
  add r12, rdi
  add r12, r10
  add r12, r9
  movsxd r11, [rel cameraX]
  sar r11, 16
  sub r12, r11
  shl r12, 2

  mov dword [r13 + r12], eax

rendererDrawSprite_skipRender:
  shl r15d, 2

  inc r9
  cmp r9, 4
  jl rendererDrawSprite_line

  inc r8
  cmp r8, 2
  jl rendererDrawSprite_horizontalLoop

  inc r14
  cmp r14, 8
  jl rendererDrawSprite_verticalLoop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

; -------------------------------------------------------------
; rendererDrawMacroSprite(edi: x, esi: y, rdx: macro_sprite, rcx: macro_palette)
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
  movzx eax, byte [r12 + r15]
  shl rax, 4
  lea rdx, [rel warrior_ow_fd_tl]
  add rdx, rax
  movzx eax, byte [rbx + r15]
  shl rax, 4
  lea rcx, [rel warrior_ow_pal_1]
  add rcx, rax
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

; -------------------------------------------------------------
; rendererDrawTile(edi: x, esi: y, rdx: macro_sprite, rcx: palette)
;
; Draws 4 8x8 tiles ordered by top-left, top-right, bottom-left and bottom-right
; each sprite tile share the same palette
;
; -------------------------------------------------------------
rendererDrawTile:
  push r12
  push r13
  push r14
  push r15
  
  xor r15, r15
  xor r13, r13
  mov r12, rdx
  mov r14, rdi

rendererDrawTile_loop:
  movzx rax, byte [r12 + r15]
  shl rax, 4
  lea rdx, [rel grass_tile_1]
  add rdx, rax
  call rendererDrawSprite

  mov rdi, r14
  add rdi, 8
  
  inc r15

  inc r13
  cmp r13, 2
  jl rendererDrawTile_loop

  mov rdi, r14
  xor r13, r13
  add rsi, 8
  
  cmp r15, 4
  jl rendererDrawTile_loop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

; -------------------------------------------------------------
; rdi: pointer to map
; -------------------------------------------------------------
rendererDrawMap:
  push rbp
  mov rbp, rsp
  sub rsp, 32

  lea rsi, [rdi + 2]
  mov qword [rbp-8], rsi  ; tilemap
  mov al, byte [rdi]
  mov byte [rbp-9], al    ; width
  mov al, byte [rdi + 1]
  mov byte [rbp-10], al   ; height
  mov byte [rbp-11], 0    ; x
  mov byte [rbp-12], 0    ; y

rendererDrawMap_verticalLoop:
  mov byte[rbp-11], 0

rendererDrawMap_horizontalLoop:
  mov rsi, qword [rbp-8]
  movzx eax, byte [rsi]
  lea rcx, [rel palette_indices]
  movzx r8d, byte [rcx + rax]
  shl r8, 4
  lea rcx, [rel grass_pal]
  add rcx, r8

  shl rax, 2
  lea rdx, [rel grass_tile]
  add rdx, rax

  movzx edi, byte [rbp-11]
  shl rdi, 4
  movzx esi, byte [rbp-12]
  shl rsi, 4
  call rendererDrawTile

  inc qword [rbp-8]

  inc byte [rbp-11]
  mov al, byte[rbp-11]
  cmp al, byte[rbp-9]
  jb rendererDrawMap_horizontalLoop

  inc byte [rbp-12]
  mov al, byte [rbp-12]
  cmp al, byte [rbp-10]
  jb rendererDrawMap_verticalLoop

  mov rsp, rbp
  pop rbp
  ret

  section .note.GNU-stack noalloc noexec nowrite progbits