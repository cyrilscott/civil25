        CPU 8086
        BITS 16

        SECTION .text

start:
        mov ax, 0x7000 ;loads where stack will be; has to be 64k
        mov ss, ax
        xor sp, sp ;sets stack pointer to 0

        mov ds, sp
        mov es, sp

        mov al, 0x80 ;move 10000000 into AL
        out 03h, al ;Move AL into 82c55 control register; setting I/O chip to mode 0, all ports are output
        mov al, 0x00 ;Sets control register of lcd to 0; just to be safe
        out 01h, al

        mov al, 00111000b ;Set 8 bit mode, 2-line display, 5x8 font
        call writeControl

        mov al, 00001111b ;Display on, cursor on, blink on
        call writeControl

        mov al, 00000110b ;Increment and shift cursor; don't shift display
        call writeControl ;Write to control register of LCD

        mov al, 00000010b ;Go to home
        call writeControl

init_irq_vectors:
	mov di, 8 * 4
	mov ax, irq_handler
	stosw
	mov ax, cs
	stosw

	mov ax, 0xc000 ;sets data segment to C000 - Will change
        mov ds, ax

init_pic:
	mov al, 00010111b      ; ICW1
        out 0x20, al
        mov al, (0x08 & 11111000b)  ; ICW2
        out 0x21, al
        mov al, 00000001b      ; ICW4
        out 0x21, al

        mov al, 01111110b      ; mask all interrupts
        out 0x21, al

        mov al, 00001000b
        out 0x20, al

writeLCDString:
        mov cx, message_end - message ;loads CX with # of characters
        mov si, message ;loads pointer into appropriate register
writeLoop:
        lodsb ;wierd instruction; loads AL with data from DS:SI with offset
        call writeLetter ;writes letter from AL
        dec cx ;decreses # of characters to write
        jnz writeLoop ;if its not done, jump back up
        jmp playSound ;otherwise jump to loop

playSound:
        mov al, 0x20 ;set register 20
        out 0x10, al
        mov al, 00000001b; defines sound MULTI/KSR/EG_TYPE/VIB/AM
        out 0x11, al

        mov al, 0x23; set register 23
        out 0x10, al
        mov al, 00000001b
        out 0x11, al

        mov al, 0x40; set register 40
        out 0x10, al
        mov al, 00011111b ;VOlume/Key scale level
        out 0x11, al

        mov al, 0x43; set register 43
        out 0x10, al
        mov al, 0x00
        out 0x11, al

        mov al, 0x60; set register 60
        out 0x10, al
        mov al, 0xe4
        out 0x11, al

        mov al, 0x63; set register 63
        out 0x10, al
        mov al, 0xe4
        out 0x11, al

        mov al, 0x80 ;set register 80
        out 0x10, al
        mov al, 0x9d
        out 0x11, al

        mov al, 0x83 ;set register 83
        out 0x10, al
        mov al, 0x9d
        out 0x11, al

        mov al, 0xa0 ;set register a0
        out 0x10, al
        mov al, 0xae
        out 0x11, al

        mov al, 0xb0
        out 0x10, al
        mov al, 0x2a ;UUSOOOFF; 00101010
        out 0x11, al

        call delay

        mov al, 0xb0
        out 0x10, al
        mov al, 0x00
        out 0x11, al

        int 08h

        jmp loop



writeControl: ;writes to control register of LCD
        out 00h, al
        xor al, al ;Turn off register select pin
        out 01h, al
        mov al, 00000100b ;Turn on enable pin, sending the instruction 
        out 01h, al
        mov al, 0x00 ;Reset pin state; Should be replaced with xor al, al
        out 01h, al
        ret

irq_handler:
	mov al, "A"
	call writeLetter
	iret

delay:
        mov cx, 15
.1:     dec cx
        jnz .1

        ret

writeLetter: ;writes to data register of LCD
        out 00h, al
        mov al, 00000001b ;Turn on register select pin
        out 01h, al
        mov al, 00000101b ;Turn on register select pin + enable pin
        out 01h, al
        mov al, 00000001b ;Reset back to original state
        out 01h, al
        ret

loop:
        mov al, 0xb0
        out 0x10, al
        mov al, 00101110b ;UUSOOOFF; 00101010
        out 0x11, al

        call delay

        mov al, 0xb0
        out 0x10, al
        mov al, 0x00
        out 0x11, al

        jmp loop

message: 
    db "i thi"
message_end: