%include "src/constants.inc"

extern rendererDrawMacroSprite

extern warrior_ow_fd_1
extern warrior_ow_pal

extern spriteAnimationRoundFrame

extern characterOverworldGetSprite
extern characterOverworldUpdateAnimationFrame
extern characterOverworldUpdateMovement

extern mapIsTileSolid

extern rngNext

global npcOverworldGetNPCAt
global npcOverworldInit
global npcOverworldUpdateIdleWalk
global npcOverworldUpdateWanderer
global npcOverworldUpdate
global npcOverworldRender
global npcs
global npcsSize

section .bss
  npcsSize resb 1
; npc(x: 32bit, y: 32bit, xt: 32bit, yt: 32bit, xp: 32bit, yp: 32bit, fi: 32bit, sprIn: 16bit, palIn: 8bit, dir: 8bit, sm: 8bit, upd: 64bit, time: 16bit) - 43 bytes per npc
  npcs resb NPC_STRUCT_SIZE * NPC_MAX

section .text

; -------------------------------------------------------------
; rdi: npcOffset
; -------------------------------------------------------------
npcOverworldInit:
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
; edi: x, esi: y
; -------------------------------------------------------------
npcOverworldGetNPCAt:
  sar edi, 20
  sar esi, 20

  movzx edx, byte [rel npcsSize]
  lea rcx, [rel npcs]

npcOverworldGetNPCAt_loop:
  test rdx, rdx
  jz npcOverworldGetNPCAt_noResult  

  dec rdx

  mov r8, rdx
  imul r8, NPC_STRUCT_SIZE
  lea rax, [rcx + r8]

  mov r8d, dword [rax + NPC_STRUCT_XP]
  sar r8d, 20
  cmp edi, r8d
  jnz npcOverworldGetNPCAt_checkTarget

  mov r8d, dword [rax + NPC_STRUCT_YP]
  sar r8d, 20
  cmp esi, r8d
  jnz npcOverworldGetNPCAt_checkTarget

  ret

npcOverworldGetNPCAt_checkTarget:
  mov r8d, dword [rax + NPC_STRUCT_XT]
  sar r8d, 20
  cmp edi, r8d
  jnz npcOverworldGetNPCAt_loop

  mov r8d, dword [rax + NPC_STRUCT_YT]
  sar r8d, 20
  cmp esi, r8d
  jnz npcOverworldGetNPCAt_loop

  ret

npcOverworldGetNPCAt_noResult:
  xor rax, rax
  ret

; -------------------------------------------------------------
npcOverworldUpdateIdleWalk:
  mov byte [rdi + NPC_STRUCT_SM], CHARACTER_SM_IDLE_WALK
  mov byte [rdi + NPC_STRUCT_DIR], CHARACTER_DIR_DOWN
  ret

; -------------------------------------------------------------
npcOverworldUpdateWanderer:
  push r12
  push r13
  push r14

  mov r12, rdi

  cmp byte [r12 + NPC_STRUCT_SM], CHARACTER_SM_IDLE
  jz npcOverworldUpdateWanderer_idle

  cmp byte [r12 + NPC_STRUCT_SM], CHARACTER_SM_WALK
  jz npcOverworldUpdateWanderer_walk

  jmp npcOverworldUpdateWanderer_done

npcOverworldUpdateWanderer_idle:
  movzx r8d, word [r12 + NPC_STRUCT_TIME]
  test r8, r8
  jz npcOverworldUpdateWanderer_idleAct
  dec word [r12 + NPC_STRUCT_TIME]
  jmp npcOverworldUpdateWanderer_done

npcOverworldUpdateWanderer_idleAct:
  call rngNext
  and eax, 3
  mov byte [r12 + NPC_STRUCT_DIR], al
  
  mov edi, dword [r12 + NPC_STRUCT_X]
  mov esi, dword [r12 + NPC_STRUCT_Y]

  cmp eax, CHARACTER_DIR_DOWN
  jnz npcOverworldUpdateWanderer_idleActNotDown
  add esi, 16 << 16
  jmp npcOverworldUpdateWanderer_idleActTryMove

npcOverworldUpdateWanderer_idleActNotDown:
  cmp eax, CHARACTER_DIR_RIGHT
  jnz npcOverworldUpdateWanderer_idleActNotRight
  add edi, 16 << 16
  jmp npcOverworldUpdateWanderer_idleActTryMove

npcOverworldUpdateWanderer_idleActNotRight:
  cmp eax, CHARACTER_DIR_UP
  jnz npcOverworldUpdateWanderer_idleActNotUp
  sub esi, 16 << 16
  jmp npcOverworldUpdateWanderer_idleActTryMove

npcOverworldUpdateWanderer_idleActNotUp:
  sub edi, 16 << 16

npcOverworldUpdateWanderer_idleActTryMove:
  mov r13d, edi
  mov r14d, esi

  xor rdx, rdx
  call mapIsTileSolid
  test rax, rax
  jnz npcOverworldUpdateWanderer_randomTime

  mov edi, dword [r12 + NPC_STRUCT_X]
  mov dword [r12 + NPC_STRUCT_XP], edi
  mov edi, dword [r12 + NPC_STRUCT_Y]
  mov dword [r12 + NPC_STRUCT_YP], edi

  mov dword [r12 + NPC_STRUCT_XT], r13d
  mov dword [r12 + NPC_STRUCT_YT], r14d
  mov byte [r12 + NPC_STRUCT_SM], CHARACTER_SM_WALK

  jmp npcOverworldUpdateWanderer_randomTime

npcOverworldUpdateWanderer_randomTime:
  call rngNext
  and ax, 63
  add ax, 60
  mov word [r12 + NPC_STRUCT_TIME], ax
  jmp npcOverworldUpdateWanderer_done

npcOverworldUpdateWanderer_walk:
  lea rdi, [r12 + NPC_STRUCT_X]
  lea rsi, [r12 + NPC_STRUCT_Y]
  lea rdx, [r12 + NPC_STRUCT_XT]
  lea rcx, [r12 + NPC_STRUCT_YT]
  call characterOverworldUpdateMovement
  test rax, rax
  jz npcOverworldUpdateWanderer_done

  mov edi, dword [r12 + NPC_STRUCT_X]
  mov dword [r12 + NPC_STRUCT_XP], edi
  mov edi, dword [r12 + NPC_STRUCT_Y]
  mov dword [r12 + NPC_STRUCT_YP], edi
  mov byte [r12 + NPC_STRUCT_SM], CHARACTER_SM_IDLE
  lea rdi, [r12 + NPC_STRUCT_FI]
  call spriteAnimationRoundFrame

npcOverworldUpdateWanderer_done:
  pop r14
  pop r13
  pop r12
  ret

; -------------------------------------------------------------
; rdi: npcOffset
; -------------------------------------------------------------
npcOverworldUpdate:
  imul rdi, NPC_STRUCT_SIZE
  lea rax, [rel npcs]
  add rdi, rax

  jmp qword [rdi + NPC_STRUCT_UPD]

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