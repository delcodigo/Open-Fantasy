%include "src/constants.inc"

%define PLAYER_SM_IDLE 0
%define PLAYER_SM_WALK 1

%define PLAYER_DIR_DOWN 0
%define PLAYER_DIR_RIGHT 1
%define PLAYER_DIR_LEFT 2
%define PLAYER_DIR_UP 3

extern rendererDrawMacroSprite
extern cameraX
extern cameraY

extern warrior_ow_fd_1
extern warrior_ow_fd
extern warrior_ow_fr
extern warrior_ow_fl
extern warrior_ow_fu
extern warrior_ow_pal

extern inputMap

extern town_test

extern spriteAnimationRoundFrame
extern spriteAnimationUpdate

global playerOverworldInit
global playerOverworldUpdate
global playerOverworldRender

section .bss
  playerX resd 1
  playerY resd 1
  playerTX resd 1
  playerTY resd 1
  playerFI resd 1
  playerSM resb 1
  playerDir resb 1

section .text

; -------------------------------------------------------------
playerOverworldInit:
  ret

; -------------------------------------------------------------
playerOverworldUpdate:
  sub rsp, 8

  cmp byte [rel playerSM], PLAYER_SM_IDLE
  jz playerOverworldUpdate_idle
  cmp byte [rel playerSM], PLAYER_SM_WALK
  jz playerOverworldUpdate_walk

playerOverworldUpdate_idle:
  call playerOverworldUpdateMovementKeyPress
  test rax, rax
  jnz playerOverworldUpdate_return

playerOverworldUpdate_walk:
  call playerOverworldUpdateMovement
  test rax, rax
  jnz playerOverworldUpdate_return

playerOverworldUpdate_return:
  call playerOverworldUpdateCamera
  add rsp, 8
  ret

; -------------------------------------------------------------
; rdi: isPositiveMovement
; -------------------------------------------------------------
playerOverworldUpdateMovementCheckFinish:
  sub rsp, 8

  test rdi, rdi
  jnz playerOverworldUpdateMovementCheckFinish_positive
  
  mov eax, [rel playerTX]
  cmp [rel playerX], eax
  jg playerOverworldUpdateMovementCheckFinish_false

  mov eax, [rel playerTY]
  cmp [rel playerY], eax
  jg playerOverworldUpdateMovementCheckFinish_false

  jmp playerOverworldUpdateMovementCheckFinish_true

playerOverworldUpdateMovementCheckFinish_positive:
  mov eax, [rel playerTX]
  cmp [rel playerX], eax
  jl playerOverworldUpdateMovementCheckFinish_false

  mov eax, [rel playerTY]
  cmp [rel playerY], eax
  jl playerOverworldUpdateMovementCheckFinish_false

playerOverworldUpdateMovementCheckFinish_true:
  mov eax, [rel playerTX]
  mov dword [rel playerX], eax
  mov eax, [rel playerTY]
  mov dword [rel playerY], eax
  mov byte [rel playerSM], PLAYER_SM_IDLE
  
  lea rdi, [rel playerFI]
  call spriteAnimationRoundFrame

  call playerOverworldUpdateMovementKeyPress

  mov eax, 1
  add rsp, 8
  ret

playerOverworldUpdateMovementCheckFinish_false:
  xor eax, eax
  add rsp, 8
  ret

; -------------------------------------------------------------
playerOverworldUpdateMovement:
  mov eax, [rel playerX]
  cmp [rel playerTX], eax
  jz playerOverworldUpdateMovement_verticalCheck
  jg playerOverworldUpdateMovement_moveRight

  sub dword [rel playerX], CHARACTERS_MOVEMENT_SPEED

  xor rdi, rdi
  jmp playerOverworldUpdateMovementCheckFinish

playerOverworldUpdateMovement_moveRight:
  add dword [rel playerX], CHARACTERS_MOVEMENT_SPEED

  mov rdi, 1
  jmp playerOverworldUpdateMovementCheckFinish

playerOverworldUpdateMovement_verticalCheck:
  mov eax, [rel playerY]
  cmp [rel playerTY], eax
  jz playerOverworldUpdateMovement_false
  jg playerOverworldUpdateMovement_moveDown

  sub dword [rel playerY], CHARACTERS_MOVEMENT_SPEED

  xor rdi, rdi
  jmp playerOverworldUpdateMovementCheckFinish

playerOverworldUpdateMovement_moveDown:
  add dword [rel playerY], CHARACTERS_MOVEMENT_SPEED

  mov rdi, 1
  jmp playerOverworldUpdateMovementCheckFinish

playerOverworldUpdateMovement_false:
  xor eax, eax
  ret

; -------------------------------------------------------------
playerOverworldUpdateMovementKeyPress:
  xor rax, rax

  cmp byte [rel inputMap + KEY_UP], 1
  jnz playerOverworldUpdateMovementKeyPress_noUp
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  sub eax, 16 << 16
  mov dword [rel playerTY], eax
  mov byte [rel playerDir], PLAYER_DIR_UP
  mov rax, 1
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noUp:
  cmp byte [rel inputMap + KEY_LEFT], 1
  jnz playerOverworldUpdateMovementKeyPress_noLeft
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  sub eax, 16 << 16
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  mov dword [rel playerTY], eax
  mov byte [rel playerDir], PLAYER_DIR_LEFT
  mov rax, 1
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noLeft:
  cmp byte [rel inputMap + KEY_DOWN], 1
  jnz playerOverworldUpdateMovementKeyPress_noDown
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  add eax, 16 << 16
  mov dword [rel playerTY], eax
  mov byte [rel playerDir], PLAYER_DIR_DOWN
  mov rax, 1
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noDown:
  cmp byte [rel inputMap + KEY_RIGHT], 1
  jnz playerOverworldUpdateMovementKeyPress_return
  mov byte [rel playerSM], PLAYER_SM_WALK
  mov eax, [rel playerX]
  add eax, 16 << 16
  mov dword [rel playerTX], eax
  mov eax, [rel playerY]
  mov dword [rel playerTY], eax
  mov byte [rel playerDir], PLAYER_DIR_RIGHT
  mov rax, 1
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_return:
  ret

; -------------------------------------------------------------
playerOverworldUpdateCamera:
  lea r8, [rel town_test]
  movzx r9d, byte [r8 + 1]
  shl r9d, 4
  sub r9d, 240
  shl r9d, 16

  movzx r8d, byte [r8]
  shl r8d, 4
  sub r8d, 256
  shl r8d, 16

  mov eax, [rel playerX]
  sub eax, 120 << 16
  cmp eax, 0
  jge playerOverworldUpdateCamera_compareMaxX
  xor eax, eax
  jmp playerOverworldUpdateCamera_setX

playerOverworldUpdateCamera_compareMaxX:
  cmp eax, r8d
  jle playerOverworldUpdateCamera_setX
  mov eax, r8d

playerOverworldUpdateCamera_setX:
  mov [rel cameraX], eax

  mov eax, [rel playerY]
  sub eax, 112 << 16
  cmp eax, 0
  jge playerOverworldUpdateCamera_compareMaxY
  xor eax, eax
  jmp playerOverworldUpdateCamera_setY

playerOverworldUpdateCamera_compareMaxY:
  cmp eax, r9d
  jle playerOverworldUpdateCamera_setY
  mov eax, r9d

playerOverworldUpdateCamera_setY:
  mov [rel cameraY], eax
  ret

; -------------------------------------------------------------
playerOverworldGetSprite:
  cmp byte [rel playerDir], PLAYER_DIR_DOWN
  jnz playerOverworldGetSprite_notDown
  lea rax, [rel warrior_ow_fd]
  ret

playerOverworldGetSprite_notDown:
  cmp byte [rel playerDir], PLAYER_DIR_RIGHT
  jnz playerOverworldGetSprite_notRight
  lea rax, [rel warrior_ow_fr]
  ret

playerOverworldGetSprite_notRight:
  cmp byte [rel playerDir], PLAYER_DIR_LEFT
  jnz playerOverworldGetSprite_notLeft
  lea rax, [rel warrior_ow_fl]
  ret

playerOverworldGetSprite_notLeft:
  lea rax, [rel warrior_ow_fu]
  ret

; -------------------------------------------------------------
playerOverworldUpdateAnimationFrame:
  cmp byte [rel playerSM], PLAYER_SM_IDLE
  jz playerOverworldUpdateAnimationFrame_idle
  lea rdi, [rel playerFI]
  mov rsi, 4
  mov rdx, CHARACTERS_ANIM_SPEED
  jmp spriteAnimationUpdate

playerOverworldUpdateAnimationFrame_idle:
  xor rax, rax
  ret

; -------------------------------------------------------------
playerOverworldRender:
  sub rsp, 8

  call playerOverworldUpdateAnimationFrame
  mov r8, rax

  mov eax, [rel playerX]
  sar eax, 16
  mov edi, eax

  mov eax, [rel playerY]
  sar eax, 16
  mov esi, eax

  call playerOverworldGetSprite
  movzx r9d, byte [rax + r8]
  lea rdx, [warrior_ow_fd_1 + r9d * 4]
  lea rcx, [rel warrior_ow_pal]
  call rendererDrawMacroSprite

  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits