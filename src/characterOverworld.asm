%include "src/constants.inc"

extern warrior_ow_fd
extern warrior_ow_fr
extern warrior_ow_fl
extern warrior_ow_fu

extern spriteAnimationUpdate

global characterOverworldGetSprite
global characterOverworldUpdateAnimationFrame

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

section .note.GNU-stack noalloc noexec nowrite progbits