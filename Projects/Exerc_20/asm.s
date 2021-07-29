        PUBLIC  __iar_program_start
        PUBLIC  GPIOJ_Handler
        EXTERN  __vector_table

        SECTION .text:CODE:REORDER
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB


SYSCTL_RCGCGPIO_R       EQU     0x400FE608              ; Inicializa clock
SYSCTL_PRGPIO_R         EQU     0x400FEA08              ; Indicador do GPIO caso esteja  pronto para uso
PORTF_BIT               EQU     0000000000100000b       ; 5 bits na porta f 
PORTJ_BIT               EQU     0000000100000000b       ; 8 bits na porta j
PORTN_BIT               EQU     0001000000000000b       ; 8 bits na porta n
GPIO_PORTF_BASE    	EQU     0x4005D000
GPIO_PORTJ_BASE    	EQU     0x40060000
GPIO_PORTN_BASE    	EQU     0x40064000
GPIO_DIR                EQU     0x0400                  
GPIO_PUR                EQU     0x0510  
GPIO_DEN                EQU     0x051C                  ;funcao digital
GPIO_ICR                EQU     0x041C                  ; ACK interrupcao 
GPIO_IS                 EQU     0x0404                  
GPIO_IBE                EQU     0x0408                  
GPIO_IEV                EQU     0x040C                  
GPIO_IM                 EQU     0x0410                  ; habilitar interrupcao
GPIO_RIS                EQU     0x0414                  ; indica se houve condicoes para interrup. mesmo sem GPIO_IM 
GPIO_MIS                EQU     0x0418                  ; indica se houve cond para ativar interrup. e a mesma esta declarada em GPIO_IM
NVIC_BASE               EQU     0xE000E000
NVIC_EN1                EQU     0x0104
NVIC_UNPEND1            EQU     0x0284
NVIC_PRI12              EQU     0x0430
LEDN_1                  EQU     00010b
LEDN_2                  EQU     00001b
LEDF_2                  EQU     00001b
LEDF_1                  EQU     10000b
DELAY                   EQU     0x005F

GPIOJ_Handler:                                          ; Interrupacao da porta J
        PUSH {R3}                                       ; Adciona R3 (AUX) na fila

        MOV R0, #00000011b
        LDR R1, =GPIO_PORTJ_BASE
        STR R0, [R1, #GPIO_ICR]

        LDR R3, [R1, #GPIO_MIS]                         
        CMP R3, #0001b                                  ; compara interrupção foi pelo 01b
        IT EQ
          ADDEQ R11, R11, #1

        CMP R3, #0010b                                  ; compara interrupção foi pelo 10b
        IT EQ
          SUBEQ R11, R11, #1
          
        POP {R3}                                        ; restaura valor incial de R3
        BX LR

__iar_program_start
        
;; main program begins here
main    MOV R0, #(PORTN_BIT)                              ; Atribui a R0 endereço da porta N
        BL HabilitaPorta                                  ; habilita a porta n

        MOV R0, #(PORTF_BIT)                              ; Atribui a R0 endereço da porta F
        BL HabilitaPorta                                  ; habilita a portra f

        MOV R0, #(PORTJ_BIT)                              ; Atribui a R0 endereço da porta J
        BL HabilitaPorta                                  ; habilita a porta j

        LDR R0, =GPIO_PORTN_BASE                        ; Endereço de memoria base da porta N
        MOV R1, #000000011b                             ; bits a seram habilitados da porta N    
        BL HabilitaGPIO_saida                           ; habilita os bits 0 e 1 da porta N
        BL Digital_Escreve_low

        LDR R0, =GPIO_PORTF_BASE                        ; Endereço de memoria base da porta J
        MOV R1, #000010001b                             ; bits a seram habilitados da porta J    
        BL HabilitaGPIO_saida                           ; habilita os bits 0 e 4 da porta J
        BL Digital_Escreve_low

        LDR R0, =GPIO_PORTJ_BASE                        ; Endereço de memoria base da porta J
        MOV R1, #000000011b                             ; bits a seram habilitados da porta J    
        BL HabilitaDig_entrada                         ; habilita os bits 0 e 4 da porta J
        BL Digital_Escreve_low
        
        BL Botao_config
      
        MOV R3, #0                                      ; Variavel usada como contador

loop:   
        MOV R3, R11
        BL Led_binario
        B loop

Led_binario:
        ;; Liga os leds no valor binario da porta n
        PUSH {LR, R2, R4}
        AND R2, R3, #0011b
        LSR R4, R2, #1
        LSL R2, R2, #1
        ADD R2, R4
        LDR R0, =GPIO_PORTN_BASE
        MOV R1, #000000011b
        BL Digital_Escreve
        ;; Liga os leds no valor binario na porta F
        AND R4, R3, #0100b
        LSL R2, R4, #2
        AND R4, R3, #1000b
        LSR R4, R4, #3
        ADD R2, R4
        
        LDR R0, =GPIO_PORTF_BASE
        MOV R1, #000010001b
        BL Digital_Escreve
        POP {R4, R2}
        BL Atraso
        POP {LR}
        BX LR

HabilitaPorta:                                          ; Habilita o GPIO da porta R0 
        LDR R2, =SYSCTL_RCGCGPIO_R                      ; carrega o valor de SYSCTL_RCGCGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor que R2 "aponta" em R1
        ORR R1, R0                                      ; OU com R1 e R0
        STR R1, [R2]                                    ; R1 recebe R2
checagem                                                
        LDR R2, =SYSCTL_PRGPIO_R                        ; carrega SYSCTL_PRGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor de R1 apontado em R2  
        TST R1, R0                                      ; verifica se o clock esta ativo
        BEQ checagem                                    ; caso inativo volta para a checagem
        BX LR                                           

HabilitaGPIO_saida:
        LDR R2, [R0, #GPIO_DIR]                         
        ORR R2, R1                                      
        STR R2, [R0, #GPIO_DIR]                         
        
        LDR R2, [R0, #GPIO_DEN]                         
        ORR R2, R1                                      
        STR R2, [R0, #GPIO_DEN]                          
        
        BX LR


HabilitaDig_entrada:                                    ; Habilita o GPIO na porta R0
        LDR R2, [R0, #GPIO_DIR]                         
	BIC R2, R1                                      ; Configura bits de entrada
	STR R2, [R0, #GPIO_DIR]                         
                                                        
	LDR R2, [R0, #GPIO_DEN]                         
	ORR R2, R1                                      ; Declara função como digital
	STR R2, [R0, #GPIO_DEN]                         
                                                        
	LDR R2, [R0, #GPIO_PUR]                         
	ORR R2, R1                                      ; "Ativa" resitor de pull-up
	STR R2, [R0, #GPIO_PUR]
        
        BX LR

Digital_Leitura:                                         ; Lê porta R2
        LDR  R2, [R0, R1, LSL #2]
        BX LR

Digital_Escreve:                                        ; Escreve a saida digital na porta R0
        STR R2, [R0, R1, LSL #2]
        BX LR

Digital_Escreve_low:                                     ; Escreve 0 em todos os bits da porta R0
        PUSH {R2}
        MOV R2, #000000000b
        STR R2, [R0, R1, LSL #2]
        POP {R2}
        BX LR
        
Atraso:                                                  ; Diminui o valor contido em R0 (Tempo de delay) 
        PUSH {R0}
        MOVT R0, #(DELAY)
Atraso_loop
        CBZ R0, Termina_atraso
        SUB R0, R0, #1
        B Atraso_loop
Termina_atraso:
        POP {R0}
        BX LR
        
Botao_config:
        MOV R2, #000000011b ; bit do PJ0
        LDR R1, =GPIO_PORTJ_BASE
        
        LDR R0, [R1, #GPIO_IM]
        BIC R0, R0, R2                   ; desabilita interruptor.
        STR R0, [R1, #GPIO_IM]
        
        LDR R0, [R1, #GPIO_IS]
        BIC R0, R0, R2                   ; interrupcao por transicao
        STR R0, [R1, #GPIO_IS]
        
        LDR R0, [R1, #GPIO_IBE]
        BIC R0, R0, R2                    ; uma transição 
        STR R0, [R1, #GPIO_IBE]
        
        LDR R0, [R1, #GPIO_IEV]
        BIC R0, R0, R2                    ; transição de descida
        STR R0, [R1, #GPIO_IEV]
        
        LDR R0, [R1, #GPIO_ICR]
        ORR R0, R0, R2                    ; limpa
        STR R0, [R1, #GPIO_ICR]
        
        LDR R0, [R1, #GPIO_IM]
        ORR R0, R0, R2                    ; habilita interrupções na porta GPIOJ
        STR R0, [R1, #GPIO_IM]

        MOV R2, #0xE0000000               ; atribui a R2 a prioridade mais baixa para a IRQ51
        LDR R1, =NVIC_BASE
        
        LDR R0, [R1, #NVIC_PRI12]
        ORR R0, R0, R2                    ; prioridade da IRQ51 no NVIC
        STR R0, [R1, #NVIC_PRI12]

        MOV R2, #10000000000000000000b    ; IRQ51 no bit 19 
        MOV R0, R2                        ; limpa NVIC
        STR R0, [R1, #NVIC_UNPEND1]

        LDR R0, [R1, #NVIC_EN1]
        ORR R0, R0, R2                    ; habilita IRQ51
        STR R0, [R1, #NVIC_EN1]
        
        BX LR
        
        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA



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