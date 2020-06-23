# 	Karolina Jablonska

#   Write a program displaying a smoothly shadowed rectangle of given height, width and vertex colors.
# 	Colors of pixels should be interpolated using fixed-point arithmetics (16.16 format).


# The rectangle is allocated at heap and displayed at Bitmap Display.
# To use bit mask used andi command - bitwise AND and load immediate.
# Eeach pixel takes 4 bites.
# $s0		width of rectangle
# $s1		height of rectangle
# $s2		heap adreess
# $s3		Color of the first vertice.
# $s4		Color of the second vertice.
# $s5		Color of the third vertice.
# $s6		Color of the fourth vertice.

# $t5		Value of the recent blue component in the column.
# $t7		Value of the recent green component in the column.
# $s5		Value of the recent red component in the column.

# $t4		Value of the recent blue component in the row.
# $t6		Value of the recent green component in the row.
# $s4		Value of the recent green component in the row.

# $t3		Interpolation parameter for blue color.
# $t8		Interpolation parameter for green color.
# $s6		Interpolation parameter for red color.

# $t0		interpolationX
# $t1		interpolationY
# $t2		interpolationDifference
	
	.data
	
	.eqv	BIT_MASK_R 	16711680 		# 0xFF0000 as integer.	
	.eqv	BIT_MASK_G 	65280 			# 0x00FF00 as integer.
	.eqv	BIT_MASK_B 	255			# 0x0000FF as integer.
	.eqv	COLOR_MIN 	65536			# 0xFF0000 as integer.
	.eqv	COLOR_MAX 	16711680		# 0x10000 as integer.
	.eqv 	MAX_RGB 	16777215		# 0xFFFFF as integer.
	
	.eqv	DISPLAY_WIDTH 	1024			# Bitmap Display frame width.	
	.eqv 	FIXED_POINT  	16			# Fixed point 16.16 arithmetics.	

interpolationX:			.word 0, 0, 0		# Interpolation parameter in X.
interpolationY:			.word 0, 0, 0		# Interpolation parameter in Y.
interpolationDifference:	.word 0, 0, 0		# Difference in number of steps.
heap:				.word 0			# Address to the begging of the heap.
allocatedRectangle:		.word 0			# Amout of allocated bytes.

getWidth:			.asciiz "Enter width: "
getHeight:			.asciiz "Enter height: "
getV1:				.asciiz "Enter color of the first vertice (as integer): "
getV2:				.asciiz "Enter color of the second vertice (as integer): "
getV3:				.asciiz "Enter color of the third vertice (as integer): "
getV4:				.asciiz "Enter color of the fourth vertice (as integer): "

	.text 

main:
	# Reading data from the user.
	li 	$v0, 4					# Display string service.
	la 	$a0, getWidth				# Get width from the user.
	syscall		
	li	$v0, 5					# Reading width
	syscall
	blt	$v0, $zero, exit
	bgt	$v0, DISPLAY_WIDTH, exit
	move	$s0, $v0				# Store width in $s0.
	
	li 	$v0, 4
	la 	$a0, getHeight
	syscall	
	li	$v0, 5					# Reading height
	syscall
	blt	$v0, $zero, exit
	move	$s1, $v0				# Store width in $s1.
	
	# Reading color of vertices.
	li 	$v0, 4
	la 	$a0, getV1
	syscall
	li	$v0, 5					# Reading 1st vertice color.
	syscall
	blt	$v0, $zero, exit			# Checking RGB range.
	bgt	$v0, MAX_RGB, exit
	move	$s3, $v0				# Store color of 1st vertice in $s3.
	
	li 	$v0, 4
	la 	$a0, getV2
	syscall
	li	$v0, 5					# Reading 2nd vertice color.
	syscall
	blt	$v0, $zero, exit
	bgt	$v0, MAX_RGB, exit
	move	$s4, $v0				# Store color of 2nd vertice in $s4.
	
	li 	$v0, 4
	la 	$a0, getV3
	syscall
	li	$v0, 5					# Reading 3rd vertice color.
	syscall
	blt	$v0, $zero, exit
	bgt	$v0, MAX_RGB, exit
	move	$s5, $v0				# Store color of 3rd vertice in $s5.
	
	li 	$v0, 4
	la 	$a0, getV4
	syscall
	li	$v0, 5					# Reading 4th vertice color.
	syscall
	blt	$v0, $zero, exit
	bgt	$v0, MAX_RGB, exit
	move	$s6, $v0				# Store color of 4th vertice in $s6.

# Heap allocation.

	# Bytes to allocate = ((height-1) * DISPLAY_WIDTH + width) * 2^2 (4 bytes per pixel).
	la	$t0, allocatedRectangle
	lw	$t1, ($t0)				# Store allocatedRectangle value.
	subiu	$t0, $s1, 1				# height - 1
	li	$t2, DISPLAY_WIDTH
	multu	$t0, $t2				# (height-1) * DISPLAY_WIDTH
	mflo	$t0
	addu	$t0, $t0, $s0				# (height-1) * DISPLAY_WIDTH + width
	sll	$t0, $t0, 2				# Scale to bytes (4 bytes per pixel)

	la 	$a0, ($t0)
	li	$v0, 9					# Bytes allocation service.
	syscall
	
	la	$t1, allocatedRectangle	
	sw	$t0, ($t1)				# Store amout of allocated bytes.
	
	la	$t0, heap				# Restore register to the beggining of the heap.
	sw	$v0, ($t0)				# Copy from register to memory.
	lw	$s2, ($t0)				# Store in $s2 begining of the heap.
	
	
# Finding interpolation parameters.
			 
	# Blue color.
	# Finding blue component of each vertice using bit mask.
	# No shift needed because blue is the last component of RGB (last 8 bytes).
	andi	$a0, $s3, BIT_MASK_B			# 1st vertcie blue color component.
	andi	$a1, $s4, BIT_MASK_B			# 2nd vertice blue color component.
	andi	$a2, $s5, BIT_MASK_B			# 3rd vertice blue color component.
	andi	$a3, $s6, BIT_MASK_B			# 4th vertice blue color component.
	
	jal	interpolate				# Find interpolation parameters.
	la	$t0, interpolationX
	la	$t1, interpolationY
	la	$t2, interpolationDifference
	
	sw	$v0, ($t0)				# Store interpolation parameters.
	sw	$v1, ($t1)
	sw	$a0, ($t2)
	
	# Green color.
	# Finding green component of each vertice using bit mask.
	# Shift by 8 bites, because green is middle component of RGB (middle 8 bytes).
	andi	$a0, $s3, BIT_MASK_G
	andi	$a1, $s4, BIT_MASK_G
	andi	$a2, $s5, BIT_MASK_G
	andi	$a3, $s6, BIT_MASK_G
	srl	$a0, $a0, 8
	srl	$a1, $a1, 8
	srl	$a2, $a2, 8
	srl	$a3, $a3, 8
	
	jal	interpolate
	sw	$v0, 4($t0)
	sw	$v1, 4($t1)
	sw	$a0, 4($t2)
	
	# Red color.
	# Finding red component of each vertice using bit mask.
	# Shift by 16 bites, because red is first component of RGB.
	andi	$a0, $s3, BIT_MASK_R
	andi	$a1, $s4, BIT_MASK_R
	andi	$a2, $s5, BIT_MASK_R
	andi	$a3, $s6, BIT_MASK_R
	srl	$a0, $a0, 16
	srl	$a1, $a1, 16
	srl	$a2, $a2, 16
	srl	$a3, $a3, 16
	
	jal	interpolate
	sw	$v0, 8($t0)
	sw	$v1, 8($t1)
	sw	$a0, 8($t2)
	

# Drawing rectangle.
	
	# Interpolate next pixel to be drawn taking the previous pixel.	
	# Blue.
	andi	$t4, $s3, BIT_MASK_B			# Value of the recent blue component in the row.
	sll	$t4, $t4, 16				# 16.16 fixed point arithmetics.
	move	$t5, $t4				# Value of the recent blue component in the column.
	
	la	$t0, interpolationX			# Interpolation in X direction parameter.
	lw	$t3, ($t0)				# Interpolation parameter for blue color (difference to be added to the previous color to obtain next color).
	
	# Green.
	andi	$t6, $s3, BIT_MASK_G			# Value of the recent green component in the row.
	sll	$t6, $t6, 8				# 16.16 fixed point arithmetics.
	move	$t7, $t6				# Value of the recent green component in the column.
	lw	$t8, 4($t0)				# Interpolation parameter for green color
	
	# Red.
	andi	$s4, $s3, BIT_MASK_R			# Value of the recent red component in the row.
	move	$s5, $s4				# Value of the recent red component in the column.
	lw	$s6, 8($t0)				# Interpolation parameter for red color.
	
	li	$t0, 0					# Reset row counter.
	
goToNextRow:
	bge	$t0, $s1, exit				# End if row greater than rectangle height.
	addiu	$t0, $t0, 1				# Increase row counter.
	li	$t1, 0					# Reset column counter.
	
drawRow:
	bgt	$t1, $s0, goToNextColumn		# If column greater than rectangle width find next column.
	sll	$t2, $t1, 2				# Scale to bytes (2^2 bytes per pixel).
	addu	$t2, $t2, $s2				# Adress of pixel to be drawn ($s2 stores adress of the begining of the heap ).
	
	# Get integer from fixed point and store RGB as one number.
	srl	$t9, $t4, FIXED_POINT			# Blue component.
	srl	$s3, $t6, FIXED_POINT			# Green component.		
	sll	$s3, $s3, 8
	add	$t9, $t9, $s3				# Save blue and green as one number.
	srl	$s3, $s4, FIXED_POINT			# Red component.
	sll	$s3, $s3, 16	
	add	$t9, $t9, $s3				# Save blue, green and red as one number (RGB).
	
	sw	$t9, ($t2)				# Store pixel color on heap.
	addiu	$t1, $t1, 1				# Increase column counter.		

# Updating colors by checking their ranges.
	add	$t4, $t4, $t3				# Blue.
	bgt	$t4, COLOR_MAX, updateBlueMax
	blt	$t4, COLOR_MIN, updateBlueMin
	
	# Each color component has the same ranges
	# If color is greater then COLOR_MAX then it is set to COLOR_MAX.
	# If color is smaller then COLOR_MIN then it is set to COLOR_MIN.	
updateGreen:
	add	$t6, $t6, $t8				# Green.
	bgt	$t6, COLOR_MAX, updateGreenMax
	blt	$t6, COLOR_MIN, updateGreenMin
	
updateRed:
	add	$s4, $s4, $s6				# Red.
	bgt	$s4, COLOR_MAX, updateRedMax
	blt	$s4, COLOR_MIN, updateRedMin
	b 	drawRow

updateBlueMax:	
	li	$t4, COLOR_MAX
	b	updateGreen
	
updateBlueMin:
	li	$t4, COLOR_MIN
	b	updateGreen
		
updateGreenMax:
	li	$t6, COLOR_MAX
	b	updateRed
	
updateGreenMin:
	li	$t6, COLOR_MIN
	b	updateRed

updateRedMax:	
	li	$s4, COLOR_MAX
	b	drawRow
	
updateRedMin:	
	li	$s4, COLOR_MIN
	b	drawRow
	
			
goToNextColumn:
	li	$t2, DISPLAY_WIDTH
	sll	$t2, $t2, 2				# Scale to bytes (2^2 bytes per pixel).
	addu	$s2, $s2, $t2				# Move to the next row.
	
	# Update color values by interpolation parameters.
	# Blue component.
	la	$s7, interpolationY			# Interpolation in Y direction parameter.
	lw	$t9, ($s7)
	# $t5 keeps value of the recent blue color component.
	add	$t4, $t5, $t9				# Interpolation parameter for blue color (difference to be added to the previous color to obtain next color).
	move	$t5, $t4
	
	# Green component.
	lw	$t9, 4($s7)
	# $t7 keeps value of the recent green color component.
	add	$t6, $t7, $t9				# Interpolation parameter for green color.
	move	$t7, $t6
	
	# Red component.
	lw	$t9, 8($s7)
	# $s5 keeps value of the recent red color component.
	add	$s4, $s5, $t9				# Interpolation parameter for red color.
	move	$s5, $s4
	
	# Update step length by adding interpolationDifference to each color component.
	la	$s7, interpolationDifference		# Apply interpolationDifference to change the setep.
	lw	$t9, ($s7)
	# $t3 keeps intepolation parameter of blue color value.			
	add	$t3, $t3, $t9				# Blue.
	
	lw	$t9, 4($s7)
	# $t8 keeps intepolation parameter of green color value.
	add	$t8, $t8, $t9				# Green.
	
	lw	$t9, 8($s7)
	# $t6 keeps intepolation parameter of red color value.
	add	$s6, $s6, $t9				# Red.
	
	b	goToNextRow


exit:
	li	$v0, 10					# Exit serivce.
	syscall	

	
# Calculating interpolation parameters between 4 vertices.
# Function calculate interpolation parameters in X, Y directions and difference between those two paremeters.
# To calculate next pixel in row we have to take previous pixel value and add interpolationX (for needed color component R, G or B).
# To calculate next pixel in column we have to take previous pixel value and add interpolationY (for needed color component R, G or B).

interpolate:
	# Step length in column - color change in each step.
	# (color component of vertice 3 - color component of vertice 1) / height	
	sub	$t4, $a2, $a0
	sll	$t4, $t4, FIXED_POINT			# 16.16 fixed point arithmetic.
	div	$t4, $s1
	mflo	$t4
	
	# Step length in row - color change in each step.
	# (color component of vertice 2 - color component of vertice 1) / width	
	sub	$t3, $a1, $a0
	sll	$t3, $t3, FIXED_POINT			# 16.16 fixed point arithmetic.
	div	$t3, $s0
	mflo	$t3
	
	# (color component of vertice 4 - color component of vertice 3) / width	
	sub	$t5, $a3, $a2
	sll	$t5, $t5, FIXED_POINT			# 16.16 fixed point arithmetic.
	div	$t5, $s0
	mflo	$t5
	
	# Difference between number of steps. Need to regulate color difference in steps. 
	sub	$t5, $t5, $t3
	div	$t5, $s1
	mflo	$t5
	
	# Store calculated parameters.
	move	$v0, $t3				# interpolationX
	move	$v1, $t4				# interpolationY
	move	$a0, $t5				# interpolationDifference

	jr	$ra
