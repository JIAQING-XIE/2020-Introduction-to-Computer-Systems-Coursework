/***********************************************************************
* File       : <wraparound.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid, including wrap-around

// Inf2C-CS Coursework 1. Task 6
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////
char style;
int grid_idx = 0;
// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;
// function to calculate the length of each row
int length(char *griddata){
	int len = 0;					      // initial value length = 0
	while(*griddata != '\0'){		// when dictionary word != '\0', row_length ++

		len++;
		griddata++;					      // go to the next character in the word
		if(*griddata == '\n')		  // if word = '\n',it means that it is at the end of the row
		{
			len++;					        // add 1 because of the '\n'
			return len;				      // return the value of the row_length
		}
	}
	return 0;
}

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {		//if word is not equal to '\n' and '\0', then print word
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the horizontal word(including wrapped word)
int contain(char *string, char *word)
{
  int k = length(grid);
  int a = 0;
  int sign = 0;
  while (1) {
    if (*string != *word){
      if(*word == '\n'){			  // word == '\n' and string != '\n' , means that the word has been found
      	style = 'H';						// go to print the word in horizontal match
      	return 1;
	  }
   	  if(*string == '\n'){			// when string =='\n', go to the first word of that line to fina a wrapped word
	  	string = string -k+1;
	  	sign = 1;							    // have the sign to record the word length(wrapped)
	  }

    }
   	if(*string != *word&&*string !='0'&&*word != '\n'){
    	style = '\0';
		return 0;							      // when string != word and word is not '\n'
	}										          // try to find the vertical word match
    if( sign == 1 ){
		a++;								        // if wrapped, then word length++
	}
	if( a > grid_idx%(k)){				// if overlapped, then return 0 and try to find a vertical match
		return 0;
	}
    if(*string == *word)				// if matched, then word++, grid++
	{
		string++;
		word++;
    }
	if(*string == '\n' && *word == '\n'){
    	style = 'H';						  // to find if matches in the end
      	return 1; 							// if so, print the word
	} 										        // begin the next loop
  }
  return 0;
}
// function to see if the string contains the vertical word(including wrapped word)
int contain2(char *string, char *word)
{
 int k = length(grid);
 int a = 0;
 int sign =0;
  while (1) {
    if (*string != *word){
      if(*word == '\n'){				// word == '\n' and string != '\n' , means that the word has been found
      	style = 'V';						// go to print the word in vertical match
      	return 1;
	  }
	  if(*string == '\0'){				// if wrapped, then word length++
	  	string = grid+grid_idx%k;
	  	sign = 1;
	  }

    }
    if(*string != *word&&*word != '\n'&&*string != '\0'){
    	style = '\0';						  // when string != word and word is not '\n'
		return 0;							      // try to find the vertical word match
	}
	if( sign == 1 ){						  // if wrapped, then word length++
		a++;
	}
    if( a > grid_idx/k){				// if overlapped, then return 0 and try to find a diagonal match
		return 0;
	}
	if(*string == *word){ 				// if matched, then word++, grid = grid +row_length
		string = string+k;
    	word++;
	}


   	if(*string == '\n' && *word == '\n'){
    	style = 'V';						  // to find if matches in the end
      	return 1;							  // if so, print the word
	}

  }

  return 0;
}

// function to see if the string contains the diagonal word(including wrapped word)
int contain3(char *string, char *word)
{
 int k = length(grid);
 int a1 = 0;
 int a2 = 0;
 int sign1 = 0;
 int sign2 = 0;
  while (1) {

    if (*string != *word){
       if(*word == '\n'){					// word == '\n' and string != '\n' , means that the word has been found
      	style = 'D';						  // go to print the word in horizontal match
      	return 1;
	  }
	 	else if(*string == '\n'||*string == '\0'){			// grid = '\n' or '\0',to find the next character in the grid
	 		if( grid_idx % k >= grid_idx / k){
	 			string = grid + grid_idx - (k+1)*(grid_idx / k);	// row >= colomn, go to the left side
	 			sign2 = 1; 
			 }
			if(grid_idx % k < grid_idx / k){
			 	string = grid + grid_idx - (k+1)*(grid_idx % k);	//row  <= colomn, go to the right side
			 	sign1 = 1;
			 }
	  }

    }
    if(*string != *word&&*word != '\n'&&*word != '\0'){
    	style = '\0';						// when string != word and word is not '\n' and'\0', idx++, go to the next inner loop
		return 0;
	}
	if(sign1 == 1){							// if wrapped in the right top corner, then word length1++
		a1++;
	}
	if(sign2 == 1){							// if wrapped in the left bottom corner, then word length2++
		a2++;
	}
	if( a1 > grid_idx%k){					// when overlapped in the right top corner,return 0 and go to the next inner loop
		return 0;
	}
	if( a2 > grid_idx/k){					// when overlapped in the left bottom corner,return 0 and go to the next inner loop
		return 0;
	}
	if( *string == *word){					// if matched, then word++, grid = grid + row_length +1
		string = string+k+1;
    	word++;
	}
	if(*string == '\n' && *word == '\n'){	// to find if matches in the end
    	style = 'D';						// if so, print the word
      	return 1;
	}
  }

  return 0;
}
// this functions finds the match in the grid
void strfind()
{
  int idx = 0;								// idx = 0
  int k = length(grid);
  int flag = 0;								// set a flag to see if there is any word matched
  char *word;
  while (grid[grid_idx] != '\0') {			// grid == '0', word search is ended.
  if(grid[grid_idx] == '\n'){				// when first matched the '\n', then go to the next line
  		grid_idx++;
  	}
  if(grid[grid_idx] == '\0'){				// when next matched '\0', then break
  		break;
	}
	for(idx = 0; idx < dict_num_words; idx ++) {	// see if index has reached the end of the word in the dictionary
      word = dictionary + dictionary_idx[idx]; 		// put the first word of each line in the dictionary
      if (contain(grid + grid_idx, word)) {			// if matched horizontally, then print	(including wrapped word)
        print_int(grid_idx/k);						// print the row
        print_char(',');							// print","
        print_int(grid_idx%k);						// print the colomn
        print_char(' ');							// print " "
        printf("%c",style);							// print "H"
        print_char(' ');							// print " "
        print_word(word);							// print word
        print_char('\n');							// print a newline
    	flag = 1;									// word has been matched (horizontally with wrapped)
	  }
	  if(contain2(grid + grid_idx, word)){			//if matched vertically, then print		(including wrapped word)
        print_int(grid_idx/k);						// print the row
        print_char(',');							// print","
        print_int(grid_idx%k);						// print the colomn
        print_char(' ');							// print " "
        printf("%c",style);							// print "V"
        print_char(' ');							// print " "
        print_word(word);							// print word
        print_char('\n');							// print a newline
    	flag = 1;									// word has been matched (vertically with wrapped)
	  }
	  if(contain3(grid + grid_idx, word)){			//if matched diagonally, then print		(including wrapped word)
        print_int(grid_idx/k);						// print the row
        print_char(',');							// print","
        print_int(grid_idx%k);						// print the colomn
        print_char(' ');							// print " "
        printf("%c",style);							// print "D"
        print_char(' ');							// print " "
        print_word(word);							// print word
        print_char('\n');							// print a newline
    	flag = 1;									// word has been matched (diagonally with wrapped)
	  }
      }


    grid_idx++;										// grid++, go to the next grid character

  }
	if(flag ){return ;}								// if there is any word matched, then system return
    print_string("-1\n");							// else print"-1" and "\n"
}




//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{
  int dict_idx = 0;
  int start_idx = 0;

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////
idx = 0;											//idx = 0
  do {
    c_input = dictionary[idx];						// input = dictionary[idx]
    if(c_input == '\0') { 							// if matched in the end of the dictionary, then break
      break;
    }
    if(c_input == '\n') {							// if matched in the end of each line, then record the idx of the start_index of each line
      dictionary_idx[dict_idx ++] = start_idx;
      start_idx = idx + 1;							// start_idx = idx + 1
    }
    idx += 1;										// idx = idx + 1
  } while (1);										// if true

  dict_num_words = dict_idx;						// put the dict_idx in a variable called "dict_num_words"
  strfind();										// begin finding the word match
  return 0;
}
