%include "src/constants.inc"

global inputKeyCallback
global inputMap

section .bss
  inputMap resb 5

section .note.GNU-stack noalloc noexec nowrite progbits

section .text

; rdi: window, esi: key, edx: scancode, ecx: action, r8: mods
inputKeyCallback:
  xor edx, edx
  cmp ecx, 0
  jz inputKeyCallback_checkKeys
  mov edx, 1

inputKeyCallback_checkKeys:
  cmp esi, GLFW_KEY_UP
  jz inputKeyCallback_upKey

  cmp esi, GLFW_KEY_LEFT
  jz inputKeyCallback_leftKey

  cmp esi, GLFW_KEY_DOWN
  jz inputKeyCallback_downKey

  cmp esi, GLFW_KEY_RIGHT
  jz inputKeyCallback_rightKey

  cmp esi, GLFW_KEY_E
  jz inputKeyCallback_eKey

  ret

inputKeyCallback_upKey:
  mov byte [rel inputMap + KEY_UP], dl
  ret

inputKeyCallback_leftKey:
  mov byte [rel inputMap + KEY_LEFT], dl
  ret

inputKeyCallback_downKey:
  mov byte [rel inputMap + KEY_DOWN], dl
  ret

inputKeyCallback_rightKey:
  mov byte [rel inputMap + KEY_RIGHT], dl
  ret

inputKeyCallback_eKey:
  cmp byte [rel inputMap + KEY_E], 0
  jz inputKeyCallback_eKeyDoPress
  cmp dl, 0
  jz inputKeyCallback_eKeyDoPress
  ret
inputKeyCallback_eKeyDoPress:
  mov byte [rel inputMap + KEY_E], dl
  ret