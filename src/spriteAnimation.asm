global spriteAnimationUpdate
global spriteAnimationRoundFrame

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
; rdi: pointer to frameIndex, rsi: frameCount, rdx: frameSpeed
; -------------------------------------------------------------
spriteAnimationUpdate:
  mov eax, [rdi]
  add rax, rdx

spriteAnimationUpdate_updateFrame:
  mov [rdi], eax
  sar eax, 16
  
  cmp eax, esi
  jl spriteAnimationUpdate_return

  shl rsi, 16

  shl eax, 16
  sub eax, esi
  jmp spriteAnimationUpdate_updateFrame

spriteAnimationUpdate_return:
  ret

section .note.GNU-stack noalloc noexec nowrite progbits