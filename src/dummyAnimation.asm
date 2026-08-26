global dummyAnimationUpdate

section .data
  frameIndex dd 0.0
  frameSpeed dd 0.1
  frameCount dd 4.0

section .text

dummyAnimationUpdate:
  movss xmm0, [rel frameIndex]
  addss xmm0, [rel frameSpeed]

dummyAnimationUpdate_updateFrame:
  cvttss2si r8d, xmm0
  movss [frameIndex], xmm0
  
  cmp r8d, 4
  jl dummyAnimationUpdate_return

  subss xmm0, [rel frameCount]
  jmp dummyAnimationUpdate_updateFrame

dummyAnimationUpdate_return:
  mov eax, r8d
  ret

