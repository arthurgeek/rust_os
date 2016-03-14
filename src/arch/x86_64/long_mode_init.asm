global long_mode_start
bits 64

long_mode_start:
  ; call the rust main
  extern rust_main
  call rust_main

.os_returned:
  ; rust main returned, print `OS returned!`
  mov rax, 0x4f724f204f534f4f ; OS r
  mov [0xb8000], rax
  mov rax, 0x4f724f754f744f65 ; etur
  mov [0xb8008], rax
  mov rax, 0x4f214f644f654f6e ; ned!
  mov [0xb8010], rax

  hlt
