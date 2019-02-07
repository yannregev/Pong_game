# A simple example that uses bootlib.

.global main
.text
	.equ LEFTBOUND, 160*22+38
	.equ RIGHTBOUND, 160*22+158
	.equ LEFT,	0
	.equ RIGHT,	1 
	.equ UP, 	1
	.equ DOWN,	0
	lose: .asciz "You lose, retry? y/n"
	main:
		pushl %ebp
		movl %esp, %ebp
		# Set the timer frequency to 1000Hz
		pushl $1000
		call set_timer_frequency
		addl $4, %esp

		# Register the handle for the timer IRQ (IRQ0) and enable it.
		pushl $irq0
		pushl $0
		call set_irq_handler
		call enable_irq
		addl $8, %esp

		# Set up VGA stuff
		call color_text_mode
		call hide_cursor
	game_start:
		movl $0, time
		movl $0, score
		movl $160*10+100, ball
		movl $160*22+104, paddle
		movb $UP, UP_DOWN
		movb $RIGHT, LEFT_RIGHT
		call clear_window
	# game loop
		pushl $0 # reserved to make the ball refresh rate half the paddles rate
	loop:
		cmpl $2, time
		jle loop
		call draw_score
		call draw_paddle
		movl $0, time
		addl $1, -4(%ebp)
		cmpl $2, -4(%ebp)
		jle loop
		call draw_ball
		call check_lose
		cmpl $1, %eax
		je lose_message
	reset_time:
		movl $0, -4(%ebp)
		jmp loop

	lose_message:
		addl $4, %ebp # clear the stack
		call clear_window
		movl $vga_memory + 160*11+58, %ebx
		movb $0x4E, %ah
		movl $lose, %edi
		movl $20, %edx
	loop_message:
		movb (%edi), %al
		incl %edi
		movw %ax, (%ebx)
		addl $2, %ebx
		decl %edx
		cmpl $0, %edx
		jne loop_message
		
		

	check_save_score:
		movl score, %ebx
		cmpl high1, %ebx
		jle dont_replace_high1
		movl high1, %edi
		movl %ebx, high1
		movl %edi, %ebx
	dont_replace_high1:
		movl $vga_memory + 160*13+68, %edi
		movl high1, %eax
		movl $10, %ecx
	print_high1:
		movl $0, %edx
		divl %ecx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi		
		test %eax, %eax
		jnz print_high1

		cmpl high2, %ebx
		jle dont_replace_high2
		movl high2, %edi
		movl %ebx, high2
		movl %edi, %ebx
	dont_replace_high2:
		movl $vga_memory + 160*14+68, %edi
		movl high2, %eax
		movl $10, %ecx
	print_high2:
		movl $0, %edx
		divl %ecx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi		
		test %eax, %eax
		jnz print_high2

		cmpl high3, %ebx
		jle dont_replace_high3
		movl high3, %edi
		movl %ebx, high3
		movl %edi, %ebx
	dont_replace_high3:
		movl $vga_memory + 160*15+68, %edi
		movl high3, %eax
		movl $10, %ecx
	print_high3:
		movl $0, %edx
		divl %ecx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi		
		test %eax, %eax
		jnz print_high3

		cmpl high4, %ebx
		jle dont_replace_high4
		movl high4, %edi
		movl %ebx, high4
		movl %edi, %ebx
	dont_replace_high4:
		movl $vga_memory + 160*16+68, %edi
		movl high4, %eax
		movl $10, %ecx
	print_high4:
		movl $0, %edx
		divl %ecx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi		
		test %eax, %eax
		jnz print_high4

		cmpl high5, %ebx
		jle dont_replace_high5
		movl high5, %edi
		movl %ebx, high5
		movl %edi, %ebx
	dont_replace_high5:
		movl $vga_memory + 160*17+68, %edi
		movl high5, %eax
		movl $10, %ecx
	print_high5:
		movl $0, %edx
		divl %ecx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi		
		test %eax, %eax
		jnz print_high5


	display_high_score:
		movl $vga_memory + 160*12+62, %edi
		movl $0, %esi
		movb $0, %cl
	high_score_line:
		movb $0x4E, %ah
		addl $158, %edi
		incb %cl
		movb %cl, %al
		addb $0x30, %al
		movw %ax, (%edi)
		addl $2, %edi
		movb $'.', %al
		movw %ax, (%edi)

		cmpb $5, %cl
		jl high_score_line


	wait_for_input:	
		inb $0x64, %al
		testb $0x2, %al
		jnz wait_for_input
		inb $0x60, %al
		cmpb $0x15, %al
		je game_start
		cmpb $0x31, %al
		je end
		jmp wait_for_input

	end:
		movl %ebp, %esp
		popl %ebp
		movl $60, %eax
		movl $0, %edx
		syscall

	draw_score:
		pushl %ebp
		movl %esp, %ebp
		movb $0x4E, %ah
		movl $vga_memory+156, %edi 
		movl score, %eax
		movl $10, %ebx
	score_loop:
		movl $0, %edx
		divl %ebx
		addb $0x30, %dl
		movb %dl, (%edi)
		subl $2, %edi
		test %eax, %eax
		jnz score_loop				

		movl %ebp, %esp
		popl %ebp
		ret


	draw_paddle:
		# Draw the paddle.
		pushl %ebp
		movl %esp, %ebp
		movl $0, time
		movb $' ', %al
		movb $0x4E, %ah
		movl $vga_memory, %edi
		addl paddle, %edi
		movl $20, %ebx
	clear_paddle_loop:
		movw %ax, (%edi)
		subl $2, %edi
		decl %ebx
		cmpl $0, %ebx
		jne clear_paddle_loop
		
	check_input:	
		inb $0x64, %al
		testb $0x2, %al
		jnz check_input
		inb $0x60, %al
		cmpb $0x4d, %al
		je move_right
		cmpb $0x4b, %al
		je move_left
		jmp no_input
	move_right:
		cmpl $RIGHTBOUND, paddle
		je no_input
		addl $6, paddle
		jmp no_input
	move_left:
		cmpl $LEFTBOUND, paddle
		je no_input
		subl $6, paddle
	no_input:
		movb $' ', %al
		movb $0x00, %ah
		movl $vga_memory, %edi
		addl paddle, %edi
		movl $20, %ebx
	draw_paddle_loop:
		movw %ax, (%edi)
		subl $2, %edi
		decl %ebx
		cmpl $0, %ebx
		jne draw_paddle_loop
	paddle_end:
		movl %ebp, %esp
		popl %ebp
		ret
		
		#Called to draw the ball
	draw_ball:
		pushl %ebp
		movl %esp, %ebp
		pushl ball
	ball_left_or_right:
		movl ball, %eax
		addl $2, %eax
		movl $0, %edx
		movl $160, %ebx
		divl %ebx
		cmpl $0, %edx
		jne dont_change_side
		xor $1, LEFT_RIGHT
	dont_change_side:	
		cmpb $LEFT,LEFT_RIGHT
		jne ball_move_right 
	ball_move_left:
		addl $2, ball
		jmp ball_up_or_down
	ball_move_right:
		subl $2, ball
		jmp ball_up_or_down
	ball_up_or_down:
		cmpl $158, ball
		jg dont_change_direction
		movb $DOWN, UP_DOWN
	dont_change_direction:
		cmpb $UP, UP_DOWN
		jne ball_move_down
	ball_move_up:
		subl $160, ball
		jmp draw_the_ball
	ball_move_down:
		addl $160, ball	
		movl ball, %eax
		movl paddle, %ebx
		subl $200, %ebx
		cmpl %ebx, %eax
		jl draw_the_ball
		addl $40, %ebx
		cmpl %ebx, %eax
		jg draw_the_ball
		incb score
		movb $UP, UP_DOWN
	draw_the_ball:
		#draw new ball
		movb $' ', %al
		movb $0x00, %ah
		movl $vga_memory, %edi
		addl ball, %edi
		movw %ax, (%edi)
		#remove old
		popl %ebx
		movb $' ', %al
		movb $0x4E, %ah
		movl $vga_memory, %edi
		addl %ebx, %edi
		movw %ax, (%edi)
	ball_end:
		movl %ebp, %esp
		popl %ebp
		ret

	clear_window:
		pushl %ebp
		movl %esp, %ebp
		movb $' ', %al
		movb $0x4E, %ah
		movl $25*80, %ecx
		movl $vga_memory, %edi
		cld
		rep stosw
		movl %ebp, %esp
		popl %ebp
		ret

	check_lose:
		pushl %ebp
		movl %esp, %ebp
		movl ball, %ecx
		cmpl $160*26, %ecx
		jle not_lose 
		movl $1, %eax
		jmp lose_end
	not_lose:
		movl $0, %eax
	lose_end:
		movl %ebp, %esp
		popl %ebp
		ret


	irq0:
		incl time
		jmp end_of_irq0



.data
	high1: .long 0
	high2: .long 0
	high3: .long 0
	high4: .long 0
	high5: .long 0
	score: .long 0
	LEFT_RIGHT: .byte 1
	UP_DOWN: .byte 1 
	ball: .long 160*10+100
	paddle: .long 160*22+104
	time: .long 0


.bss
		
