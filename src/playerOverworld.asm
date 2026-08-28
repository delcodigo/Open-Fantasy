%include "src/constants.inc"

%define PLAYER_SM_IDLE 0
%define PLAYER_SM_WALK 1

%define PLAYER_FACE_DOWN 0
%define PLAYER_FACE_RIGHT 1
%define PLAYER_FACE_LEFT 2
%define PLAYER_FACE_UP 3

%define MOVEMENT_SPEED 0x11111

extern rendererDrawMacroSprite

extern warrior_ow_fd_1
extern warrior_ow_fd
extern warrior_ow_fr
extern warrior_ow_fl
extern warrior_ow_fu
extern warrior_ow_pal

extern inputMap

extern spriteAnimationRoundFrame
extern spriteAnimationUpdate

global playerOverworld_init
global playerOverworld_update
global playerOverworld_render

section .bss
  playerX resd 1
  playerY resd 1
  playerTX resd 1
  playerTY resd 1
  playerFI resd 1
  playerSM resb 1
  playerFace resb 1

section .text

; -------------------------------------------------------------
playerOverworld_init:
  ret

; -------------------------------------------------------------
playerOverworld_update:
  cmp byte [rel playerSM], PLAYER_SM_IDLE
  jz playerOverworld_update_idle
  cmp byte [rel playerSM], PLAYER_SM_WALK
  jz playerOverworld_update_walk

playerOverworld_update_idle:
  call playerOverworld_updateMovementKeyPress
  test rax, rax
  jnz playerOverworld_update_return

playerOverworld_update_walk:
  call playerOverworld_updateMovement
  test rax, rax
  jnz playerOverworld_update_return

playerOverworld_update_return:
  ret

; -------------------------------------------------------------
; rdi: isPositiveMovement
; -------------------------------------------------------------
playerOverworld_updateMovementCheckFinish:
  test rdi, rdi
  jnz playerOverworld_updateMovementCheckFinish_positive
  
  mov eax, [rel playerTX]
  cmp [rel playerX], eax
  jg playerOverworld_updateMovementCheckFinish_false

  mov eax, [rel playerTY]
  cmp [rel playerY], eax
  jg playerOverworld_updateMovementCheckFinish_false

  jmp playerOverworld_updateMovementCheckFinish_true

playerOverworld_updateMovementCheckFinish_positive:
  mov eax, [rel playerTX]
  cmp [rel playerX], eax
  jl playerOverworld_updateMovementCheckFinish_false

  mov eax, [rel playerTY]
  cmp [rel playerY], eax
  jl playerOverworld_updateMovementCheckFinish_false

playerOverworld_updateMovementCheckFinish_true:
  mov eax, [rel playerTX]
  mov dword [rel playerX], eax
  mov eax, [rel playerTY]
  mov dword [rel playerY], eax
  mov byte [rel playerSM], PLAYER_SM_IDLE
  mov eax, 1
  
  lea rdi, [rel playerFI]
  call spriteAnimationRoundFrame

  call playerOverworld_updateMovementKeyPress
  ret

playerOverworld_updateMovementCheckFinish_false:
  xor eax, eax
  ret

; -------------------------------------------------------------
playerOverworld_updateMovement:
  mov eax, [rel playerX]
  cmp [rel playerTX], eax
  jz playerOverworld_updateMovement_verticalCheck
  jg playerOverworld_updateMovement_moveRight

  sub dword [rel playerX], MOVEMENT_SPEED

  xor rdi, rdi
  call playerOverworld_updateMovementCheckFinish
  ret

playerOverworld_updateMovement_moveRight:
  add dword [rel playerX], MOVEMENT_SPEED

  mov rdi, 1
  call playerOverworld_updateMovementCheckFinish
  ret

playerOverworld_updateMovement_verticalCheck:
  mov eax, [rel playerY]
  cmp [rel playerTY], eax
  jz playerOverworld_updateMovement_false
  jg playerOverworld_updateMovement_moveDown

  sub dword [rel playerY], MOVEMENT_SPEED

  xor rdi, rdi
  call playerOverworld_updateMovementCheckFinish
  ret

playerOverworld_updateMovement_moveDown:
  add dword [rel playerY], MOVEMENT_SPEED

  mov rdi, 1
  call playerOverworld_updateMovementCheckFinish
  ret

playerOverworld_updateMovement_false:
  xor eax, eax
  ret

; -------------------------------------------------------------
playerOverworld_updateMovementKeyPress:
  cmp byte [rel inputMap + KEY_UP], 1
  jnz playerOverworld_updateMovementKeyPress_noUp
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  sub eax, 16 << 16
  mov dword [rel playerTY], eax
  mov byte [rel playerFace], PLAYER_FACE_UP
  jmp playerOverworld_updateMovementKeyPress_return

playerOverworld_updateMovementKeyPress_noUp:
  cmp byte [rel inputMap + KEY_LEFT], 1
  jnz playerOverworld_updateMovementKeyPress_noLeft
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  sub eax, 16 << 16
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  mov dword [rel playerTY], eax
  mov byte [rel playerFace], PLAYER_FACE_LEFT
  jmp playerOverworld_updateMovementKeyPress_return

playerOverworld_updateMovementKeyPress_noLeft:
  cmp byte [rel inputMap + KEY_DOWN], 1
  jnz playerOverworld_updateMovementKeyPress_noDown
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  add eax, 16 << 16
  mov dword [rel playerTY], eax
  mov byte [rel playerFace], PLAYER_FACE_DOWN
  jmp playerOverworld_updateMovementKeyPress_return

playerOverworld_updateMovementKeyPress_noDown:
  cmp byte [rel inputMap + KEY_RIGHT], 1
  jnz playerOverworld_updateMovementKeyPress_return
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  add eax, 16 << 16
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  mov dword [rel playerTY], eax
  mov byte [rel playerFace], PLAYER_FACE_RIGHT
  jmp playerOverworld_updateMovementKeyPress_return

playerOverworld_updateMovementKeyPress_return:
  ret

; -------------------------------------------------------------
playerOverworld_getSprite:
  cmp byte [rel playerFace], PLAYER_FACE_DOWN
  jnz playerOverworld_getSprite_notDown
  lea rax, [rel warrior_ow_fd]
  ret

playerOverworld_getSprite_notDown:
  cmp byte [rel playerFace], PLAYER_FACE_RIGHT
  jnz playerOverworld_getSprite_notRight
  lea rax, [rel warrior_ow_fr]
  ret

playerOverworld_getSprite_notRight:
  cmp byte [rel playerFace], PLAYER_FACE_LEFT
  jnz playerOverworld_getSprite_notLeft
  lea rax, [rel warrior_ow_fl]
  ret

playerOverworld_getSprite_notLeft:
  lea rax, [rel warrior_ow_fu]
  ret

; -------------------------------------------------------------
playerOverworld_updateAnimationFrame:
  cmp byte [rel playerSM], PLAYER_SM_IDLE
  jz playerOverworld_updateAnimationFrame_idle
  lea rdi, [rel playerFI]
  call spriteAnimationUpdate
  ret

playerOverworld_updateAnimationFrame_idle:
  xor rax, rax
  ret

; -------------------------------------------------------------
playerOverworld_render:
  call playerOverworld_updateAnimationFrame
  mov r8, rax

  mov eax, [rel playerX]
  sar eax, 16
  mov edi, eax

  mov eax, [rel playerY]
  sar eax, 16
  mov esi, eax

  call playerOverworld_getSprite
  movzx r9d, byte [rax + r8]
  lea rdx, [warrior_ow_fd_1 + r9d * 4]
  lea rcx, [rel warrior_ow_pal]
  call rendererDrawMacroSprite

  ret

section .note.GNU-stack noalloc noexec nowrite progbits