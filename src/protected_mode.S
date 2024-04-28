.equ CODE_SEG, gdt_code - gdt_start
.equ DATA_SEG, gdt_data - gdt_start

/* Switch to protected mode */
.code16
switch_to_protected_mode:
    cli                             /* Disable interrupts */
    lgdt gdt_descriptor             /* Load the Global Descriptor Table (GDT) */
    
    /* Load Control Register CR0 and set the Protection Enable (PE) bit to 1 */
    mov %cr0, %eax
    orl $0x1, %eax
    mov %eax, %cr0
    
    ljmp $CODE_SEG, $protected_mode /* Jump to protected mode */

/* Global Descriptor Table (GDT) */
gdt_start:
    /* Null descriptor */
    gdt_null:
        .long 0x0 
        .long 0x0 

    /* Code descriptor */
    gdt_code:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10011010
        .byte 0b11001111 
        .byte 0x0 

    /* Data descriptor */
    gdt_data:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10010010
        .byte 0b11001111
        .byte 0x0 
    gdt_end:

    /* GDT descriptor */
    gdt_descriptor:
        .word gdt_end - gdt_start - 1 
        .long gdt_start 


/* Protected mode initialization */
.code32
protected_mode:
    /* Initialize stack pointer */
    mov $0x7000, %ebp
    mov %ebp, %esp
    
    /* Call the check_protected_mode function */
    call check_protected_mode

    hlt


/* Check if in protected mode and print message */
check_protected_mode:
    mov %cr0, %eax         /* Load Control Register CR0 */
    test $0x1, %eax        /* Test the PE bit (bit 0) */
    jnz protected_mode_detected  /* Jump if PE bit is set (in protected mode) */
    /* If PE bit is not set, handle real mode or other cases */
    /* You can print an error message or take appropriate action */
    jmp not_in_protected_mode
protected_mode_detected:
    /* Processor is in protected mode */
    /* Call the print_message function */
    call print_message
    jmp continue_execution
not_in_protected_mode:
    /* Processor is not in protected mode */
    /* You can perform actions specific to real mode or other cases here */
    jmp continue_execution
continue_execution:
    /* Continue with the program execution */


/* Print message on VGA */
print_message:
    /* Load the address of the message into ECX */
    mov $message, %ecx
    /* Load the address of the VGA buffer into EAX */
    mov vga, %eax
    /* Calculate VGA memory address */
    mov $160, %edx
    mul %edx
    lea 0xb8000(%eax), %edx
    mov $0x0f, %ah 
loop:
    /* Load the character from the message into AL */
    mov (%ecx), %al
    /* Check for the end of the message */
    cmp $0, %al
    je end
    /* Write the character to the VGA buffer */
    mov %ax, (%edx)
    /* Move to the next character in the message and VGA buffer */
    add $1, %ecx
    add $2, %edx
    /* Repeat the loop */
    jmp loop
end:
    ret

/* Message to be printed on VGA */
message:
    .asciz "Successfully switched to protected mode."

/* VGA buffer address */
vga:
    .long 10
