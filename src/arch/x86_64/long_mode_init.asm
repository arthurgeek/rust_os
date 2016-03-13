global long_mode_start
bits 64

long_mode_start:
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
