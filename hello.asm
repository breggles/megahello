
include "Megaprocessor_defs.asm";

CHAR_MASK           equ 0x07;
DISPLAY_CHAR_WIDTH  equ 0x04;
DISPLAY_CHAR_HEIGHT equ 0x06;
ENC_CHAR_WIDTH      equ 0x03;
CHAR_BYTE_WIDTH     equ 0x10;

        // set up data stack
        ld.w    r0,#EXT_RAM_LEN-1;  // -1 to avoid signed maths confusion
        move    sp,r0;

        ld.w    r2,#hello_str;      // str ptr
        ld.b    r0,#18;             // str len
        jsr     prn_str;
spin:
        nop;
        jmp     spin;

prn_str:
        push    r2;          // str ptr
        push    r0;          // str len
        move    r3,r2;
        ld.b    r1,cur_out_pos;     // x
        ld.b    r2,cur_out_pos+1;   // y
prn_str_loop:
        ld.b    r0,(r3++);
        push    r3;
        ld.b    r3,#0xA;        // line feed
        cmp     r0,r3;
        beq     prn_str_new_row;
        jsr     prn_chr;
        ld.b    r3,#7;
        cmp     r1,r3;          // 8 chars in a row
        beq     prn_str_new_row;
        addq    r1,#1;
        jmp     prn_str_same_row_or_grid;
prn_str_new_row:
        clr     r1;
        ld.b    r3,#9;
        cmp     r2,r3;          // 10 rows in the grid
        beq     prn_str_new_grid;
        addq    r2,#1;
        jmp     prn_str_same_row_or_grid;
prn_str_new_grid:
        clr     r2;
prn_str_same_row_or_grid:
        pop     r3;
        ld.b    r0,(sp+0);
        addq    r0,#-1;
        st.b    (sp+0),r0;
        bne     prn_str_loop;
        st.b    cur_out_pos,r1;
        st.b    cur_out_pos+1,r2;
        pop     r0;
        pop     r2;
        ret;

prn_chr:
        // TODO: what happens if print outside internal RAM?
        push    r2;                     // y
        push    r1;                     // x
        push    r0;                     // char
        ld.b    r3,#'Z';
        cmp     r3,r0;
        bcc     prn_chr_in_range;
        ld.b    r3,#0x20;               // 0x20 = 'a' - 'A', the assumption being it's a lower case char
        sub     r0,r3;
prn_chr_in_range:
        ld.b    r3,#' ';
        sub     r0,r3;
        lsl     r0,#1;                  // char encoding is 2 bytes wide
        ld.w    r3,#c_space;
        add     r3,r0;
        ld.w    r0,(r3);
        push    r0;                     // char encoding
        move    r3,r2;
        lsl     r2,#4;                  // y * 24
        lsl     r3,#3;
        add     r2,r3;
        lsr     r1,#1;                  // x / 2
        add     r2,r1;
        ld.w    r3,#INT_RAM_START;
        add     r2,r3;
        ld.b    r3,#CHAR_BYTE_WIDTH;
        add     r3,r2;                  // char end ptr
prn_chr_loop:
        ld.w    r1,#CHAR_MASK;
        and     r1,r0;
        ld.b    r0,(sp+4);
        btst    r0,#0;
        beq     prn_chr_even;
        lsl     r1,#DISPLAY_CHAR_WIDTH;
        ld.b    r0,(r2);
        or      r1,r0;
prn_chr_even:
        st.b    (r2),r1;
        cmp     r2,r3;
        beq     prn_chr_done;
        ld.b    r1,#INT_RAM_BYTES_ACROSS;
        add     r2,r1;
        ld.w    r0,(sp+0);
        lsr     r0,#ENC_CHAR_WIDTH;
        st.w    (sp+0),r0;
        jmp     prn_chr_loop;
prn_chr_done:
        pop     r0;
        pop     r0;
        pop     r1;
        pop     r2;
        ret;

hello_str:
        dm      "Hello, Mega-World!";

cur_out_pos:
        db      0;          // x
        db      0;          // y

c_space:
        dw      0b0000000000000000;
c_exclamation_mark:
        dw      0b0010000010010010;
c_double_quote:
        dw      0b0000000000101101;
c_hash:
        dw      0b0101111101111101;
c_dollar:
        dw      0b1111111111111111;
c_percent:
        dw      0b1111111111111111;
c_ampersand:
        dw      0b1111111111111111;
c_single_quote:
        dw      0b0000000000010010;
c_open_parenthesis:
        dw      0b0100010010010100;
c_close_parenthesis:
        dw      0b0001010010010001;
c_asterisk:
        dw      0b0101010111010101;
c_plus:
        dw      0b0000010111010000;
c_comma:
        dw      0b0010010000000000;
c_hyphen:
        dw      0b0000000111000000;
c_period:
        dw      0b0010000000000000;
c_slash:
        dw      0b0001001010100100;
c_0:
        dw      0b0111101101101111;
c_1:
        dw      0b0111010010011010;
c_2:
        dw      0b0111001010100011;
c_3:
        dw      0b0011100010100011;
c_4:
        dw      0b0100100111101101;
c_5:
        dw      0b0011100011001111;
c_6:
        dw      0b0010101011001110;
c_7:
        dw      0b0010010010100111;
c_8:
        dw      0b0010101010101010;
c_9:
        dw      0b0011100110101010;
c_colon:
        dw      0b0000010000010000;
c_semicolon:
        dw      0b0001010000010000;
c_less_than:
        dw      0b0100010001010100;
c_equals:
        dw      0b0000111000111000;
c_greater_than:
        dw      0b0001010100010001;
c_question_mark:
        dw      0b0010000010100011;
c_at:
        dw      0b1111111111111111;
c_A:
        dw      0b0101101111101010;
c_B:
        dw      0b0011101011101011;
c_C:
        dw      0b0010101001101010;
c_D:
        dw      0b0011101101101011;
c_E:
        dw      0b0111001111001111;
c_F:
        dw      0b0001001111001111;
c_G:
        dw      0b0110101001001110;
c_H:
        dw      0b0101101111101101;
c_I:
        dw      0b0010010010010010;
c_J:
        dw      0b0010101100100100;
c_K:
        dw      0b0101101011101101;
c_L:
        dw      0b0111001001001001;
c_M:
        dw      0b0101101101111101;
c_N:
        dw      0b0101101101101011;
c_O:
        dw      0b0010101101101010;
c_P:
        dw      0b0001001011101011;
c_Q:
        dw      0b0110111101101010;
c_R:
        dw      0b0101101011101011;
c_S:
        dw      0b0011100010001110;
c_T:
        dw      0b0010010010010111;
c_U:
        dw      0b0111101101101101;
c_V:
        dw      0b0010111101101101;
c_W:
        dw      0b0101111101101101;
c_X:
        dw      0b0101101010101101;
c_Y:
        dw      0b0010010111101101;
c_Z:
        dw      0b0111001010100111;

        // clr internal RAM
        org    INT_RAM_START;

        ds      256, 0;
