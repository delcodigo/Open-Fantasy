%include "src/constants.inc"

extern rendererDrawMacroSprite

extern warrior_ow_fd_1
extern warrior_ow_pal

extern characterOverworldGetSprite
extern characterOverworldUpdateAnimationFrame

global npcOverworld_init
global npcOverworldRender
global npcs
global npcsSize

section .bss
  npcsSize resb 1
; npc(x: 32bit, y: 32bit, xt: 32bit, yt: 32bit, fi: 32bit, sprIn: 16bit, palIn: 8bit, dir: 8bit, sm: 8bit) - 25 bytes per npc
  npcs resb NPC_STRUCT_SIZE * NPC_MAX

section .text

; -------------------------------------------------------------
; rdi: npcOffset
; -------------------------------------------------------------
npcOverworld_init:
  mov rdx, rdi
  imul rdx, NPC_STRUCT_SIZE
  lea rax, [rel npcs]
  add rdx, rax

  mov rdi, rdx
  xor eax, eax
  mov ecx, NPC_STRUCT_SIZE
  rep stosb

  ret

; -------------------------------------------------------------
; rdi: npcOffset
; -------------------------------------------------------------
npcOverworldRender:
  push r12

  mov r12, rdi
  imul r12, NPC_STRUCT_SIZE
  lea rax, [rel npcs]
  add r12, rax

  mov sil, byte [r12 + NPC_STRUCT_SM]
  lea rdi, [r12 + NPC_STRUCT_FI]
  call characterOverworldUpdateAnimationFrame
  mov r8, rax

  mov dil, byte [r12 + NPC_STRUCT_DIR]
  mov si, word [r12 + NPC_STRUCT_SPRIN]
  call characterOverworldGetSprite
  movzx r9d, byte [rax + r8]
  lea r8, [rel warrior_ow_fd_1]
  lea rdx, [r8 + r9 * 4]

  mov edi, dword [r12 + NPC_STRUCT_X]
  sar rdi, 16
  mov esi, dword [r12 + NPC_STRUCT_Y]
  sar rsi, 16
  
  movzx eax, byte [r12 + NPC_STRUCT_PALIN]
  shl rax, 2
  lea r11, [rel warrior_ow_pal]
  lea rcx, [r11 + rax]
  call rendererDrawMacroSprite

  pop r12
  ret

section .note.GNU-stack noalloc noexec nowrite progbits