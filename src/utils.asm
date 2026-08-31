global indexOfByte
global strLen
global sysPrint
global sysExit

%define SYSCALL_WRITE 1
%define SYSCALL_EXIT 60

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

; -------------------------------------------------------------
; strLen(rdi_str_pointer: string)
;
; Walks through a NULL terminated string counting the number of 
; characters and returns the count. It doesn't includes the NULL
; terminator as part of the count
;
; assumes input is a NULL terminated string
;
; rdi: pointer to string
;
; returns:
;	rax = rcx pointer - rdi pointer
;
; registers:
;	rcx = local pointer to string
; -------------------------------------------------------------
strLen:
	mov rcx, rdi

strLen_loop:
  cmp byte [rcx], 0
  jz strLen_return
  inc rcx
  jmp strLen_loop

strLen_return:
  mov rax, rcx
  sub rax, rdi
  ret

; -------------------------------------------------------------
; sysPrint(rdi: string)
;
; Prints a string to the console
;
; rdi: message to print
; -------------------------------------------------------------
sysPrint:
	call strLen

	mov rsi, rdi
	mov rdx, rax
	mov rax, SYSCALL_WRITE
	mov rdi, 1
	syscall	
	ret

; -------------------------------------------------------------
; Terminates the program with status 0
; -------------------------------------------------------------
sysExit:
	mov rax, SYSCALL_EXIT
  mov rdi, 0
	syscall
	ret

section .note.GNU-stack noalloc noexec nowrite progbits