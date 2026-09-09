global sceneOverworldInit
global sceneOverworldUpdate
global sceneOverworldRender
global currentMap
global swapSceneEvent

extern playerOverworldInit
extern playerOverworldUpdate
extern playerOverworldRender

extern rendererDrawMap
extern rendererUpdateAnimationFrameIndex

extern town_test
extern house_test

extern sceneUpdate
extern sceneRender

extern fadeActive
extern fadeUpdate

extern npcOverworldUpdate
extern npcOverworldRender
extern npcsSize

extern mapInitNPCs

section .bss
  currentMap resq 1
  swapSceneEvent resq 1

section .text

; -------------------------------------------------------------
sceneOverworldInit:
  sub rsp, 8

  lea rax, [rel town_test]
  mov qword [rel currentMap], rax

  lea rax, [rel sceneOverworldUpdate]
  mov [rel sceneUpdate], rax

  lea rax, [rel sceneOverworldRender]
  mov [rel sceneRender], rax

  mov edi, 0
  mov esi, 0
  mov dl, 0
  call playerOverworldInit

  call mapInitNPCs

  add rsp, 8
  ret

sceneOverworldSwapScene:
  sub rsp, 8

  mov r8, [rel swapSceneEvent]
  mov rax, [r8 + 3]
  mov qword [rel currentMap], rax
  
  movzx edi, byte [r8 + 11]
  movzx esi, byte [r8 + 12]
  movzx rdx, byte [r8 + 13]
  call playerOverworldInit

  call mapInitNPCs

  mov qword [rel swapSceneEvent], 0

  add rsp, 8
  ret

; -------------------------------------------------------------
sceneOverworldUpdate:
  sub rsp, 8

  cmp byte [rel fadeActive], 0
  jz sceneOverworldUpdate_noFade
  call fadeUpdate

  cmp byte [rel fadeActive], 1
  jz sceneOverworldUpdate_noUpdate

sceneOverworldUpdate_noFade:
  mov rdi, [rel swapSceneEvent]
  cmp rdi, 0
  jz sceneOverworldUpdate_noSwap
  call sceneOverworldSwapScene

sceneOverworldUpdate_noSwap:
  cmp byte [rel fadeActive], 0
  ja sceneOverworldUpdate_noUpdate

  call playerOverworldUpdate
  call rendererUpdateAnimationFrameIndex

  movzx r12d, byte [rel npcsSize]
  test r12d, r12d
  jz sceneOverworldUpdate_noUpdate

sceneOverworldUpdate_npcs:
  dec r12
  mov rdi, r12
  call npcOverworldUpdate
  cmp r12, 0
  jg sceneOverworldUpdate_npcs

sceneOverworldUpdate_noUpdate:
  add rsp, 8
  ret

; -------------------------------------------------------------
sceneOverworldRender:
  push r12
  mov rdi, [rel currentMap]
  call rendererDrawMap

  call playerOverworldRender

  movzx r12d, byte [rel npcsSize]
  test r12d, r12d
  jz sceneOverworldRender_done

sceneOverworldRender_npcs:
  dec r12
  mov rdi, r12
  call npcOverworldRender
  cmp r12, 0
  jg sceneOverworldRender_npcs

sceneOverworldRender_done:
  pop r12
  ret

section .note.GNU-stack noalloc noexec nowrite progbits