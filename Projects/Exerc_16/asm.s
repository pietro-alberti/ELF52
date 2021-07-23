        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTN_BIT               EQU     1000000000000b ; bit 12 = Port N

GPIO_PORTN_DATA_R    	EQU     0x400643FC
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C
        
__iar_program_start
        
main    MOV R2, #PORTN_BIT                       ; Atribui R2 porta N
	LDR R0, =SYSCTL_RCGCGPIO_R               ; ENdere�o de memoria do SYSCTL_RCGCGPIO_R
	LDR R1, [R0]                             ; leitura do estado anterior
	ORR R1, R2                               ; Habilita porta N
	STR R1, [R0]                             ; Atribui��o do novo estado
        LDR R0, =SYSCTL_PRGPIO_R                 ; ENdere�o de memoria do SYSCTL_RCGCGPIO_R
Aguarda	LDR R2, [R0]                             ; leitura do estado atual
	TEQ R1, R2                               ; IF porta N habilitado
	BNE Aguarda                              ; caso negativo, aguarda

        MOV R2, #00000001b                       ; Atribui R2 o bit 0
        
	LDR R0, =GPIO_PORTN_DIR_R                 ; ENdere�o de memoria do GPIO_PORTN_DIR_R
	LDR R1, [R0]                              ; leitura do estado anterior
	ORR R1, R2                                ; OU de R1 e R2 (bit de sa�da)
	STR R1, [R0]                              ;  Atribui��o do novo estado

	LDR R0, =GPIO_PORTN_DEN_R                 ; ENdere�o de memoria do GPIO_PORTN_DEN_R
	LDR R1, [R0]                              ; leitura do estado anterior
	ORR R1, R2                                ; Habilita digital
	STR R1, [R0]                              ; Atribui��o do novo estado

        MOV R1, #000000001b                       ; Atribui a R1 o estado inicial
 	LDR R0, = GPIO_PORTN_DATA_R               ; ENdere�o de memoria do GPIO_PORTN_DATA_R
        MOV R2, #0x3FC

loop	
        LDR R3, [R0]                              ; Estado inciapl da porta N
        EOR R3, R1                                ; Altera o bit da saida do led
        STR R3, [R0]                              ; Salva a altera��o a porta
        
        MOVT R3, #0x001F                          ; Constante
Atraso  CBZ R3, Fim                            
        SUB R3, R3, #1                            
        B Atraso                                  
Fim  
        B loop

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
