.section .data
    prompt1:      .asciz "Digite a base do triângulo (ou o primeiro número): "
    prompt2:      .asciz "Digite a altura do triângulo (ou o segundo número): "
    op_prompt:    .asciz "Digite a operação (+, -, *, /, t): "
    output:       .asciz "Resultado: %lf\n"
    scan_format:  .asciz "%lf"
    err_msg:      .asciz "Operação inválida!\n"
    div_by_zero:  .asciz "Erro: Divisão por zero!\n"
    half_const:   .double 0.5

.section .bss
    num1: .space 8
    num2: .space 8
    result: .space 8
    operation: .space 2

.section .text
    .globl _start

_start:
    # Solicita e lê o primeiro número (ou base) diretamente como double
    pushl $prompt1
    call printf
    addl $4, %esp

    pushl $num1
    pushl $scan_format
    call scanf
    addl $8, %esp

    # Solicita e lê o segundo número (ou altura) diretamente como double
    pushl $prompt2
    call printf
    addl $4, %esp

    pushl $num2
    pushl $scan_format
    call scanf
    addl $8, %esp

    # Solicita a operação ao usuário
    movl $4, %eax
    movl $1, %ebx
    movl $op_prompt, %ecx
    movl $40, %edx
    int $0x80

    # Lê a operação
    movl $3, %eax
    movl $0, %ebx
    lea operation, %ecx
    movl $2, %edx
    int $0x80

    # Executa a operação
    fldl num2
    fldl num1
    cmpb $'+', operation
    je add_nums
    cmpb $'-', operation
    je sub_nums
    cmpb $'*', operation
    je mul_nums
    cmpb $'/', operation
    je div_nums
    cmpb $'t', operation
    je triangle_area
    jmp invalid_op

add_nums:
    faddp
    fstpl result
    jmp print_result

sub_nums:
    fsubp
    fstpl result
    jmp print_result

mul_nums:
    fmulp
    fstpl result
    jmp print_result

div_nums:
    ftst                           # Testa o valor no topo da pilha (num1 neste caso)
    fstsw %ax                      # Armazena o status da word
    sahf                           # Configura as flags de acordo
    jz division_by_zero            # Verifica se a divisão é por zero
    fdivp
    fstpl result
    jmp print_result

triangle_area:
    fmulp                          # Multiplica base e altura
    fmull half_const               # Multiplica o produto por 0.5
    fstpl result
    jmp print_result

division_by_zero:
    movl $4, %eax
    movl $1, %ebx
    movl $div_by_zero, %ecx
    movl $23, %edx
    int $0x80
    jmp end_program

invalid_op:
    movl $4, %eax
    movl $1, %ebx
    movl $err_msg, %ecx
    movl $18, %edx
    int $0x80
    jmp end_program

print_result:
    # Carregar o resultado no FPU
    fldl result
    subl $8, %esp
    fstpl (%esp)  # armazenar o topo da pilha do FPU na pilha
    pushl $output
    call printf
    addl $12, %esp
    jmp end_program

end_program:
    # Saída
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
