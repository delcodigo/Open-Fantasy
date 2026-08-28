global spriteAnimationUpdate
global spriteAnimationRoundFrame

section .rodata
  frameSpeed dd 0.13333333
  frameCount dd 4.0

section .text

; -------------------------------------------------------------
; rdi: pointer to frameIndex
; -------------------------------------------------------------
spriteAnimationRoundFrame:
  movss xmm0, [rdi]
  cvtss2si r8d, xmm0
  cvtsi2ss xmm0, r8d
  movss [rdi], xmm0

; -------------------------------------------------------------
; rdi: pointer to frameIndex
; -------------------------------------------------------------
spriteAnimationUpdate:
  movss xmm0, [rdi]
  addss xmm0, [rel frameSpeed]

spriteAnimationUpdate_updateFrame:
  cvttss2si r8d, xmm0
  movss [rdi], xmm0
  
  cmp r8d, 4
  jl spriteAnimationUpdate_return

  subss xmm0, [rel frameCount]
  jmp spriteAnimationUpdate_updateFrame

spriteAnimationUpdate_return:
  mov eax, r8d
  ret

section .note.GNU-stack noalloc noexec nowrite progbits