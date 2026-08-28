global spriteAnimationUpdate
global spriteAnimationRoundFrame

section .rodata
  frameSpeed dd 0x00002222
  frameCount dd 4 << 16

section .text

; -------------------------------------------------------------
; rdi: pointer to frameIndex
; -------------------------------------------------------------
spriteAnimationRoundFrame:
  mov eax, [rdi]
  add eax, 0x8000
  and eax, 0xFFFF0000
  mov [rdi], eax
  ret

; -------------------------------------------------------------
; rdi: pointer to frameIndex
; -------------------------------------------------------------
spriteAnimationUpdate:
  mov eax, [rdi]
  add eax, [rel frameSpeed]

spriteAnimationUpdate_updateFrame:
  mov [rdi], eax
  sar eax, 16
  
  cmp eax, 4
  jl spriteAnimationUpdate_return

  shl eax, 16
  sub eax, [rel frameCount]
  jmp spriteAnimationUpdate_updateFrame

spriteAnimationUpdate_return:
  ret

section .note.GNU-stack noalloc noexec nowrite progbits