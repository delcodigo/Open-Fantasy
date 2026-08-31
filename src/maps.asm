global town_test
global mapIsTileSolid

extern solid_tiles

extern indexOfByte

section .rodata
  town_test: 
    db 20, 23
    db 0,0,0,0,0,0,0,4,4,4,4,4,2,0,0,0,0,0,0,0,
    db 0,4,0,0,0,0,4,4,4,4,4,4,2,4,4,0,0,0,0,0,
    db 0,0,13,13,13,13,0,4,4,4,4,2,2,4,13,13,13,13,0,0,
    db 0,0,14,14,14,14,15,0,0,4,4,2,2,0,14,14,14,14,15,0,
    db 0,0,8,9,10,8,15,0,0,4,2,2,2,0,8,9,10,8,15,0,
    db 0,0,0,0,1,0,0,0,0,2,2,2,4,0,0,0,1,0,0,0,
    db 5,6,6,7,1,5,7,0,2,2,0,0,0,5,6,7,1,5,6,7,
    db 0,0,0,0,1,0,0,2,2,0,0,0,0,0,0,0,1,0,0,0,
    db 0,4,0,0,1,4,2,2,0,1,1,1,1,0,0,0,1,0,0,0,
    db 0,4,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,
    db 0,4,4,4,2,2,2,2,0,1,1,1,1,0,0,0,0,0,0,4,
    db 2,2,2,2,2,2,2,4,0,1,1,1,1,0,0,0,0,0,4,4,
    db 2,2,13,13,13,12,13,13,0,0,1,0,0,0,0,0,0,4,4,4,
    db 2,0,14,14,14,11,14,14,15,0,1,0,4,4,4,0,0,13,13,0,
    db 0,0,8,9,8,10,9,8,15,0,1,0,4,4,0,0,0,13,13,15,
    db 0,0,5,6,7,1,0,0,0,0,1,0,0,0,0,0,0,13,13,15,
    db 0,4,0,0,0,1,1,1,1,1,1,0,0,0,13,13,13,13,13,15,
    db 4,4,4,4,0,0,0,0,0,0,1,0,0,4,14,14,14,14,14,15,
    db 0,4,4,4,0,0,0,4,4,0,1,0,0,4,8,9,10,9,8,15,
    db 0,4,4,0,0,0,4,4,4,0,1,1,1,1,1,1,1,5,6,7,
    db 0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,
    db 6,7,4,4,0,5,6,6,7,0,1,0,5,6,6,7,0,4,0,4,
    db 0,4,4,4,0,4,4,0,0,0,1,0,0,0,0,0,0,4,4,4
  
section .text

; rdi: x, rsi: y
mapIsTileSolid:
  shr rdi, 20
  shr rsi, 20

  lea rax, [rel town_test]
  movzx edx, byte [rax]
  imul esi, edx
  add rsi, rdi
  add rsi, 2

  movzx rdx, byte [rax + rsi]

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

section .note.GNU-stack noalloc noexec nowrite progbits