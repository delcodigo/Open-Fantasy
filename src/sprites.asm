global warrior_ow_fd_tl
global warrior_ow_pal_1

section .rodata
  warrior_ow_pal_1 dd 0x00000000, 0xFF000000, 0xFF3010B2, 0xFFBACBFF

  warrior_ow_fd_tl:
    db 0b00000000, 0b00010101
    db 0b00000101, 0b01101010
    db 0b00000001, 0b10101010
    db 0b00000110, 0b10101010
    db 0b00000001, 0b10010111
    db 0b00000001, 0b10110111
    db 0b00000000, 0b01110111
    db 0b00000000, 0b01011111

section .note.GNU-stack noalloc noexec nowrite progbits