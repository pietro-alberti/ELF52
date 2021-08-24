 PUBLIC  __iar_program_start
        EXTERN  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

; System Control definitions
SYSCTL_BASE             EQU     0x400FE000
SYSCTL_RCGCGPIO         EQU     0x0608                  
SYSCTL_RCGCGPIO_R       EQU     0x400FE608              ; Run-mode Clock Gating -> Inicializacao -> Habilita clock
SYSCTL_PRGPIO		EQU     0x0A08          
SYSCTL_PRGPIO_R		EQU     0x400FEA08              ; Peripheral Ready      -> Inicializacao -> Indica se a porta GPIO está pronta para uso
SYSCTL_RCGCUART         EQU     0x0618
SYSCTL_PRUART           EQU     0x0A18
; System Control bit definitions
PORTA_BIT               EQU     000000000000001b        ; Define quantos bits que pode se escrever na porta a -> datasheet
PORTF_BIT               EQU     0000000000100000b       ; Define quantos bits que pode se escrever na porta f -> datasheet
PORTJ_BIT               EQU     0000000100000000b       ; Define quantos bits que pode se escrever na porta j -> datasheet
PORTN_BIT               EQU     0001000000000000b       ; Define quantos bits que pode se escrever na porta n -> datasheet
UART0_BIT               EQU     00000001b               ; Define quantos bits que pode se escrever na porta o -> datasheet

; NVIC definitions
NVIC_BASE               EQU     0xE000E000
NVIC_EN1                EQU     0x0104
VIC_DIS1                EQU     0x0184
NVIC_PEND1              EQU     0x0204
NVIC_UNPEND1            EQU     0x0284
NVIC_ACTIVE1            EQU     0x0304
NVIC_PRI12              EQU     0x0430

; GPIO Port definitions
GPIO_PORTA_BASE         EQU     0x40058000
GPIO_PORTF_BASE    	EQU     0x4005D000
GPIO_PORTJ_BASE    	EQU     0x40060000
GPIO_PORTN_BASE    	EQU     0x40064000
GPIO_DIR                EQU     0x0400                 
GPIO_IS                 EQU     0x0404                  
GPIO_IBE                EQU     0x0408                  
GPIO_IEV                EQU     0x040C                  
GPIO_IM                 EQU     0x0410                  
GPIO_RIS                EQU     0x0414                  
GPIO_MIS                EQU     0x0418                  
GPIO_ICR                EQU     0x041C                  
GPIO_AFSEL              EQU     0x0420
GPIO_PUR                EQU     0x0510
GPIO_DEN                EQU     0x051C                  ; Habilitar funcao digital
GPIO_PCTL               EQU     0x052C

; UART definitions
UART_PORT0_BASE         EQU     0x4000C000
UART_FR                 EQU     0x0018
UART_IBRD               EQU     0x0024
UART_FBRD               EQU     0x0028
UART_LCRH               EQU     0x002C
UART_CTL                EQU     0x0030
UART_CC                 EQU     0x0FC8

;UART bit definitions
TXFE_BIT                EQU     10000000b               ; TX FIFO full
RXFF_BIT                EQU     01000000b               ; RX FIFO empty
BUSY_BIT                EQU     00001000b               ; Busy

; Tempo de delay
DELAY                    EQU     0x005F                 ; tempo de delay

; PROGRAMA PRINCIPAL

__iar_program_start

main:   
        MOV R2, #(UART0_BIT)
	BL UART_enable                                  ; habilita UART0

        MOV R0, #(PORTA_BIT)
	BL Enable_port                                  ; habilita porta A
        
	LDR R0, =GPIO_PORTA_BASE
        MOV R1, #00000011b                              
        BL GPIO_special

	MOV R1, #0xFF                                   ; máscara das funções especiais no port A (bits 1 e 0)
        MOV R2, #0x11                                   ; funções especiais RX e TX no port A (UART)
        BL GPIO_select

	LDR R2, =UART_PORT0_BASE
        BL UART_config                                  ; configura periférico UART0

        LDR R0, =UART_PORT0_BASE                        
                                                    
                                                        
loop:
        BL Reset_tudo                                  ; Reseta todas as variáveis do ambiente
Monta_num1:
        CMP R10, #4                                      ; verifica se r3 tem menos de 4 digitos
        IT PL
          BLPL Espera_operacao

        BL Le_serial                                  ; le a serial e salva o valor em r1
        MOV R6, R3                                      ; r6 = r3
        
        CMP R1, #67                                    ; se a entrada for C finaliza a operação
        ITTT EQ
          BLEQ Escreve_serial
          BLEQ Nova_linha
          BEQ loop
        
        CMP R1, #61                                     ; verifica se R1 é sinal de =
        ITT EQ                                          ; se não for igual escreve o valor na serial
          BLEQ Nova_linha
          BEQ loop
          
        BL valida_oper                              ; verefica operação                            
        CMP R4, #0                                      ; se estiver, finaliza num1, salva a operacao em r4
        ITTT HI                                         ; e monta o numero 2
          MOVHI R10, #0
          BLHI Escreve_serial
          BHI Monta_num2
        
        BL NAN                                          ; Verifica se a entrada eh um numero, se não for ignora a leitura
        CMP R7, #1
        IT EQ
          BEQ Monta_num1
        
        BL Escreve_serial
        ITTT LO
          BLLO Faz_num                              ; r6 = r3*10+r1 // R10++
          MOVLO R3, R6                                  ; r3 = r6
          BLO Monta_num1
          
Espera_operacao:
        BL Le_serial
        CMP R1, #61
        IT EQ
          BLEQ Escreve_serial
        CMP R1, #61
        ITTTT EQ
          MOVEQ R1, R3                                ; calcula o valor de R3 e R5 com a operação contida em R4                            
          BLEQ Mostra_resultado
          BLEQ Nova_linha                                 ; e imprimi na tela
          BEQ loop

        CMP R1, #67                                    ; se a entrada for C finaliza a operação
        ITTT EQ
          BLEQ Escreve_serial
          BLEQ Nova_linha
          BEQ loop
          
        BL valida_oper                              ; verefica se está recebendo um operando                               
        CMP R4, #0                                      ; se estiver, salva em r4 e vai para Monta_num2
        ITTT HI                                         
          MOVHI R10, #0
          BLHI Escreve_serial
          BHI Monta_num2
        B Espera_operacao

Monta_num2:
        CMP R10, #4                                     ; Se o segundo numero ja tiver 4 digitos o usuario
        ITTT PL                                         ; nao precisa digitar igual
          BLPL Calcula
          BLPL Nova_linha
          BPL loop

        BL Le_serial
        MOV R6, R5

        CMP R1, #61
        ITTT EQ
          BLEQ Calcula                                ; calcula o valor de R3 e R5 com a operação contida em R4                            
          BLEQ Nova_linha                                 ; e imprimi na tela
          BEQ loop

        CMP R1, #67                                    ; se a entrada for C finaliza a operação
        ITTT EQ
          BLEQ Escreve_serial
          BLEQ Nova_linha
          BEQ loop
        
        BL NAN                                          ; Verifica se a entrada eh um numero, se não for ignora a leitura
        CMP R7, #1
        IT EQ
          BEQ Monta_num2

        CMP R10, #4                                      ; menor que 4 digitos
        ITTTT LO
          BLLO Escreve_serial
          BLLO Faz_num                              ; r6 = r5*10+r1 // R10++
          MOVLO R5, R6                                  ; r5 = r6
          BLO Monta_num2

        B loop  

Le_serial:                                            ; Le a serial e salva o valor em R1 
        LDR R2, [R0, #UART_FR]                          ; status da UART
        TST R2, #RXFF_BIT                               ; Verifica se o receptor 
        BEQ Le_serial
        LDR R1, [R0]                                    ; Le a resial e joga em R1
        BX LR

Escreve_serial:                                           ; Escreve na serial o valor contido em R1 
        LDR R2, [R0, #UART_FR]                          ; status da UART
        TST R2, #TXFE_BIT                               ; transmissor vazio?
        BEQ Escreve_serial
        
        STR R1, [R0]                                    ; escreve no registrador de dados da UART0 (transmite)
        BX LR

UART_enable:                                            ; habilita UART0
        PUSH {R0, R1}
        LDR R0, =SYSCTL_BASE                            ; carrega o valor de SYSCTL_BASE em R0
	LDR R1, [R0, #SYSCTL_RCGCUART]                  ; R1 = [R0 + #SYSCTL_RCGCUART]
	ORR R1, R2                                      ; R2 ou R1 e salva em R1
	STR R1, [R0, #SYSCTL_RCGCUART]                  ; [R0, #SYSCTL_RCGCUART] = R1

waitu	LDR R1, [R0, #SYSCTL_PRUART]                    ; R1 = [R0 + #SYSCTL_PRUART]
	TEQ R1, R2                                      ; Verifica se clock da UART0 está abilitado
	BNE waitu
        
return_UART_enable
        POP {R1}
        POP {R0}
        BX LR
        
UART_config:                                            ; Configuracao da UART
        PUSH {R1}
        LDR R1, [R2, #UART_CTL]                         ; R1 = [R0 + #SYSCTL_RCGCUART]
        BIC R1, #0x01                                   ; desabilita UART (bit UARTEN = 0)
        STR R1, [R2, #UART_CTL]                         ; [R2, #UART_CTL] = R1

        ; clock = 16MHz, baud rate = 9600 bps
        MOV R1, #104                                     ; R1 = #69
        STR R1, [R2, #UART_IBRD]                        ; [R2, #UART_IBRD] = R1
        MOV R1, #11                                     ; R1 = #29
        STR R1, [R2, #UART_FBRD]                        ; [R2, #UART_FBRD] = R1
        
        ; 8 bits, 1 stop, paridade impar
        MOV R1, #01100010b                            
        STR R1, [R2, #UART_LCRH]                        ; [R2 + #UART_LCRH] = R1
        
        ; clock source = system clock
        MOV R1, #0x00                                   ; R1 = #0x00   
        STR R1, [R2, #UART_CC]                          ; [R2 + #UART_CC] = R1
        
        LDR R1, [R2, #UART_CTL]                         ; R1 = [R2, #UART_CTL] 
        ORR R1, #0x01                                   ; R1 = R1 OU R0 -> habilita UART (bit UARTEN = 1)
        STR R1, [R2, #UART_CTL]                         ; [R2, #UART_CTL] = R1
        
        POP {R1}
        BX LR

GPIO_special:                                           ; Habilita a função especial do GPIO no registrador R0 
        PUSH {R2}
	LDR R2, [R0, #GPIO_AFSEL]                       ; R2 = [R0, #GPIO_AFSEL]
	ORR R2, R1                                      ; R2 = R2 ou R1            
	STR R2, [R0, #GPIO_AFSEL]                       ; [R0, #GPIO_AFSEL] = R2

	LDR R2, [R0, #GPIO_DEN]                         ; R2 = [R0, #GPIO_DEN]
	ORR R2, R1                                      ; R2 = R2 ou R1 
	STR R2, [R0, #GPIO_DEN]                         ; [R0, #GPIO_DEN] = R2

        POP {R2}
        BX LR

GPIO_select:                                            ; Seleciona a função especial do GPIO no registrador R0
        PUSH {R3}
	LDR R3, [R0, #GPIO_PCTL]
        BIC R3, R1
	ORR R3, R2 ; seleciona bits especiais
	STR R3, [R0, #GPIO_PCTL]
        POP {R3}
        BX LR

Enable_port:                                            ; habilita o GPIO da porta R0
        PUSH {R1, R2}
        LDR R2, =SYSCTL_RCGCGPIO_R                      ; carrega o valor de SYSCTL_RCGCGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor que R2 "aponta" em R1
        ORR R1, R0                                      ; operação de OU com R1 e R0
        STR R1, [R2]                                    ; carrega o valor de R1 em R2
check      
        LDR R2, =SYSCTL_PRGPIO_R                        ; carrega SYSCTL_PRGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor que R2 "aponta" em R1
        TST R1, R0                                      ; verifica se o clock esta ativo
        BEQ check                                       ; se ainda nao estiver ativo volta para check
return_Enable_port
        POP {R2}
        POP {R1}
        BX LR

Faz_num:                                            ; Recebe um numero base + um numero para colocar no final, salva em R6
        PUSH {R7, R8}
        MOV R8, #0x30
        MOV R7, #10
        MUL R6, R6, R7
        SUB R1, R1, R8
        ADD R6, R6, R1
        ADD R10, R10, #1
        POP {R7, R8}
        BX LR

Mostra_resultado:                                            ; Printa na serial o valor contido em R1
        PUSH {LR}
        PUSH {R7, R8}                                   ; Conserva os registradores

        MOV R7, #0xaa                                   ; Dado de stop para pilha
        PUSH {R7}                                       ; aplica na pilha o stop  
        MOV R7, #10

        CMP R11, #2                                     ; R11 == 2 -> Div por zero
        ITTT EQ
          MOVEQ R1, #69                                 ; Em hexa - 'E' (0x45) eh sem graça
          PUSHEQ {R1}
          BEQ Print_resultado

        CMP R11, #1                                     ; R11 == 1 -> numero negativo
        ITTTT EQ
          PUSHEQ {R1}
          MOVEQ R1, #45
          BLEQ Escreve_serial
          POPEQ {R1}

        CMP R1, #0                                      ; Se resultado igual a zero nao tem 
        ITTT EQ                                         ; pq decompor o numero
          ADDEQ R1, R1, #0x30
          PUSHEQ {R1}
          BEQ Print_resultado
          
Decomposicao:                                          ; Pega o resto da divisao por 10
        CMP R1, #0                                      ; e joga na pilha
        BEQ Print_resultado
        UDIV R8, R1, R7
        MUL R9, R8, R7 
        SUB R9, R1, R9
        ADD R9, R9, #0x30
        PUSH {R9}
        MOV R1, R8
        B Decomposicao
        
Print_resultado                                            ; Tira numero a numero da pilha
        POP {R1}                                        ; ate chegar no 0xaa e vai 
        CMP R1, #0xaa                                   ; mostrando na tela
        IT EQ
        BEQ Finaliza_demont_resultado
        BL Escreve_serial
        B Print_resultado
Finaliza_demont_resultado:
        POP {R7, R8}
        POP {PC}
        
Nova_linha:                   ;  Gera nova linha na serial
        PUSH {R1, LR}
        MOV R1, #10
        BL Escreve_serial
        MOV R1, #13
        BL Escreve_serial
        POP {R1, PC}
        
Reset_tudo:                   ; Reseta todas as variáveis do ambiente
       MOV R1, #0
       MOV R2, #0
       MOV R3, #0
       MOV R4, #0
       MOV R5, #0
       MOV R6, #0
       MOV R10, #0
       MOV R11, #0
       BX LR

valida_oper:                                ; valida operação
        CMP R1, #42                             ; Multiplicação
        IT EQ                                   
          MOVEQ R4, #1

        CMP R1, #43                             ; Soma
        IT EQ
          MOVEQ R4, #2
          
        CMP R1, #45                             ; Subtração
        IT EQ
          MOVEQ R4, #3
          
        CMP R1, #47                             ; Divisão
        IT EQ
          MOVEQ R4, #4
        BX LR

Calcula                                      ; calcula operação (R4) dos numeros nos registradores Re e R5
        PUSH {LR}

        MOV R1, #61
        BL Escreve_serial

        CMP R4, #1                             ; MULTIPICACAO
        IT EQ
          MULEQ R1, R3, R5

        CMP R4, #2                             ; SOMA
        IT EQ
          ADDEQ R1, R3, R5
          
        CMP R4, #3                             ; SUB
        IT EQ
          BLEQ Executa_sub

        CMP R4, #4                             ; DIV
        IT EQ
          BLEQ Executa_div

        BL Mostra_resultado

        POP {PC}   

Executa_sub:                                    ; Executa subtracao entre R3 e R5, salva em R1. Se negativo R11 = 1 
        SUBS R1, R3, R5
        ITTT MI
          MOVMI R11, #1
          MVNMI R1, R1
          ADDMI R1, R1, #1
        BX LR

Executa_div:                                    ; Executa divisao entre R3 e R5, salva em R1. Se invalida R11 = 2
        UDIV R1, R3, R5
        CMP R5, #0
        IT EQ
          MOVEQ R11, #2
        BX LR

NAN:                                            ; verifica se input é um numero 
        MOV R7, #0
        CMP R1, #0x30
        IT LO
          MOVLO R7, #1
        CMP R1, #0x39
        IT HI
          MOVHI R7, #1
        BX LR

        END