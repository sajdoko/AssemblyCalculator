;----------------------------------------------------------------------------------------------------------------------------------
;	CIT - Canadian Institute of Technology
;		Course	 	: Compter Architecture and Assembly Language (Microprocessor Systemes)
;		Professor	: Dr. Bledar Kazia
;		Student	 	: Sajmir Doko
;		Project	 	: Build a simple Assembly calculator which performs the four basic calculations by taking the operands from user input. Print the results.
;----------------------------------------------------------------------------------------------------------------------------------

;	Declaring Constants
;----------------------------------------------------------------------------------------------------------------------------------
section .data
	INVALID_ARGS: db "command should be : ./calculator <operator> <operand1> <operand2>", 0xA
	INVALID_OPERATOR: db "Invalid Operator", 0xA
	INVALID_OPERAND: db "Invalid Operand", 0XA
	BYTE_BUFFER: times 10 db 0 ; It's just a memory to size 10 , each slot holds the value 0

;	The actual code
;----------------------------------------------------------------------------------------------------------------------------------
section .text

	global _start

	_start:
		pop rdx ; get the command line arguments count from the stack and put it to rdx register (general purpose register)
		cmp rdx, 4 ; compare the rdx register with 4
		jne invalid_args ; if number of arguments in the rdx register is not equal to 4, go to invalid_args procedure and exit (jne means if not equal)

		; rsp is the stack pointer register
		add rsp, 8 ; skip the first argument as it is the program name (./calculator) - rsp is now pointing at second argument
		pop rsi ; pop first argument from the argument stack to get the operand, rsi is the source index register

		; 0b00101011 in binary is (+) operator in ASCII
		; 0b00101101 in binary is (-) operator in ASCII
		; 0b00101010 in binary is (*) operator in ASCII
		; 0b00101111 in binary is (/) operator in ASCII
		; The "0b" is a prefix to denote that the number is in binary.

		; Start comparing the rsi register, which holds the <operand> + - * /
		cmp byte[rsi], 0b00101011 ; Compare specifically 1 byte (8 bits) with + (0b00101011) in binary
		je addition	; If operator is '+' then go to the addition procedure (je means if equal)

		cmp byte[rsi], 0b00101101 ; If operator is '-' then go to the subtraction procedure
		je subtraction

		cmp byte[rsi], 0b00101010 ; If operator is '*' then go to the multiplication procedure. Don't forget to excape \* on the argument input
		je multiplication

		cmp byte[rsi], 0b00101111 ; If operator is '/' then go to the division procedure
		je division


		jmp invalid_operator ; If <operator> does not match to any case then go to the invalid_operator procedure (jmp is unconditional jump)

	;-------------------
	;	ADDITION ---------
	;-------------------
	addition:
		pop rsi ; Pop second argument from the argument stack which is <operand1>
		; The input charatters from the keyboard are in ASCII code representation so they must convert to actual integers
		call char_to_int ; This procedure will take the number in its ASCII form (rsi as argument) and return its integer equivalent in rax
		mov r10, rax ; Store the integer equivalent of <operand1> in r10
		pop rsi ; Pop the third argument from argument stack which is <operand2>
		call char_to_int ; Get the integer for <operand2>
		add rax, r10 ; Add the integer equivalents of <operand1> and <operand2>
		jmp print_result ; Jump to the print_result procedure

	;-------------------
	;	SUBTRACTION -----
	;-------------------
	subtraction:
		; Almost the same as in addition
		pop rsi
		call char_to_int
		mov r10, rax
		pop rsi
		call char_to_int
		sub r10, rax ; Subtract <operand2> saved in rax from <operand1> saved previously in r10
		mov rax, r10 ; Move the result to rax
		jmp print_result

	;-------------------
	;	MULTIPLICATION ---
	;-------------------
	multiplication:
		pop rsi
		call char_to_int
		mov r10, rax
		pop rsi
		call char_to_int
		mul r10 ; Multiplies the the <operand1> stored in r10 with <operand2> stored in rax, result is stored in rax
		jmp print_result

	;-------------------
	;	DIVISION ---------
	;-------------------
	division:
		pop rsi
		call char_to_int
		mov r10, rax
		pop rsi
		call char_to_int
		mov r11, rax ; Store <operand2> int value on r11
		mov rax, r10 ; Move <operand1> from r10 to rax
		mov rdx, 0	; rdx must be zero, or we get a SIGFPE (reports a fatal arithmetic error)
		div r11 ; Divide the <operand1> stored in rax by <operand2> stored in r11, put the ratio into rax and the remainder into rdx
		jmp print_result


	; This procedure prints the content. The content must be stored in rax first.
	print_result:
		; This procedure will convert our integer in rax back to ASCII format (character)
		; Argument - takes integer to be converted (must be stored in rax)
		; Returns pointer to the char string (returns r9 as pointer to the string or char)
		call int_to_char
		mov rax, 1 ; Store syscall number , 1 is for sys_write
		mov rdi, 1 ; Descriptor where we want to write, 1 is for stdout (rdi register is destination index)
		mov rsi, r9 ; This is pointer to the string which was returned by int_to_char
		mov rdx, r11 ; r11 stores the number of chars in the string
		syscall ; invoke systemcall
		jmp exit ; jump to exit procedure


	invalid_args:
		mov rdi, INVALID_ARGS ; Move the invalid args message to rdi register (destination index)
		call print_the_error

	invalid_operator:
		mov rdi, INVALID_OPERATOR
		call print_the_error

	invalid_operand:
		mov rdi, INVALID_OPERAND
		call print_the_error

	; Print the error procedure
	print_the_error:
		push rdi	; push rdi onto the stack
		call strlen ; calculate the length of rdi (error message)
		mov rdi, 2 ; write to stderr
		pop rsi	; remove topmost value from the stack
		mov rdx, rax ; move result of strlen onto rdx
		mov rax, 1 ; write syscall
		syscall ; invoke systemcall
		call error_exit	; exit with error procedure
		ret

	strlen:
		xor rax, rax ; XORing an operand with itself changes the operand to 0. This is used to clear a register
		strlen_loop:
			cmp BYTE [rdi + rax], 0xA ; compare byte to a newline character
			je strlen_break ; break if the current byte is a newline
			inc rax	; increment rax register by one
			jmp strlen_loop ; repeat if the current byte isn't a newline
		strlen_break:
			inc rax ; add one to string length to count the newline
			ret

	; This procedure converts input character to integers
	;	Argument - pointer to string or char ( takes rsi as argument )
	;	Returns equivalent integer value (in rax)
	char_to_int:
		xor ax, ax ; store zero in ax, clear the register
		xor cx, cx ; clear cx
		mov bx, 10 ; store 10 in bx - the input string is in base 10, so each place value increases by a factor of 10

		loop_proc_cti:
			;REMEMBER rsi is base address to the string which we want to convert to integer equivalent
			mov cl, [rsi] ; Store the value at address (rsi + 0) or (rsi + index) in cl, rsi is incremented below
			cmp cl, byte 0 ; If value at address (rsi + index ) is byte 0 (NULL) , this means that the string is terminated here
			je return_proc_cti

			; Each digit must be between 0 (ASCII code 48) and 9 (ASCII code 57)
			cmp cl, 0x30 ; If value is lesser than 0 go to invalid operand
			jl invalid_operand
			cmp cl, 0x39 ; If value is greater than 9 go to invalid operand
			jg invalid_operand

			sub cl, 48 ;C onvert ASCII to integer by subtracting 48 - '0' is ASCII code 48, so subtracting 48 gives us the integer value

			; Multiply the value in 'ax' (implied by 'mul') by bx (always 10). This can be thought of as shifting the current value
			; to the left by one place (e.g. '123' -> '1230'), which 'makes room' for the current digit to be added onto the end.
			; The result is stored in dx:ax.
			mul bx

			; Add the current digit, stored in cl, to the current intermediate number.
			; The resulting sum will be mulitiplied by 10 during the next iteration of the loop, with a new digit being added onto it
			add ax, cx

			inc rsi ; Increment the rsi's index i.e (rdi + index ) we are incrementing the index

			jmp loop_proc_cti ; Keep looping until loop breaks on its own

		return_proc_cti:
			ret

	; This is the procedure which will convert our integers back to characters
	; Argument - Integer Value in rax
	; Returns pointer to equivalent string (in r9)
	int_to_char:
		mov rbx, 10
		; Use BYTE_BUFFER as buffer to store the result
		mov r9, BYTE_BUFFER+10 ; Store the number in backward order like LSB in 10 index and decrement index as we move to MSB
		mov [r9], byte 0 ; Store NULL terminating byte in last slot
		dec r9 ; Decrement memory index
		mov [r9], byte 0XA ; Store break line
		dec r9 ; Decrement memory index
		mov r11, 2; r11 will store the size of the string stored in buffer. Use it while printing as argument to sys_write

		loop_proc_itc:
			mov rdx, 0
			div rbx 	; Get the LSB by dividing number by 10, LSB will be remainder (stored in 'dl') like 23 divider 10 will give us 3 as remainder which is LSB here
			cmp rax, 0 ; If rax (quotient) becomes 0 the procedure reached to the MSB of the number
			je return_proc_itc
			add dl, 48 ; Convert each digit to its ASCII value
			mov [r9], dl ; Store the ASCII value in memory by using r9 as index
			dec r9 ; Dont forget to decrement r9 remember we are using memory backwards
			inc r11 ; Increment size as soon as you add a digit in memory
			jmp loop_proc_itc ; Loop until it breaks on its own

		return_proc_itc:
			add dl, 48 ; Don't forget to repeat the routine for out last MSB as loop ended early
			mov [r9], dl
			dec r9
			inc r11
			ret


	error_exit:
		mov rax, 60 ; exit systemcall
		mov rdi, 1 ; Set rdi to 1 to indicate error
		syscall

	;	exit procedure without errors
	exit:
		mov rax, 60 ; exit systemcall
		mov rdi, 0 ; Set rdi to 0 to indicate that there is no error
		syscall

;----------------------------------------------------------------------------------------------------------------------------------
;	LINKS
;		GitHub Project			: https://github.com/sajdoko/AssemblyCalculator
;		Assembly Tutorial		:	https://www.tutorialspoint.com/assembly_programming/assembly_quick_guide.htm
;		ASCII Table 				: https://bytetool.web.app/en/ascii/
;		Other Links					:	https://www.cs.uaf.edu/2006/fall/cs301/support/x86_64/, https://github.com/0xAX/asm
;----------------------------------------------------------------------------------------------------------------------------------