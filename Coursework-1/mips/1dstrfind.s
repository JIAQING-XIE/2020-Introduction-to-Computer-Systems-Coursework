
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
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

print_char:       .asciiz" " 
print_string:     .asciiz"-1\n"
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:            	.space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx:         .space 11001	# Maximum number of index of dictionary index  is the  same that of the dictionary 
word:   		.space 15	# The maximun length of the word should be 10, buffer to 15.
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
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
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
outof_storeloop:     	 addi $s1, $t2, 0    				# dict_num_words = dict_idx
			
# The end of the store loop


			 li $t4,0					# $t4 is used to compare idx and dict_num_words
			 li $t0,0					# grid_idx = 0
			 li $t2,0 					# idx = 0
			 li $t3,0					# as a flag to identify if it has an '-1' output or not 		
#strfind function begin                    						
loop_outer: 		
			 lb $s2, grid($t0)      			# load grid(grid_idx) in $s2
                     	 beq $s2, 0,strfind_end   			# grid(grid_idx) ! = '\0',next            	 					
			 li $t2, 0					# idx = 0
			 
loop_inner: 	
			 slt $t4,  $t2, $s1				# idx < dict_num_words, $t4 =1;else $t4 = 0 					     					
                     	 beq $t4, 0,  finish_loop			# if idx >= dict_num_words, finish the inner loop
                     	 lw $t4, dictionary_idx($t2)   			# $t5 = dictionary_idx[idx]
    		         lb $s3, dictionary($t4) 			#*word= *[dictionary+dictionary_idx[idx]]
			 addi $s4, $t0, 0				# save the current grid_idx
			 addi $s5, $t4,0 				# save the current dictionary[idx]
			 li $t6,0					       	
contain_H:		 beq $s2, $s3, equal1				# if *word = * grid, then word++, grid++
			 beq $s3, 10, find1
			 j then1
equal1: 		 sb $s3, word($t6)			
			 addi $s4, $s4,1				# *(++grid)
			 lb $s2, grid($s4)							
			 addi $s5,$s5,1					# *(++word)
			 lb $s3, dictionary($s5) 	
			 addi $t6,$t6,1					# save it to the word
			 j contain_H
find1:			 				
			 li $v0,1
			 move $a0,$t0
			 syscall			 		# print grid_idx
			 li $v0,4
			 la $a0, print_char				# print "  "
			 syscall
			 li $v0, 4
			 li $t7, 0	 
			 la $a0,word($t7)				# print the word that has been found
			 syscall
			 li $v0,4
			 la $a0,newline					# print a new line, ready to print next word
			 syscall
			 li $t3,1					# flag =1 
then1:		 	 lb $s2,grid($t0)				# reload grid[grid_idx]
			 lb $s3, dictionary($t4) 			# reload [dictionary+dictionary_idx[idx]]
  			 li $t9,0					
#clear word			
word_clear1: 		 beq $t9,15,finish_innerloop			# if word clear, go to the Vertical part
			 sb $0, word($t9)				# clear word
			 addi $t9, $t9,1
			 j word_clear1


finish_innerloop:
			 addi $t2,$t2,4					# idx ++
			 j loop_inner					# go to loop_inner
finish_loop:
			 addi $t0,$t0,1					# grid_idx++
			 j loop_outer					# go to loop_outer


strfind_end:		 beq $t3,1  ,main_end				# if(grid(grid_idx) == '\0'), then go to the end
			 li $v0, 4					# print_string , when $v0 = 4
			 la $a0,print_string				# if not find ,then output " -1\n "
			 syscall					# go to the end of the main function

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
