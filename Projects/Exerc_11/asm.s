        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
main    
        MOV R0, #13             ; Atribui R0
        BL Fatorial             
        B Stop
        
Fatorial
        PUSH {R1, R3}           ; Adiciona registradores auxiliares na pilha
        MOV R1, R0              ; Atribui R0 a R1 (aux)
        CMP R1, #0              ; Compara se R1 é 0 afim de se evitar o caso de 0!
        ITTT EQ                  ; Caso 0 retorna 1 (0! = 1)
          MOVEQ R0, #1
          POPEQ {R1, R3}
          BXEQ LR
        SUB R1, #1              ; Atribui a R1 o proximo valor a ser multiplicado pelo fatorial (R0 - 1)

loop_Fatorial
        CMP R1, #1              ; Verifica se é o último valor (1) a ser multiplicado no loop do fatorial 
        ITT EQ                  ; Caso seja o ultimo, encerra o loop
          POPEQ {R1, R3}
          BXEQ LR
        MULS R0, R1             ; Multiplica fatorial pelo seu proximo valor  (R0:=R0*R1  =>  R0:=R0*(R0 - 1))
        ADDS R3, R0, R0         ; Examina o valor atual em R0 multiplicado em 2 (menor valor possível a ser multiplicado na fatoração a excessão de 1)
        ITTT VS                 ; Caso ocorra overflow, impossibilita a atribuição correta de valores em R0
          MOVVS R0, #-1         ; Atribui R0:=-1 pois estoura o limite de 32 bits e encerra o loop
          POPVS {R1, R3}
          BXVS LR
        SUB R1, #1              ; Atribui a R1 o próximo valor a ser multiplicado pelo fatorial (R0 - 1)
        B loop_Fatorial
Stop
        B Stop

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
