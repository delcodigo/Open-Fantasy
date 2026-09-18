global dialogue_town_test_npc1
global dialogue_town_test_npc2

section .rodata
  dialogue_town_test_npc1: 
    db 2
    db "Can you believe the prices in these", 10, "inns?", 0
    db "Things were better in Tull.", 0

  dialogue_town_test_npc2: 
    db 3
    db "Another day in this beautiful test town.", 10, "I wouldn't change it or move somwhere", 10, "else no matter the money I got offered.", 0
    db "Sometimes life is about appreciating the", 10, "The small things in life, you know?", 0
    db "Anyway, what can I do for you?"

section .note.GNU-stack noalloc noexec nowrite progbits