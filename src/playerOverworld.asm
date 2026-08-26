%include "src/constants.inc"

extern rendererDrawMacroSprite

extern warrior_ow_fd
extern warrior_ow_pal

extern inputMap

extern dummyAnimationUpdate

global playerOverworld_update
global playerOverworld_render

section .data
  playerX dd 0
  playerY dd 0

section .text

; -------------------------------------------------------------
playerOverworld_update:
  call playerOverworld_updateMovement
  test rax, rax
  jnz playerOverworld_update_return

playerOverworld_update_return:
  ret

; -------------------------------------------------------------
playerOverworld_updateMovement:
  cmp byte [inputMap + KEY_UP], 1
  jnz playerOverworld_updateMovement_noUp
  sub dword [rel playerY], 1
  jmp playerOverworld_updateMovement_return

playerOverworld_updateMovement_noUp:
  cmp byte [inputMap + KEY_LEFT], 1
  jnz playerOverworld_updateMovement_noLeft
  sub dword [rel playerX], 1
  jmp playerOverworld_updateMovement_return

playerOverworld_updateMovement_noLeft:
  cmp byte [inputMap + KEY_DOWN], 1
  jnz playerOverworld_updateMovement_noDown
  add dword [rel playerY], 1
  jmp playerOverworld_updateMovement_return

playerOverworld_updateMovement_noDown:
  cmp byte [inputMap + KEY_RIGHT], 1
  jnz playerOverworld_updateMovement_return
  add dword [rel playerX], 1
  jmp playerOverworld_updateMovement_return

playerOverworld_updateMovement_return:
  ret

; -------------------------------------------------------------
playerOverworld_render:
  call dummyAnimationUpdate
  mov r8, rax

  mov edi, [rel playerX]
  mov esi, [rel playerY]
  lea rax, [rel warrior_ow_fd]
  mov rdx, [rax + r8 * 8]
  lea rcx, [rel warrior_ow_pal]
  call rendererDrawMacroSprite

  ret

section .note.GNU-stack noalloc noexec nowrite progbits