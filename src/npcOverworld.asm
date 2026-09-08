%include "src/constants.inc"

extern rendererDrawMacroSprite

extern warrior_ow_fd_1
extern warrior_ow_pal

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

  mov edi, dword [r12]
  sar rdi, 16
  mov esi, dword [r12 + 4]
  sar rsi, 16
  movzx eax, word [r12 + 20]
  imul eax, 48
  lea r11, [rel warrior_ow_fd_1]
  lea rdx, [r11 + rax]
  movzx eax, byte [r12 + 22]
  shl rax, 2
  lea r11, [rel warrior_ow_pal]
  lea rcx, [r11 + rax]
  call rendererDrawMacroSprite

  pop r12
  ret

section .note.GNU-stack noalloc noexec nowrite progbits