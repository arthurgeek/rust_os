global start

section .text
bits 32
start:
  mov esp, stack_top

  call check_multiboot
  call check_cpuid
  call check_long_mode

  ; print Hello World! to the screen
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

check_multiboot:
  cmp eax, 0x36d76289
  jne .no_multiboot
  ret

.no_multiboot:
  mov al, "0"
  jmp error

check_cpuid:
  ; Check if CPUID is supported by attempting to flip the ID bit (bit 21) in
  ; the FLAGS register. If we can flip it, CPUID is available.

  ; Copy FLAGS in to EAX via stack
  pushfd
  pop eax

  ; Copy to ECX as well for comparing later on
  mov ecx, eax

  ; Flip the ID bit
  xor eax, 1 << 21

  ; Copy EAX to FLAGS via the stack
  push eax
  popfd

  ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
  pushfd
  pop eax

  ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
  ; back if it was ever flipped).
  push ecx
  popfd

  ; Compare EAX and ECX. If they are equal then that means the bit wasn't
  ; flipped, and CPUID isn't supported.
  cmp eax, ecx
  je .no_cpuid
  ret

.no_cpuid:
  mov al, "1"
  jmp error

check_long_mode:
  ; test if extended processor info is available
  mov eax, 0x80000000 ; implicit argument for CPUID
  cpuid               ; get highest supported argument
  cmp eax, 0x80000001 ; it needs to be at least 0x80000001
  jb .no_long_mode    ; if it's less, the CPU is too old for long mode

  ; use extended info to test if lomg mode is available
  mov eax, 0x80000001 ; argument for extended processor info
  cpuid               ; returns various feature bits in ecx and edx
  test edx, 1 << 29   ; test if the LM-bit is set in the D-register
  jz .no_long_mode
  ret

.no_long_mode:
  mov al, "2"
  jmp error

set_up_page_tables:
  ; map first P4 entry to P3 table
  mov eax, p3_table
  or eax, 0b11 ; present + writable
  mov [p4_table], eax

  ; map first p3 entry to P2 table
  mov eax, p2_table
  or eax, 0b11 ; present + writable
  mov [p3_table], eax

  ; map each P2 entry to a huge 2MiB page
  mov ecx, 0 ; counter variable

.map_p2_table:
  ; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
  mov eax, 0x200000   ; 2MiB
  mul ecx             ; start address of ecx-th page
  or eax, 0b10000011  ; present + writable + huge
  mov [p2_table + ecx * 8], eax ; map ecx-th entry

  inc ecx             ; increase counter
  cmp ecx, 512        ; if counter is 512, the whole P2 table is mapped
  jne .map_p2_table   ; else map the next entry

  ret

; Prints `ERR: ` and the given error code to screen and hangs.
; parameter: error code (in ascii) in al
error:
  mov word [0xb8000], 0x4f45 ; E
  mov word [0xb8002], 0x4f52 ; R
  mov word [0xb8004], 0x4f52 ; R
  mov word [0xb8006], 0x4f3a ; :
  mov word [0xb8008], 0x4f20 ;  
  mov word [0xb800a], 0x4f20 ;  
  mov byte [0xb800a], al
  hlt

section .bss
align 4096
p4_table:
  resb 4096
p3_table:
  resb 4096
p2_table:
  resb 4096
stack_bottom:
  resb 64
stack_top:
