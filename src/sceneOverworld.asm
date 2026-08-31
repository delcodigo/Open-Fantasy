global sceneOverworldInit
global sceneOverworldUpdate
global sceneOverworldRender
global currentMap

extern playerOverworldInit
extern playerOverworldUpdate
extern playerOverworldRender

extern rendererDrawMap
extern rendererUpdateAnimationFrameIndex

extern town_test

extern sceneUpdate
extern sceneRender

section .bss
  currentMap resq 1

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

  call playerOverworldInit

  add rsp, 8
  ret

; -------------------------------------------------------------
sceneOverworldUpdate:
  sub rsp, 8
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