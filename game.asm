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
.eqv CH_HEIGHT 0
.eqv CH_WIDTH 0
.eqv ENM_HEIGHT 0
.eqv ENM_WIDTH 0

.include "menu.inc"

.data
CH_COLOUR:	.word 0
F_Bullet:	.word 0:2
F_Shot_Timer:	.word 0
E_Bullet:	.word 0:16
E_Location:	.word 0:16
LEVEL:		.word 0
CH_Location:	.word 0:2
E_Count:	.word 0




.text
.globl main
main:
	
START:
	# Initialize menu
	jal InitializeMenu
	
	# Run Menu Loop
	
	# Initialize Game
	
	# Run Game Loop
	
	
	
	
	
END:
	li $v0, 10 # terminate the program gracefully
	syscall
	
# Functions
# Initializes bitmap display to menu
InitializeMenu:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, 0xffffff # $t1 stores white colour code
	li $t2, 0x000000 # $t2 stores black colour code
	move $t4, $t0
	addi $t5, $t4, 262144
	la $t6, menu_scr
MENULOOP1:
	beq $t4, $t5, MENULOOP2
	lw $t7, 0($t6)
	sw $t7, 0($t4)
	addi $t4, $t4, 4
	addi $t6, $t6, 4
	j MENULOOP1
MENULOOP2:
	jr $ra

# Initializes bitmap display for game
InitializeLevel:

# Draw character at given location
DrawCharacter:

# Draw enemy at given location
DrawEnemy:

# Checks collision with platforms
CheckCollision:

# Checks friendly fire on enemies
CheckFHit:

# Checks enemy fire on player
CheckEHit:

# Draw win screen
Win:

# Draw lose screen
Lose: