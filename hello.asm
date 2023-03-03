
include "Megaprocessor_defs.asm";

CHAR_MASK           equ 0x07;
DISPLAY_CHAR_WIDTH  equ 0x04;
DISPLAY_CHAR_HEIGHT equ 0x06;
ENC_CHAR_WIDTH      equ 0x03;
CHAR_BYTE_WIDTH     equ 0x10;

        // set up data stack
        ld.w    r0,#EXT_RAM_LEN-1;  // -1 to avoid signed maths confusion
        move    sp,r0;

        ld.w    r2,#hello_msg;  // str ptr
        ld.b    r0,#18;             // str len
        jsr     _prn_str;

_halt:
        nop;
        jmp     _halt;

_prn_chr:
        // TODO: what happens if print outside internal RAM?
        push    r2;                     // y
        push    r1;                     // x
        push    r0;                     // char
        ld.b    r3,#'Z';
        cmp     r3,r0;
        bcc     _prn_chr_in_range;
        ld.b    r3,#0x20;               // 0x20 = 'a' - 'A', the assumption being it's a lower case char
        sub     r0,r3;
_prn_chr_in_range:
        ld.b    r3,#' ';
        sub     r0,r3;
        lsl     r0,#1;                  // char encoding is 2 bytes wide
        ld.w    r3,#_c_space;
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
_prn_chr_loop:
        ld.w    r1,#CHAR_MASK;
        and     r1,r0;
        ld.b    r0,(sp+4);
        btst    r0,#0;
        beq     _prn_chr_even;
        lsl     r1,#DISPLAY_CHAR_WIDTH;
        ld.b    r0,(r2);
        or      r1,r0;
_prn_chr_even:
        st.b    (r2),r1;
        cmp     r2,r3;
        beq     _prn_chr_done;
        ld.b    r1,#INT_RAM_BYTES_ACROSS;
        add     r2,r1;
        ld.w    r0,(sp+0);
        lsr     r0,#ENC_CHAR_WIDTH;
        st.w    (sp+0),r0;
        jmp     _prn_chr_loop;
_prn_chr_done:
        pop     r0;
        pop     r0;
        pop     r1;
        pop     r2;
        ret;

_prn_str:
        push    r1;
        push    r3;
        push    r2;          // str ptr
        push    r0;          // str len
        move    r3,r2;
        ld.b    r1,cur_out_pos;     // x
        ld.b    r2,cur_out_pos+1;   // y
_prn_str_loop:
        ld.b    r0,(r3++);
        push    r3;
        ld.b    r3,#0xA;        // line feed
        cmp     r0,r3;
        beq     _prn_str_new_row;
        jsr     _prn_chr;
        ld.b    r3,#7;
        cmp     r1,r3;          // 8 chars in a row
        beq     _prn_str_new_row;
        addq    r1,#1;
        jmp     _prn_str_same_row_or_grid;
_prn_str_new_row:
        clr     r1;
        ld.b    r3,#9;
        cmp     r2,r3;          // 10 rows in the grid
        beq     _prn_str_new_grid;
        addq    r2,#1;
        jmp     _prn_str_same_row_or_grid;
_prn_str_new_grid:
        clr     r2;
_prn_str_same_row_or_grid:
        pop     r3;
        ld.b    r0,(sp+0);
        addq    r0,#-1;
        st.b    (sp+0),r0;
        bne     _prn_str_loop;
        st.b    cur_out_pos,r1;
        st.b    cur_out_pos+1,r2;
        pop     r0;
        pop     r2;
        pop     r3;
        pop     r1;
        ret;

hello_msg:
        dm      "Hello, Mega-World!";

cur_out_pos:
        db      0;          // x
        db      0;          // y

_c_space:
        dw      0b0000000000000000;
_c_exclamation_mark:
        dw      0b0010000010010010;
_c_double_quote:
        dw      0b0000000000101101;
_c_hash:
        dw      0b0101111101111101;
_c_dollar:
        dw      0b1111111111111111;
_c_percent:
        dw      0b1111111111111111;
_c_ampersand:
        dw      0b1111111111111111;
_c_single_quote:
        dw      0b0000000000010010;
_c_open_parenthesis:
        dw      0b0100010010010100;
_c_close_parenthesis:
        dw      0b0001010010010001;
_c_asterisk:
        dw      0b0101010111010101;
_c_plus:
        dw      0b0000010111010000;
_c_comma:
        dw      0b0010010000000000;
_c_hyphen:
        dw      0b0000000111000000;
_c_period:
        dw      0b0010000000000000;
_c_slash:
        dw      0b0001001010100100;
_c_0:
        dw      0b0111101101101111;
_c_1:
        dw      0b0111010010011010;
_c_2:
        dw      0b0111001010100011;
_c_3:
        dw      0b0011100010100011;
_c_4:
        dw      0b0100100111101101;
_c_5:
        dw      0b0011100011001111;
_c_6:
        dw      0b0010101011001110;
_c_7:
        dw      0b0010010010100111;
_c_8:
        dw      0b0010101010101010;
_c_9:
        dw      0b0011100110101010;
_c_colon:
        dw      0b0000010000010000;
_c_semicolon:
        dw      0b0001010000010000;
_c_less_than:
        dw      0b0100010001010100;
_c_equals:
        dw      0b0000111000111000;
_c_greater_than:
        dw      0b0001010100010001;
_c_question_mark:
        dw      0b0010000010100011;
_c_at:
        dw      0b1111111111111111;
_c_A:
        dw      0b0101101111101010;
_c_B:
        dw      0b0011101011101011;
_c_C:
        dw      0b0010101001101010;
_c_D:
        dw      0b0011101101101011;
_c_E:
        dw      0b0111001111001111;
_c_F:
        dw      0b0001001111001111;
_c_G:
        dw      0b0110101001001110;
_c_H:
        dw      0b0101101111101101;
_c_I:
        dw      0b0010010010010010;
_c_J:
        dw      0b0010101100100100;
_c_K:
        dw      0b0101101011101101;
_c_L:
        dw      0b0111001001001001;
_c_M:
        dw      0b0101101101111101;
_c_N:
        dw      0b0101101101101011;
_c_O:
        dw      0b0010101101101010;
_c_P:
        dw      0b0001001011101011;
_c_Q:
        dw      0b0110111101101010;
_c_R:
        dw      0b0101101011101011;
_c_S:
        dw      0b0011100010001110;
_c_T:
        dw      0b0010010010010111;
_c_U:
        dw      0b0111101101101101;
_c_V:
        dw      0b0010111101101101;
_c_W:
        dw      0b0101111101101101;
_c_X:
        dw      0b0101101010101101;
_c_Y:
        dw      0b0010010111101101;
_c_Z:
        dw      0b0111001010100111;

        // clr internal RAM
        org    INT_RAM_START;

        ds      256, 0;
