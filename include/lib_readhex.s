##ifndef _LIB_READHEX_S

##define _LIB_READHEX_S

# --------------------------------------------------------------
# skip_space
#
# Entry:
# - r1 is the address of the string
#
# Exit:
# - r1 is updated to skip and spaces
# - r2 is non-space character
# - all other registers preserved

skip_spaces:
    DEC     (r1, 1)
skip_spaces_loop:
    INC     (r1, 1)
    ld      r2, r1
    cmp     r2, r0, 0x20
    z.mov   pc, r0, skip_spaces_loop
    RTS     ()

# --------------------------------------------------------------
#
# read_hex
#
# Read a multi-digit hex value, terminated by a non hex character
#
# Entry:
# - r1 is the address of the hex string
#
# Exit:
# - r1 is updated after processing the string
# - r2 contains the hex value
#
# - all registers preserved

read_hex:
    PUSH    (r13)
    JSR     (skip_spaces)
    mov     r2, r0          # r2 is will contain the hex value

read_hex_loop:
    JSR     (read_hex_1)
    nc.mov  pc, r0, read_hex_loop
    POP     (r13)
    RTS     ()

# --------------------------------------------------------------
#
# read_hex_2
#
# Read a 2-digit hex value
#
# Entry:
# - r1 is the address of the hex string
#
# Exit:
# - r1 is updated after processing the string
# - r2 contains the hex value
# - carry set if there was an error
# - all registers preserved

read_hex_2:
    PUSH    (r13)
    mov     r2, r0          # r2 is will contain the hex value
    JSR     (read_hex_1)
    JSR     (read_hex_1)
    POP     (r13)
    RTS     ()

# --------------------------------------------------------------
#
# read_hex_4
#
# Read a 4-digit hex value
#
# Entry:
# - r1 is the address of the hex string
#
# Exit:
# - r1 is updated after processing the string
# - r2 contains the hex value
# - carry set if there was an error
# - all registers preserved

read_hex_4:
    PUSH    (r13)
    mov     r2, r0          # r2 is will contain the hex value
    JSR     (read_hex_1)
    JSR     (read_hex_1)
    JSR     (read_hex_1)
    JSR     (read_hex_1)
    POP     (r13)
    RTS     ()

# --------------------------------------------------------------
#
# read_hex_1
#
# Read a 1-digit hex value
#
# Entry:
# - r1 is the address of the hex string
#
# Exit:
# - r1 is updated after processing the string
# - r2 contains the hex value
# - carry set if there was an error
# - all registers preserved
        
read_hex_1:
    PUSH    (r3)
    ld      r3, r1
    cmp     r3, r0, 0x30
    nc.mov  pc, r0, read_hex_1_invalid
    cmp     r3, r0, 0x3A
    nc.mov  pc, r0, read_hex_1_valid
    and     r3, r0, 0xdf
    sub     r3, r0, 0x07
    nc.mov  pc, r0, read_hex_1_invalid
    cmp     r3, r0, 0x40
    c.mov   pc, r0, read_hex_1_invalid

read_hex_1_valid:
    add     r2, r2
    add     r2, r2
    add     r2, r2
    add     r2, r2

    and     r3, r0, 0x0F
    add     r2, r3

    INC     (r1,1)
    CLC     ()
    mov     pc, r0, read_hex_1_exit

read_hex_1_invalid:
    SEC     ()

read_hex_1_exit:
    POP     (r3)
    RTS     ()

##endif
