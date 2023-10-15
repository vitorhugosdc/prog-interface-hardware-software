.section .data
	abertura:		.asciz	"COMB SORT\n"

	pedeTam:		.asciz	"Digite o numero de elementos do vetor => "

	pedeElem:		.asciz	"Digite o elemento %d => "

	mostraVetor:	.asciz	"Vetor -> "

	msgOrdenacao: 	.asciz	"\n\nOrdenação:\n"

	msgGap: 		.asciz	"\nGap: %d\n"

	gap: 		.int 0
	ultima:		.int 0

	fatorEncolhimento: 	.float 	1.3

	tam:		.int	0
	elem:		.int	0
	endFinal: 	.int	0

	controleFpu: 	.word 0

	tipoNum:	.asciz	"%d"
	tipoFloat: 	.asciz	"%f"

	mostraNum:	.asciz	"%d, "

	vetor:		.space	200

	pulaLinha:	.asciz	"\n"

.section .bss
	.lcomm 	control, 2

.section .text
.globl _start
_start:

	pushl	$abertura
	call	printf

	call	leTam 			# chama sub-rotina letam
	call 	leVetor
	call	mostraVet			# chama sub-rotina mostraVet
	call 	combSort

_fim:

	pushl 	$0
	call	exit

leTam:

	pushl	$pedeTam
	call	printf

	pushl	$tam
	pushl	$tipoNum
	call	scanf

	addl	$12, %esp   	# limpa pilha (3 ultimos push)

	movl	tam, %eax		# move nº elem. para eax
	cmpl	$0, %eax		# compara eax com zero 	
	jle		leTam			# caso o nº elem. for menor ou igual a zero pula para letam

	cmpl	$50, %eax		# compara 50 com eax  (EAX - 50) - seta EFLAGS
	jg		leTam			# se EAX for maior que 50, pula para letam

	RET						# return (retorna o fluxo de controle do programa para o end. de retorno que foi armazenado na pilha durante a chamada da subrotina

leVetor:

	movl	$vetor, %edi	# move endereço inicial do espaço de 200 para EDI
	movl	$1, %ebx		# move 1 para EBX	
	movl	tam, %ecx		# move tam para ECX

_leMaisUm:

	pushl	%ecx			# backup na pilha de ecx
	pushl	%edi			# backup na pilha de edi (estes regis. podem ser modificados pela função printf)
	pushl	%ebx			# coloca ebx na pilha
	pushl	$pedeElem   	# Digite o elemento X (EBX inicia em 1)
	call	printf

	pushl	%edi			#coloca edi na pilha
	pushl	$tipoNum		
	call	scanf

	addl	$12, %esp		# atualiza ESP atualizando os 3 últimos pushl
	
	popl	%ebx			# tira da pilha e atualiza ebx
	popl	%edi			
	popl	%ecx			# tira da pilha e atualiza ecx

	incl	%ebx
	addl	$4, %edi		# soma 4 ao início do espaço de endereçamento (para o próx. elemento)

	loop	_leMaisUm		# loop até valor de ECX = 0 (ECX = ECX - 1)

	RET

mostraVet:

	movl	$vetor, %edi	# valor inicial do espaço reservado é movido para EDI
	movl	tam, %ecx		# ECX = tam (nº de elementos do vetor)

_mostraMaisUm:

	pushl	%ecx			
	pushl	%edi

	pushl	$mostraVetor
	call	printf
	addl	$4, %esp		#remove o ultimo pushl
	
	popl	%edi			#backup EDI
	popl	%ecx			#backup ECX
	
_volta1:

	pushl	%ecx		
	pushl	%edi

	movl	(%edi), %eax	# move conteúdo apontado por edi para EAX (1º elemento do vetor)		
	pushl	%eax			# coloca o EAX na pilha
	pushl	$mostraNum		# mostra o valor, utilizando o eax como argumento da função
	call	printf
	
	addl	$8, %esp		# remove os 2 ultimos push

	popl	%edi			# backup edi
	popl	%ecx			# backup ECX

	addl	$4, %edi		# soma 4 ao endereço do EDI, para pegar o próx. elemento do vetor

	loop	_volta1			# ECX = ECX - 1

	pushl	$pulaLinha
	call	printf
	addl	$4, %esp

	RET

combSort:
	pushl 	$msgOrdenacao
	call 	printf
	addl 	$4, %esp

	movl 	tam, %eax
	movl	%eax, gap
	call 	calculaGap			# move o tamanho para gap para calcular o primeiro gap
	
	movl 	$vetor, %edi		# valor i no edi
	movl 	%edi, %esi
	
	movl 	gap, %eax
	movl 	$4, %ebx
	mull	%ebx				# multiplicamos gap por 4 para ter o gap em bytes e somamos 
								# ao endereço para ter o valor j na sua posição 
	addl 	%eax, %esi			# valor j no esi 	->	(edi + (4 * gap))

	movl 	tam, %eax
	mull 	%ebx
	addl 	%edi, %eax
	movl 	%eax, endFinal		# multiplicamos o tamanho por 4 e somamos isso ao endereço inicial
								# para ter o último endereço do vetor	($vetor+ (4 * tam))
	
	_loopComeco:
		cmpl 	$1, gap			# se gap é diferente maior ou igual a 1, faz o loop normal
		jge		_loopGap

		movl	$1, gap			# se gap é menor que 1, setamos gap como 1
		movl	$1, ultima		# setamos também a flag ultima, que indica que aquele será o último loop


		_loopGap:
			cmpl 	%esi, endFinal		# se j estiver no endereço final do vetor, 
			je		_preparaLoop		# salta para a preparação de um novo loop

			movl 	(%edi), %ebx		# valor de i no ebx
			movl 	(%esi), %ecx		# valor de j no ecx
			cmpl 	%ebx, %ecx			# compara os dois
			jge 	_naoTroca			# se j for maior que i, não troca e continua o loop

			movl 	%ecx, (%edi)		# se for menor, troca j e i de lugar
			movl 	%ebx, (%esi)

		_naoTroca:
			addl 	$4, %edi			# somamos 4 ao endereço de i e j para irmos à próxima
			addl 	$4, %esi			# posição do vetor e continuar o loop

			jmp		_loopGap			# continua o loop

	_preparaLoop:						# entra aqui quando foi percorrido todo o vetor com determinado
										# valor em gap. aqui prepara para iniciar um novo loop com
										# novo valor de gap

		cmpl	$1, ultima				# se a flag ultima estiver ativa, terminamos a ordenação
		je		_fimComb

		call 	calculaGap				# recalcula o gap

		movl 	$vetor, %edi			# movemos o endereço inicial do vetor para edi (i)

		movl 	%edi, %esi
		movl 	gap, %eax
		movl 	$4, %edx
		mull	%edx
		addl 	%eax, %esi				# fazemos novamente o calculo para posicionar o esi (j)
										# na sua devida posição do vetor (edi + (4 * gap))

		jmp		_loopComeco				# começa um novo loop
			

	_fimComb:

		call 	mostraVet				# finalizou a ordenação, printa o vetor
		RET


calculaGap:

	finit								# (re)inicializa a pilha de floats
	movl $controleFpu, %eax
    fstcw (%eax)
    orw $0xfdf, controleFpu
    fldcw (%eax) 						# seta o controle da pilha de float para arredondar para baixo 

	flds 	fatorEncolhimento			# coloca fator de encolhimento (1.3) na pilha de float
	filds	gap							# coloca gap na pilha de float (gap é sempre int)
	fdiv	%st(1), %st(0)				# dividimos gap pelo fator de encolhimento (resultado em float)
	fists	gap							# retiramos o valor da pilha como inteiro e colocamos na variável gap

	RET

