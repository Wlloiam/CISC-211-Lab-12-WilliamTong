/*** asmSort.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data
.align    

@ Define the globals so that the C code can access them

.if 0    
@ left these in as an example. Not used.
.global fMax
.type fMax,%gnu_unique_object
 fMax: .word 0
.endif 

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word dize)
    
    If v1 or v2 is 0, this function immediately
    places 0 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11,LR}
    mov r4,r0
    mov r5,r1
    mov r6,r2
    
    cmp r6,1
    beq element_size_1
    cmp r6,2
    beq element_size_2
    b	element_size_4
    
    element_size_1:
    ldrb r7,[r4]
    ldrb r8,[r4,4]
    cmp r7,0
    beq zero_element_size_1
    cmp r8,0
    beq zero_element_size_1
    cmp r5,0
    beq unsigned_case1
    b   sigened_case1
    unsigned_case1:
    cmp r7,r8
    beq equal_size1
    bhi greater_size1
    bls lower_size1
    
    sigened_case1:
    ldr r11,=0xFFFFFF00
    mov r9,r7
    mov r10,r8
    lsls r9,r9,24
    lsr r9,r9,24
    orrmi r9,r9,r11
    lsls r10,r10,24
    lsr r10,r10,24
    orrmi r10,r10,r11
    cmp r9,r10
    beq equal_size1
    bge greater_size1
    blt lower_size1
    
    zero_element_size_1:
    mov r0,-1
    b done
    
    equal_size1:
    mov r0,0
    b done
    
    greater_size1:
    strb r8,[r4]
    strb r7,[r4,4]
    mov r0,1
    b done
    mov r0,0
    b done
    
    lower_size1:
    mov r0,0
    b done
    
    element_size_2:
    ldrh r7,[r4]
    ldrh r8,[r4,4]
    cmp r7,0
    beq zero_element_size_2
    cmp r8,0
    beq zero_element_size_2
    
    cmp r5,0
    beq unsigned_case2
    b   sigened_case2
    
    unsigned_case2:
    cmp r7,r8
    beq equal_size2
    bhi greater_size2
    bls lower_size2
    
    sigened_case2:
    ldr r11,=0xFFFF0000
    mov r9,r7
    mov r10,r8
    lsls r9,r9,16
    lsr r9,r9,16
    orrmi r9,r9,r11
    lsls r10,r10,16
    lsr r10,r10,16
    orrmi r10,r10,r11
    cmp r9,r10
    beq equal_size2
    bge greater_size2
    blt lower_size2
    
    zero_element_size_2:
    mov r0,-1
    b done
    
    equal_size2:
    mov r0,0
    b done
    
    greater_size2:
    strh r8,[r4]
    strh r7,[r4,4]
    mov r0,1
    b done
    mov r0,0
    b done
    
    lower_size2:
    mov r0,0
    b done
    
    element_size_4:
    ldr r7,[r4]
    ldr r8,[r4,4]
    
    cmp r7,0
    beq zero_element_size_4
    cmp r8,0
    beq zero_element_size_4
    
    cmp r5,0
    beq unsigned_case4
    b   sigened_case4
    
    unsigned_case4:
    cmp r7,r8
    beq equal_size4
    bhi greater_size4
    bls lower_size4
    
    sigened_case4:
    cmp r7,r8
    beq equal_size4
    bge greater_size4
    blt lower_size4
    
    zero_element_size_4:
    mov r0,-1
    b done
    
    equal_size4:
    mov r0,0
    b done
    
    greater_size4:
    str r8,[r4]
    str r7,[r4,4]
    mov r0,1
    b done
    
    lower_size4:
    mov r0,0
    b done
    
    done:
    
    pop {r4-r11,LR}
    bx LR

    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* Note to Profs: 
     */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11,LR}
    
    mov r4,r0	/*for manipulation*/
    mov r9,r0	/**for repeat*/
    mov r10,0
    mov r11,0
    
    sorting:
    mov r0,r4
    BL asmSwap
    cmp r0,-1
    beq check_repeat_or_not
    add r10,r10,r0
    add r11,r11,r0
    add r4,r4,4
    b	sorting
    
    check_repeat_or_not:
    cmp r11,0
    beq done_for_asmSort
    mov r4,r9
    mov  r11,0
    b	sorting
    
    done_for_asmSort:
    mov r0,r10
    
    pop {r4-r11,LR}
    bx LR
    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




