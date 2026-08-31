global indexOfByte

section .text

; rdi: pointer, rsi: sizeOfSample, rdx: valueToSearch
indexOfByte:
  test rsi, rsi
  jz indexOfByte_notFound

  xor rax, rax

indexOfByte_loop:
  cmp byte [rdi], dl
  jz indexOfByte_found

  inc rax
  inc rdi
  cmp rax, rsi
  jb indexOfByte_loop

  jmp indexOfByte_notFound

indexOfByte_found:
  ret

indexOfByte_notFound:
  mov rax, -1
  ret

section .note.GNU-stack noalloc noexec nowrite progbits