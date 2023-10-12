.section .data
data:          .long 40, 20, 60, 10, 50
count:         .long 5
print_format:  .asciz "%d "
newline_format:.asciz "\n"

.section .text
.globl _start

_bubble_sort:
    movl $4, %esi  # Outer loop counter starts at n-1

outer_loop:
    testl %esi, %esi
    jz end_bubble  # If counter is 0, sorting is done

    xorl %edi, %edi  # Inner loop counter starts at 0

inner_loop:
    cmpl %esi, %edi  # Check if we've reached the outer loop counter
    jge end_inner

    # Compare data[edi] with data[edi+1]
    movl data(, %edi, 4), %eax
    movl data+4(, %edi, 4), %ebx

    cmpl %ebx, %eax
    jle skip_swap  # If data[edi] <= data[edi+1], skip swapping

    # Swap data[edi] with data[edi+1]
    movl %ebx, data(, %edi, 4)
    movl %eax, data+4(, %edi, 4)

skip_swap:
    incl %edi  # Move to the next element
    jmp inner_loop

end_inner:
    decl %esi  # Decrement the outer loop counter
    jmp outer_loop

end_bubble:
    ret

_start:
    call _imprime_vetor
    call _bubble_sort
    call _imprime_vetor

    # Exit
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

_imprime_vetor:
    xorl %edi, %edi      # EDI = 0
print_loop:
    cmpl $5, %edi
    je print_end
    movl data(, %edi, 4), %eax
    pushl %eax
    pushl $print_format
    call printf
    addl $8, %esp
    addl $1, %edi
    jmp print_loop
print_end:
    pushl $newline_format
    call printf
    addl $4, %esp
    ret

