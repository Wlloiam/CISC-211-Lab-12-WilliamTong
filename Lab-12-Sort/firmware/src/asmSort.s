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
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /**storing inputs r0,r1,r2 in r4,r5,r6**/
    mov r4,r0	/*storing the input r0, Address of v1 to be examined, in r4*/
    mov r5,r1	/*storing the input r1, signed, in r5*/
    mov r6,r2	/*storing the input r2, size: number of bytes for each input value, in r6*/
    /**This part is to check whether the size of the input value is 1,2, or 4**/
    cmp r6,1	/*compare r6 with 1 to know the size of the input*/
    beq element_size_1	/*if r6 equals to 1, the size of the input number is 1, so direct to the element_size_1 branch*/
    cmp r6,2	/*if not equals, compare r6 with 2 again, to know the size of the input*/
    beq element_size_2	/*if r6 equals to 2, the size of the input number is 2, so direct to the element_size_2 branch*/
    b	element_size_4	/*if r6 does not equal to 1, or 2, then the size of the input number is 4, so direct to the element_size_4 branch*/
    /**This is for the number which size is only 1**/
    element_size_1: 
    ldrb r7,[r4]    /*storing LSB 8 bits, which is located at the address determined by r4, in r7*/
    ldrb r8,[r4,4]  /*storing LSB 8 bits, which is located at the address determined by r4 + M4 word size, in r8*/
    cmp r7,0	    /*compare r7 with 0*/
    beq zero_element_size_1 /*if r7 is 0, direct to the zero_element_size_1 branch*/
    cmp r8,0	    /*if not, compare r8 with 0 again*/ 
    beq zero_element_size_1 /*if r8 is 0, direct to the zero_element_size_1 branch*/
    /*if both r7 and r8 is not 0, check the case is signed cased or unsigned case*/
    cmp r5,0	    /*check r5, which indicates sign case or not, with 0*/
    beq unsigned_case1	/*if r5 equals to 0, then the case is unsigned case, and direct to the unsigned_case1 branch*/
    b   sigened_case1	/* if not, the case is signed case, and direcr to the signed_case1 branch*/
    /*This is for the number which size is 1, and which case is unsigned case*/
    unsigned_case1:
    cmp r7,r8	    /*compare r7 and r8 to know which number is higher*/
    beq equal_size1 /*if they are equal, then driect to the equal_size1 branch*/
    bhi greater_size1	/*if r7 is greater than the r8, we need to swap the number, so direct to the greater_size1 branch*/
    bls lower_size1 /*if r7 is lower than the r8, direct to the lower_size1 branch*/
    /*This is for the number which size is 1, and which case is signed case*/
    sigened_case1:
    
    ldr r11,=0xFFFFFF00	/*storing 0xFFFFFF00, which will be used to get a negative sign, in r11*/
    mov r9,r7	/*storing r7 in r9*/
    mov r10,r8	/*storing r8 in r10*/
    
    lsls r9,r9,24   /*shifting r9 left to the 24 bits, store the result in r9, and then update the flags*/
    lsr r9,r9,24    /*shifting r9 right to 24 bits back, and store it the result r9*/
    orrmi r9,r9,r11 /*if the negative flag is set, use orr operation(r9 or r11), then store the result in r9*/
    
    lsls r10,r10,24 /*shifting r10 left to the 24 bits, store the result in r9, and then update the flags*/
    lsr r10,r10,24  /*shifting r10 right to the 24 bits back, and store the result in r10*/
    orrmi r10,r10,r11	/*if the negative flag is set, use orr operation(r10 or r11), then store the result in r10*/
    /*Here we only compare r9 and r10 not r7 and r8, since r9 represents r7, and r10 represents r8*/
    cmp r9,r10	/*compare r9 with r10 to know which number is greater*/
    beq equal_size1 /*if they are equal, direct to the equal_size1 branch*/
    bge greater_size1	/*if r9 is greater than r10, then need to swap the numbers, so direct to the greater_size1 branch*/
    blt lower_size1 /*if r9 is lower than r10, then direct to the lower_size1*/
    
    /*This is for the case, when the number size is 1, and the number is 0. In this case we don't need to swap the numbers,
    store -1 in r0*/
    zero_element_size_1:
    mov r0,-1	/*storing -1 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 1, and both numbers are equal. In this case, do not need to swap the numbers,
    store 0 in r0*/
    equal_size1:
    mov r0,0	/*storing 0 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 1, and r7 is greater than r8. In this case we need to swap the number. Since the
    size is 1, only swap the LSB 8 bits of each one, others are ignored. store 1 in r0*/
    greater_size1:
    strb r8,[r4]    /*storing a byte from r8 to the memory address pointed to by r4*/
    strb r7,[r4,4]  /*storing a byte from register r7 to the memory address pointed to by r4  + M4 word size*/
    mov r0,1	/*storing 1 in r0*/
    b done	/*directing to the done branch*/
    /*This is for the case when the number size is 1, and r7 is lower than r8, in this case we do not need to swap the numbers,
    store 0 in r0*/
    lower_size1:
    mov r0,0	/*storing 0 in r0*/
    b done  /*directing to the done branch*/
    
    /**This is for the number which size is 2**/
    element_size_2:
    ldrh r7,[r4]    /*storing LSB 16 bits(2 bytes), which is located at the address determined by r4, in r7*/
    ldrh r8,[r4,4]  /*storing LSB 16 bits(2 bytes), which is located at the address determined by r4 + M4 word size, in r8*/
    cmp r7,0	/*compare r7 with 0*/
    beq zero_element_size_2 /*if r7 is 0, direct to the zero_element_size_2 branch*/
    cmp r8,0	/*if not, compare r8 with 0 again*/ 
    beq zero_element_size_2 /*if r8 is 0, direct to the zero_element_size_2 branch*/
    /*if both r7 and r8 is not 0, check the case is signed cased or unsigned case*/
    cmp r5,0	/*check r5, which indicates sign case or not, with 0*/
    beq unsigned_case2	/*if r5 equals to 0, then the case is unsigned case, and direct to the unsigned_case2 branch*/
    b   sigened_case2	/* if not, the case is signed case, and direcr to the signed_case2 branch*/
    /*This is for the number which size is 2, and which case is unsigned case*/
    unsigned_case2:
    cmp r7,r8	/*compare r7 and r8 to know which number is higher*/
    beq equal_size2 /*if they are equal, then driect to the equal_size2 branch*/
    bhi greater_size2	/*if r7 is greater than the r8, we need to swap the number, so direct to the greater_size2 branch*/
    bls lower_size2 /*if r7 is lower than the r8, direct to the lower_size2 branch*/
    /*This is for the number which size is 1, and which case is signed case*/
    sigened_case2:
    ldr r11,=0xFFFF0000	/*storing 0xFFFF0000, which will be used to get a negative sign, in r11*/
    mov r9,r7	/*storing r7 in r9*/
    mov r10,r8	/*storing r8 in r10*/
    
    lsls r9,r9,16   /*shifting r9 left to the 16 bits, store the result in r9, and then update the flags*/
    lsr r9,r9,16    /*shifting r9 right to 16 bits back, and store it the result r9*/
    orrmi r9,r9,r11 /*if the negative flag is set, use orr operation(r9 or r11), then store the result in r9*/
    
    lsls r10,r10,16 /*shifting r10 left to the 16 bits, store the result in r9, and then update the flags*/
    lsr r10,r10,16  /*shifting r10 right to the 16 bits back, and store the result in r10*/
    orrmi r10,r10,r11	/*if the negative flag is set, use orr operation(r10 or r11), then store the result in r10*/
    /*Here we only compare r9 and r10 not r7 and r8, since r9 represents r7, and r10 represents r8*/
    cmp r9,r10	/*compare r9 with r10 to know which number is greater*/
    beq equal_size2 /*if they are equal, direct to the equal_size2 branch*/
    bge greater_size2	/*if r9 is greater than r10, then need to swap the numbers, so direct to the greater_size2 branch*/
    blt lower_size2 /*if r9 is lower than r10, then direct to the lower_size2*/
    /*This is for the case, when the number size is 2, and either of the number is 0, In this case we don't need to swap the numbers,
    store -1 in r0*/
    zero_element_size_2:
    mov r0,-1	/*storing -1 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 2, and both numbers are equal, In this case, do not need to swap the numbers,
    store 0 in r0*/
    equal_size2:
    mov r0,0	/*storing 0 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 2, and r7 is greater than r8. In this case we need to swap the number. Since the
    size is 1, only swap the LSB 16 bits( 2bytes) of each one, others are ignored. store 1 in r0*/
    greater_size2:
    strh r8,[r4]    /*storing 2 byte from r8 to the memory address pointed to by r4*/
    strh r7,[r4,4]  /*storing 2 byte from register r7 to the memory address pointed to by r4  + M4 word size*/
    mov r0,1	/*storing 1 in r0*/
    b done	/*directing to the done branch*/
    /*This is for the case when the number size is 2, and r7 is lower than r8, in this case we do not need to swap the numbers
    and store 0 in r0*/
    lower_size2:
    mov r0,0	/*storing 0 in r0*/
    b done	/*directing to the done branch*/
    
    /**This is for the number which size is 4**/
    element_size_4:
    ldr r7,[r4]	    /*store the value, which is located in the address pointed by r4, in r7*/
    ldr r8,[r4,4]   /*store the value, which is located in the address pointed by r4 + M4 word size, in r8*/
    
    cmp r7,0	/*compare r7 with 0*/
    beq zero_element_size_4 /*if r7 is 0, direct to the zero_element_size_4 branch*/
    cmp r8,0	/*if not, compare r8 with 0 again*/ 
    beq zero_element_size_4 /*if r8 is 0, direct to the zero_element_size_4 branch*/
    /*if both r7 and r8 is not 0, check the case is signed cased or unsigned case*/
    cmp r5,0	/*check r5, which indicates sign case or not, with 0*/
    beq unsigned_case4	/*if r5 equals to 0, then the case is unsigned case, and direct to the unsigned_case4 branch*/
    b   sigened_case4	/* if not, the case is signed case, and direcr to the signed_case4 branch*/
    /*This is for the number which size is 4, and which case is unsigned case*/
    unsigned_case4:
    cmp r7,r8	/*compare r7 and r8 to know which number is higher*/
    beq equal_size4 /*if they are equal, then driect to the equal_size4 branch*/
    bhi greater_size4	/*if r7 is higher than the r8, we need to swap the number, so direct to the greater_size4 branch*/
    bls lower_size4 /*if r7 is lower than the r8, direct to the lower_size4 branch*/
    /*This is for the number which size is 4, and which case is signed case*/
    sigened_case4:
    cmp r7,r8	/*compare r7 and r8 to know which number is greater*/
    beq equal_size4 /*if they are equal, then driect to the equal_size4 branch*/
    bge greater_size4	/*if r7 is greater than the r8, we need to swap the number, so direct to the greater_size4 branch*/
    blt lower_size4 /*if r7 is lower than the r8, direct to the lower_size4 branch*/
    /*This is for the case, when the number size is 4, and either of the number is 0, In this case we don't need to swap the numbers,
    store -1 in r0*/
    zero_element_size_4:
    mov r0,-1	/*storing -1 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 4, and both numbers are equal, In this case, do not need to swap the numbers,
    store 0 in r0*/
    equal_size4:
    mov r0,0	/*storing 0 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 4, and r7 is greater than r8. In this case we need to swap the numbers, 
    store 1 in r0 */
    greater_size4:
    str r8,[r4]	/*storing a value from r8 to the memory address pointed to by r4*/
    str r7,[r4,4]   /*storing a value from r8 to the memory address pointed to by r4 + M4 word size*/
    mov r0,1	/*storing 1 in r0*/
    b done  /*directing to the done branch*/
    /*This is for the case when the number size is 4, and r7 is lower than r8, in this case we do not need to swap the numbers,
    store 0 in r0*/
    lower_size4:
    mov r0,0	/*storing 0 in r0*/
    b done  /*directing to the done branch*/
    
    done:   /*This is the end of the asmSwap function*/
    /**restore the caller's registers, as required by the ARM calling convention**/
    pop {r4-r11,LR}
    mov pc,lr   /**asmSwap return to caller**/

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
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    mov r4,r0	/*storing input r0, address of first value in array, in r4. This will be used in loop to point the address of the array*/
    mov r9,r0	/*storing input r0, address of first value in array, in r9. This is to get the address of first value in array easily
		    when the r4 in loop reach the address of last value and still need to repeat the loop*/
    mov r10,0	/**storing 0 in r10. This is to store the numbers of swap**/
    mov r11,0	/**storing 0 in r11. This is to check whether we need to repeat the loop or not**/
    
    /**This is the start of the bubble sorting loop**/
    sorting:
    mov r0,r4	/*storing the address of the first array, located in r4, in r0*/
    BL asmSwap	/*call the asmSwap function*/
    /**If we do the swap, the output r0 will be 1, if we do not do the swap,and neither of the input number is 0, the output r0, will 
     be 0, if the either of the input number is 0, the output r0 will be -1**/
    cmp r0,-1	/*compare values in r0, which is the output from asmSwap function, with -1*/
    beq check_repeat_or_not /*if the output value is -1, that means it reaches 0 in array, so need to check we need to do bubble sorting
			    again, or the sorted array is in order and we do not need to do bubble sort*/
    add r10,r10,r0  /*if not equals to -1, the array value does not reach 0, so add r0,the output value from asmSwap, to r10, and store
		    the result in r10. This is for the number of swaps*/
    add r11,r11,r0  /*add the r0, the output value from asmSwap, to r11, and store the result in r11. This is to check the sorted array
		    is in order, or not*/
    add r4,r4,4	    /*add the value in r4, which is the address of the array, to 4, and store the result in r4.. This is to get the
		    address of the next value in array*/
    b	sorting	    /*directing to the sorting branch again*/
    /*When the array reachs 0, it is the end of the array, and need to check the sorted array is in order or still need to do the
    bubble sort. If the r11 is 0, and the array reaches end, it means the sorted array is in order, and do not need to do bubble sort
    again. So direct to the done_for_asmSort branch. If not, need to do bubble sort again. In this case, store r9, which is the address 
    of the first value in array,in r4, then store 0 in r11, and direct to the sorting branch again*/
    check_repeat_or_not:
    cmp r11,0	/*compare r11 with 0 to check the array is in order or not*/   
    beq done_for_asmSort    /*if r11 equals 0, the sorted array is in order, and direct to the done_for_asmSort branch*/
    mov r4,r9	/*storing r9, which is the address of the first value in array, in r4*/
    mov  r11,0	/*storing 0 in r11*/
    b	sorting	/*directing to the sorting branch*/
    
    done_for_asmSort:	/*This is the end of the asmSort*/
    mov r0,r10	/*storing r10, which is the number of swaps, in r0*/
    /**restore the caller's registers, as required by the ARM calling convention**/
    pop {r4-r11,LR}
    mov pc,lr   /**asmSort return to caller**/
    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




