Project Title:
--------------
Sanskrit Compiler with Three Address Code Generation

Description:
------------
This project is a custom-built compiler for a unique programming language that uses Sanskrit keywords and Devanagari numerals. The purpose of this project is both educational and exploratory — showcasing how traditional linguistic structures can be used to design modern programming languages.

The compiler consists of two main phases:
1. Lexical Analysis (using Flex)
2. Syntax Parsing and Intermediate Code Generation (using Bison/Yacc)

As a core feature, the compiler generates Three Address Code (TAC) for valid Sanskrit programs and writes it to a file named 'output_TAC.txt'. This intermediate representation forms the basis for later stages of compilation like optimization or target code generation.

Key Features:
-------------
-> Sanskrit Language Constructs:
    • मुद्रय       - Print  
    • प्रत्यावर्तय - Return  
    • निर्गच्छ     - Exit  
    • यदि         - If  
    • अन्यथा      - Else  
    • यदा         - While  

-> Data Types in Sanskrit:
    • रिक्त       - void  
    • पूर्णांक     - int  
    • दशमांश      - float  
    • वर्ण         - char  
    • सूत्र        - string  

-> Devanagari Digits Support:  
  Accepts input written using Devanagari numerals (०-९) and converts them to ASCII numbers internally.

-> Basic Arithmetic & Comparison Operators:  
  +, -, *, /, ==, !=, >=, <=, >, <

-> Identifiers and String Literals in Sanskrit:  
  Allows Sanskrit letters for variable names and string expressions

-> Three Address Code (TAC) Generation:  
  For every valid construct, the parser generates TAC instructions and writes them to 'output_TAC.txt'.  
  This helps in visualizing the intermediate steps of the compiler and serves as input to backend stages like code generation.

Files Included:
---------------
1. 'lexer.l'          → Lexical analyzer (Flex)
2. 'parser.y'         → Syntax analyzer + TAC generation (Bison/Yacc)
3. 'parser.tab.h'     → Bison-generated header file
4. 'parser.tab.c'     → Bison-generated parser code
5. 'lex.yy.c'         → Flex-generated lexer code
6. 'output_TAC.txt'   → Generated Three Address Code (output)
7. 'input.txt'        → Sample Sanskrit program


How to Compile:
---------------
Requirements:

-> 'flex', 'bison', 'gcc' installed

Steps:

1. Generate lexer and parser files:
   > flex lexer.l  
   > bison -d parser.y  

2. Compile the generated C files:
   > gcc -o sanskrit_compiler parser.tab.c lex.yy.c 

3. Set the CMD to use UTF-8 encoding.
   > chcp 65001

4. Run the compiler with input file:
   > ./sanskrit_compiler < test_input.txt  

The compiler will process the Sanskrit code and create:
   • Console output
   • 'output_TAC.txt' file with Three Address Code

Known Limitations:
------------------
• No support for functions beyond 'मुख्य()' currently  
• Does not perform type checking or semantic analysis  
• Error handling is minimal (prints basic syntax errors)

Future Improvements:
--------------------
• Add semantic analyzer for type checking  
• Support functions, arrays, and more control structures  
• Generate target code for a virtual machine or real architecture  
• Develop a web-based playground for Sanskrit programming

Author:
-------
Ravalji Maitryba
22000410  

License:
--------
This project is intended for academic, educational, and experimental use. You are free to modify, extend, and share it with proper credits.


