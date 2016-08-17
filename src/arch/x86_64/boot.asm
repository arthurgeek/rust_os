global start

section .text
bits 32
start:
  ; point the first entry of level 4 page table to the first entry in the
  ; p3 table
  mov eax, p3_table
  or eax, 0b11 ; present + writable
  mov dword [p4_table + 0], eax

  ; point the first entry of level 3 page table to the first entry in the
  ; p2 table
  mov eax, p2_table
  or eax, 0b11 ; present + writable
  mov dword [p3_table + 0], eax

  ; point each page table level 2 entry to a page
  mov ecx, 0 ; counter variable

.map_p2_table:
  mov eax, 0x200000 ; 2MiB
  mul ecx
  or eax, 0b10000011 ; present + writable + huge
  mov [p2_table + ecx * 8], eax

  inc ecx ; increase counter
  cmp ecx, 512 ; if counter is 512, the whole P2 table is mapped
  jne .map_p2_table ; else map the next entry

  mov word [0xb8000], 0x0148 ; H
  mov word [0xb8002], 0x0265 ; e
  mov word [0xb8004], 0x036c ; l
  mov word [0xb8006], 0x046c ; l
  mov word [0xb8008], 0x056f ; o
  mov word [0xb800a], 0x0220 ;  
  mov word [0xb800c], 0x0677 ; w
  mov word [0xb800e], 0x076f ; o
  mov word [0xb8010], 0x0872 ; r
  mov word [0xb8012], 0x096c ; l
  mov word [0xb8014], 0x0e64 ; d
  mov word [0xb8016], 0x0f21 ; !
  hlt

section .bss
align 4096
p4_table: 
  resb 4096
p3_table:
  resb 4096
p2_table:
  resb 4096
