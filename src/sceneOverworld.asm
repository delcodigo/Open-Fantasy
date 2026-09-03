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

  mov qword [rel swapSceneEvent], 0

  add rsp, 8
  ret

; -------------------------------------------------------------
sceneOverworldUpdate:
  sub rsp, 8
  mov rdi, [rel swapSceneEvent]
  cmp rdi, 0
  jz sceneOverworldUpdate_noSwap
  call sceneOverworldSwapScene

sceneOverworldUpdate_noSwap:
  call playerOverworldUpdate
  call rendererUpdateAnimationFrameIndex
  add rsp, 8
  ret

; -------------------------------------------------------------
sceneOverworldRender:
  sub rsp, 8
  mov rdi, [rel currentMap]
  call rendererDrawMap

  call playerOverworldRender
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits