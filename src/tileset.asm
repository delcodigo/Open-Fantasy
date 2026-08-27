global grass_tile_1
global grass_pal
global stonepavedRoad_pal
global grass_tile
global stonepavedRoad_tile

section .rodata
  grass_pal dd 0x00000000, 0xFF10AA49, 0xFF006D38, 0x00000000
  stonepavedRoad_pal dd 0x00000000, 0xFFB2B2B2, 0xFF797979, 0x00000000

  grass_tile_1: ; [0]
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010110, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101

  grass_tile_2: ; [1]
    db 0b01010101, 0b01010110
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01011001, 0b01010101
    db 0b01010101, 0b01010101
    db 0b01010101, 0b01010110
    db 0b01010101, 0b01010101

  stonepavedRoad_tile_1: ; [2]
    db 0b00010000, 0b01000000
    db 0b00010010, 0b01010001
    db 0b00010000, 0b00000010
    db 0b00010010, 0b01000100
    db 0b00010000, 0b00100101
    db 0b00010010, 0b00101001
    db 0b00010010, 0b01000010
    db 0b00010000, 0b00011000
  
  stonepavedRoad_tile_2: ; [3]
    db 0b00100100, 0b00000100
    db 0b01000001, 0b10000100
    db 0b01000100, 0b01000100
    db 0b00100101, 0b00000100
    db 0b10001000, 0b01000100
    db 0b01000001, 0b01000100
    db 0b01000101, 0b10000100
    db 0b00010010, 0b10000100

  grass_tile db 0, 1, 1, 0
  stonepavedRoad_tile db 2, 3, 2, 3

section .note.GNU-stack noalloc noexec nowrite progbits