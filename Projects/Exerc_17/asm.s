        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
SYSCTL_RCGCGPIO_R       EQU     0x400FE608              ; Inicializa clock
SYSCTL_PRGPIO_R         EQU     0x400FEA08              ; Indicador do GPIO caso esteja  pronto para uso
PORTF_BIT               EQU     0000000000100000b       ; 5 bits na porta f 
PORTJ_BIT               EQU     0000000100000000b       ; 8 bits na porta j 
PORTN_BIT               EQU     0001000000000000b       ; 8 bits na porta n 
GPIO_PORTF_BASE         EQU     0x4005D000
GPIO_PORTJ_BASE         EQU     0x40060000
GPIO_PORTN_BASE         EQU     0x40064000
GPIO_DIR                EQU     0x0400          
GPIO_PUR                EQU     0x0510  
GPIO_DEN                EQU     0x051C                  ;funcao digital
LEDN_1                  EQU     00010b                  ; Bit para controle do led
LEDN_2                  EQU     00001b                  ; Bit para controle do led
LEDF_2                  EQU     00001b                  ; Bit para controle do led
LEDF_1                  EQU     10000b                  ; Bit para controle do led
DELAY                   EQU     0x005F                  ; Tempo do delay
        
__iar_program_start
        
main    MOV R0, #(PORTN_BIT)              ; Atribui a R0 endereço da porta N
        BL HabilitaPorta                  ; habilita a porta N

        MOV R0, #(PORTJ_BIT)              ;Atribui a R0 endereço da porta J
        BL HabilitaPorta                  ; habilita a porta J

        LDR R0, =GPIO_PORTN_BASE        ; Endereço de memoria base da porta N
        MOV R1, #000000011b             ; Atribui a R0 os bits a seram habilitados da porta N    
        BL HabilitaGPIO_saida           ; habilita os bits 0 e 1 da porta N
        BL Digital_Escreve_low

        LDR R0, =GPIO_PORTF_BASE        ; Endereço de memoria base da porta J
        MOV R1, #000010001b             ; bits a seram habilitados da porta J    
        BL HabilitaGPIO_saida           ; habilita os bits 0 e 4 da porta J
        BL Digital_Escreve_low
        
        MOV R3, #0b
loop:   
        
        ADD R3, R3, #1
        Bl Led_binario
        B loop

HabilitaPorta:                          ; Habilita o GPIO da porta R0 
        LDR R2, =SYSCTL_RCGCGPIO_R      ; carrega o valor de SYSCTL_RCGCGPIO_R em R2
        LDR R1, [R2]                    ; carrega o valor que R2 "aponta" em R1
        ORR R1, R0                      ; OU com R1 e R0
        STR R1, [R2]                    ; R1 recebe R2
checagem      
        LDR R2, =SYSCTL_PRGPIO_R        ; carrega SYSCTL_PRGPIO_R em R2
        LDR R1, [R2]                    ; carrega o valor de R1 apontado em R2  
        TST R1, R0                      ; verifica se o clock esta ativo
        BEQ checagem                    ; caso inativo volta para a checagem
        BX LR                           

HabilitaGPIO_saida:                     ; Habilita o GPIO da porta em R0
        LDR R2, [R0, #GPIO_DIR]         ; R2 recebe R0 + #GPIO_DIR
        ORR R2, R1                      ; OU com R1 e R2
        STR R2, [R0, #GPIO_DIR]         ; (R0 + #GPIO_DIR) = R2 
        LDR R2, [R0, #GPIO_DEN]         ; R2 = [R0 + #GPIO_DEN]
        ORR R2, R1                      ; R2 ou R1 e salva em R2
        STR R2, [R0, #GPIO_DEN]         ; [R0 + #GP IO_DEN] = R2                
        BX LR

Digital_Escreve:                        ; Escreve a saida digital na porta R0
        STR R2, [R0, R1, LSL #2]
        BX LR
        
Digital_Escreve_low:                     ; Escreve 0 em todos os bits da porta R0
        PUSH {R2}
        MOV R2, #000000000b
        STR R2, [R0, R1, LSL #2]
        POP {R2}
        BX LR

Atraso:                               ; Diminui o valor contido em R0 (Tempo de delay) 
        PUSH {R0}
        MOVT R0, #(DELAY)
Atraso_loop
        CBZ R0, Termina_delay
        SUB R0, R0, #1
        B Atraso_loop
Termina_delay:
        POP {R0}
        BX LR
        
Led_binario:
        ;; Liga os leds no valor binario na porta N
        PUSH {LR, R2, R4}        
        AND R2, R3, #0011b
        LSR R4, R2, #1
        LSL R2, R2, #1
        ADD R2, R4
        LDR R0, =GPIO_PORTN_BASE
        MOV R1, #000000011b
        BL Digital_Escreve
        
        ;; Liga os leds no valor binariona porta F
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
