%include "src/constants.inc"

extern warrior_ow_fd
extern warrior_ow_fr
extern warrior_ow_fl
extern warrior_ow_fu

extern spriteAnimationUpdate

global characterOverworldGetSprite
global characterOverworldUpdateAnimationFrame
global characterOverworldUpdateMovement

section .text

; -------------------------------------------------------------
; dil: direction, si: characterOffset
; -------------------------------------------------------------
characterOverworldGetSprite:
  movzx esi, si
  shl rsi, 4

  cmp dil, CHARACTER_DIR_DOWN
  jnz characterOverworldGetSprite_notDown
  lea rax, [rel warrior_ow_fd]
  add rax, rsi
  ret

characterOverworldGetSprite_notDown:
  cmp dil, CHARACTER_DIR_RIGHT
  jnz characterOverworldGetSprite_notRight
  lea rax, [rel warrior_ow_fr]
  add rax, rsi
  ret

characterOverworldGetSprite_notRight:
  cmp dil, CHARACTER_DIR_LEFT
  jnz characterOverworldGetSprite_notLeft
  lea rax, [rel warrior_ow_fl]
  add rax, rsi
  ret

characterOverworldGetSprite_notLeft:
  lea rax, [rel warrior_ow_fu]
  add rax, rsi
  ret

; -------------------------------------------------------------
; rdi: frameIndexAddress, sil: stateMachine
; -------------------------------------------------------------
characterOverworldUpdateAnimationFrame:
  cmp sil, CHARACTER_SM_WALK
  jz characterOverworldUpdateAnimationFrame_walk
  cmp sil, CHARACTER_SM_IDLE_WALK
  jz characterOverworldUpdateAnimationFrame_idleWalk
  jmp characterOverworldUpdateAnimationFrame_idle

characterOverworldUpdateAnimationFrame_walk:
  mov rsi, 4
  mov rdx, CHARACTERS_ANIM_SPEED
  jmp spriteAnimationUpdate

characterOverworldUpdateAnimationFrame_idleWalk:
  mov rsi, 4
  mov rdx, CHARACTERS_ANIM_IDLE_SPEED
  jmp spriteAnimationUpdate

characterOverworldUpdateAnimationFrame_idle:
  xor rax, rax
  ret

; -------------------------------------------------------------
; rdi: pntrX, rsi: pntrY, rdx: pntrXT, rcx: pntrYT, r8: isPositiveMovement
; -------------------------------------------------------------
characterOverworldUpdateMovementCheckFinish:
  test r8, r8
  jnz characterOverworldUpdateMovementCheckFinish_positive
  
  mov eax, dword [rdx]
  cmp dword [rdi], eax
  jg characterOverworldUpdateMovementCheckFinish_false

  mov eax, dword [rcx]
  cmp dword [rsi], eax
  jg characterOverworldUpdateMovementCheckFinish_false

  jmp characterOverworldUpdateMovementCheckFinish_true

characterOverworldUpdateMovementCheckFinish_positive:
  mov eax, dword [rdx]
  cmp dword [rdi], eax
  jl characterOverworldUpdateMovementCheckFinish_false

  mov eax, dword [rcx]
  cmp dword [rsi], eax
  jl characterOverworldUpdateMovementCheckFinish_false

characterOverworldUpdateMovementCheckFinish_true:
  mov eax, dword [rdx]
  mov dword dword [rdi], eax
  mov eax, dword [rcx]
  mov dword dword [rsi], eax
  
  mov eax, 1
  ret

characterOverworldUpdateMovementCheckFinish_false:
  xor eax, eax
  ret

; -------------------------------------------------------------
; rdi: pntrX, rsi: pntrY, rdx: pntrXT, rcx: pntrYT
; -------------------------------------------------------------
characterOverworldUpdateMovement:
  mov eax, dword [rdi]
  cmp dword [rdx], eax
  jz characterOverworldUpdateMovement_verticalCheck
  jg characterOverworldUpdateMovement_moveRight

  sub dword [rdi], CHARACTERS_MOVEMENT_SPEED

  xor r8, r8
  jmp characterOverworldUpdateMovementCheckFinish

characterOverworldUpdateMovement_moveRight:
  add dword [rdi], CHARACTERS_MOVEMENT_SPEED

  mov r8, 1
  jmp characterOverworldUpdateMovementCheckFinish

characterOverworldUpdateMovement_verticalCheck:
  mov eax, dword [rsi]
  cmp dword [rcx], eax
  jz characterOverworldUpdateMovement_false
  jg characterOverworldUpdateMovement_moveDown

  sub dword [rsi], CHARACTERS_MOVEMENT_SPEED

  xor r8, r8
  jmp characterOverworldUpdateMovementCheckFinish

characterOverworldUpdateMovement_moveDown:
  add dword [rsi], CHARACTERS_MOVEMENT_SPEED

  mov r8, 1
  jmp characterOverworldUpdateMovementCheckFinish

characterOverworldUpdateMovement_false:
  xor eax, eax
  ret

section .note.GNU-stack noalloc noexec nowrite progbits