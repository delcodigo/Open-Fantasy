global warrior_ow_fd
global warrior_ow_pal

section .rodata
  warrior_ow_pal_1 dd 0x00000000, 0xFF000000, 0xFF3010B2, 0xFFBACBFF
  warrior_ow_pal_2 dd 0x00000000, 0xFF000000, 0xFFB2B2B2, 0xFF3010B2

  warrior_ow_fd_tl:
    db 0b00000000, 0b00010101
    db 0b00000101, 0b01101010
    db 0b00000001, 0b10101010
    db 0b00000110, 0b10101010
    db 0b00000001, 0b10010111
    db 0b00000001, 0b10110111
    db 0b00000000, 0b01110111
    db 0b00000000, 0b01011111

  warrior_ow_fd_tr:
    db 0b01010100, 0b00000000
    db 0b10101001, 0b00000000
    db 0b10101001, 0b00000000
    db 0b11101010, 0b01000000
    db 0b11010110, 0b01000000
    db 0b11011101, 0b00000000
    db 0b11011101, 0b00000000
    db 0b11110101, 0b00000000
  
  warrior_ow_fd_1_bl:
    db 0b00000001, 0b10100101
    db 0b00000111, 0b11011110
    db 0b00000101, 0b01011010
    db 0b00000110, 0b01100111
    db 0b00000001, 0b01100111
    db 0b00000001, 0b10101001
    db 0b00000000, 0b01010100
    db 0b00000000, 0b00000000

  warrior_ow_fd_1_br:
    db 0b01011010, 0b01000000
    db 0b10110101, 0b01010100
    db 0b10100110, 0b11100100
    db 0b11010111, 0b11110100
    db 0b11010110, 0b11100100
    db 0b01101001, 0b01010000
    db 0b00010101, 0b01010100
    db 0b00000000, 0b00000000

  warrior_ow_fd_2_bl:
    db 0b00000000, 0b01100101
    db 0b00000001, 0b11011110
    db 0b00000001, 0b10011010
    db 0b00000001, 0b10010111
    db 0b00000000, 0b01100111
    db 0b00000000, 0b01100111
    db 0b00000000, 0b01101001
    db 0b00000000, 0b00010101

  warrior_ow_fd_2_br:
    db 0b01011010, 0b01000000
    db 0b01010101, 0b01000000
    db 0b01101110, 0b01000000
    db 0b01111111, 0b01000000
    db 0b01101110, 0b01000000
    db 0b10010101, 0b01000000
    db 0b01010101, 0b01010000
    db 0b00000000, 0b00000000
  
  warrior_ow_fd_3_bl:
    db 0b00000001, 0b10100101
    db 0b00000001, 0b11010110
    db 0b00000001, 0b01101001
    db 0b00000000, 0b01101001
    db 0b00000000, 0b01010111
    db 0b00000000, 0b01101001
    db 0b00000000, 0b00010101
    db 0b00000000, 0b00000001

  warrior_ow_fd_3_br:
    db 0b01011001, 0b01010100
    db 0b10110110, 0b01100100
    db 0b10100110, 0b01110100
    db 0b11010101, 0b01100100
    db 0b11010110, 0b01010000
    db 0b11011001, 0b01010000
    db 0b01101001, 0b01010100
    db 0b01010100, 0b00000000

  warrior_ow_fd_1:
    dq warrior_ow_fd_tl, warrior_ow_fd_tr
    dq warrior_ow_fd_1_bl, warrior_ow_fd_1_br

  warrior_ow_fd_2:
    dq warrior_ow_fd_tl, warrior_ow_fd_tr
    dq warrior_ow_fd_2_bl, warrior_ow_fd_2_br

  warrior_ow_fd_3:
    dq warrior_ow_fd_tl, warrior_ow_fd_tr
    dq warrior_ow_fd_3_bl, warrior_ow_fd_3_br
  
  warrior_ow_fd:
    dq warrior_ow_fd_1, warrior_ow_fd_2
    dq warrior_ow_fd_1, warrior_ow_fd_3

  warrior_ow_pal:
    dq warrior_ow_pal_1, warrior_ow_pal_1
    dq warrior_ow_pal_2, warrior_ow_pal_2

section .note.GNU-stack noalloc noexec nowrite progbits