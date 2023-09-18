.section .data

data:          .long 40, 20, 60, 10, 50     # Vetor de dados a ser ordenado
count:         .long 5                      # Contador representando o tamanho do vetor
print_format:  .asciz "%d "                 # Formato de impressão para printf (imprimir um inteiro seguido por espaço)
newline_format:.asciz "\n"                  # Formato para imprimir quebra de linha

.section .text
.globl _start

_ordenacao_insercao:                       # Função de ordenação por inserção
    movl $1, %ebx                          # Inicializa i = 1, EBX será nosso índice i
loop_externo:
    cmpl count, %ebx                       # Compara i com count
    jge fim_ordenacao                      # Se i >= count, o vetor já está ordenado
    movl data(, %ebx, 4), %eax             # Carrega o valor do vetor na posição i em EAX
    movl %ebx, %ecx                        # Define j = i, ECX será nosso índice j
loop_interno:
    testl %ecx, %ecx                       # Testa se j == 0
    jz incrementa_i                        # Se j == 0, vai para incrementa_i
    cmpl data-4(, %ecx, 4), %eax           # Compara o elemento anterior (j-1) com o elemento atual (j)
    jge incrementa_i                       # Se o anterior for maior ou igual ao atual, vai para incrementa_i
    movl data-4(, %ecx, 4), %edx           # Carrega o valor do elemento anterior em EDX
    movl %edx, data(, %ecx, 4)             # Move o elemento anterior para a posição atual
    decl %ecx                              # Decrementa j
    jmp loop_interno                       # Volta para o início do loop interno
incrementa_i:
    movl %eax, data(, %ecx, 4)             # Insere o valor de EAX na posição j do vetor
    incl %ebx                              # Incrementa i
    jmp loop_externo                       # Volta para o início do loop externo
fim_ordenacao:
    ret

_imprime_vetor:
    movl $0, %edi                          # Inicializa o índice de impressão EDI = 0
loop_impressao:
    cmpl count, %edi                       # Compara EDI com o contador (tamanho do vetor)
    je fim_impressao                       # Se EDI == count, termina a impressão
    movl data(, %edi, 4), %eax             # Carrega o valor atual do vetor em EAX
    pushl %eax                             # Empilha o valor para o printf
    pushl $print_format                    # Empilha o formato de impressão
    call printf                            # Chama printf
    addl $8, %esp                          # Ajusta a pilha
    incl %edi                              # Incrementa o índice de impressão EDI
    jmp loop_impressao                     # Volta para o início do loop de impressão
fim_impressao:
    pushl $newline_format                  # Empilha o formato de quebra de linha
    call printf                            # Chama printf para imprimir quebra de linha
    addl $4, %esp                          # Ajusta a pilha
    ret

_start:
    call _imprime_vetor                    # Chama a função para imprimir o vetor antes da ordenação
    call _ordenacao_insercao               # Chama a função de ordenação por inserção
    call _imprime_vetor                    # Chama a função para imprimir o vetor após a ordenação

    # Finaliza o programa
    movl $1, %eax                          # Código para syscall: sys_exit
    xorl %ebx, %ebx                        # Define status de saída: 0
    int $0x80                              # Chama a interrupção

