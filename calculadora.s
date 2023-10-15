.section .data
    prompt:          .asciz "Digite o próximo número: " 
    num_prompt:      .asciz "Quantos números você deseja inserir? "
    op_prompt:       .asciz "Digite a operação (+, -, *, /, t, r): "
    scan_format:     .asciz "%lf"               # Formato para ler números do tipo double
    scan_format_int: .asciz "%d"                # Formato para ler números inteiros
    scan_op_format:  .asciz " %c"               # Formato para ler um caractere (operação)
    operation:       .space 2                   # Espaço reservado para armazenar a operação escolhida pelo usuário
    output:          .asciz "Resultado: %lf\n"
    single_output:   .asciz "Raiz de %lf: %lf\n"
    err_msg:         .asciz "Operação inválida!\n"
    div_zero_msg:    .asciz "Erro: Divisão por zero!\n"

.section .bss                       # Início da seção para variáveis não inicializadas
    numbers:  .space 800   # Espaço reservado para armazenar até 100 números do tipo double (cada um tem 8 bytes)
    count:    .space 4     # Espaço reservado para armazenar a quantidade de números inseridos pelo usuário
    result:   .space 8     # Espaço reservado para armazenar o resultado final da operação (8 por ser double)


.section .text        # Esta linha indica o início da seção de texto, onde o código é armazenado.
    .globl _start     # Torna o símbolo "_start" global para que o linker possa encontrá-lo. É o ponto de entrada do programa.

_start:               # Este é o ponto de entrada do programa.
    # Solicita e lê a quantidade de números
    pushl $num_prompt # Coloca o endereço da string "num_prompt" na pilha para passá-lo como argumento para printf.
    call printf       # Chama a função printf para exibir a string.
    addl $4, %esp     # Ajusta o ponteiro da pilha após a chamada da função (libera 4 bytes).

    pushl $count      # Coloca o endereço da variável "count" na pilha, que armazenará a entrada do usuário.
    pushl $scan_format_int # Coloca o endereço do formato de leitura "%d" na pilha.
    call scanf        # Chama a função scanf para ler a entrada do usuário.
    addl $8, %esp     # Ajusta o ponteiro da pilha (libera 8 bytes, pois dois endereços foram colocados na pilha).

    # Verifique se o número de entradas é válido
    cmpl $100, %eax   # Compara o valor em %eax (resultado do scanf) com 100.
    jg end_program    # Se o valor for maior que 100, vai para "end_program".

    # Coletar todos os números
    movl $0, %esi     # Inicializa o contador %esi com 0.
read_loop:            # Início do loop de leitura.
    cmpl count, %esi  # Compara o valor em "count" com %esi.
    je ask_operation  # Se eles forem iguais, todos os números foram lidos; vai para "ask_operation".

    pushl $prompt     # Coloca o endereço da string "prompt" na pilha.
    call printf       # Exibe o prompt para o usuário.
    addl $4, %esp     # Ajusta o ponteiro da pilha.

    leal numbers(, %esi, 8), %edi  # Calcula o endereço para onde o próximo número será armazenado e coloca em %edi.
    pushl %edi        # Coloca esse endereço na pilha.
    pushl $scan_format
    call scanf        # Lê o número do usuário.
    addl $8, %esp     # Ajusta o ponteiro da pilha.

    incl %esi         # Incrementa o contador.
    jmp read_loop     # Volta ao início do loop para ler o próximo número.

ask_operation:        # Solicita ao usuário a operação desejada.
    pushl $op_prompt  # Coloca o endereço da string "op_prompt" na pilha.
    call printf       # Exibe o prompt de operação para o usuário.
    addl $4, %esp     # Ajusta o ponteiro da pilha.

    leal operation, %ecx   # Calcula o endereço da variável "operation" e coloca em %ecx.
    pushl %ecx        # Coloca esse endereço na pilha.
    pushl $scan_op_format # Coloca o formato de leitura na pilha.
    call scanf        # Lê a operação desejada do usuário.
    addl $8, %esp     # Ajusta o ponteiro da pilha.

    # Comparando o caráter de operação inserido e pulando para a função correspondente.
    cmpb $'+', operation  # Compara a operação com '+'.
    je perform_addition   # Se igual, pula para a função de adição.
    cmpb $'-', operation  # Compara com '-'.
    je perform_subtraction # E assim por diante...
    cmpb $'*', operation  
    je perform_multiplication
    cmpb $'/', operation
    je perform_division
    cmpb $'t', operation
    je calculate_triangle_area
    cmpb $'r', operation
    je calculate_square_root

    # Se chegou aqui, a operação é inválida
    jmp invalid_op     # Pula para a função que exibe mensagem de erro.


perform_addition:                      # Rotina para realizar adição de todos os números.
    movl $0, %esi                     # Inicializa o contador em 0.
    fldz                              # Empilha um 0.0 para começar a soma.
add_loop:                              # Começo do loop de adição.
    cmpl count, %esi                  # Compara o contador com a quantidade total de números.
    je done_addition                  # Se todos os números foram processados, termina a adição.
    leal numbers(, %esi, 8), %edi     # Calcula o endereço do próximo número e armazena em %edi.
    fldl (%edi)                       # Empilha o próximo número.
    faddp                             # Soma o número ao acumulador no topo da pilha.
    incl %esi                         # Incrementa o contador.
    jmp add_loop                      # Repete o loop.
done_addition:                         # Fim da rotina de adição.
    fstpl result                      # Armazena o resultado da soma.
    jmp print_result                  # Vai para a rotina que exibe o resultado.

perform_subtraction:                   # Rotina para realizar a subtração dos números.
    leal numbers, %edi                # Pega o endereço do primeiro número.
    fldl (%edi)                       # Carrega o primeiro número (o minuendo).
    movl $1, %esi                     # Configura o contador para começar do segundo número.
subtraction_loop:                      # Começo do loop de subtração.
    cmpl count, %esi                  # Compara o contador com a quantidade total de números.
    je done_subtraction               # Se todos os números foram processados, termina a subtração.
    addl $8, %edi                     # Avança para o próximo número.
    fldl (%edi)                       # Carrega o próximo número (o subtraendo).
    fsubrp                            # Subtrai o subtraendo do minuendo e coloca o resultado no topo da pilha.
    incl %esi                         # Incrementa o contador.
    jmp subtraction_loop              # Repete o loop.
done_subtraction:                      # Fim da rotina de subtração.
    fstpl result                      # Armazena o resultado da subtração.
    jmp print_result                  # Vai para a rotina que exibe o resultado.

perform_multiplication:           # Rotina para multiplicar todos os números.
    leal numbers, %edi            # Apontar para o começo dos números.
    fld1                          # Carregar 1.0 (neutral na multiplicação) para a pilha.

    movl $0, %esi                 # Iniciar do primeiro número.
multiplication_loop:              # Início do loop de multiplicação.
    cmpl count, %esi              # Comparar o contador com a quantidade total de números.
    je done_multiplication        # Se todos os números foram processados, termina a multiplicação.

    fldl (%edi)                   # Carregar o próximo número.
    fmulp                         # Multiplicar pelo valor no topo da pilha (acumulador).

    addl $8, %edi                 # Mover para o próximo número.
    incl %esi                     # Incrementar o contador.
    jmp multiplication_loop       # Repetir o loop.

done_multiplication:              # Fim da rotina de multiplicação.
    fstpl result                  # Armazenar o resultado da multiplicação.
    jmp print_result              # Ir para a rotina que exibe o resultado.

perform_division:                 # Rotina para dividir todos os números pelo primeiro número.
    leal numbers, %edi            # Apontar para o começo dos números.
    fldl (%edi)                   # Carregar o primeiro número (dividendo) para a pilha.

    movl $1, %esi                 # Começar do segundo número.
division_loop:                    # Início do loop de divisão.
    cmpl count, %esi              # Comparar o contador com a quantidade total de números.
    je done_division              # Se todos os números foram processados, termina a divisão.

    addl $8, %edi                 # Mover para o próximo número.
    fldl (%edi)                   # Carregar o próximo número (divisor).
    ftst                          # Testar o valor atual na pilha (verificar se é 0).
    fstsw %ax
    sahf
    jz division_by_zero           # Se o número é 0, erro de divisão por zero.
    fdivrp                        # Dividir o acumulador pelo número e pop ambos os valores da pilha.

    incl %esi                     # Incrementar o contador.
    jmp division_loop             # Repetir o loop.

done_division:                    # Fim da rotina de divisão.
    fstpl result                  # Armazenar o resultado da divisão.
    jmp print_result              # Ir para a rotina que exibe o resultado.

division_by_zero:                 # Rotina para tratar o erro de divisão por zero.
    pushl $div_zero_msg           # Empilhar a mensagem de erro.
    call printf                  # Exibir a mensagem de erro.
    addl $4, %esp                # Ajustar o ponteiro da pilha.
    jmp end_program              # Terminar o programa.
    
calculate_triangle_area:               # Rotina para calcular a área de um triângulo.
    leal numbers, %edi                # Pega o endereço do primeiro número (base).
    fldl (%edi)                       # Carrega a base.
    addl $8, %edi                     # Avança para o próximo número.
    fldl (%edi)                       # Carrega a altura.
    fmulp                             # Multiplica base x altura.
    fld1                              # Empilha 1.0.
    fld1                              # Empilha outro 1.0.
    faddp                             # Soma os dois 1.0 para obter 2.0.
    fdivrp                            # Divide (base x altura) por 2.
    fstpl result                      # Armazena o resultado.
    jmp print_result                  # Vai para a rotina que exibe o resultado.

calculate_square_root:                 # Rotina para calcular a raiz quadrada de cada número.
    movl $0, %esi                     # Configura o contador para começar do primeiro número.
sqrt_loop:                             # Começo do loop de raiz quadrada.
    cmpl count, %esi                  # Compara o contador com a quantidade total de números.
    je end_program                    # Se todos os números foram processados, termina o programa.
    leal numbers(, %esi, 8), %edi     # Calcula o endereço do número atual.
    fldl (%edi)                       # Carrega o número atual.
    fsqrt                             # Calcula a raiz quadrada.
    subl $16, %esp                    # Reserva espaço na pilha para dois doubles.
    fstpl 8(%esp)                     # Armazena a raiz quadrada no espaço reservado.
    fldl (%edi)                       # Recarrega o número original.
    fstpl (%esp)                      # Armazena o número original no espaço reservado.
    pushl $single_output              # Coloca o formato de saída na pilha.
    call printf                       # Exibe o número original e sua raiz quadrada.
    addl $20, %esp                    # Ajusta o ponteiro da pilha.
    incl %esi                         # Avança para o próximo número.
    jmp sqrt_loop                     # Repete o loop.

invalid_op:                     # Rotina para tratar uma operação inválida.
    pushl $err_msg              # Empilhar a mensagem de erro.
    call printf                 # Exibir a mensagem de erro.
    addl $4, %esp               # Ajustar o ponteiro da pilha após a chamada.
    jmp end_program             # Ir para o final do programa.

print_result:                   # Rotina para exibir o resultado de qualquer operação.
    fldl result                 # Carregar o resultado da operação na pilha FPU.
    subl $8, %esp               # Reservar espaço na pilha para o valor double.
    fstpl (%esp)                # Armazenar o valor do topo da pilha FPU no espaço reservado.
    pushl $output               # Empilhar a string de formato.
    call printf                 # Exibir o resultado.
    addl $12, %esp              # Ajustar o ponteiro da pilha após a chamada e empurrar o double e a string.
    jmp end_program             # Ir para o final do programa.

end_program:                    # Rotina para encerrar o programa.
    movl $1, %eax               # A instrução 1 do syscall representa a saída do programa no Linux.
    xorl %ebx, %ebx             # Zerar %ebx. A saída com status 0 significa sucesso.
    int $0x80                   # Realizar a interrupção, chamando o sistema para encerrar o programa.
