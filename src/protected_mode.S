.equ CODE_SEG, gdt_code - gdt_start
.equ DATA_SEG, gdt_data - gdt_start

/* Switch to protected mode */
.code16
switch_to_protected_mode:
    cli                                 /* Step 0. Disable interrupts */
    lgdt gdt_descriptor                 /* Step 1. Load the Global Descriptor Table (GDT) */
    
    /* Step 2. Load Control Register CR0 and set the Protection Enable (PE) bit to 1 */
    mov %cr0, %eax
    orl $0x1, %eax
    mov %eax, %cr0
    
    /* Step 3. Jump to 32bits code section. */
    ljmp $CODE_SEG, $protected_mode


/* Global Descriptor Table (GDT) */
gdt_start:
    /* Null descriptor */
    gdt_null:
        .long 0x0                       /* Null segment descriptor - limit */
        .long 0x0                       /* Base address */

    /* Code descriptor */
    gdt_code:
        .word 0xffff                    /* Segment limit (lower 16 bits) */
        .word 0x0                       /* Base address (lower 16 bits) */
        .byte 0x0                       /* Base address (middle 8 bits) */
        .byte 0b10011010                /* Flags: Present, Privilege Level 0, Code Segment, Executable, Readable */
        .byte 0b11001111                /* Flags: Granularity (4KB), 32-bit mode, Limit (upper 4 bits) */
        .byte 0x0                       /* Base address (upper 8 bits) */

    /* Data descriptor */
    gdt_data:
        .word 0xffff                    /* Segment limit (lower 16 bits) */
        .word 0x0                       /* Base address (lower 16 bits) */
        .byte 0x0                       /* Base address (middle 8 bits) */
        .byte 0b10010010                /* Flags: Present, Privilege Level 0, Data Segment, Readable, Writable */
        .byte 0b11001111                /* Flags: Granularity (4KB), 32-bit mode, Limit (upper 4 bits) */
        .byte 0x0                       /* Base address (upper 8 bits) */

    gdt_end:

    /* GDT descriptor */
    gdt_descriptor:
        .word gdt_end - gdt_start - 1   /* Limit of GDT (size - 1) */
        .long gdt_start                 /* Base address of GDT */


/* Protected mode initialization */
.code32
protected_mode:
    /* Initialize the registers and stack pointer */
    mov $DATA_SEG, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x7000, %ebp
    mov %ebp, %esp

    mov $0x7000, %ebp
    mov %ebp, %esp
    
    /* Jump the check_protected_mode function */
    jmp check_protected_mode


/* Check if in protected mode and print message */
check_protected_mode:
    mov %cr0, %eax                      /* Load Control Register CR0 */
    test $0x1, %eax                     /* Test the PE bit (bit 0) */
    jnz protected_mode_detected         /* Jump if PE bit is set (in protected mode) */
    jmp not_in_protected_mode
protected_mode_detected:
    /* Processor is in protected mode */
    call print_message
    jmp continue_execution
not_in_protected_mode:
    /* Processor is not in protected mode */
    hlt
continue_execution:
    /* Continue with the program execution */
    hlt


/* Print message on VGA */
print_message:
    mov $message, %ecx                  /* Load the address of the message into ECX */
    mov vga, %eax                       /* Load the address of the VGA buffer into EAX */
    
    /* Calculate VGA memory address */
    mov $160, %edx
    mul %edx
    lea 0xb8000(%eax), %edx
    mov $0x0f, %ah 
loop:
    mov (%ecx), %al                     /* Load the character from the message into AL */
    cmp $0, %al                         /* Check for the end of the message */
    je end
    
    mov %ax, (%edx)                     /* Write the character to the VGA buffer */
    
    /* Move to the next character in the message and VGA buffer */
    add $1, %ecx
    add $2, %edx
    jmp loop
end:
    ret

/* Message to be printed on VGA */
message:
    .asciz "Successfully switched to protected mode."

/* VGA buffer address */
vga:
    .long 10