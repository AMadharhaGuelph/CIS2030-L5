*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
            ORG         $8000
**** Main Code ****
MAIN:       PEA         LIST                ;push pointer to list
            BSR         GET_DATA            ;get list input
            MOVE.L      D3,-(A7)            ;push size of list
            PEA         LIST                ;push pointer to list
            PEA         STRUCT              ;push pointer to struct
            BSR         STATISTICS          ;calculate min,max,average,remainder
            LEA         STRUCT,A1           ;initialize pointer to start of struct to push its elements to the stack
            MOVE.L      (A1)+,-(A7)         ;push min
            MOVE.L      (A1)+,-(A7)         ;push max
            MOVE.L      (A1)+,-(A7)         ;push quotient
            MOVE.L      (A1)+,-(A7)         ;push remainder
            BSR         DISPLAY             ;display all struct elements
            BRA         END

**** Subroutine: GET_DATA(*list) ****
GET_DATA    MOVEM.L     D0-D2/A1/A2,-(A7)   ;save working registers
            MOVEA.L     24(A7),A2           ;initialize pointer to list
ERR         LEA         MSG1,A1             ;point to MSG1
            MOVE.L      #14,D0              ;output mode
            TRAP        #15                 ;prompt user for number of values
            MOVE.L      #4,D0               ;input mode
            TRAP        #15                 ;input number of values into D1
            CMP         #10,D1              ;check if input is greater 10
            BGT         ERR                 ;loop
            CMP         #1,D1               ;check if input is less than 1
            BLT         ERR                 ;loop
            MOVE.L      D1,D2               ;move counter to D2 for future input
            MOVE.L      D1,D3               ;size of list returned in D3
INPUTLOOP   BEQ         EXIT                ;counter = 0? yes, then exit
            LEA         MSG2,A1             ;point to MSG2
            MOVE.L      #14,D0              ;output mode
            TRAP        #15                 ;prompt user for number
            MOVE.L      #4,D0               ;input mode
            TRAP        #15                 ;input number
            MOVE.L      D1,(A2)+            ;move number to list        
            SUB.B       #1,D2               ;decrement loop counter
            BRA         INPUTLOOP           ;loop         
EXIT        MOVEM.L     (A7)+,D0-D2/A1/A2   ;restore working registers   
            RTS                             ;return to calling code 

**** Subroutine: STATISTICS(int number, *list, *struct) ****
STATISTICS  MOVEM.L     D1-D5/A2,-(A7)      ;save working registers
            MOVEA.L     32(A7),A2           ;initialize pointer to list
            MOVEA.L     28(A7),A3           ;initalize pointer to struct
            MOVE.L      (A2),D1             ;store first element in list into D1
            MOVE.L      (A2),D2             ;store first element in list into D2
            MOVE.L      D3,D5               ;store total amount of elements into D5, turning D3 into a counter
            
LOOP        SUB.L       #1,D3               ;decrement counter 
            CMP         #-1,D3              ;compare counter
            BEQ         EXIT1               ;counter = 0? yes, then exit
            MOVE.L      (A2)+,D0            ;store current item
            ADD.L       D0,D4               ;add to total sum
            CMP         D0,D1               ;compare current item with current min
            BLT         GREATER             ;if current item is greater than current min, go to greater
LESSER      MOVE.L      D0,D1               ;otherwise, update current min to current item           
            BRA         LOOP                ;loop
            
GREATER     CMP         D0,D2               ;compare current item with current max
            BGE         LOOP                ;if current item is less than or equal to current max, loop
            MOVE.L      D0,D2               ;otherwise, update current max
            BRA         LOOP                ;loop         
                       
EXIT1       MOVE.L      D1,(A3)+            ;move min to struct
            MOVE.L      D2,(A3)+            ;move max to struct
            DIVS        D5,D4               ;sum/totalElements -> D4
            MOVE.W      #0,(A3)+            ;add buffer zeros
            MOVE.W      D4,(A3)+            ;move quotient to struct
            SWAP        D4                  ;swap remainder into the lower bits
            MOVE.W      #0,(A3)+            ;add buffer zeros
            MOVE.W      D4,(A3)+            ;move remainder to struct
            MOVEM.L     (A7)+,D1-D5/A2      ;restore working registers
            RTS
            
     
**** Subroutine: DISPLAY(int max, int min, int quotient, int remainder) ****
DISPLAY     MOVEM.L     D0-D1/A1,-(A7)      ;save working register(s)
            MOVE.L      #14,D0              ;output mode
            LEA         MSG3,A1             ;point to msg 3    
            TRAP        #15                 ;output minimum
            
            MOVE.L      #3,D0               ;output single signed value mode
            MOVE.L      28(A7),D1           ;store min in D1
            TRAP        #15                 ;output min value
            
            MOVE.L      #14,D0              ;change output mode
            LEA         NEWLINE,A1          ;point to newline
            TRAP        #15                 ;output newline
            
            LEA         MSG4,A1             ;point to msg 4
            MOVE.L      #14,D0              ;null character ended ouput mode
            TRAP        #15                 ;output maximum
            
            MOVE.L      #3,D0               ;change single signed value mode
            MOVE.L      24(A7),D1           ;store max in D1
            TRAP        #15                 ;output maximum value
            
            MOVE.L      #14,D0              ;change output mode
            LEA         NEWLINE,A1          ;point to newline
            TRAP        #15                 ;output newline
            
            MOVE.L      #14,D0              ;change output mode
            LEA         MSG5,A1             ;point to msg 5
            TRAP        #15                 ;output average
            MOVE.L      #3,D0               ;change output mode
            MOVE.L      20(A7),D1           ;move average to D1
            TRAP        #15                 ;ouput average value
            
            CLR.L       D1                  ;clear D1
            MOVE.L      #6,D0               ;change output mode
            MOVE.B      #32,D1              ;move a space to D1
            TRAP        #15                 ;output space
            
            MOVE.L      #3,D0               ;change output mode
            CLR.L       D1                  ;clear D1
            MOVE.L      16(A7),D1           ;move remainder to D1
            TRAP        #15                 ;output remainder
            
            CLR.L       D1                  ;clear D1
            MOVE.L      #6,D0               ;change output mode
            MOVE.B      #47,D1              ;move / to D1
            TRAP        #15                 ;ouput /
            
            CLR.L       D1                  ;clear D1
            MOVE.L      #3,D0               ;change output mode
            MOVE.L      D3,D1               ;move D3 to D1 (total amount of elements)
            TRAP        #15                 ;output total elements
            
            MOVEM.L     (A7)+,D0-D1/A1      ;restore working registers
            RTS

**** END ****
END         SIMHALT          

**** Variables and Constants ****
            ORG         $9000
LIST        DS.L        10
STRUCT      DS.L        4
MSG1        DC.B        'Enter number of values in list (1-10): ',0
MSG2        DC.B        'Enter number: ',0
MSG3        DC.B        'Minimum = ',0
MSG4        DC.B        'Maximum = ',0
MSG5        DC.B        'Average = ',0
NEWLINE     DC.B        '',CR,LF,0

CR          EQU         $0D
LF          EQU         $0A
            END         MAIN      



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
