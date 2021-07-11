# ELF52
Repositório de disciplina de sistemas microcontrolados.

# Laboratório 1

Durante a execução e simulação, do exemplo 3 do primeiro laboratório, foi possível realizar algumas observações para cada linha de comando.

**OBSERVAÇÕES**

 - MOV R0, #0x55
	 > Atribui o valor 0x55(0000,0055) na variável R0. 
 - MOV R1, R0, LSL #16
	  > Move logicamente 16 bits para a esquerda no R0 (0000,0055), e em seguida atribui R0 a R1 (0055,0000).
 - MOV R2, R1, LSR #8 
	> Move logicamente 8 bits do R1 (0055,0000) para a direita e em seguida atribui em R2 (0000,5500).
 - MOV R3, R2, ASR #4 
	 >Move aritmeticamente 4 bits do R2 (0000,0550) para a direita e em seguida atribui a R3 (0000,0550).
 - MOV R4, R3, ROR #2 
	 >Circula 2 bits de R3 (0000,0550) a direita e afeta a flag c quando usada s (0000,0154). 
 - MOV R5, R4, RRX 
	 >Circula 1 bit de R4 (0000,0154) a direita só que toda bit a direita gera flag c (0000,00aa) .  

 - MVN R0, #0x55 
	 >Atribui o valor 0x55(0000,0055) na variável R0 e depois realiza função not deixando, atribuido R0 o seu oposto (not) (ffff,ffaa).     
 - MVN R1, R0, LSL #16
	 >Move logicamente 0x55 16 bits para a esquerda no R0 (ffff,ffaa) e em seguida atribui R0 a R1 o seu oposto (not) (0055,ffff).
 - MVN R2, R1, LSR #8
	 >Move logicamente 0x55 8 bits do R1 (0055,ffff) para a direita e em seguida atribui em R2 o seu oposto (not) (ffff,aa00). 
 - MVN R3, R2, ASR #4
	 >Move aritmeticamente 0x55 4 bits do R2 (ffff,aa00) para a direita e em seguida atribui a R3 o seu oposto (not) (0000,055f). 
 - MVN R4, R3, ROR #2 
	 >Circula 2 bits de R3 (0000,055f) a direita, e afeta a flag c quando usada s, e atribui a R4 o seu oposto (not) (3fff,fea8).
 - MVN R5, R4, RRX 
	 >Circula 1 bit de R4 (3fff,fea8) a direita, só que toda bit a direita, gera flag c, e atribui a R5 o seu oposto (not) (e0000,00ab).   
