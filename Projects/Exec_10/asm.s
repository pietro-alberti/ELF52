        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
main     
        MOV R0, #5              ; Atribui R0        
        MOV R1, #4              ; Atribui R1
        PUSH {R1, R3, R4}       ; Adiciona R1, bem como os registradores auxialiares na pilha 
        
        BL Mul16b               ; Começa sub-rotina
        POP {R1, R3, R4}        ; Retorna os valores originais dos registradores R3 e R4
        B Stop
        
Mul16b:
        MOV R2, R0              ; Atribui R0 a R2
loop_Mul16b                     ; Abre loop do Multiplicador (Somará R0 a R2 n(número de vezes que R1 for maior que 0) vezes)
        CMP R1, #0              ; Verifica se R1 é maior que 0
        BEQ end_Mul16b          ; Caso R1 seja igual a 0 (Z=1) termina o Loop
        LSRS R1, R1, #1         ; Desloca R1 1 bit a direita e adciona a flag C
        ITT CS                  ; Caso a flag C = 1 
          LSLCS R4, R0, R3      ; Move/adiciona R0 a potência R3 em R4 (aux)
          ADDCS R2, R2, R4      ; Adiciona R4 (aux) a R2 
        ADD R3, R3, #1          ; AUmenta o valor do expoente
        B loop_Mul16b
end_Mul16b
        SUBS R2, R0             ; Subtrai R0 de R2 para corrigir o valor no loop
        BX LR
        
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
