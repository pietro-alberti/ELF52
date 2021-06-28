        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
main    MOV R0, #0x55       ;; atribui o valor 0x55(0000,0055) na variável R0
        MOV R1, R0, LSL #16 ;; move logicamente 0x55 16 bits para a esquerda no R0 (0055,0000) e em seguida atribui R0 a R1
        MOV R2, R1, LSR #8  ;; move logicamente 0x55 8 bits do R1 para a direita (0000,5500) e em seguida atribui em R2
        MOV R3, R2, ASR #4  ;; move aritmeticamente 0x55 4 bits do R2 para a direita (0000,0550) e em seguida atribui a R3
        MOV R4, R3, ROR #2  ;; circula 2 bytes de R3 a direita e afeta a flag c quando usada s
        MOV R5, R4, RRX     ;; circula 1 bit de R4 a direita só que toda bit a direita gera flag c
        
        MVN R0, #0x55        ;; atribui o valor 0x55(0000,0055) na variável R0 e depois realiza função not deixando, atribuido R0 o seu oposto (not)
        MVN R1, R0, LSL #16  ;; move logicamente 0x55 16 bits para a esquerda no R0 (0055,0000) e em seguida atribui R0 a R1 o seu oposto (not)
        MVN R2, R1, LSR #8   ;; move logicamente 0x55 8 bits do R1 para a direita (0000,5500) e em seguida atribui em R2 o seu oposto (not)
        MVN R3, R2, ASR #4   ;; move aritmeticamente 0x55 4 bits do R2 para a direita (0000,0550) e em seguida atribui a R3 o seu oposto (not)
        MVN R4, R3, ROR #2   ;; circula 2 bytes de R3 a direita, e afeta a flag c quando usada s, e atribui a R4 o seu oposto (not)
        MVN R5, R4, RRX      ;; circula 1 bit de R4 a direita, só que toda bit a direita gera flag c, e atribui a R5 o seu oposto (not)

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
