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
.eqv TOTAL_LEVELS 3 # Change to 5 later
.eqv CH_HEIGHT 27
.eqv CH_WIDTH 12
.eqv ENM_HEIGHT 26
.eqv ENM_WIDTH 42
.eqv SHOT_HEIGHT 2
.eqv SHOT_WIDTH 8
.eqv GOAL_HEIGHT 22
.eqv GOAL_WIDTH 16
.eqv DARK_BLUE 0x3f48cc
.eqv RED 0xed1c24
.eqv LIGHT_BLUE 0x7092be
.eqv BLACK 0x000000
.eqv YELLOW 0xfff200
.eqv FRAME 40
.eqv COYOTE_TIME 4
.eqv E_SHOT_COOLDOWN 40
.eqv F_SHOT_COOLDOWN 100
.eqv BULLET_SPEED 12
.eqv GUN_LEVEL 2

.include "bitmap_buffer.asm"
.include "menu.asm"
.include "menuarrow.asm"
.include "background1.asm"
.include "background2.asm"
.include "background3.asm"
.include "Level1Info.asm"
.include "Level2Info.asm"
.include "Level3Info.asm"
.include "Ch_Right.asm"
.include "Ch_Left.asm"
.include "Ch_Right_Gun.asm"
.include "Ch_Left_Gun.asm"
.include "Enemy_Right.asm"
.include "Enemy_Left.asm"
.include "GunReady.asm"
.include "GunCharging.asm"
.include "Door.asm"
.include "Heart.asm"
.include "GunSprite.asm"
.include "WinScreen.asm"
.include "LoseScreen.asm"

.data
F_Bullet:	.word 0:4
F_Shot_Timer:	.word 0
E_Bullet:	.word 0:32
E_Shot_Timer:	.word 0:8
CH_Location:	.word 0:2
Goal_Location:	.word 0:2
Player_V_Speed:	.word 0
Player_H_Speed:	.word 0
LEVEL:		.word 2 # Change to 0 later
Health:		.word 0
Airbourne:	.word 0
Character:	.word 0
Redraw:		.word 0
Gun:		.word 0
Gun_Location:	.word 110, 177

Level_Back:	.word 0:TOTAL_LEVELS
Level_Coll:	.word 0:TOTAL_LEVELS
LevelCollCount:	.word 0:TOTAL_LEVELS
LevelEnemy:	.word 0:TOTAL_LEVELS
LevelECount:	.word 0:TOTAL_LEVELS
Characters:	.word 0:4
Enemies:	.word 0:2

# For code reuse purposes
Enemy_Loc:	.word 0:4


debug_space:	.asciiz " "


.text
.globl main
main:
	la $t3, background1
	la $t4, Level_Back
	sw $t3, 0($t4)
	la $t3, background2
	sw $t3, 4($t4)
	la $t3, background3
	sw $t3, 8($t4)
	
	la $t3, Level1PlatColl
	la $t4, Level_Coll
	sw $t3, 0($t4)
	la $t3, Level2PlatColl
	sw $t3, 4($t4)
	la $t3, Level3PlatColl
	sw $t3, 8($t4)
	
	la $t3, Level1PlatNo
	la $t4, LevelCollCount
	sw $t3, 0($t4)
	la $t3, Level2PlatNo
	sw $t3, 4($t4)
	la $t3, Level3PlatNo
	sw $t3, 8($t4)
	
	la $t3, Level1EnemyNo
	la $t4, LevelECount
	sw $t3, 0($t4)
	la $t3, Level2EnemyNo
	sw $t3, 4($t4)
	la $t3, Level3EnemyNo
	sw $t3, 8($t4)
	
	la $t3, Level1Enemy
	la $t4, LevelEnemy
	sw $t3, 0($t4)
	la $t3, Level2Enemy
	sw $t3, 4($t4)
	la $t3, Level3Enemy
	sw $t3, 8($t4)
	
	la $t3, CH_Right
	la $t4, Characters
	sw $t3, 0($t4)
	la $t3, CH_Left
	sw $t3, 4($t4)
	la $t3, Ch_Right_Gun
	sw $t3, 8($t4)
	la $t3, Ch_Left_Gun
	sw $t3, 12($t4)
	
	la $t3, Enemy_Right
	la $t4, Enemies
	sw $t3, 0($t4)
	la $t3, Enemy_Left
	sw $t3, 4($t4)
	
	
	li $s0, -1
	li $s1, -1
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
	
	li $t3, 32
	sw $t3, Player_H_Speed
	
	j LEVELKEYDONE
LEVEL_NO_D:
	li $t1, 97 # a key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVEL_NO_A # If a is pressed
	
	li $t3, -32
	sw $t3, Player_H_Speed
	
	j LEVELKEYDONE
LEVEL_NO_A:
	li $t1, 119 # w key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVEL_NO_W # If w is pressed
	
	# Deny jump if airbourne already, with added coyote time
	lw $t3, Airbourne
	li $t4, COYOTE_TIME
	bge $t3, $t4, LEVELKEYDONE
	
	# Jump
	li $t3, 4
	sw $t3, Airbourne
	li $t3, -55
	sw $t3, Player_V_Speed
	
	j LEVELKEYDONE
LEVEL_NO_W:
	# Player shoot
	
LEVEL_NO_Z:
	# P to restart
	li $t1, 112 # p key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LEVELNOKEY # If p is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	sw $t3, Gun
	j START
	
LEVELNOKEY:
	lw $t3, Airbourne
	bnez $t3, AIRBOURNE_DECAY # If not airbourne
	lw $t3, Player_H_Speed
	li $t4, 2
	div $t3, $t4
	mflo $t3
	sw $t3, Player_H_Speed # Slow horizontal movement
	j LEVELKEYDONE
AIRBOURNE_DECAY:
	lw $t3, Player_H_Speed
	bltz $t3, DECAYLEFT
	addi $t3, $t3, -4
	sw $t3, Player_H_Speed
	bgez $t3, LEVELKEYDONE
	li $t3, 0
	sw $t3, Player_H_Speed
	j LEVELKEYDONE
DECAYLEFT:
	addi $t3, $t3, 4
	sw $t3, Player_H_Speed
	blez $t3, LEVELKEYDONE
	li $t3, 0
	sw $t3, Player_H_Speed
LEVELKEYDONE:

	# Apply Horizontal Movement
	lw $t3, Player_H_Speed
	
	beqz $t3, NO_H_SPEED
	li $t4, 1
	sw $t4, Redraw
	lw $s0, CH_Location
	
	la $t5, CH_Location
	lw $t4, 0($t5) # player x coordinate
	sra $t3, $t3, 3 # speed // 8
	add $t4, $t4, $t3 # add speed to x
	sw $t4, 0($t5) # store new x coordinate
	bltz $t3, NOT_RIGHT # Check if player is going right
	
	# Make character face right
	lw $t3, Character
	srl $t3, $t3, 1
	sll $t3, $t3, 1
	sw $t3, Character
	
	li $a0, 0
	jal CheckAllCollision
	j NO_H_SPEED
NOT_RIGHT:
	# Make character face left
	lw $t3, Character
	srl $t3, $t3, 1
	sll $t3, $t3, 1
	addi $t3, $t3, 1
	sw $t3, Character
	
	li $a0, 1
	jal CheckAllCollision
NO_H_SPEED:
	# Check grounded, apply gravity, apply horizontal and vertical speed
	lw $t3, Player_V_Speed
	
	beqz $t3, GRAVITY
	li $t4, 1
	sw $t4, Redraw
	lw $s1, CH_Location + 4
	
	la $t5, CH_Location
	lw $t4, 4($t5) # player y coordinate
	sra $t3, $t3, 3 # speed // 8
	add $t4, $t4, $t3 # add speed to y
	sw $t4, 4($t5) # store new y coordinate
	bgez $t3, GRAVITY # no need to check upwards collision if falling
	# Check for roof collision
	li $a0, 3
	jal CheckAllCollision
GRAVITY:
	lw $t3, Player_V_Speed
	addi $t3, $t3, 4
	sw $t3, Player_V_Speed # Update speed
	# Set airbourne, if collision airbourne will reset
	lw $t3, Airbourne
	addi $t3, $t3, 1
	sw $t3, Airbourne
	# Check for collision
	li $a0, 2
	jal CheckAllCollision
	
	
	lw $t3, Redraw
	beqz $t3, NO_REDRAW1
	move $a0, $s0
	move $a1, $s1
	bgez $a0, REDRAW1
	lw $a0, CH_Location
REDRAW1:
	bgez $a1, REDRAW2
	lw $a1, CH_Location + 4
REDRAW2:
	li $s0, -1
	li $s1, -1
	jal EraseCharacter
	
	jal DrawCharacter
	li $t3, 0
	sw $t3, Redraw
NO_REDRAW1:
	
	# Enemies shoot
	jal EnemyShoot
	
	# Move enemy bullets
	jal EnemyFireMove
	
	# Move player bullet
	
	# Update Gun Cooldown
	
	# Check Gun Pickup
	lw $t0, LEVEL
	li $t1, GUN_LEVEL
	bne $t0, $t1, WINCON
	lw $t0, Gun
	bnez $t0, WINCON
	lw $t0, CH_Location
	lw $t1, CH_Location + 4
	# Check if touching gun sprite
	li $t2, 98
	ble $t0, $t2, WINCON
	li $t2, 122
	bge $t0, $t2, WINCON
	li $t2, 150
	ble $t1, $t2, WINCON
	# Gun Get!
	li $t0, 1
	sw $t0, Gun
	li $t0, 0
	sw $t0, F_Shot_Timer
	lw $t0, Character
	ori $t0, 2
	sw $t0, Character
	jal DrawGunReady
	jal EraseGunSprite
	jal DrawCharacter
	
	# Check win condition
WINCON:
	lw $t3, CH_Location
	li $t4, 226
	ble $t3, $t4, NOT_WIN
	lw $t3, CH_Location + 4
	li $t4, 31
	bgt $t3, $t4, NOT_WIN
	lw $t5, LEVEL
	addi $t5, $t5, 1
	sw $t5, LEVEL
	li $t6, TOTAL_LEVELS
	beq $t5, $t6, Win
	j MENULOOPEND
	
NOT_WIN:
	
	# Sleep
	li $v0, 32
	li $a0, FRAME
	syscall
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
	
	# Draw door
	jal DrawDoor
	
	# Draw Enemies
	jal DrawEnemies
	
	# Draw Hearts
	li $t0, 3
	sw $t0, Health
	jal DrawHearts
	
	# Initialize Enemy shot timers
	lw $t0, LEVEL
	la $t1, LevelECount
	sll $t0, $t0, 2 # times 4
	add $t1, $t1, $t0
	lw $t1, 0($t1)
	lw $t1, 0($t1) # number of enemies
	li $t2, 0
	la $t3, E_Bullet
	la $t4, E_Shot_Timer
	li $t5, 0
	# Also initialize friendly shot timer
	sw $t5, F_Bullet
	sw $t5, F_Shot_Timer
	lw $t6, Gun
	li $t7, 40
	bnez $t6, SHOTINITLOOP
	li $t7, 20000
	sw $t7, F_Shot_Timer
	li $t7, E_SHOT_COOLDOWN
SHOTINITLOOP:
	beq $t2, $t1, SHOTINITDONE
	sw $t5, 0($t3)
	sw $t7, 0($t4)
	addi $t3, $t3, 16
	addi $t4, $t4, 4
	addi $t2, $t2, 1
	j SHOTINITLOOP
SHOTINITDONE:
	
	# Setup gun pickup
	lw $t0, LEVEL
	li $t1, GUN_LEVEL
	bne $t0, $t1, NOTGUNLEVEL
	jal DrawGunSprite
	
NOTGUNLEVEL:
	# Draw gun on toolbar
	lw $t0, Gun
	beqz $t0, INITNOGUN
	jal DrawGunReady
	
INITNOGUN:
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
	
# Erase character from given location, stored in a0 and a1
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
	move $t5, $a0 # x coordinate
	move $t7, $a1 # y coordinate
	li $t6, 256
	mult $t6, $t7
	mflo $t7 # y * 256
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

# Draw all enemies
DrawEnemies:
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelECount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of enemies (address)
	lw $a3, 0($t4)
	
	la $t5, LevelEnemy
	add $t5, $t2, $t5
	lw $a2, 0($t5) # enemy data
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # Store return value
	addi $sp, $sp, -8 # Two word spaces in stack
	li $t6, 0
	sw $t6, 0($sp) # Counter variable
	sw $a2, 4($sp) # Enemy data (pointer)
ENMDRAWLOOP:
	lw $t0, 0($sp) # Get counter variable
	bge $t0, $a3, ENMDRAWDONE # branch if counter >= no of enemies
	lw $t0, 4($sp) # Get enemy data
	lw $a0, 0($t0) # Enemy x
	lw $a1, 4($t0) # Enemy y
	lw $a2, 8($t0) # Enemy model
	jal DrawEnemy # Draw enemy
	# Increment counter
	lw $t0, 0($sp)
	addi $t0, $t0, 1
	sw $t0, 0($sp)
	# Increment enemy data pointer
	lw $t0, 4($sp)
	addi $t0, $t0, 12
	sw $t0, 4($sp)
	j ENMDRAWLOOP
ENMDRAWDONE:
	addi $sp, $sp, 8
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# Draw enemy at given location
# a0: x coordinate, a1: y coordinate, a2: which model
DrawEnemy:
	li $t0, BASE_ADDRESS
	la $t1, Enemies
	li $t2, 4
	mult $a2, $t2
	mflo $t2
	add $t1, $t1, $t2
	lw $t1, 0($t1)
	
	li $t2, 0
	li $t3, 42
	
	addi $t4, $t1, 4368
	li $t5, 256
	mult $t5, $a1
	mflo $t5
	add $t5, $t5, $a0
	li $t6, 4
	mult $t5, $t6
	mflo $t5
	add $t0, $t5, $t0
ENEMYLOOP1:
	beq $t1, $t4, ENEMYDRAWN
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, ENEMYJUMP1
	li $t2, 0
	addi $t0, $t0, 856 # Next line
ENEMYJUMP1:
	j ENEMYLOOP1
ENEMYDRAWN:
	jr $ra

# Draws and clears hearts
DrawHearts:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $a0, 106
	li $a1, 208
	jal EraseHeart
	lw $t0, Health
	li $t1, 3
	blt $t0, $t1, TWOHP
	li $a0, 106
	li $a1, 208
	jal DrawHeart
TWOHP:
	li $a0, 156
	jal EraseHeart
	lw $t0, Health
	li $t1, 2
	blt $t0, $t1, ONEHP
	jal DrawHeart
ONEHP:
	li $a0, 206
	jal EraseHeart
	lw $t0, Health
	blez $t0, ZEROHP
	jal DrawHeart
ZEROHP:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Draws a heart
# a0 stores x coordinate, a1 stores y coordinate
DrawHeart:
	li $t0, BASE_ADDRESS
	la $t1, Heart
	
	li $t2, 0
	li $t3, 41
	
	addi $t4, $t1, 6232
	li $t5, 256
	mult $t5, $a1
	mflo $t5
	add $t5, $t5, $a0
	li $t6, 4
	mult $t5, $t6
	mflo $t5
	add $t0, $t5, $t0
HEARTLOOP1:
	beq $t1, $t4, HEARTDRAWN
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, HEARTJUMP1
	li $t2, 0
	addi $t0, $t0, 860 # Next line
HEARTJUMP1:
	j HEARTLOOP1
HEARTDRAWN:
	jr $ra

# Erases a heart
# a0 stores x coordinate, a1 stores y coordinate
EraseHeart:
	li $t0, BASE_ADDRESS
	lw $t1, LEVEL
	la $t2, Level_Back
	sll $t1, $t1, 2 # times 4
	add $t2, $t2, $t1
	lw $t3, 0($t2)
	move $t4, $t3
	addi $t4, $t4, 38912
	
	move $t5, $a0 # x coordinate
	move $t7, $a1 # y coordinate
	li $t6, 256
	mult $t6, $t7
	mflo $t7 # y * 256
	add $t7, $t7, $t5
	li $t6, 4
	mult $t6, $t7
	mflo $t7
	
	add $t0, $t0, $t7 # add (y * 256 + x) * 4
	add $t4, $t4, $t7
	add $t3, $t3, $t7
	li $t6, 0
	li $t7, 41
	
HEARTLOOP2:
	beq $t3, $t4, HEARTERASED
	lw $t5, 0($t3)
	sw $t5, 0($t0)
	addi $t3, $t3, 4
	addi $t0, $t0, 4
	addi $t6, $t6, 1
	bne $t6, $t7, HEARTJUMP2
	li $t6, 0
	addi $t0, $t0, 860 # Next line
	addi $t3, $t3, 860
HEARTJUMP2:
	j HEARTLOOP2
HEARTERASED:
	jr $ra
	
# Draws the gun sprite
DrawGunSprite:
	li $t0, BASE_ADDRESS
	la $t1, GunSprite
	
	li $t2, 0
	li $t3, 12
	
	addi $t4, $t1, 960
	
	lw $t5, Gun_Location + 4
	sll $t5, $t5, 8 # multiply by 256
	lw $t6, Gun_Location
	add $t5, $t5, $t6
	sll $t5, $t5, 2 # multiply by 4
	add $t0, $t5, $t0
GUNSPRITELOOP1:
	beq $t1, $t4, GUNSPRITEDRAWN
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, GUNSPRITEJUMP1
	li $t2, 0
	addi $t0, $t0, 976 # Next line
GUNSPRITEJUMP1:
	j GUNSPRITELOOP1
GUNSPRITEDRAWN:
	jr $ra

# Erases the gun sprite
EraseGunSprite:
	li $t0, BASE_ADDRESS
	lw $t1, LEVEL
	la $t2, Level_Back
	sll $t1, $t1, 2 # times 4
	add $t2, $t2, $t1
	lw $t3, 0($t2)
	move $t4, $t3
	addi $t4, $t4, 20480
	
	lw $t5, Gun_Location # x coordinate
	lw $t7, Gun_Location + 4 # y coordinate
	li $t6, 256
	mult $t6, $t7
	mflo $t7 # y * 256
	add $t7, $t7, $t5
	li $t6, 4
	mult $t6, $t7
	mflo $t7
	
	add $t0, $t0, $t7 # add (y * 256 + x) * 4
	add $t4, $t4, $t7
	add $t3, $t3, $t7
	li $t6, 0
	li $t7, 12
	
GUNSPRITELOOP2:
	beq $t3, $t4, GUNSPRITEERASED
	lw $t5, 0($t3)
	sw $t5, 0($t0)
	addi $t3, $t3, 4
	addi $t0, $t0, 4
	addi $t6, $t6, 1
	bne $t6, $t7, GUNSPRITEJUMP2
	li $t6, 0
	addi $t0, $t0, 976 # Next line
	addi $t3, $t3, 976
GUNSPRITEJUMP2:
	j GUNSPRITELOOP2
GUNSPRITEERASED:
	jr $ra

# Draws a bullet
# a0 stores x coordinate, a1 stores y coordinate, a2 stores colour
DrawBullet:
	li $t0, BASE_ADDRESS
	sll $t1, $a1, 8 # y times by 256
	add $t1, $t1, $a0 # add x
	sll $t1, $t1, 2 # times 4
	add $t0, $t0, $t1 # add to t0
	sw $a2, 0($t0)
	sw $a2, 4($t0)
	sw $a2, 8($t0)
	sw $a2, 12($t0)
	sw $a2, 16($t0)
	sw $a2, 20($t0)
	sw $a2, 24($t0)
	sw $a2, 28($t0)
	sw $a2, 1024($t0)
	sw $a2, 1028($t0)
	sw $a2, 1032($t0)
	sw $a2, 1036($t0)
	sw $a2, 1040($t0)
	sw $a2, 1044($t0)
	sw $a2, 1048($t0)
	sw $a2, 1052($t0)
	jr $ra

# Erases a bullet
# a0 stores x coordinate, a1 stores y coordinate
EraseBullet:
	li $t0, BASE_ADDRESS
	lw $t1, LEVEL
	la $t2, Level_Back
	sll $t1, $t1, 2 # times 4
	add $t2, $t2, $t1
	lw $t1, 0($t2) # level background pointer
	
	sll $t2, $a1, 8 # y times by 256
	add $t2, $t2, $a0 # add x
	sll $t2, $t2, 2 # times 4
	add $t0, $t0, $t2 # add to t0
	add $t1, $t1, $t2 # add to t1
	
	# Erase
	lw $t2, 0($t1)
	sw $t2, 0($t0)
	lw $t2, 4($t1)
	sw $t2, 4($t0)
	lw $t2, 8($t1)
	sw $t2, 8($t0)
	lw $t2, 12($t1)
	sw $t2, 12($t0)
	lw $t2, 16($t1)
	sw $t2, 16($t0)
	lw $t2, 20($t1)
	sw $t2, 20($t0)
	lw $t2, 24($t1)
	sw $t2, 24($t0)
	lw $t2, 28($t1)
	sw $t2, 28($t0)
	lw $t2, 1024($t1)
	sw $t2, 1024($t0)
	lw $t2, 1028($t1)
	sw $t2, 1028($t0)
	lw $t2, 1032($t1)
	sw $t2, 1032($t0)
	lw $t2, 1036($t1)
	sw $t2, 1036($t0)
	lw $t2, 1040($t1)
	sw $t2, 1040($t0)
	lw $t2, 1044($t1)
	sw $t2, 1044($t0)
	lw $t2, 1048($t1)
	sw $t2, 1048($t0)
	lw $t2, 1052($t1)
	sw $t2, 1052($t0)
	jr $ra
	
# Draws the door
DrawDoor:
	li $t0, BASE_ADDRESS
	la $t1, door
	li $t2, 0
	li $t3, 16
	move $t4, $t1
	addi $t4, $t4, 1408
	addi $t0, $t0, 11200 #3008 #936
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

# Draws ready gun in the toolbar
DrawGunReady:
	li $t0, BASE_ADDRESS
	la $t1, GunReady
	li $t2, 0
	li $t3, 100
	move $t4, $t1
	addi $t4, $t4, 22400
	addi $t0, $t0, 204800 #3008 #936
DRAWGUNLOOP1:
	beq $t1, $t4, GUNDRAWN1
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, DRAWGUNJUMP1
	li $t2, 0
	addi $t0, $t0, 624 # Next line
DRAWGUNJUMP1:
	j DRAWGUNLOOP1
GUNDRAWN1:
	jr $ra

# Draw charging gun in the toolbar
DrawGunCharging:
	li $t0, BASE_ADDRESS
	la $t1, GunCharging
	li $t2, 0
	li $t3, 100
	move $t4, $t1
	addi $t4, $t4, 22400
	addi $t0, $t0, 204800 #3008 #936
DRAWGUNLOOP2:
	beq $t1, $t4, GUNDRAWN2
	lw $t5, 0($t1)
	sw $t5, 0($t0)
	addi $t1, $t1, 4
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, DRAWGUNJUMP2
	li $t2, 0
	addi $t0, $t0, 624 # Next line
DRAWGUNJUMP2:
	j DRAWGUNLOOP2
GUNDRAWN2:
	jr $ra

# Checks collision with platforms
# Stored in a0: 0 for left side, 1 for right, 2 for top, 3 for bottom
CheckAllCollision:
	# Check collision for all enemies
	li $a1, 0
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelECount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of enemies (address)
	lw $a3, 0($t4)
	
	la $t5, LevelEnemy
	add $t5, $t2, $t5
	lw $a2, 0($t5) # enemy data
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # Store return value
	addi $sp, $sp, -8 # Two word spaces in stack
	li $t6, 0
	sw $t6, 0($sp) # Counter variable
	sw $a2, 4($sp) # Enemy data (pointer)
	li $a1, 0
	la $a2, Enemy_Loc
ENMCOLLLOOP:
	lw $t0, 0($sp) # Get counter variable
	bge $t0, $a3, ENMCOLLDONE # branch if counter >= no of enemies
	lw $t0, 4($sp) # Get enemy data
	lw $t1, 0($t0) # Enemy x
	lw $t2, 4($t0) # Enemy y
	sw $t1, 0($a2)
	sw $t2, 8($a2)
	addi $t1, $t1, ENM_WIDTH
	addi $t1, $t1, -1
	addi $t2, $t2, ENM_HEIGHT
	addi $t2, $t2, -1
	sw $t1, 4($a2)
	sw $t2, 12($a2) # $a2 now stores enemy location data
	jal CheckCollision # Check collision for that enemy
	# Increment counter
	lw $t0, 0($sp)
	addi $t0, $t0, 1
	sw $t0, 0($sp)
	# Increment enemy data pointer
	lw $t0, 4($sp)
	addi $t0, $t0, 12
	sw $t0, 4($sp)
	j ENMCOLLLOOP
ENMCOLLDONE:
	addi $sp, $sp, 8 # Free the two spaces taken from stack

	# Check collision for all platforms
	li $a1, 0
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelCollCount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of platforms (address)
	lw $a3, 0($t4)
	
	la $t5, Level_Coll
	add $t5, $t2, $t5
	lw $a2, 0($t5) # platform data
COLLLOOP:
	beq $a1, $a3, BOUNDARYCHECK # break loop
	jal CheckCollision
	addi $a1, $a1, 1
	j COLLLOOP
	
	# Check collision for boundaries of screen
BOUNDARYCHECK:
	lw $ra, 0($sp) # Get return value
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
	sw $t1, 0($t4)
	
	# If vertical reset vertical speed, set airbourne to 0
	beqz $t7, HORIZONTAL1
	li $t6, 0
	sw $t6, Player_V_Speed
	sw $t6, Airbourne
	j COLLDONE2
	
HORIZONTAL1:
	li $t6, 0
	sw $t6, Player_H_Speed
	
	j COLLDONE2
BOUNDGREATER:
	bgt $t3, $t1, COLLDONE2
	addi $t1, $t1, 1
	sw $t1, 0($t4)
	
	# If vertical, reset vertical speed
	beqz $t7, HORIZONTAL2
	li $t6, 0
	sw $t6, Player_V_Speed
	j COLLDONE2

HORIZONTAL2:
	li $t6, 0
	sw $t6, Player_H_Speed
	
COLLDONE2:
	jr $ra

# Stored in a0: which side
# Stored in a1: Which platform, in a2: level data address for this level
CheckCollision:
	move $t1, $a1 # which platform
	move $t0, $a0 # which side
	li $t2, 16
	mult $t1, $t2
	mflo $t1
	add $t1, $t1, $a2 # pointer to the platform in question
	
	# Check left side
	lw $t3, 0($t1) # left side x value
	subi $t3, $t3, CH_WIDTH
	lw $t4, CH_Location # x coordinate
	ble $t4, $t3, COLLDONE1
	# Check right side
	lw $t3, 4($t1) # right side x value
	bgt $t4, $t3, COLLDONE1
	# Check top side
	lw $t3, 8($t1) # top side y value
	subi $t3, $t3, CH_HEIGHT
	lw $t4, CH_Location + 4 # y coordinate
	ble $t4, $t3, COLLDONE1
	# Check bottom side
	lw $t3, 12($t1) # bottom side y value
	bgt $t4, $t3, COLLDONE1
	
	# Move character
	li $t2, 4
	mult $t0, $t2
	mflo $t0
	add $t1, $t1, $t0 # points to the side in question
	andi $t6, $a0, 2
	bnez $t6, UPDOWN
	la $t3, CH_Location 
	li $t4, CH_WIDTH
	la $t5, Player_H_Speed
	j CHECK1
UPDOWN:
	la $t3, CH_Location + 4
	li $t4, CH_HEIGHT
	la $t5, Player_V_Speed
CHECK1:
	andi $t6, $a0, 1
	bnez $t6, GREATERTHAN
	li $t6, 0
	sw $t6, 0($t5) # set relevent speed to 0
	lw $t6, 0($t1) # location of collision side
	sub $t6, $t6, $t4 # offset by ch size
	sw $t6, 0($t3) # set new ch location
	# check airbourne
	andi $t6, $a0, 2
	beqz $t6, COLLDONE1
	li $t6, 0
	sw $t6, Airbourne
	j COLLDONE1
GREATERTHAN:
	li $t6, 0
	sw $t6, 0($t5) # set relevent speed to 0
	lw $t6, 0($t1) # location of collision side
	addi $t6, $t6, 1 # offset by 1
	sw $t6, 0($t3) # set new ch location
COLLDONE1:
	jr $ra

# Makes the enemies shoot, then decrements the timer
EnemyShoot:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -16 # get 4 spaces
	lw $t0, LEVEL
	sll $t0, $t0, 2
	la $t1, LevelECount
	add $t1, $t1, $t0
	lw $t1, 0($t1)
	lw $t1, 0($t1) # LevelECount (number)
	sw $t1, 0($sp)
	la $t2, LevelEnemy
	add $t2, $t2, $t0
	lw $t2, 0($t2) # LevelEnemy (pointer)
	sw $t2, 4($sp)
	la $t3, E_Shot_Timer # E_Shot_Timer (pointer)
	sw $t3, 8($sp)
	la $t4, E_Bullet # E_Bullet (pointer)
	sw $t4, 12($sp)
	li $a3, 0
ESHOOTLOOP:
	lw $t0, 0($sp) # LevelECount
	beq $a3, $t0, ESHOOTDONE
	lw $t1, 8($sp) # E_Shot_Timer
	lw $t2, 0($t1)
	bnez $t2, ENOSHOT
	# reset shot timer
	li $t2, E_SHOT_COOLDOWN
	sw $t2, 0($t1)
	
	lw $t3, 12($sp) # E_Bullet
	lw $t4, 4($sp) # Enemy that's shooting
	li $t5, 1
	sw $t5, 0($t3) # Shot now exists
	lw $t5, 4($t4) # y coordinate of enemy
	addi $t5, $t5, 5
	sw $t5, 8($t3) # y coordinate of shot
	lw $t5, 8($t4) # which way enemy is facing
	sw $t5, 12($t3) # which way shot is facing
	bnez $t5, ESHOOTLEFT
	lw $t5, 0($t4) # x coordinate of enemy
	addi $t5, $t5, 42
	sw $t5, 4($t3) # x coordinate of shot
	j ESHOOTCONTINUE
ESHOOTLEFT:
	lw $t5, 0($t4) # x coordinate of enemy
	addi $t5, $t5, -8
	sw $t5, 4($t3) # x coordinate of shot
ESHOOTCONTINUE:
	lw $a0, 4($t3)
	lw $a1, 8($t3)
	li $a2, RED
	jal DrawBullet
ENOSHOT:
	addi $a3, $a3, 1 # increment counter
	lw $t0, 4($sp)
	addi $t0, $t0, 12 # increment enemy pointer
	sw $t0, 4($sp)
	lw $t0, 8($sp)
	# Decrement shot cooldown
	lw $t1, 0($t0)
	addi $t1, $t1, -1
	sw $t1, 0($t0)
	
	addi $t0, $t0, 4 # increment shot timer pointer
	sw $t0, 8($sp)
	lw $t0, 12($sp)
	addi $t0, $t0, 16 # increment bullet pointer
	sw $t0, 12($sp)
	j ESHOOTLOOP
ESHOOTDONE:
	# free stack space
	addi $sp, $sp, 16
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# Moves enemy bullets
EnemyFireMove:
	# Loop through each bullet
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -20 # get 5 spaces
	lw $t0, LEVEL
	sll $t0, $t0, 2 # times 4
	la $t1, LevelECount
	add $t1, $t1, $t0
	lw $t1, 0($t1)
	lw $t1, 0($t1) # LevelECount (number)
	sw $t1, 0($sp)
	la $t2, LevelEnemy
	add $t2, $t2, $t0
	lw $t2, 0($t2) # LevelEnemy (pointer)
	sw $t2, 4($sp)
	la $t3, E_Shot_Timer # E_Shot_Timer (pointer)
	sw $t3, 8($sp)
	la $t4, E_Bullet # E_Bullet (pointer)
	sw $t4, 12($sp)
	li $t4, 0 # Counter
	sw $t4, 16($sp)
EBULLETLOOP:
	lw $t0, 0($sp) # LevelECount
	lw $t1, 16($sp) # Counter
	beq $t1, $t0, EMOVEDONE

	lw $t0, 12($sp) # bullet info
	lw $t1, 0($t0)
	beqz $t1, ENOBULLET # check if shot exists
	
	# Erase the bullet
	lw $t0, 12($sp)
	lw $a0, 4($t0)
	lw $a1, 8($t0)
	jal EraseBullet
	
	# Move the bullet
	lw $t0, 12($sp)
	lw $t1, 4($t0)
	lw $t2, 12($t0)
	bnez $t2, ELEFTBULLET
	addi $t1, $t1, BULLET_SPEED
	j EMOVEBULLET
ELEFTBULLET:
	subi $t1, $t1, BULLET_SPEED
EMOVEBULLET:
	sw $t1, 4($t0)
	
	# Check collision with Player
	lw $a0, 12($sp) # bullet data
	jal EHit
	lw $t0, 12($sp)
	lw $t1, 0($t0)
	beqz $t1, ENOBULLET # if bullet gone, no need to check collision anymore
	
	# Check collision with other things
	lw $a0, 12($sp) # bullet data
	jal EShotColl
	
	# If bullet still exists, draw bullet
	lw $t0, 12($sp)
	lw $t1, 0($t0)
	beqz $t1, ENOBULLET
	lw $a0, 4($t0)
	lw $a1, 8($t0)
	jal DrawBullet
	
ENOBULLET:
	# Increment data
	lw $t0, 4($sp)
	addi $t0, $t0, 12 # increment enemy pointer
	sw $t0, 4($sp)
	lw $t0, 8($sp)
	addi $t0, $t0, 4 # increment shot timer pointer
	sw $t0, 8($sp)
	lw $t0, 12($sp)
	addi $t0, $t0, 16 # increment bullet pointer
	sw $t0, 12($sp)
	lw $t0, 16($sp)
	addi $t0, $t0, 1 # increment counter
	sw $t0, 16($sp)
	
	j EBULLETLOOP
EMOVEDONE:
	# free stack space
	addi $sp, $sp, 20
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# Checks friendly fire collision
CheckFHit:

# Checks enemy fire collision
# Stored in a0: bullet data
CheckEHit:

# Checks if shot collided with platforms/enemies/border
# Stored in a0: bullet data
EShotColl:
	# Check collision for all enemies
	li $a1, 0
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelECount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of enemies (address)
	lw $a3, 0($t4)
	
	la $t5, LevelEnemy
	add $t5, $t2, $t5
	lw $a2, 0($t5) # enemy data
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # Store return value
	addi $sp, $sp, -8 # Two word spaces in stack
	li $t6, 0
	sw $t6, 0($sp) # Counter variable
	sw $a2, 4($sp) # Enemy data (pointer)
	li $a1, 0
	la $a2, Enemy_Loc
ENMCOLLLOOP2:
	lw $t0, 0($sp) # Get counter variable
	bge $t0, $a3, ENMCOLLDONE2 # branch if counter >= no of enemies
	lw $t0, 4($sp) # Get enemy data
	lw $t1, 0($t0) # Enemy x
	lw $t2, 4($t0) # Enemy y
	sw $t1, 0($a2)
	sw $t2, 8($a2)
	addi $t1, $t1, ENM_WIDTH
	addi $t1, $t1, -1
	addi $t2, $t2, ENM_HEIGHT
	addi $t2, $t2, -1
	sw $t1, 4($a2)
	sw $t2, 12($a2) # $a2 now stores enemy location data
	jal ShotPlatformColl # Check collision for that enemy
	# Increment counter
	lw $t0, 0($sp)
	addi $t0, $t0, 1
	sw $t0, 0($sp)
	# Increment enemy data pointer
	lw $t0, 4($sp)
	addi $t0, $t0, 12
	sw $t0, 4($sp)
	
	# If bullet no longer exists, break loop
	lw $t0, 0($a0)
	beqz $t0, ENMCOLLDONE2
	j ENMCOLLLOOP2
ENMCOLLDONE2:
	addi $sp, $sp, 8 # Free the two spaces taken from stack

	# Check collision for all platforms
	li $a1, 0
	lw $t0, LEVEL
	li $t1, 4
	mult $t0, $t1
	mflo $t2 # level * 4
	la $t5, LevelCollCount
	add $t5, $t2, $t5
	lw $t4, 0($t5) # number of platforms (address)
	lw $a3, 0($t4)
	
	la $t5, Level_Coll
	add $t5, $t2, $t5
	lw $a2, 0($t5) # platform data
COLLLOOP2:
	beq $a1, $a3, BOUNDARYCHECK2 # break loop
	jal ShotPlatformColl
	addi $a1, $a1, 1
	# If bullet no longer exists, break loop
	lw $t0, 0($a0)
	beqz $t0, BOUNDARYCHECK2
	j COLLLOOP2
	
	# Check collision for boundaries of screen
BOUNDARYCHECK2:

	lw $ra, 0($sp) # Get return value
	addi $sp, $sp, 4
	
	lw $t0, 4($a0) # x coordinate
	li $t4, 248 # right border
	bgt $t0, $t4, HIT1
	bltz $t0, HIT1 # left border
	
	# Boundary has not been hit
	jr $ra
HIT1:
	li $t0, 0
	sw $t0, 0($a0) # delete bullet
	jr $ra

# Checks if shot collided with platform
# Stored in a0: bullet data
# Stored in a1: Which platform, in a2: level data address for this level
ShotPlatformColl:
	move $t1, $a1 # which platform
	move $t0, $a0 # which side
	li $t2, 16
	mult $t1, $t2
	mflo $t1
	add $t1, $t1, $a2 # pointer to the platform in question
	
	# Check left side
	lw $t3, 0($t1) # left side x value
	subi $t3, $t3, SHOT_WIDTH
	lw $t4, 4($a0) # x coordinate
	ble $t4, $t3, COLLDONE3
	# Check right side
	lw $t3, 4($t1) # right side x value
	bgt $t4, $t3, COLLDONE3
	# Check top side
	lw $t3, 8($t1) # top side y value
	subi $t3, $t3, SHOT_HEIGHT
	lw $t4, 8($a0) # y coordinate
	ble $t4, $t3, COLLDONE3
	# Check bottom side
	lw $t3, 12($t1) # bottom side y value
	bgt $t4, $t3, COLLDONE3
	
	# Delete bullet
	li $t0, 0
	sw $t0, 0($a0)
COLLDONE3:

	
	jr $ra

# Checks if friendly shot collided with enemy
# Stored in a0: enemy data
FHit:

# Checks if enemy shot collided with friendly
# Stored in a0: bullet data
EHit:
	lw $t0, 4($a0) # x coordinate
	lw $t1, 8($a0) # y coordinate
	lw $t2, CH_Location # x coordinate
	lw $t3, CH_Location + 4 # y coordinate
	subi $t4, $t2, SHOT_WIDTH
	ble $t0, $t4, NOHIT1
	addi $t4, $t2, CH_WIDTH
	bge $t0, $t4, NOHIT1
	subi $t4, $t3, SHOT_HEIGHT
	ble $t1, $t4, NOHIT1
	addi $t4, $t3, CH_HEIGHT
	bge $t1, $t4, NOHIT1
	
	# Player has been hit
	li $t0, 0
	sw $t0, 0($a0) # delete bullet
	lw $t0, Health
	addi $t0, $t0, -1
	sw $t0, Health # decrement health
	
	# redraw hearts
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal DrawHearts
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	# Check if health = 0
	lw $t0, Health
	bnez $t0, NOHIT1
	# At 0 health
	addi $sp, $sp, 20 # free stack space: 20 from EnemyFireMove, for which this is a helper function
	j Lose
NOHIT1:
	jr $ra

# Draw win screen
Win:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	addi $t5, $t0, 262144
	la $t1, WinScreen
WINLOOP1:
	beq $t0, $t5, WINLOOP2
	lw $t6, 0($t1)
	sw $t6, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j WINLOOP1
WINLOOP2:
	# Check Player input
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	li $t1, 1
	bne $t8, $t1, WINLOOP2
	
	# z to select
	li $t1, 122 # z key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, WIN_NO_Z # If z is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	sw $t3, Gun
	j START
WIN_NO_Z:
	# P to restart
	li $t1, 112 # p key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, WINLOOP2 # If p is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	sw $t3, Gun
	j START

# Draw lose screen
Lose:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	addi $t5, $t0, 262144
	la $t1, LoseScreen
LOSELOOP1:
	beq $t0, $t5, LOSELOOP2
	lw $t6, 0($t1)
	sw $t6, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j LOSELOOP1
LOSELOOP2:
	# Check Player input
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	li $t1, 1
	bne $t8, $t1, LOSELOOP2
	
	# z to select
	li $t1, 122 # z key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LOSE_NO_Z # If z is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	sw $t3, Gun
	j START
LOSE_NO_Z:
	# P to restart
	li $t1, 112 # p key ascii code
	lw $t2, 4($t9) # Key pressed
	bne $t1, $t2, LOSELOOP2 # If p is pressed
	jal ClearScreen
	li $t3, 0
	sw $t3, LEVEL
	sw $t3, Character
	sw $t3, Gun
	j START

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



# Debug Code
	move $v1, $a0
	li $v0, 1
	move $a0, $s0
	syscall
	li $v0, 4
	la $a0, debug_space
	syscall
	li $v0, 32
	li $a0, 1000
	syscall
	move $a0, $v1
