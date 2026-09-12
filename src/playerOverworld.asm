%include "src/constants.inc"

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

extern currentMap

extern spriteAnimationRoundFrame
extern spriteAnimationUpdate

extern mapIsTileSolid
extern mapGetEventAt
extern mapEventExecute

extern characterOverworldGetSprite
extern characterOverworldUpdateAnimationFrame
extern characterOverworldUpdateMovement

extern npcOverworldFaceAt
extern npcOverworldGetNPCAt

global playerOverworldInit
global playerOverworldUpdate
global playerOverworldRender
global playerX
global playerXT
global playerY
global playerYT

section .bss
  playerX resd 1
  playerY resd 1
  playerXT resd 1
  playerYT resd 1
  playerFI resd 1
  playerSM resb 1
  playerDir resb 1
  playerEvent resq 1

section .text

; edi: x, esi: y, dl: dir
playerOverworldInit:
  shl rdi, 20
  shl esi, 20
  mov dword [rel playerX], edi
  mov dword [rel playerY], esi
  mov byte [rel playerDir], dl
  mov byte [rel playerSM], CHARACTER_SM_IDLE
  mov qword [rel playerEvent], 0
  ret

; -------------------------------------------------------------
playerOverworldUpdate:
  sub rsp, 8

  cmp byte [rel playerSM], CHARACTER_SM_IDLE
  jz playerOverworldUpdate_idle
  cmp byte [rel playerSM], CHARACTER_SM_WALK
  jz playerOverworldUpdate_walk
  cmp byte [rel playerSM], CHARACTER_SM_EVENT
  jz playerOverworldUpdate_executeEvent

playerOverworldUpdate_idle:
  call playerOverworldUpdateMovementKeyPress
  test rax, rax
  jnz playerOverworldUpdate_return
  call playerOverworldUpdateAction
  jmp playerOverworldUpdate_return

playerOverworldUpdate_walk:
  lea rdi, [rel playerX]
  lea rsi, [rel playerY]
  lea rdx, [rel playerXT]
  lea rcx, [rel playerYT]
  call characterOverworldUpdateMovement
  test rax, rax
  jz playerOverworldUpdate_return

  mov eax, [rel playerXT]
  mov [rel playerX], eax
  mov eax, [rel playerYT]
  mov [rel playerY], eax
  mov byte [rel playerSM], CHARACTER_SM_IDLE
  lea rdi, [rel playerFI]
  call spriteAnimationRoundFrame

  mov edi, [rel playerX]
  mov esi, [rel playerY]
  call mapGetEventAt
  test rax, rax
  jz playerOverworldUpdate_walkNoEvent
  mov byte [rel playerSM], CHARACTER_SM_EVENT
  mov qword [rel playerEvent], rax

playerOverworldUpdate_walkNoEvent:
  call playerOverworldUpdateMovementKeyPress
  jmp playerOverworldUpdate_return

playerOverworldUpdate_executeEvent:
  mov byte [rel playerSM], CHARACTER_SM_NONE
  mov rdi, [rel playerEvent]
  call mapEventExecute
  
playerOverworldUpdate_return:
  call playerOverworldUpdateCamera
  add rsp, 8
  ret

; -------------------------------------------------------------
playerOverworldUpdateAction:
  sub rsp, 8
  
  cmp byte [rel inputMap + KEY_E], 1
  jnz playerOverworldUpdateAction_return
  mov byte [rel inputMap + KEY_E], 2

  mov edi, [rel playerX]
  mov esi, [rel playerY]

  cmp byte [rel playerDir], CHARACTER_DIR_DOWN
  jnz playerOverworldUpdateAction_notDown
  add esi, 16 << 16
  jmp playerOverworldUpdateAction_checkNPC

playerOverworldUpdateAction_notDown:
  cmp byte [rel playerDir], CHARACTER_DIR_RIGHT
  jnz playerOverworldUpdateAction_notRight
  add edi, 16 << 16
  jmp playerOverworldUpdateAction_checkNPC

playerOverworldUpdateAction_notRight:
  cmp byte [rel playerDir], CHARACTER_DIR_UP
  jnz playerOverworldUpdateAction_notUp
  sub esi, 16 << 16
  jmp playerOverworldUpdateAction_checkNPC

playerOverworldUpdateAction_notUp:
  sub edi, 16 << 16

playerOverworldUpdateAction_checkNPC:
  call npcOverworldGetNPCAt
  test rax, rax
  jz playerOverworldUpdateAction_return

  mov rdi, rax
  mov esi, [rel playerX]
  mov edx, [rel playerY]
  call npcOverworldFaceAt

  mov rax, 1

playerOverworldUpdateAction_return:
  add rsp, 8
  ret

; -------------------------------------------------------------
playerOverworldUpdateMovementKeyPressCheckCollision:
  sub rsp, 8
  mov edi, [rel playerXT]
  mov esi, [rel playerYT]
  mov rdx, 1
  call mapIsTileSolid
  add rsp, 8
  ret

; -------------------------------------------------------------
playerOverworldUpdateMovementKeyPress:
  sub rsp, 8
  xor rax, rax

  cmp byte [rel inputMap + KEY_UP], 1
  jnz playerOverworldUpdateMovementKeyPress_noUp
  mov eax, [rel playerX]
  mov dword [rel playerXT], eax
  mov eax, [rel playerY]
  sub eax, 16 << 16
  mov dword [rel playerYT], eax
  mov byte [rel playerDir], CHARACTER_DIR_UP
  mov rax, 1

  call playerOverworldUpdateMovementKeyPressCheckCollision
  cmp rax, 1
  jz playerOverworldUpdateMovementKeyPress_return

  mov byte [rel playerSM], CHARACTER_SM_WALK
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noUp:
  cmp byte [rel inputMap + KEY_LEFT], 1
  jnz playerOverworldUpdateMovementKeyPress_noLeft
  mov eax, [rel playerX]
  sub eax, 16 << 16
  mov dword [rel playerXT], eax
  mov eax, [rel playerY]
  mov dword [rel playerYT], eax
  mov byte [rel playerDir], CHARACTER_DIR_LEFT
  mov rax, 1

  call playerOverworldUpdateMovementKeyPressCheckCollision
  cmp rax, 1
  jz playerOverworldUpdateMovementKeyPress_return

  mov byte [rel playerSM], CHARACTER_SM_WALK
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noLeft:
  cmp byte [rel inputMap + KEY_DOWN], 1
  jnz playerOverworldUpdateMovementKeyPress_noDown
  mov eax, [rel playerX]
  mov dword [rel playerXT], eax
  mov eax, [rel playerY]
  add eax, 16 << 16
  mov dword [rel playerYT], eax
  mov byte [rel playerDir], CHARACTER_DIR_DOWN
  mov rax, 1

  call playerOverworldUpdateMovementKeyPressCheckCollision
  cmp rax, 1
  jz playerOverworldUpdateMovementKeyPress_return

  mov byte [rel playerSM], CHARACTER_SM_WALK
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_noDown:
  cmp byte [rel inputMap + KEY_RIGHT], 1
  jnz playerOverworldUpdateMovementKeyPress_return
  mov eax, [rel playerX]
  add eax, 16 << 16
  mov dword [rel playerXT], eax
  mov eax, [rel playerY]
  mov dword [rel playerYT], eax
  mov byte [rel playerDir], CHARACTER_DIR_RIGHT
  mov rax, 1

  call playerOverworldUpdateMovementKeyPressCheckCollision
  cmp rax, 1
  jz playerOverworldUpdateMovementKeyPress_return

  mov byte [rel playerSM], CHARACTER_SM_WALK
  jmp playerOverworldUpdateMovementKeyPress_return

playerOverworldUpdateMovementKeyPress_return:
  add rsp, 8
  ret

; -------------------------------------------------------------
playerOverworldUpdateCamera:
  mov r8, [rel currentMap]
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
playerOverworldRender:
  sub rsp, 8

  mov sil, byte [rel playerSM]
  lea rdi, [rel playerFI]
  call characterOverworldUpdateAnimationFrame
  mov r8, rax

  mov dil, byte [rel playerDir]
  xor rsi, rsi
  call characterOverworldGetSprite
  movzx r9d, byte [rax + r8]
  lea rdx, [warrior_ow_fd_1 + r9d * 4]
  lea rcx, [rel warrior_ow_pal]
  
  mov eax, [rel playerX]
  sar eax, 16
  mov edi, eax

  mov eax, [rel playerY]
  sar eax, 16
  mov esi, eax

  call rendererDrawMacroSprite

  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits