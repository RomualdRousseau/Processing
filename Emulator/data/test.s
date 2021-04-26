  .org $0000
  
  .org $0200
setup:
  lda #50
  sta $0900
  lda #50
  sta $0901

  lda #0
i:
  pha
  lda #42
  sta $0903
  pla
  clc
  adc #1
  cmp #3
  bne i
  
  ldx #0
  lda #0
  sta $06FF
  
loop:
  clc
  adc #10
  sta $0400,x
  pha
  txa
  clc
  adc #1
  cmp #255
  bne continue
  lda #0
continue:
  tax
  pla
  jmp loop

  .org $0700
nmi:
  pha
  txa
  pha
  ldx #0
  lda #255
  sta $06FF
  pla
  tax
  pla
  rti

  .org $07FA
  .word $0700
  .word $0200 
  .word $0000
     
