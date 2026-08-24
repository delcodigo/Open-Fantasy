extern glfwInit
extern glfwTerminate
extern glfwWindowHint
extern glfwCreateWindow
extern glfwDestroyWindow
extern glfwMakeContextCurrent
extern glfwSwapInterval
extern glfwSwapBuffers
extern glfwPollEvents
extern glfwWindowShouldClose
extern gladLoadGL
extern glClearColor
extern glClear

section .rodata
  gameExitSuccesfully db "The fantasy is over", 10, 0
  glfwInitErrorMessage db "Failed to initialize GLFW", 10, 0
  glfwInitWindowErrorMessage db "Failed to create window", 10, 0
  gladLoadError db "Failed to load OpenGL functions", 10, 0
  windowTitle db "Open Fantasy", 0
  clearColor0_1 dd 0.1
  clearColor1_0 dd 1.0

section .data
  window dd 0

section .note.GNU-stack noalloc noexec nowrite progbits

section .text
  global _start

%define SYSCALL_WRITE 1
%define SYSCALL_EXIT 60

_start:
  call glfwInit
  test eax, eax
  jz _start_glfw_error

  mov rdi, 0x22002
  mov rsi, 2
  call glfwWindowHint

  mov rdi, 0x22003
  mov rsi, 1
  call glfwWindowHint

  mov rdi, 800
  mov rsi, 600
  mov rdx, windowTitle
  mov rcx, 0
  mov rax, 0
  call glfwCreateWindow
  test eax, eax
  jz _start_glfw_window_error
  mov [window], eax

  mov edi, [window]
  call glfwMakeContextCurrent

  mov rdi, 1
  call glfwSwapInterval

  call gladLoadGL
  test eax, eax
  jz _start_glad_load_error

  movss xmm0, [rel clearColor0_1]
  movss xmm1, [rel clearColor0_1]
  movss xmm2, [rel clearColor0_1]
  movss xmm3, [rel clearColor1_0]
  call glClearColor

_start_window_loop:
  mov rdi, 0x4100
  call glClear

  ; The game happens here

  mov edi, [window]
  call glfwSwapBuffers
  call glfwPollEvents

  mov edi, [window]
  call glfwWindowShouldClose
  test eax, eax
  jz _start_window_loop

  mov edi, [window]
  call glfwDestroyWindow
  call glfwTerminate

  mov rdi, gameExitSuccesfully
  call sys_print
  call sys_exit

_start_glfw_error:
  mov rdi, glfwInitErrorMessage
  call sys_print
  call sys_exit

_start_glfw_window_error:
  call glfwTerminate
  mov rdi, glfwInitWindowErrorMessage
  call sys_print
  call sys_exit

_start_glad_load_error:
  mov rdi, gladLoadError
  call sys_print
  mov edi, [window]
  call glfwDestroyWindow
  call glfwTerminate
  call sys_exit

; -------------------------------------------------------------
; str_len(rdi_str_pointer: string)
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
str_len:
	mov rcx, rdi

str_len_loop:
  cmp byte [rcx], 0
  jz str_len_return
  inc rcx
  jmp str_len_loop

str_len_return:
  mov rax, rcx
  sub rax, rdi
  ret

; -------------------------------------------------------------
; sys_print(rdi: string)
;
; Prints a string to the console
;
; rdi: message to print
; -------------------------------------------------------------
sys_print:
	call str_len

	mov rsi, rdi
	mov rdx, rax
	mov rax, SYSCALL_WRITE
	mov rdi, 1
	syscall	
	ret

; -------------------------------------------------------------
; Terminates the program with status 0
; -------------------------------------------------------------
sys_exit:
	mov rax, SYSCALL_EXIT
  mov rdi, 0
	syscall
	ret