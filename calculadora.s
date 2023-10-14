.section .data
    prompt:          .asciz "Digite o próximo número: "
    num_prompt:      .asciz "Quantos números você deseja inserir? "
    op_prompt:       .asciz "Digite a operação (+, -): "
    scan_format:     .asciz "%lf"
    scan_format_int: .asciz "%d"
    scan_op_format:  .asciz " %c"
    operation:       .space 2
    output:          .asciz "Resultado: %lf\n"
    err_msg:         .asciz "Operação inválida!\n"

.section .bss
    numbers:  .space 800   # Para armazenar 100 doubles (8 bytes cada)
    count:    .space 4     # Armazenar a contagem de números inseridos pelo usuário
    result:   .space 8

.section .text
    .globl _start

_start:
    # Solicita e lê a quantidade de números
    pushl $num_prompt
    call printf
    addl $4, %esp

    pushl $count
    pushl $scan_format_int
    call scanf
    addl $8, %esp

    # Verifique se o número de entradas é válido
    cmpl $100, %eax
    jg end_program

    # Coletar todos os números
    movl $0, %esi  # contador
read_loop:
    cmpl count, %esi
    je ask_operation

    pushl $prompt
    call printf
    addl $4, %esp

    leal numbers(, %esi, 8), %edi
    pushl %edi
    pushl $scan_format
    call scanf
    addl $8, %esp

    incl %esi
    jmp read_loop

ask_operation:
    pushl $op_prompt
    call printf
    addl $4, %esp

    leal operation, %ecx
    pushl %ecx
    pushl $scan_op_format
    call scanf
    addl $8, %esp

    cmpb $'+', operation
    je perform_addition

    cmpb $'-', operation
    je perform_subtraction

    # Se chegou aqui, a operação é inválida
    jmp invalid_op

perform_addition:
    movl $0, %esi
    fldz  # Empilhe 0 para iniciar a soma

add_loop:
    cmpl count, %esi
    je done_addition

    leal numbers(, %esi, 8), %edi
    fldl (%edi)    # Empilhe o próximo número
    faddp          # Adicione ao acumulador

    incl %esi
    jmp add_loop

done_addition:
    fstpl result
    jmp print_result

perform_subtraction:
    leal numbers, %edi   # Apontar para o começo dos números
    fldl (%edi)          # Carregue o primeiro número para a pilha

    # Agora, avance para o próximo número e comece a subtração
    movl $1, %esi       # Começar do segundo número
subtraction_loop:
    cmpl count, %esi
    je done_subtraction

    addl $8, %edi        # Mova para o próximo número
    fldl (%edi)          # Carregue o próximo número
    fsubrp               # Subtraia do acumulador e pop ambos os valores

    incl %esi
    jmp subtraction_loop

done_subtraction:
    fstpl result
    jmp print_result

invalid_op:
    pushl $err_msg
    call printf
    addl $4, %esp
    jmp end_program

print_result:
    fldl result
    subl $8, %esp
    fstpl (%esp)
    pushl $output
    call printf
    addl $12, %esp
    jmp end_program

end_program:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
