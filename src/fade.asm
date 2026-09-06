global fadeY
global fadeActive
global fadeUpdate

%define FADE_SPEED 4

section .bss
  fadeY resb 1
  fadeActive resb 1

section .text

fadeUpdate:
  cmp byte [rel fadeActive], 0
  jz fadeUpdate_done
  
  cmp byte [rel fadeActive], 2
  jz fadeUpdate_fadeOut

  add byte [rel fadeY], FADE_SPEED
  cmp byte [rel fadeY], 240
  jb fadeUpdate_done

  mov byte [rel fadeActive], 2
  mov byte [rel fadeY], 240
  jmp fadeUpdate_done

fadeUpdate_fadeOut:
  sub byte [rel fadeY], FADE_SPEED
  cmp byte [rel fadeY], 0
  ja fadeUpdate_done

  mov byte [rel fadeActive], 0
  mov byte [rel fadeY], 0

fadeUpdate_done:
  ret

section .note.GNU-stack noalloc noexec nowrite progbits