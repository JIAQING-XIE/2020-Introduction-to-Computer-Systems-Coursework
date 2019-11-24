
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
print_char1:      .asciiz" H " 			# print " H "
print_char2:      .asciiz" V "			# print " V "
print_char3:      .asciiz" D "			# print " D "
print_string1:    .asciiz"-1\n"			# print" -1\n"
print_string2:    .asciiz","			# print ","
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)

.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # (maximum size of each word + \n) + NULL
# You can add your data here!
.align 4  
dictionary_idx:         .space 1057

word:   		.space 15

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     	# Declare main label to be globally visible.
                                	# Needed for correct operation with MARS
main:	
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
# l promise that all the codes below are written by myself 
#And l never tell others my code until the deadline has been over.

			 li $t0, 0   					# idx = 0
			 li $t1, 0					# $t1 is used to reserve grid(idx)
			 li $t2, 0					# $t2 is used to reserve length_row
length_calculation:
			 lb $t1,grid($t0)				# $t1 = grid(idx)
			 addi $t0,$t0,1					# else idx= idx+1;
			 addi $t2,$t2,1					# length_row++;
			 bne $t1,10,length_calculation			# if grid(idx)!='\n', then loop
			 addi $s0,$t2,0  				# length_row is reserved in $s0
# end_calculation:
# begin store_loop:
			 li $t0,0					# $t0 is used to reserve idx,initial_value = 0
			 li $t1,0					# $t1 is used to reserve dictionary()
			 li $t2,0					# $t2 is used to reserve dict_idx
			 li $t3,0					# $t3 is given to dictionary_idx(dict_idx)  
			 li $s1,0					# $s4 is used to reserve dict_num_words
Store_loop:    								# do{
       			 lb $t1, dictionary($t0)  			# c_iput = dictionary(idx)						
      			 beq $t1, 0, outof_storeloop	  		# c_input == '\0', then break
        		 bne $t1, 10, continue 				# c_input != '\n', then idx = idx +1 and again loop
        		 sw $t3,dictionary_idx($t2)     		# dictionary_idx[dict_idx ] = start_idx
       			 addi $t2, $t2, 4				# dict_idx ++
       			 addi $t3, $t0, 1 				# start_idx = idx + 1
continue: 		 addi $t0, $t0, 1 				# idx += 1  
               		 j Store_loop					# continue
outof_storeloop:   	 addi $s1, $t2, 0    				# dict_num_words = dict_idx
			
# The end of the store loop


			 li $t4,0
			 li $t0,0					# grid_idx = 0;
			 li $t2,0 					# idx = 0
			 li $t3,0					# as a flag to identify if it has an '-1' output or not 		
#strfind function begin                    						
loop_outer: 		
			 lb $s2, grid($t0)      			# load grid(grid_idx) in $s2
                     	 beq $s2, 0,strfind_end   			# grid(grid_idx) ! = '\0',next   

			 bne $s2,10,begin
			 addi $t0,$t0,1
			 lb $s2, grid($t0)
begin:			 beq $s2,0, strfind_end  
			 
			 li $t2, 0					# idx = 0
			 
loop_inner: 	
			 slt $t4,  $t2, $s1				# idx < dict_num_words, $t4 =1;else $t4 = 0 					     					
                     	 beq $t4, 0,  finish_loop			# if idx >= dict_num_words, finish the inner loop
                     	 lw $t4, dictionary_idx($t2)   			# $t5 = dictionary_idx[idx]
    		         lb $s3, dictionary($t4) 			# *word= *[dictionary+dictionary_idx[idx]]
			 addi $s4, $t0, 0				# save the current grid_idx
			 addi $s5, $t4,0 				# save the current dictionary[idx]
			 li $t6,0					
			 li $t7,0					# t7 reserves the length of each dictionary 
			 li $t1,0					# sign = 0 ( to see if overlapped)		
			 li $t8,0					# t8 is sign2
			 li $t9,0					# t9 is used to count a1
			 li $s6,0					# $s6 is used to count a2		       	
contain_H:		 beq $s2, $s3, next1				# if *word = * grid, then next1
			 bne $s3,10,next2				# if *word != '\n', go to next contain fucntion
			 j find1					# if *word =='\n', then return 1, find the horizontal match
next2:		 
			 bne $s2,10,next1				# if string != '\n', then go to next1
			 addi $t1, $zero, 1				# sign = 1
			 sub $s4,$s4,$s0				# string = string-k
			 addi $s4,$s4, 1				# string = string +1
			 lb $s2,grid($s4)
next1:			 beq $s2,$s3, sign1				# string == word, go to sign1
			 beq $s2,0,sign1				# string == 0, go to sign1
			 beq $s3,10,sign1				# word == 0, go to sign1
			 j then1					# clear word , go to the vertical part

sign1:			 bne $t1,1, length_over1	
length_over1:	 
			 div $t0,$s0					
			 mfhi $k1					# grid_idx%(k)
			 mflo $k0					# grid_idx/(k)
			 slt $t9, $t7,$k1				
			 bne $t9, 0,next3
			 beq $t7,$k1,next3
			 j then1
next3:		 	 bne $s2,10, equal1				# if string != '\n', return back
			 bne $s3,10,equal1				# if word !='\n',  return back 
			 j find1

equal1: 		 bne $s2,$s3,contain_H
			 sb $s3, word($t6)			
			 addi $s4, $s4,1				# *(++grid)
			 lb $s2, grid($s4)							
			 addi $s5,$s5,1					# *(++word)
			 lb $s3, dictionary($s5) 	
			 addi $t6,$t6,1					# save it to the word
			 j contain_H
find1:			 div $t0,$s0					
			 mfhi $k1					# gird_idx%k
			 mflo $k0					# grid_idx/k
			 li $v0,1
			 move $a0,$k0
			 syscall			 		# print grid_idx/k
			 li $v0,4						
			 la $a0,print_string2				# print ","
			 syscall
			 li $v0,1
			 move $a0, $k1					# print grid_idx%k
			 syscall
			 li $v0,4
			 la $a0, print_char1				# print " H "
			 syscall
			 li $v0, 4
			 li $t7, 0	 
			 la $a0,word($t7)				# print the word that has been found
			 syscall
			 li $v0,4
			 la $a0,newline					# print a new line, ready to print next word
			 syscall
			 li $t3,1					# flag =1 
then1:		  	 lb $s2,grid($t0)				# reload grid[grid_idx]
			 lb $s3, dictionary($t4) 			# reload [dictionary+dictionary_idx[idx]]
  			 li $t9,0					
#clear word			
word_clear1: 	 	 beq $t9,15,contain_Vpre			# if word clear, go to the Vertical part
			 sb $0, word($t9)				# clear word
			 addi $t9, $t9,1
			 j word_clear1
contain_Vpre:	 	 li $t7,0
			 addi $s4, $t0,0				# save the current grid_idx
			 addi $s5, $t4,0 				# save the current dictionary[idx]
			 lw $t4, dictionary_idx($t2) 			# load dictionary_idx[idx]
			 lb $s3, dictionary($t4) 			# load dictionary[dictionary_idx[idx]]
			 lb $s2,grid($t0)				# load grid[grid_idx]
			 li $t6,0					# first address of the word
			 li $t1,0					# t1 is sign1
			 li $t8,0					# t8 is sign2
			 li $t9,0					# t9 is used to count a1
			 li $s6,0					# $s6 is used to count a2
contain_V:		 beq $s2, $s3, next4				# if *word = * grid, then next1
			 bne $s3,10,next5				# if *word != '\n', go to next contain fucntion
			 j find2					# if *word =='\n', then return 1, find the horizontal match
next5:		 
			 bne $s2,0,next4				# if string != '\n', then go to next1
 			 div $t0,$s0					
			 mfhi $s4					# grid_idx%(k)
			 mflo $k0					# grid_idx/(k)
			 lb $s2,grid($s4)
next4:		 	 beq $s2,$s3, sign2				# string == word, go to sign1
			 beq $s2,0,sign2				# string ==0, go to sign1
			 beq $s3,10,sign2				# word ==0, go to sign1
			 j then2					# clear word , go to the vertical part

sign2:			 bne $t1,1, length_over2	
									# a = a+1
length_over2:	 	 div $t0,$s0					
			 mfhi $k1					# grid_idx%(k)
			 mflo $k0					# grid_idx/(k)
			 slt $t9, $t7,$k0				
			 bne $t9, 0,next6
			 beq $t7,$k0,next6
			 j then2
next6:		 	 bne $s2,10, equal2				# if string != '\n', return back
			 bne $s3,10,equal2				# if word !='\n',  return back 
			 j find2

equal2: 		 bne $s2,$s3,contain_V
			 sb $s3, word($t6)			
			 add $s4,$s4, $s0				# *(++grid)
			 lb $s2, grid($s4)							
			 addi $s5,$s5,1					# *(++word)
			 lb $s3, dictionary($s5) 	
			 addi $t6,$t6,1					# save it to the word
			 j contain_V
find2:			 div $t0,$s0					
			 mfhi $k1					# gird_idx%k
			 mflo $k0					# grid_idx/k
			 li $v0,1
			 move $a0,$k0
			 syscall			 		# print grid_idx/k
			 li $v0,4						
			 la $a0,print_string2				# print ","
			 syscall
			 li $v0,1
			 move $a0, $k1					# print grid_idx%k
			 syscall
			 li $v0,4
			 la $a0, print_char2				# print " V "
			 syscall
			 li $v0, 4
			 li $t7, 0	 
			 la $a0,word($t7)				# print the word that has been found
			 syscall
			 li $v0,4
			 la $a0,newline					# print a new line, ready to print next word
			 syscall
			 li $t3,1					# flag =1 
then2:		 	 lb $s2,grid($t0)				# reload grid[grid_idx]
			 lb $s3, dictionary($t4) 			# reload [dictionary+dictionary_idx[idx]]
  			 li $t9,0					
#clear word			
word_clear2: 	 	 beq $t9,15,contain_Dpre			# if word clear, go to the Vertical part
			 sb $0, word($t9)				# clear word
			 addi $t9, $t9,1
			 j word_clear2

contain_Dpre:	 
			 li $t1,0					# $t1 is sign1
			 li $t8,0					# $t8 is sign2
			 li $t9,0					# t9 is used to count a1
			 li $s6,0					# $s6 is used to count a2
			 addi $s4, $t0,0				# save the current grid_idx
			 addi $s5, $t4,0 				# save the current dictionary[idx]
			 lw $t4, dictionary_idx($t2) 			# load dictionary_idx[idx]
			 lb $s3, dictionary($t4) 			# load dictionary[dictionary_idx[idx]]
			 lb $s2,grid($t0)				# load grid[grid_idx]
			 li $t6,0					# first address of the word
			 addi $t7,$s0,1					# t7 is usd to save k+1
contain_D:		 beq $s2, $s3, next7				# if *word = * grid, then next1
			 bne $s3,10,next8				# if *word != '\n', go to next contain fucntion
			 j find3					# if *word =='\n', then return 1, find the diagonal match
next8:		 	 
			 beq $s2,10,next9				# if string == '\n', then go to next9
			 beq $s2,0,next9				# if string == '\0', then go to next9
			 j next7	

next9:  		 
			 addi $t7,$s0,1				
			 div $t0,$s0					
			 mfhi $k1					# grid_idx%k
			 mflo $k0					# grid_idx/k				
			 slt $a2,$k1,$k0				# compare grid_idx%k and grid_idx/k
			 bne $a2,0,op					# if grid_idx/k <= grid_idx%k
			 mul $a2,$t7,$k0				
			 sub $s4,$t0,$a2						
			 lb $s2,grid($s4)
			 j next7		
op:			 mul $a2,$t7,$k1
			 sub $s4,$t0,$a2						
			 lb $s2,grid($s4)
next7:		 	 beq $s2,$s3, sign3_1				# string == word, go to sign1
			 beq $s3,0,sign3_1				# string ==0, go to sign1
			 beq $s3,10,sign3_1				# word ==0, go to sign1
			 j then3					# clear word , go to the vertical part

sign3_1:		 bne $t1,1, sign3_2				# sign1 != 1, go to sign2
			 addi $t9,$t9,1					# a1++
sign3_2:		 bne $t8,1, length_over3_1			# sign2 != 1, go to length_over3_1
			 addi $s6,$s6,1					# a2++
 
length_over3_1:	 	 div $t0,$s0					
			 mfhi $k1					# grid_idx%(k)
			 mflo $k0					# grid_idx/(k)
			 slt $s7, $t9 ,$k1				# a1 > grid_idx%k, then return 0
			 bne $s7, 0,length_over3_2
			 beq $t9,$k1,length_over3_2
			 j then3

length_over3_2:	 	 div $t0,$s0					
			 mfhi $k1					# grid_idx%(k)
			 mflo $k0					# grid_idx/(k)
			 slt $s7, $s6,$k0				# a2 > grid_idx/k, then return 0
			 bne $s7, 0,equal3
			 beq $s6,$k0,equal3
			 j then3
next10:	 	 
			 bne $s2,10, contain_D				# if string != '\n', return back
			 bne $s3,10,contain_D				# if word !='\n',  return back 
			 j find3

equal3: 		 bne $s2,$s3,next10
			 sb $s3, word($t6)			
			 add $s4, $s4,$t7				# *(grid = grid+k+1)		
			 lb $s2, grid($s4)							
			 addi $s5,$s5,1					# *(++word)
			 lb $s3, dictionary($s5) 	
			 addi $t6,$t6,1					# save it to the word
			 j next10
find3:			 div $t0,$s0					
			 mfhi $k1					# gird_idx%k
			 mflo $k0					# grid_idx/k
			 li $v0,1
			 move $a0,$k0
			 syscall			 		# print grid_idx/k
			 li $v0,4						
			 la $a0,print_string2				# print ","
			 syscall
			 li $v0,1
			 move $a0, $k1					# print grid_idx%k
			 syscall
			 li $v0,4
			 la $a0, print_char3				# print   " D "   
			 syscall
			 li $v0, 4
			 li $s7, 0	 
			 la $a0,word($s7)				# print the word that has been found
			 syscall
			 li $v0,4
			 la $a0,newline					# print a new line, ready to print next word
			 syscall
			 li $t3,1					# flag =1 
then3:		 	 lb $s2,grid($t0)				# reload grid[grid_idx]
			 lb $s3, dictionary($t4) 			# reload [dictionary+dictionary_idx[idx]]
  			 li $t9,0					
#clear word			
word_clear3: 	 	 beq $t9,15,finish_innerloop			# if word clear, go to next loop
			 sb $0, word($t9)				# clear word
			 addi $t9, $t9,1
			 j word_clear3

finish_innerloop:
			 addi $t2,$t2,4					# idx ++
			 j loop_inner					# go to loop_inner
finish_loop:
			 addi $t0,$t0,1					# grid_idx++
			 j loop_outer					# go to loop_outer


strfind_end:		 beq $t3,1  ,main_end				# if(grid(grid_idx) == '\0'), then go to the end
			 li $v0, 4					# print_string , when $v0 = 4
			 la $a0,print_string1				# if not find ,then output " -1\n "
			 syscall
			 j main_end






#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
