interface Func {
  void run();
}

class MEMORY {
  static final int BOOT = 0x0000;
  static final int STAK = 0x0100;
  static final int CODE = 0x0200;
  static final int DATA = 0x0400;
  static final int IRQB = 0x07FE;
  static final int RESB = 0x07FC;
  static final int NIMB = 0x07FA;
  static final int GPU  = 0x9000;
}

class PROCESSOR {
  static final char RST  = 0x00;
  static final char FTCH = 0x01;
  static final char NMI  = 0x02;
}

class INSTRUCTION {
  static final char LDA = 0xa9;
  static final char LDX = 0xa2;
  static final char LDY = 0xa0;

  static final char TXA = 0x8a;
  static final char TYA = 0x98;

  static final char TAX = 0xaa;
  static final char TAY = 0xa8;

  static final char STA = 0x8d;
  static final char STAX = 0x9d;
  static final char STX = 0x8e;
  static final char STY = 0x8c;

  static final char ADC = 0x69;

  static final char CMP = 0xc9;

  static final char BEQ = 0xf0;
  static final char BNE = 0xd0;
  static final char JMP = 0x4c;

  static final char PHA = 0x48;

  static final char PLA = 0x68;

  static final char RTI = 0x40;
  
  static final char CLC = 0x18;
}

class STATUS {
  static final char CARY = 0b00000001;
  static final char ZERO = 0b00000010;
  static final char IRQB = 0b00000100;
  static final char DEC  = 0b00001000;
  static final char BRK  = 0b00010000;
  static final char NMIB = 0b00100000;
  static final char OVER = 0b01000000;
  static final char NEG  = 0b10000000;
}

class CPU_t {
  int pc;
  int sp;
  char ps;
  char a;
  char x;
  char y;

  int alu;
  int state;
  Func func;
  Func control_func;
  Func opcode_func;
  
  CPU_t() {
    control_func = () -> {
      switch (state) {
        case (PROCESSOR.RST << 4):
          sp = MEMORY.STAK + 0x100;
          ps = STATUS.NMIB | STATUS.BRK | STATUS.IRQB;
          BUS.nmi = 1;
          BUS.reset = 1;
          BUS.rw = 1;
          BUS.addr = MEMORY.RESB;
          state++;
          break;
          
        case (PROCESSOR.RST << 4) + 1:
          alu = BUS.data;
          BUS.addr = MEMORY.RESB + 1;
          state++;
          break;
          
        case (PROCESSOR.RST << 4) + 2:
          alu = alu + (BUS.data << 8) + 0;
          pc = alu;
          BUS.addr = pc;
          state = PROCESSOR.FTCH << 4;
          break;

        case (PROCESSOR.FTCH << 4): // FECTH OPCODE
          if (BUS.nmi < 0.5f && (ps & STATUS.NMIB) > 0) {
            ps &= ~STATUS.NMIB;
            state = PROCESSOR.NMI << 4;
          } else {
            if (BUS.rw == 1) {
              pc++;
              state = BUS.data << 4;
              func = opcode_func;
            }
            BUS.rw = 1;
            BUS.addr = pc;
          }
          break;

        case (PROCESSOR.NMI << 4): // PUSH hi(PC) IN STACK
          sp--;
          BUS.rw = 0;
          BUS.addr = sp;
          BUS.data = (char) ((pc & 0xFF00) >> 8); 
          state++;
          break;
        case (PROCESSOR.NMI << 4) + 1: // PUSH lo(PC) IN STACK
          sp--;
          BUS.rw = 0;
          BUS.addr = sp;
          BUS.data = (char) (pc & 0x00FF); 
          state++;
          break;
        case (PROCESSOR.NMI << 4) + 2: // GET NMI ADDRESS #1
          BUS.rw = 1;
          BUS.addr = MEMORY.NIMB;
          state++;
          break;
        case (PROCESSOR.NMI << 4) + 3: // GET NMI ADDRESS #2
          alu = BUS.data;
          BUS.rw = 1;
          BUS.addr = MEMORY.NIMB + 1;
          state++;
          break;
        case (PROCESSOR.NMI << 4) + 4: // JMP NMI ADDRESS
          alu = alu + (BUS.data << 8) + 0;
          pc = alu;
          BUS.rw = 1;
          BUS.addr = pc;
          state = PROCESSOR.FTCH << 4;
          break;
      }
    };

    opcode_func = () -> {
      switch (state) {
        case (INSTRUCTION.LDA << 4): // LOAD DATA IN ACC
          a = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.LDX << 4): // LOAD DATA IN X
          x = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.LDY << 4): // LOAD DATA IN Y
          y = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.TXA << 4): // TRANSFER X TO ACC
          a = x;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.TYA << 4): // TRANSFER Y TO ACC
          a = y;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.TAX << 4): // TRANSFER ACC TO X
          x = a;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.TAY << 4): // TRANSFER ACC TO Y
          y = a;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.ADC << 4): // ADD DATA TO ACC
          alu = ps & STATUS.CARY;
          alu = alu + a + BUS.data;
          ps = (char) (((alu & 0xFF) == 0) ? (ps | STATUS.ZERO) : (ps & ~STATUS.ZERO));
          ps = (char) ((alu > 255) ? (ps | STATUS.CARY) : (ps & ~STATUS.CARY));
          ps = (char) ((alu < 0) ? (ps | STATUS.NEG) : (ps & ~STATUS.NEG));
          a = (char) alu;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.CMP << 4):  // CMP DATA TO ACC
          alu = 0;
          alu = alu + a - BUS.data;
          ps = (char) (((alu & 0xFF) == 0) ? (ps | STATUS.ZERO) : (ps & ~STATUS.ZERO));
          ps = (char) ((alu > 255) ? (ps | STATUS.CARY) : (ps & ~STATUS.CARY));
          ps = (char) ((alu < 0) ? (ps | STATUS.NEG) : (ps & ~STATUS.NEG));
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.STA << 4): // MOVE ACC TO MEM #1
          alu = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state++;
          break;
        case (INSTRUCTION.STA << 4) + 1: // MOVE ACC TO MEM #2
          alu = alu + (BUS.data << 8) + 0;
          pc++;
          BUS.rw = 0;
          BUS.addr = alu;
          BUS.data = a;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;
          
        case (INSTRUCTION.STAX << 4): // MOVE ACC TO MEM #1
          alu = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state++;
          break;
        case (INSTRUCTION.STAX << 4) + 1: // MOVE ACC TO MEM #2
          alu = alu + (BUS.data << 8) + x;
          pc++;
          BUS.rw = 0;
          BUS.addr = alu;
          BUS.data = a;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.STX << 4): // MOVE X TO MEM #1
          alu = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state++;
          break;
        case (INSTRUCTION.STX << 4) + 1: // MOVE X TO MEM #2
          alu = alu + (BUS.data << 8);
          pc++;
          BUS.rw = 0;
          BUS.addr = alu;
          BUS.data = x;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.STY << 4): // MOVE Y TO MEM #1
          alu = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state++;
          break;
        case (INSTRUCTION.STY << 4) + 1: // MOVE Y TO MEM #2
          alu = alu + (BUS.data << 8);
          pc++;
          BUS.rw = 0;
          BUS.addr = alu;
          BUS.data = y;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
        break;

        case (INSTRUCTION.BEQ << 4): // BNE TO MEM #1
          alu = (byte) BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          if ((ps & STATUS.ZERO) > 0) {
            state = (INSTRUCTION.BEQ << 4) + 1;
          } else {
            state = PROCESSOR.FTCH << 4;
            func = control_func;
          }
          break;
        case (INSTRUCTION.BEQ << 4) + 1: // IF NOT EQ 0
          alu = alu + pc + 0;
          pc = alu;
          BUS.rw = 1;
          BUS.addr = pc;
          state = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.BNE << 4): // BNE TO MEM #1
          alu = (byte) BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          if ((ps & STATUS.ZERO) == 0) {
            state = (INSTRUCTION.BNE << 4) + 1;
          } else {
            state = PROCESSOR.FTCH << 4;
            func = control_func;
          }
          break;
        case (INSTRUCTION.BNE << 4) + 1: // IF NOT EQ 0
          alu = alu + pc + 0;
          pc = alu;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.JMP << 4): // JMP TO MEM #1
          alu = BUS.data;
          pc++;
          BUS.rw = 1;
          BUS.addr = pc;
          state++;
          break;
        case (INSTRUCTION.JMP << 4) + 1:  // JMP TO MEM #2
          alu = alu + (BUS.data << 8) + 0;
          pc = alu;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.PHA << 4): // PUSH ACC IN STACK
          sp--;
          BUS.rw = 0;
          BUS.addr = sp;
          BUS.data = a;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.PLA << 4): // POP STACK ACC #1
          BUS.rw = 1;
          BUS.addr = sp;
          state++;
          break;
        case (INSTRUCTION.PLA << 4) + 1: // POP STACK ACC #2
          a = BUS.data;
          sp++;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;

        case (INSTRUCTION.RTI << 4): // POP STACK hi(PC) #1
          BUS.rw = 1;
          BUS.addr = sp;
          state++;
          break;
        case (INSTRUCTION.RTI << 4) + 1: // POP lo(PC) ACC #2
          alu = BUS.data;
          sp++;
          BUS.rw = 1;
          BUS.addr = sp;
          state++;
          break;
        case (INSTRUCTION.RTI << 4) + 2: // JMP TO RET ADDRESS
          alu = alu + (BUS.data << 8) + 0;
          pc = alu;
          ps |= STATUS.NMIB;
          sp++;
          BUS.nmi = 1;
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;
          
        case (INSTRUCTION.CLC << 4): // CLEAR CARY
          ps &= ~STATUS.CARY; 
          BUS.rw = 1;
          BUS.addr = pc;
          state  = PROCESSOR.FTCH << 4;
          func = control_func;
          break;
      }
    };
    
    state = PROCESSOR.RST << 4;
    func = control_func;
  }

  void clock() {
    if (BUS.reset < 0.5f) {
      state = PROCESSOR.RST << 4;
      func = control_func;
    }
    func.run();
  }

  void debug() {
    println((state >> 4), "#" + hex(pc, 4), (int) a, (int) x, (int) y, "#" + hex(alu, 4));
  }
}
CPU_t CPU = new CPU_t();
