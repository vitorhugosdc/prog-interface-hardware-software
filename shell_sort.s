.section .data

# Esta seção armazena os dados, como constantes e variáveis globais.

data:          .long 40, 20, 60, 10, 50    # Declara um vetor de inteiros com os valores fornecidos.
count:         .long 5                     # Declara uma variável 'count' e a inicializa com 5 (tamanho do vetor).
print_format:  .asciz "%d "                # Define um formato de string para printf, que é usado para imprimir inteiros.
newline_format:.asciz "\n"                 # Define um formato de string para printf para imprimir uma nova linha.

.section .text

# Esta seção contém o código do programa.

.globl _start

_shell_sort:
    # Função que implementa o algoritmo de ordenação Shell Sort.

    movl count, %eax          # Carrega o valor de 'count' (tamanho do vetor) para o registrador %eax.
    shrl %eax                 # Divide o valor em %eax por 2 (equivalente à operação count/2).
    movl %eax, %ebx           # Move o resultado da divisão para %ebx, que atuará como o 'gap' para a ordenação.

loop_gap:
    # Este é o loop principal que ajusta o valor de 'gap'.

    testl %ebx, %ebx          # Verifica se %ebx (gap) é zero.
    jz end_shell              # Se o gap for 0, pula para o final da função, pois a ordenação está completa.

    movl %ebx, %esi           # Inicializa o índice i com o valor de gap.

i_loop:
    # Este é o loop interno que percorre os elementos do vetor.

    cmpl count, %esi          # Compara 'count' (tamanho do vetor) com i (%esi).
    jge decrement_gap         # Se i >= tamanho do vetor, pula para 'decrement_gap'.

    movl data(, %esi, 4), %eax  # Carrega o valor de data[i] em %eax.
                                #data: é a base do endereço. É onde começa o vetor na memória.
                                #%esi é o índice i do elemento do vetor que quer acessar.
                                #4 é o multiplicador, ou seja, cada elemento ocupa 4 bytes, temos que multiplicar i por 4, pra acessar o elemento desejado
                                
    movl %esi, %edi            # Configura j (%edi) para ser igual a i (%esi).

j_loop:
    # Este loop compara elementos em índices distantes pelo gap.

    subl %ebx, %edi            # Subtrai o gap de j.
    js skip                    # Se j é negativo, pula para 'skip'.

    cmpl data(, %edi, 4), %eax # Compara data[j] com data[i].
    jge skip                   # Se data[j] >= data[i], pula para 'skip'.

    # Troca data[j] e data[j+gap].
    movl data(, %edi, 4), %edx # Carrega data[j] em %edx.
    movl %edi, %ecx            # Copia j para %ecx.
    addl %ebx, %ecx            # Adiciona gap a %ecx.
    movl %edx, data(, %ecx, 4) # Move o valor de %edx para data[j+gap].
    movl %eax, data(, %edi, 4) # Move data[i] para data[j].

    jmp j_loop                 # Repete o loop j.

skip:
    addl $1, %esi              # Incrementa o valor de i.
    jmp i_loop                 # Repete o loop i.

decrement_gap:
    shrl %ebx                  # Divide o valor de gap por 2.
    jmp loop_gap               # Repete o loop principal.

end_shell:
    ret                        # Retorna da função Shell Sort.

_imprime_vetor:
    # Função para imprimir o vetor.

    movl $0, %edi              # Configura o índice de impressão para 0.

loop_print:
    cmpl count, %edi           # Compara o índice de impressão com 'count'.
    je end_print               # Se o índice é igual ao tamanho do vetor, termina a impressão.

    movl data(, %edi, 4), %eax # Carrega o valor do vetor no índice atual em %eax.
    pushl %eax                 # Empilha o valor.
    pushl $print_format        # Empilha o formato de string para printf.
    call printf                # Chama a função printf.

    addl $8, %esp              # Ajusta o ponteiro da pilha.
    addl $1, %edi              # Incrementa o índice.
    jmp loop_print             # Repete o loop de impressão.

end_print:
    pushl $newline_format      # Empilha o formato de string para imprimir uma nova linha.
    call printf                # Chama a função printf.
    addl $4, %esp              # Ajusta o ponteiro da pilha.
    ret                        # Retorna da função de impressão.

_start:
    # Ponto de entrada principal do programa.

    call _imprime_vetor        # Chama a função para imprimir o vetor.
    call _shell_sort           # Chama a função Shell Sort para ordenar o vetor.
    call _imprime_vetor        # Chama a função para imprimir o vetor novamente.

    # Termina o programa.
    movl $1, %eax              # Configura o valor de %eax para a syscall de saída.
    xorl %ebx, %ebx            # Configura o valor de retorno como 0.
    int $0x80                  # Chama a interrupção para sair do programa.


