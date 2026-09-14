%include "src/constants.inc"

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
extern animated_indices

extern indexOfByte

extern spriteAnimationUpdate

extern fadeY
extern fadeActive

global frameBuffer
global rendererUpdateFrameBuffer
global rendererDrawSpriteNoClip
global rendererDrawSprite
global rendererDrawMacroSprite
global rendererClearFrameBuffer
global rendererFrameBufferResizeCallback
global rendererDrawTile
global rendererDrawMap
global rendererUpdateAnimationFrameIndex
global cameraX
global cameraY

section .bss
  cameraX resd 1
  cameraY resd 1
  worldFI resd 1
  frameBuffer resb 245760

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
  jl rendererFrameBufferResizeCallback_xLessY
  mov ecx, r9d

rendererFrameBufferResizeCallback_xLessY:
  cmp ecx, 1
  jge rendererFrameBufferResizeCallback_scale1OrMore
  mov ecx, 1

rendererFrameBufferResizeCallback_scale1OrMore:
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
  sub rsp, 40

  mov edi, 0xDE1
  mov esi, [rel texture]
  call glBindTexture

  mov edi, 0xDE1
  xor esi, esi
  xor edx, edx
  xor ecx, ecx
  mov r8d, 256
  mov r9d, 240

  mov qword [rsp], 0x1908
  mov qword [rsp + 8], 0x1401

  lea rax, [rel frameBuffer]
  mov qword [rsp + 16], rax

  call glTexSubImage2D

  add rsp, 40
  ret

; -------------------------------------------------------------
; rendererDrawSpriteWithClip(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
;
; -------------------------------------------------------------
rendererDrawSpriteWithClip:
  push r12
  push r13
  push r14
  push r15

  mov r12, rsi
  shl r12, 8
  add r12, rdi
  shl r12, 2

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawSpriteWithClip_verticalLoop:
  xor r8, r8

  mov r10, rsi
  add r10, r14

  cmp byte [rel fadeActive], 0
  jz rendererDrawSpriteWithClip_horizontalLoop
  cmp r10b, byte [rel fadeY]
  jbe rendererDrawSpriteWithClip_skipLine

rendererDrawSpriteWithClip_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r15d, byte [rdx + r10]

  xor r9, r9

rendererDrawSpriteWithClip_line:
  mov eax, r15d
  shr eax, 6
  and eax, 0b11

  test eax, eax
  jz rendererDrawSpriteWithClip_skipRender

  mov eax, [rcx + rax * 4]

  mov r10, r8
  shl r10, 2
  add r10, rdi
  add r10, r9
  
  cmp r10, 255
  ja rendererDrawSpriteWithClip_skipRender

  mov r10, rsi
  add r10, r14

  cmp r10, 239
  ja rendererDrawSpriteWithClip_skipRender

  mov dword [r13 + r12], eax

rendererDrawSpriteWithClip_skipRender:
  shl r15d, 2

  add r12, 4

  inc r9
  cmp r9, 4
  jl rendererDrawSpriteWithClip_line

  inc r8
  cmp r8, 2
  jl rendererDrawSpriteWithClip_horizontalLoop

  add r12, 992

rendererDrawSpriteWithClip_nextLine:
  inc r14
  cmp r14, 8
  jl rendererDrawSpriteWithClip_verticalLoop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

rendererDrawSpriteWithClip_skipLine:
  add r12, 1024
  jmp rendererDrawSpriteWithClip_nextLine

; -------------------------------------------------------------
; rendererDrawSpriteNoClip(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
; it trusts that the sprite lives completely inside the viewport
;
; -------------------------------------------------------------
rendererDrawSpriteNoClip:
  push r12
  push r13
  push r14
  push r15

  mov r12, rsi
  shl r12, 8
  add r12, rdi
  shl r12, 2

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawSpriteNoClip_verticalLoop:
  xor r8, r8

  mov r10, rsi
  add r10, r14

  cmp byte [rel fadeActive], 0
  jz rendererDrawSpriteNoClip_horizontalLoop
  cmp r10b, byte [rel fadeY]
  jbe rendererDrawSpriteNoClip_skipLine

rendererDrawSpriteNoClip_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r15d, byte [rdx + r10]

  xor r9, r9

rendererDrawSpriteNoClip_line:
  mov eax, r15d
  shr eax, 6
  and eax, 0b11

  test eax, eax
  jz rendererDrawSpriteNoClip_skipRender

  mov eax, [rcx + rax * 4]

  mov dword [r13 + r12], eax

rendererDrawSpriteNoClip_skipRender:
  shl r15d, 2

  add r12, 4

  inc r9
  cmp r9, 4
  jl rendererDrawSpriteNoClip_line

  inc r8
  cmp r8, 2
  jl rendererDrawSpriteNoClip_horizontalLoop

  add r12, 992

rendererDrawSpriteNoClip_nextLine:
  inc r14
  cmp r14, 8
  jl rendererDrawSpriteNoClip_verticalLoop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

rendererDrawSpriteNoClip_skipLine:
  add r12, 1024
  jmp rendererDrawSpriteNoClip_nextLine

; -------------------------------------------------------------
; rendererDrawSprite(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
; depends on if the sprite is fully in viewport or not it calls
; a fast path or a clipping path
;
; -------------------------------------------------------------
rendererDrawSprite:
  movsxd rdi, edi
  movsxd rsi, esi

  movsxd r11, [rel cameraX]
  sar r11, 16
  sub rdi, r11

  movsxd r11, [rel cameraY]
  sar r11, 16
  sub rsi, r11

  cmp rdi, 248
  ja rendererDrawSpriteWithClip
  cmp rsi, 232
  ja rendererDrawSpriteWithClip

  jmp rendererDrawSpriteNoClip

; -------------------------------------------------------------
; rendererDrawOpaqueWithClip(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
;
; -------------------------------------------------------------
rendererDrawOpaqueWithClip:
  push r12
  push r13
  push r14
  push r15

  mov r12, rsi
  shl r12, 8
  add r12, rdi
  shl r12, 2

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawOpaqueWithClip_verticalLoop:
  xor r8, r8

  mov r10, rsi
  add r10, r14

  cmp byte [rel fadeActive], 0
  jz rendererDrawOpaqueWithClip_horizontalLoop
  cmp r10b, byte [rel fadeY]
  jbe rendererDrawOpaqueWithClip_skipLine

rendererDrawOpaqueWithClip_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r15d, byte [rdx + r10]

  xor r9, r9

rendererDrawOpaqueWithClip_line:
  mov eax, r15d
  shr eax, 6
  and eax, 0b11

  mov eax, [rcx + rax * 4]

  mov r10, r8
  shl r10, 2
  add r10, rdi
  add r10, r9
  
  cmp r10, 255
  ja rendererDrawOpaqueWithClip_skipRender

  mov r10, rsi
  add r10, r14

  cmp r10, 239
  ja rendererDrawOpaqueWithClip_skipRender

  mov dword [r13 + r12], eax

rendererDrawOpaqueWithClip_skipRender:
  shl r15d, 2

  add r12, 4

  inc r9
  cmp r9, 4
  jl rendererDrawOpaqueWithClip_line

  inc r8
  cmp r8, 2
  jl rendererDrawOpaqueWithClip_horizontalLoop

  add r12, 992

rendererDrawOpaqueWithClip_nextLine:
  inc r14
  cmp r14, 8
  jl rendererDrawOpaqueWithClip_verticalLoop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

rendererDrawOpaqueWithClip_skipLine:
  add r12, 1024
  jmp rendererDrawOpaqueWithClip_nextLine

; -------------------------------------------------------------
; rendererDrawOpaqueNoClip(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
; it trusts that the sprite lives completely inside the viewport
;
; -------------------------------------------------------------
rendererDrawOpaqueNoClip:
  push r12
  push r13
  push r14
  push r15

  mov r12, rsi
  shl r12, 8
  add r12, rdi
  shl r12, 2

  xor r14, r14
  lea r13, [rel frameBuffer]

rendererDrawOpaqueNoClip_verticalLoop:
  xor r8, r8

  mov r10, rsi
  add r10, r14

  cmp byte [rel fadeActive], 0
  jz rendererDrawOpaqueNoClip_horizontalLoop
  cmp r10b, byte [rel fadeY]
  jbe rendererDrawOpaqueNoClip_skipLine

rendererDrawOpaqueNoClip_horizontalLoop:
  mov r10, r14
  shl r10, 1
  add r10, r8
  movzx r15d, byte [rdx + r10]

  xor r9, r9

rendererDrawOpaqueNoClip_line:
  mov eax, r15d
  shr eax, 6
  and eax, 0b11

  mov eax, [rcx + rax * 4]

  mov dword [r13 + r12], eax

  shl r15d, 2

  add r12, 4

  inc r9
  cmp r9, 4
  jl rendererDrawOpaqueNoClip_line

  inc r8
  cmp r8, 2
  jl rendererDrawOpaqueNoClip_horizontalLoop

  add r12, 992

rendererDrawOpaqueNoClip_nextLine:
  inc r14
  cmp r14, 8
  jl rendererDrawOpaqueNoClip_verticalLoop

  pop r15
  pop r14
  pop r13
  pop r12
  ret

rendererDrawOpaqueNoClip_skipLine:
  add r12, 1024
  jmp rendererDrawOpaqueNoClip_nextLine

; -------------------------------------------------------------
; rendererDrawOpaque(edi: x, esi: y, rdx: sprite, rcx: palette)
;
; Draws an 8x8 sprite using 2bpp indexed sprites and a palette
; depends on if the sprite is fully in viewport or not it calls
; a fast path or a clipping path
;
; -------------------------------------------------------------
rendererDrawOpaque:
  movsxd rdi, edi
  movsxd rsi, esi

  movsxd r11, [rel cameraX]
  sar r11, 16
  sub rdi, r11

  movsxd r11, [rel cameraY]
  sar r11, 16
  sub rsi, r11

  cmp rdi, 248
  ja rendererDrawOpaqueWithClip
  cmp rsi, 232
  ja rendererDrawOpaqueWithClip

  jmp rendererDrawOpaqueNoClip

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
  mov rbx, rcx

  mov r14d, edi
  shl r14, 32
  mov eax, esi
  or r14, rax

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
  sar rdi, 32
  add rdi, 8

  movsxd rsi, r14d
  
  inc r15

  inc r13
  cmp r13, 2
  jl rendererDrawMacroSprite_loop

  mov rdi, r14
  sar rdi, 32
  xor r13, r13
  add rsi, 8
  add r14, 8
  
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
  sub rsp, 8
  
  xor r15, r15
  xor r13, r13
  mov r12, rdx

  mov r14d, edi
  shl r14, 32
  mov eax, esi
  or r14, rax

rendererDrawTile_loop:
  movzx rax, byte [r12 + r15]
  shl rax, 4
  lea rdx, [rel grass_tile_1]
  add rdx, rax
  call rendererDrawOpaque

  mov rdi, r14
  sar rdi, 32
  add rdi, 8

  mov esi, r14d
  
  inc r15

  inc r13
  cmp r13, 2
  jl rendererDrawTile_loop

  mov rdi, r14
  sar rdi, 32
  xor r13, r13
  add rsi, 8
  add r14, 8
  
  cmp r15, 4
  jl rendererDrawTile_loop

  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  ret

; -------------------------------------------------------------
rendererUpdateAnimationFrameIndex:
  lea rdi, [rel worldFI]
  mov rsi, 2
  mov rdx, WORLD_ANIM_SPEED
  jmp spriteAnimationUpdate

; -------------------------------------------------------------
; rdi: pointer to map
; -------------------------------------------------------------
rendererDrawMap:
  push r12
  push r13
  push r14
  push r15
  sub rsp, 8

  mov eax, [rel cameraY]
  shr rax, 20
  movzx r8d, byte [rdi]
  imul rax, r8
  mov r8d, [rel cameraX]
  shr r8, 20
  add rax, r8

  lea r12, [rdi + rax + 18]
  mov r14d, [rel cameraY]
  shr r14, 20

  mov eax, [rel cameraX]
  shr eax, 20
  add eax, 17
  movzx r8d, byte [rdi]
  cmp r8d, eax
  cmovb eax, r8d
  mov r15d, eax

  mov eax, [rel cameraY]
  shr eax, 20
  add eax, 16
  movzx r8d, byte [rdi + 1]
  cmp r8d, eax
  cmovb eax, r8d
  shl eax, 8
  add r15d, eax

  movzx eax, byte [rdi]
  sub al, r15b
  mov r8d, [rel cameraX]
  shr r8, 20
  add rax, r8
  shl rax, 16
  add r15, rax

rendererDrawMap_verticalLoop:
  mov r13d, [rel cameraX]
  shr r13, 20

rendererDrawMap_horizontalLoop:
  movzx eax, byte [r12]
  dec eax

  lea rdi, [rel animated_indices]
  movzx esi, byte [rdi]
  inc rdi
  mov edx, eax
  call indexOfByte

  cmp rax, 0
  movzx eax, byte [r12]
  lea eax, [eax - 1]
  jl rendererDrawMap_noAnimatedFrame

  mov ecx, [rel worldFI]
  shr rcx, 16
  add rax, rcx

rendererDrawMap_noAnimatedFrame:
  
  lea rcx, [rel palette_indices]
  movzx r8d, byte [rcx + rax]
  shl r8, 4
  lea rcx, [rel grass_pal]
  add rcx, r8

  shl rax, 2
  lea rdx, [rel grass_tile]
  add rdx, rax

  mov edi, r13d
  shl rdi, 4
  mov esi, r14d
  shl rsi, 4
  call rendererDrawTile

  inc r12

  inc r13d
  cmp r13b, r15b
  jb rendererDrawMap_horizontalLoop

  mov rax, r15
  shr rax, 16
  add r12, rax

  inc r14d
  mov r9, r15
  shr r9, 8
  cmp r14b, r9b
  jb rendererDrawMap_verticalLoop

  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  ret

  section .note.GNU-stack noalloc noexec nowrite progbits