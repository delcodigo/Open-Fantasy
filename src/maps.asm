%include "src/constants.inc"

global town_test
global house_test
global mapIsTileSolid
global mapGetEventAt
global mapEventExecute

extern solid_tiles

extern indexOfByte

extern currentMap
extern swapSceneEvent

section .rodata
  town_test: 
    db 20, 23
    dq town_test_events
    db 1,1,1,1,1,1,1,5,5,5,5,5,3,1,1,1,1,1,1,1,
    db 1,5,1,1,1,1,5,5,5,5,5,5,3,5,5,1,1,1,1,1,
    db 1,1,14,14,14,14,1,5,5,5,5,3,3,5,14,14,14,14,1,1,
    db 1,1,15,15,15,15,16,1,1,5,5,3,3,1,15,15,15,15,16,1,
    db 1,1,9,10,11,9,16,1,1,5,3,3,3,1,9,10,11,9,16,1,
    db 1,1,1,1,2,1,1,1,1,3,3,3,5,1,1,1,2,1,1,1,
    db 6,7,7,8,2,6,8,1,3,3,1,1,1,6,7,8,2,6,7,8,
    db 1,1,1,1,2,1,1,3,3,1,1,1,1,1,1,1,2,1,1,1,
    db 1,5,1,1,2,5,3,3,1,2,2,2,2,1,1,1,2,1,1,1,
    db 1,5,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,
    db 1,5,5,5,3,3,3,3,1,2,2,2,2,1,1,1,1,1,1,5,
    db 3,3,3,3,3,3,3,5,1,2,2,2,2,1,1,1,1,1,5,5,
    db 3,3,14,14,14,13,14,14,1,1,2,1,1,1,1,1,1,5,5,5,
    db 3,1,15,15,15,12,15,15,16,1,2,1,5,5,5,1,1,14,14,1,
    db 1,1,9,10,9,11,10,9,16,1,2,1,5,5,1,1,1,14,14,16,
    db 1,1,6,7,8,2,1,1,1,1,2,1,1,1,1,1,1,14,14,16,
    db 1,5,1,1,1,2,2,2,2,2,2,1,1,1,14,14,14,14,14,16,
    db 5,5,5,5,1,1,1,1,1,1,2,1,1,5,15,15,15,15,15,16,
    db 1,5,5,5,1,1,1,5,5,1,2,1,1,5,9,10,11,10,9,16,
    db 1,5,5,1,1,1,5,5,5,1,2,2,2,2,2,2,2,6,7,8,
    db 1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,
    db 7,8,5,5,1,6,7,7,8,1,2,1,6,7,7,8,1,5,1,5,
    db 1,5,5,5,1,5,5,1,1,1,2,1,1,1,1,1,1,5,5,5

  town_test_events:
    db 1
  town_test_event0:
    db EVENT_EXIT
    db 4, 4
    dq house_test
    db 8, 9, PLAYER_DIR_UP
    times EVENT_SIZE - ($ - town_test_event0) db 0
  
  house_test:
    db 16, 15
    dq house_test_events
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,9,18,9,9,19,9,18,9,19,19,19,19,
    db 19,19,19,19,20,20,20,27,19,28,28,28,19,19,19,19,
    db 19,19,19,19,20,23,20,20,19,28,28,28,19,19,19,19,
    db 19,19,19,19,20,24,20,20,19,28,28,28,19,19,19,19,
    db 19,19,19,19,20,25,20,20,9,20,20,20,19,19,19,19,
    db 19,19,19,19,20,26,20,20,20,20,20,20,19,19,19,19,
    db 19,19,19,19,20,20,20,20,20,20,20,27,19,19,19,19,
    db 19,19,19,19,19,19,19,19,22,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,
    db 19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19
  
  house_test_events:
    db 1
  house_test_event0:
    db EVENT_EXIT
    db 8, 10
    dq town_test
    db 4, 5, PLAYER_DIR_DOWN
    times EVENT_SIZE - ($ - house_test_event0) db 0

section .text

; rdi: x, rsi: y
mapIsTileSolid:
  shr rdi, 20
  shr rsi, 20

  mov rax, [rel currentMap]
  movzx edx, byte [rax]
  imul esi, edx
  add rsi, rdi
  add rsi, 10

  movzx rdx, byte [rax + rsi]
  dec rdx

  lea rdi, [rel solid_tiles]
  movzx esi, byte [rdi]
  inc rdi

  sub rsp, 8
  call indexOfByte
  add rsp, 8

  test rax, rax
  jl mapIsTileSolid_notSolid

  mov rax, 1
  ret

mapIsTileSolid_notSolid:
  xor rax, rax
  ret

; rdi: x, rsi: y
mapGetEventAt:
  shr rdi, 20
  shr rsi, 20

  mov rax, [rel currentMap]
  mov rax, qword [rax + 2]

  movzx edx, byte [rax]
  inc rax

  test edx, edx
  jz mapGetEventAt_noEvents

mapGetEventAt_loop:
  movzx ecx, byte [rax + 1]
  cmp rcx, rdi
  jne mapGetEventAt_skipToNextLoop

  movzx ecx, byte [rax + 2]
  cmp rcx, rsi
  jne mapGetEventAt_skipToNextLoop

  ret

mapGetEventAt_skipToNextLoop:
  add rax, EVENT_SIZE
  dec rdx
  jnz mapGetEventAt_loop

mapGetEventAt_noEvents:
  xor rax, rax
  ret

; rdi: pointer to event
mapEventExecute:
  sub rsp, 8

  movzx eax, byte [rdi]
  cmp rax, EVENT_EXIT
  jnz mapEventExecute_noEvent

  mov qword [rel swapSceneEvent], rdi

mapEventExecute_noEvent:
  add rsp, 8
  ret

section .note.GNU-stack noalloc noexec nowrite progbits