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
extern glCreateShader
extern glShaderSource
extern glCompileShader
extern glGetShaderiv
extern glCreateProgram
extern glAttachShader
extern glLinkProgram
extern glGetProgramiv
extern glDeleteShader
extern glUseProgram
extern glGenVertexArrays
extern glGenBuffers
extern glBindVertexArray
extern glBindBuffer
extern glBufferData
extern glVertexAttribPointer
extern glEnableVertexAttribArray
extern glDrawArrays

section .rodata
  gameExitSuccesfully db "The fantasy is over.", 10, 0
  glfwInitErrorMessage db "Failed to initialize GLFW", 10, 0
  glfwInitWindowErrorMessage db "Failed to create window", 10, 0
  gladLoadError db "Failed to load OpenGL functions", 10, 0
  shaderCompileFailedMsg db "Failed to compile the shader", 10, 0
  shaderLinkFailedMsg db "Program linking failed", 10, 0
  windowTitle db "Open Fantasy", 0

  shaderVertexSource db `#version 120\nvoid main() {\n  gl_Position = gl_Vertex;\n}\n`, 0
  shaderFragmentSource db `#version 120\nvoid main() {\n  gl_FragColor = vec4(1.0);\n}\n`, 0

  clearColor0_1 dd 0.1
  clearColor1_0 dd 1.0

  screenVertices:
    dd -1.0, -1.0, 0.0
    dd  1.0, -1.0, 0.0
    dd -1.0,  1.0, 0.0
    dd  1.0, -1.0, 0.0
    dd  1.0,  1.0, 0.0
    dd -1.0,  1.0, 0.0

section .data
  window dq 0
  shaderVertexSourcePtr dq shaderVertexSource
  shaderFragmentSourcePtr dq shaderFragmentSource
  shaderProgram dd 0

section .bss
  shaderCompileSucess resd 1
  screenVAO resd 1
  screenVBO resd 1

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
  lea rdx, [rel windowTitle]
  mov rcx, 0
  mov r8, 0
  call glfwCreateWindow
  test rax, rax
  jz _start_glfw_window_error
  mov [rel window], rax

  mov rdi, [rel window]
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

  call shaderCreateProgram
  mov edi, eax
  call glUseProgram

  call geometryCreateScreen

_start_window_loop:
  mov rdi, 0x4100
  call glClear

  call screenRender

  mov rdi, [rel window]
  call glfwSwapBuffers
  call glfwPollEvents

  mov rdi, [rel window]
  call glfwWindowShouldClose
  test eax, eax
  jz _start_window_loop

  mov rdi, [rel window]
  call glfwDestroyWindow
  call glfwTerminate

  lea rdi, [rel gameExitSuccesfully]
  call sys_print
  call sys_exit

_start_glfw_error:
  lea rdi, [rel glfwInitErrorMessage]
  call sys_print
  call sys_exit

_start_glfw_window_error:
  call glfwTerminate
  lea rdi, [rel glfwInitWindowErrorMessage]
  call sys_print
  call sys_exit

_start_glad_load_error:
  lea rdi, [rel gladLoadError]
  call sys_print
  mov rdi, [rel window]
  call glfwDestroyWindow
  call glfwTerminate
  call sys_exit

; -------------------------------------------------------------
; screenRender()
;
; Renders two triangles from the screenVAO into OpenGL
;
; -------------------------------------------------------------
screenRender:
  sub rsp, 8

  mov edi, [rel screenVAO]
  call glBindVertexArray

  mov rdi, 0x0004
  xor rsi, rsi
  mov rdx, 6
  call glDrawArrays

  add rsp, 8
  ret

; -------------------------------------------------------------
; shaderCompile(rdi_uint_type: unsigned int, rsi_source: const char *source)
;
; Compiles a fragment or vertex shader and checks if it fails
; it doesn't check the shader logs because the shader is simple enough
; and this is not meant for a general purpose shader function
;
; rdi: type of shader
; rsi: pointer to the shader source code
;
; returns:
;	rax = uint for created shader
;
; -------------------------------------------------------------
shaderCompile:
  push r12
  push r13
  sub rsp, 8

  mov r13, rsi

  call glCreateShader
  mov r12d, eax

  mov edi, r12d
  mov esi, 1
  mov rdx, r13
  xor ecx, ecx
  call glShaderSource

  mov edi, r12d
  call glCompileShader

  mov edi, r12d
  mov esi, 0x8B81
  lea rdx, [rel shaderCompileSucess]  
  call glGetShaderiv
  mov eax, [rel shaderCompileSucess]
  test eax, eax
  jz shaderCompileFailed

  mov eax, r12d

  add rsp, 8
  pop r13
  pop r12
  ret

shaderCompileFailed:
  lea rdi, [rel shaderCompileFailedMsg]
  call sys_print
  mov rdi, [rel window]
  call glfwDestroyWindow
  call glfwTerminate
  call sys_exit

; -------------------------------------------------------------
; shaderCreateProgram()
;
; Compiles both vertex and fragment shaders and link them
; together into the shader program
;
; returns:
;	eax = uint for the shader program
;
; -------------------------------------------------------------
shaderCreateProgram:
  push r12
  push r13
  sub rsp, 8

  mov edi, 0x8B31
  lea rsi, [rel shaderVertexSourcePtr]
  call shaderCompile
  mov r12d, eax

  mov edi, 0x8B30
  lea rsi, [rel shaderFragmentSourcePtr]
  call shaderCompile
  mov r13d, eax

  call glCreateProgram
  mov [rel shaderProgram], eax

  mov edi, [rel shaderProgram]
  mov esi, r12d
  call glAttachShader

  mov edi, [rel shaderProgram]
  mov esi, r13d
  call glAttachShader

  mov edi, [rel shaderProgram]
  call glLinkProgram

  mov edi, [rel shaderProgram]
  mov esi, 0x8B82
  lea rdx, [rel shaderCompileSucess]  
  call glGetProgramiv
  mov eax, [rel shaderCompileSucess]
  test eax, eax
  jz shaderCreateProgramError

  mov edi, r12d
  call glDeleteShader

  mov edi, r13d
  call glDeleteShader

  mov eax, [rel shaderProgram]
  add rsp, 8
  pop r13
  pop r12
  ret

shaderCreateProgramError:
  lea rdi, [rel shaderLinkFailedMsg]
  call sys_print
  mov rdi, [rel window]
  call glfwDestroyWindow
  call glfwTerminate
  call sys_exit

; -------------------------------------------------------------
; geometryCreateScreen()
;
; Uploads the two triangle array as an openGL VAO, VBO for the
; only screen geometry in the game
;
; -------------------------------------------------------------
geometryCreateScreen:
  sub rsp, 8

  mov rdi, 1
  lea rsi, [rel screenVAO]
  call glGenVertexArrays

  mov rdi, 1
  lea rsi, [rel screenVBO]
  call glGenBuffers

  mov edi, [rel screenVAO]
  call glBindVertexArray

  mov rdi, 0x8892
  mov esi, [rel screenVBO]
  call glBindBuffer

  mov rdi, 0x8892
  mov rsi, 72
  lea rdx, [rel screenVertices]
  mov rcx, 0x88E4
  call glBufferData

  xor rdi, rdi
  mov rsi, 3
  mov rdx, 0x1406
  xor rcx, rcx
  mov r8, 12
  xor r9, r9
  call glVertexAttribPointer

  xor rdi, rdi
  call glEnableVertexAttribArray

  mov rdi, 0x8892
  xor rsi, rsi
  call glBindBuffer

  xor rdi, rdi
  call glBindVertexArray

  add rsp, 8
  ret

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