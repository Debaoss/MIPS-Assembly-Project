#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Eddy Chen, 1008180488, chenedd1, eddyalfred.chen@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 1 (update this as needed)
# - Unit height in pixels: 1 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################


.eqv BASE_ADDRESS 0x10008000
.eqv TOTAL_LEVELS 5
.eqv CH_HEIGHT 27
.eqv CH_WIDTH 12
.eqv ENM_HEIGHT 0
.eqv ENM_WIDTH 0
.eqv GOAL_HEIGHT 22
.eqv GOAL_WIDTH 16
.eqv DARK_BLUE 0x3f48cc
.eqv RED 0xed1c24
.eqv LIGHT_BLUE 0x7092be
.eqv BLACK 0x000000
.eqv FRAME 40

.include "bitmap_buffer.inc"
.include "menu.inc"
.include "menuarrow.inc"
.include "background1.inc"
.include "Level1Info.inc"
.include "Ch_Right.inc"
.include "Ch_Left.inc"
.include "Door.inc"

.data
F_Bullet:	.word 0:3
F_Shot_Timer:	.word 0
E_Bullet:	.word 0:24
E_Shot_Timer:	.word 0:8
CH_Location:	.word 0:2
Goal_Location:	.word 0:2
Player_V_Speed:	.word 0
LEVEL:		.word 0
Health:		.word 0
Airbourne:	.word 0
Character:	.word 0

Level_Back:	.word 0:TOTAL_LEVELS
Level_Coll:	.word 0:TOTAL_LEVELS
LevelCollCount:	.word 0:TOTAL_LEVELS
LevelEnemy:	.word 0:TOTAL_LEVELS
LevelECount:	.word 0:TOTAL_LEVELS
Characters:	.word 0:4




debug_space:	.asciiz " "


.text
.globl main
main:
	la $t3, background1
	la $t4, Level_Back
	sw $t3, 0($t4)
	
	la $t3, Level1PlatColl
	la $t4, Level_Coll
	sw $t3, 0($t4)
	
	la $t3, Level1PlatNo
	la $t4, LevelCollCount
	sw $t3, 0($t4)
	
	la $t3, Level1EnemyNo
	la $t4, LevelECount
	sw $t3, 0($t4)
	
	la $t3, Level1Enemy
	la $t4, LevelEnemy
	sw $t3, 0($t4)
	
	la $t3, CH_Right
	la $t4, Characters
	sw $t3, 0($t4)
	la $t3, CH_Left
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	
START:
	# Initialize menu
	jal InitializeMenu
	
	# Run Menu Loop
MENULOOP2:
	# Check Player input
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	li $t1, 1
	bne $t8, $t1, MENUNOKEY
	
	# Call MenuArrow if needed
	li $t1, 119 # w key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, MENU_NO_W # If w is pressed
	addi $t7, $t7, 1
	andi $t7, $t7, 1
	jal MenuArrow
MENU_NO_W:
	li $t1, 115 # s key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, MENU_NO_S # If s is pressed
	addi $t7, $t7, 1
	andi $t7, $t7, 1
	jal MenuArrow
	
	# Break loop if needed
MENU_NO_S:
	li $t1, 122 # z key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, MENU_NO_Z # If z is pressed
	bnez $t7, MENUQUIT # Arrow is on quit button
	j MENULOOPEND
MENUQUIT:
	j END
	
	# P to restart
MENU_NO_Z:
	li $t1, 112 # p key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, MENUNOKEY # If p is pressed
	jal ClearScreen
	j START
	
	# No key press
MENUNOKEY:
	# Sleep
	li $v0, 32
	li $a0, FRAME
	syscall
	j MENULOOP2
MENULOOPEND:
	
	# Initialize Game
	jal InitializeLevel
	
	# Run Game Loop
LEVELLOOP:
	
	# Check inputs
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	li $t1, 1
	bne $t8, $t1, LEVELNOKEY
	
	# Move character
	li $t1, 100 # d key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVEL_NO_D # If d is pressed
	
	jal EraseCharacter
	
	la $t3, CH_Location
	lw $t4, 0($t3)
	addi $t4, $t4, 4
	sw $t4, 0($t3)
	
	lw $t3, Character
	srl $t3, $t3, 1
	sll $t3, $t3, 1
	sw $t3, Character
	# Check for collision
	li $a0, 0
	jal CheckAllCollision
	
	jal DrawCharacter
	
	j LEVELNOKEY
LEVEL_NO_D:
	li $t1, 97 # a key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVEL_NO_A # If a is pressed
	
	jal EraseCharacter
	
	la $t3, CH_Location
	lw $t4, 0($t3)
	addi $t4, $t4, -4
	sw $t4, 0($t3)
	
	lw $t3, Character
	srl $t3, $t3, 1
	sll $t3, $t3, 1
	addi $t3, $t3, 1
	sw $t3, Character
	# Check for collision
	li $a0, 1
	jal CheckAllCollision
	
	jal DrawCharacter
	
	j LEVELNOKEY
LEVEL_NO_A:
	
	
	
	# Player shoot
	
	# P to restart
	li $t1, 112 # p key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVELNOKEY # If p is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	j START
	
LEVELNOKEY:

	# Check grounded, apply gravity
	
	# Enemies shoot
	
	# Move bullets
	
	# Check Collision
	
	
	
	
	
	
	
	j LEVELLOOP
	
	
	
	
	
	
END:
	jal ClearScreen
	li $v0, 10 # terminate the program gracefully
	syscall
	
# Functions
# Initializes bitmap display to menu
InitializeMenu:
	li $t4, BASE_ADDRESS # $t0 stores the base address for display
	addi $t5, $t4, 262144
	la $t6, menu_scr
MENULOOP1:
	beq $t4, $t5, MENUDONE
	lw $t2, 0($t6)
	sw $t2, 0($t4)
	addi $t4, $t4, 4
	addi $t6, $t6, 4
	j MENULOOP1
MENUDONE:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t7, 0
	jal MenuArrow
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Draw menu arrow pointing to a certain button
MenuArrow:
	# Draw arrow
	li $t0, BASE_ADDRESS
	la $t1, menu_arr
	li $t2, 0
	li $t3, 35
	move $t4, $t1
	addi $t4, $t4, 4900
	addi $t0, $t0, 137344
	beqz $t7, ARROWLOOP1
	addi $t0, $t0, 50176 # Change location of arrow drawn
ARROWLOOP1:
	beq $t1, $t4, ARROWDRAWN
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, ARROWJUMP1
	li $t2, 0
	addi $t0, $t0, 884 # Next line
ARROWJUMP1:
	j ARROWLOOP1
ARROWDRAWN:
	li $t0, BASE_ADDRESS
	li $t1, RED
	li $t2, 0
	li $t3, 35
	addi $t0, $t0, 187520
	move $t4, $t0
	addi $t4, $t4, 35840
	beqz $t7, ARROWLOOP2
	subi $t0, $t0, 50176 # Change location of arrow erased
	subi $t4, $t4, 50176
ARROWLOOP2:
	beq $t0, $t4, ARROWERASED
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, ARROWJUMP2
	li $t2, 0
	addi $t0, $t0, 884
ARROWJUMP2:
	j ARROWLOOP2
ARROWERASED:
	jr $ra

# Initializes bitmap display for game
InitializeLevel:
	li $t4, BASE_ADDRESS # $t0 stores the base address for display
	addi $t5, $t4, 262144
	lw $t1, LEVEL
	la $t2, Level_Back
	sll $t1, $t1, 2
	add $t2, $t2, $t1
	lw $t3, 0($t2)
LEVELLOOP1:
	beq $t4, $t5, LEVELDONE
	lw $t2, 0($t3)
	sw $t2, 0($t4)
	addi $t4, $t4, 4
	addi $t3, $t3, 4
	j LEVELLOOP1
LEVELDONE:
	# Set character at 0, 170
	la $t6, CH_Location
	li $t5, 0
	sw $t5, 0($t6)
	li $t5, 170
	sw $t5, 4($t6)
	lw $t5, Character
	# Make Character face right
	srl $t5, $t5, 1
	sll $t5, $t5, 1
	# Draw Character on screen
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal DrawCharacter
	jal DrawDoor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	jr $ra

# Draw character at given location
DrawCharacter:
	li $t0, BASE_ADDRESS
	lw $t1, Character
	la $t2, Characters
	sll $t1, $t1, 2
	add $t2, $t2, $t1
	lw $t3, 0($t2)
	move $t4, $t3
	addi $t4, $t4, 1296
	
	# Get Ch location
	la $t6, CH_Location
	lw $t5, 0($t6)
	lw $t7, 4($t6)
	li $t6, 256
	mult $t6, $t7
	mflo $t7
	add $t7, $t7, $t5
	li $t6, 4
	mult $t6, $t7
	mflo $t7
	
	add $t0, $t0, $t7 # add (y * 256 + x) * 4
	li $t6, 0
	li $t7, 12 # (CH_WIDTH)
CHLOOP1:
	beq $t3, $t4, CHDRAWN
	lw $t5, 0($t3)
	sw $t5, 0($t0)
	addi $t3, $t3, 4
	addi $t0, $t0, 4
	addi $t6, $t6, 1
	bne $t6, $t7, CHJUMP1
	li $t6, 0
	addi $t0, $t0, 976 # Next line
CHJUMP1:
	j CHLOOP1
CHDRAWN:
	jr $ra
	
# Erase character from given location
EraseCharacter:
	li $t0, BASE_ADDRESS
	lw $t1, LEVEL
	la $t2, Level_Back
	sll $t1, $t1, 2 # times 4
	add $t2, $t2, $t1
	lw $t3, 0($t2)
	move $t4, $t3
	addi $t4, $t4, 27648 #27696
	
	# Get Ch location
	la $t6, CH_Location
	lw $t5, 0($t6)
	lw $t7, 4($t6)
	li $t6, 256
	mult $t6, $t7
	mflo $t7
	add $t7, $t7, $t5
	li $t6, 4
	mult $t6, $t7
	mflo $t7
	
	add $t0, $t0, $t7 # add (y * 256 + x) * 4
	add $t4, $t4, $t7
	add $t3, $t3, $t7
	li $t6, 0
	li $t7, 12 # (CH_WIDTH)
	
CHLOOP2:
	beq $t3, $t4, CHERASED
	lw $t5, 0($t3)
	sw $t5, 0($t0)
	addi $t3, $t3, 4
	addi $t0, $t0, 4
	addi $t6, $t6, 1
	bne $t6, $t7, CHJUMP2
	li $t6, 0
	addi $t0, $t0, 976 # Next line
	addi $t3, $t3, 976
CHJUMP2:
	j CHLOOP2
CHERASED:
	jr $ra

# Draw enemies at given locations
DrawEnemy:

# Draws and clears hearts
DrawHeart:

# Draws the door
DrawDoor:
	li $t0, BASE_ADDRESS
	la $t1, door
	li $t2, 0
	li $t3, 16
	move $t4, $t1
	addi $t4, $t4, 1408
	addi $t0, $t0, 3008 #936
DOORLOOP1:
	beq $t1, $t4, DOORDRAWN
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, DOORJUMP1
	li $t2, 0
	addi $t0, $t0, 960 # Next line
DOORJUMP1:
	j DOORLOOP1
DOORDRAWN:
	jr $ra

# Checks collision with platforms
# Stored in a0: 0 for left side, 1 for right, 2 for top, 3 for bottom
CheckAllCollision:
	# Check collision for all platforms
	li $a1, 0
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelCollCount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of platforms
	lw $a3, 0($t4)
	
	la $t5, Level_Coll
	add $t5, $t2, $t5
	lw $a2, 0($t5) # platform data
	addi $sp, $sp, -4
	sw $ra, 0($sp) # Store return value
COLLLOOP:
	beq $a1, $a3, BOUNDARYCHECK # break loop
	jal CheckCollision
	addi $a1, $a1, 1
	j COLLLOOP
	
	# Check collision for boundaries of screen
BOUNDARYCHECK:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	andi $t0, $a0, 1
	andi $t7, $a0, 2
	
	move $t1, $a1 # platform_no
	li $t2, 4
	mult $t1, $t2
	mflo $t1 # 4 * platform_no
	add $t1, $t1, $a0 # 4 * platform_no + side
	mult $t1, $t2
	mflo $t1 # correct index
	add $t2, $a2, $t1
	lw $t1, 0($t2) # t1 now points to the correct boundary
	
	bnez $t7, UPDOWN2
	la $t4, CH_Location
	lw $t3, 0($t4) # t3 now points to x coordinate
	li $t5, CH_WIDTH
	j CHECKBOUND
UPDOWN2:
	la $t4, CH_Location
	addi $t4, $t4, 4
	lw $t3, 0($t4) # t3 now points to y coordinate
	li $t5, CH_HEIGHT
	j CHECKBOUND
	
CHECKBOUND:
	bnez $t0, BOUNDGREATER
	sub $t1, $t1, $t5
	blt $t3, $t1, COLLDONE2
	subi $t1, $t1, 1
	sw $t1, 0($t4)
	
	# If vertical reset vertical speed, set airbourne to 0
	beqz $t7, COLLDONE2
	li $t6, 0
	sw $t6, Player_V_Speed
	sw $t6, Airbourne
	
	j COLLDONE2
BOUNDGREATER:
	bgt $t3, $t1, COLLDONE2
	addi $t1, $t1, 1
	sw $t1, 0($t4)
	
	# If vertical, reset vertical speed
	beqz $t7, COLLDONE2
	li $t6, 0
	sw $t6, Player_V_Speed
COLLDONE2:
	jr $ra

# Stored in a0: which side
# Stored in a1: Which platform, in a2: level data address for this level
CheckCollision:
	move $t1, $a1 # Which platform
	move $t0, $a0 # Which side
	li $t2, 4
	mult $t1, $t2
	mflo $t1 # platform * 4
	add $t0, $t1, $t0 # platform * 4 + side
	mult $t0, $t2
	mflo $t0 # Platform * 4 + side
	mult $t1, $t2
	mflo $t1 # Platform * 4
	
	# words are size 4
	mult $t0, $t2
	mflo $t0
	mult $t1, $t2
	mflo $t1
	
	move $t2, $a2
	add $t2, $t2, $t0
	lw $t3, 0($t2) # Relevent side of the platform
	move $v0, $t2 # save for later
	
	add $t1, $t1, $a2
	
	# left/right or up/down
	move $t5, $a0
	andi $t5, 2
	bnez $t5, UPDOWN
	
	# Check if y value within platform
	lw $t4, 8($t1)
	lw $t5, 12($t1)
	la $t7, CH_Location
	lw $t6, 4($t7) # y coordinate of person
	subi $t4, $t4, CH_HEIGHT
	ble $t6, $t4, COLLDONE1
	bgt $t6, $t5, COLLDONE1
	
	# Less than or greater than
	move $t0, $a0
	andi $t0, $t0, 1
	lw $t1, 0($t7) # x coordinate of person
	li $t2, CH_WIDTH
	li $t4, 0
	j SIDECHECK
UPDOWN:
	# Check if x value within platform
	lw $t4, 0($t1)
	lw $t5, 4($t1)
	la $t7, CH_Location
	lw $t6, 0($t7) # x coordinate of person
	subi $t4, $t4, CH_HEIGHT
	ble $t6, $t4, COLLDONE1
	bgt $t6, $t5, COLLDONE1
	
	# Less than or greater than
	move $t0, $a0
	andi $t0, $t0, 1
	lw $t1, 4($t7) # y coordinate of person
	li $t2, CH_HEIGHT
	li $t4, 4
	j SIDECHECK
	
	# Check the side
SIDECHECK:
	bnez $t0, COLLGREATER
	sub $t3, $t3, $t2
	blt $t1, $t3, COLLDONE1
	
	addi $v0, $v0, 4
	lw $t5, 0($v0) #other side of platform
	bgt $t1, $t5, COLLDONE1
	
	subi $t3, $t3, 1
	add $t7, $t7, $t4
	sw $t3, 0($t7)
	
	# If vertical, reset vertical speed, set airbourne to 0
	move $t4, $a0
	andi $t4, $t4, 2
	beqz $t4, COLLDONE1
	li $t6, 0
	sw $t6, Player_V_Speed
	sw $t6, Airbourne
	
	j COLLDONE1
COLLGREATER:
	bgt $t1, $t3, COLLDONE1
	addi $t3, $t3, 1
	add $t7, $t7, $t4
	sw $t3, 0($t7)
	
	addi $v0, $v0, -4
	lw $t5, 0($v0) # other side of platform
	sub $t5, $t5, $t2
	ble $t1, $t5, COLLDONE1
	
	# If vertical, reset vertical speed
	move $t4, $a0
	andi $t4, $t4, 2
	beqz $t4, COLLDONE1
	li $t6, 0
	sw $t6, Player_V_Speed

COLLDONE1:
	jr $ra

# Checks friendly fire on enemies
CheckFHit:

# Checks enemy fire on player
CheckEHit:

# Draw win screen
Win:

# Draw lose screen
Lose:

# Clear Screen
ClearScreen:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	addi $t5, $t0, 262144
	li $t6, BLACK
CLEARLOOP:
	beq $t0, $t5, CLEARDONE
	sw $t6, 0($t0)
	addi $t0, $t0, 4
	j CLEARLOOP
CLEARDONE:
	jr $ra
