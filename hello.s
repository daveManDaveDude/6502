PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff         ;load ff into x reg so we can set the stack pointer
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001  ; CLear Display
  jsr lcd_instruction

loop:
  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print

message: .asciiz "X# "

lcd_wait:
  pha
  lda #%00000000  ; Port B to input
  sta DDRB        ; Set data direction registar
lcdbusy:
  lda #RW         ; Set the Read Write flag
  sta PORTA       ; send to port a or VIA that has last 3 bits connected to flag bits of display
  lda #(RW | E)   ; set read write and enable bits (toggel the bit to make display do smowthnig!)
  sta PORTA       ; send enable bit to port A to execute the last flag change
  lda PORTB       ; read the busy flag
  and #%10000000  ; set all apart from first bit busy flag to zero
  bne lcdbusy    ; bne jumps when the zero flag is set, and the zero flag is 0
                  ; when busy flag not set zero flag set so loops back to lcd_wait

  lda #RW         ; Set the Read Write flag switching off the enable
  sta PORTA       ; send to port a or VIA that has last 3 bits connected to flag bits of display
  lda #%11111111  ; Port B to input
  sta DDRB        ; Set data direction registar
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts



  .org $fffc
  .word reset
  .word $0000
