%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern void yy_scan_string(const char *str);

char variables[100][100];
char values[100][200];
int is_string[100];
int var_count = 0;

int in_if_else = 0;
int suppress_output = 0;

FILE *tacFile;
int tempCount = 0;
int labelCount = 0;

char* newTemp() {
    static char temp[10];
    sprintf(temp, "t%d", tempCount++);
    return temp;
}

char* newLabel() {
    static char label[10];
    sprintf(label, "L%d", labelCount++);
    return label;
}

const char* getValue(const char* id) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i], id) == 0)
            return values[i];
    }
    return "0";
}

int getType(const char* id) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i], id) == 0)
            return is_string[i];
    }
    return 0;
}

void setValue(const char* id, const char* val, int isStr) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i], id) == 0) {
            strcpy(values[i], val);
            is_string[i] = isStr;
            return;
        }
    }
    strcpy(variables[var_count], id);
    strcpy(values[var_count], val);
    is_string[var_count] = isStr;
    var_count++;
}
%}

%union {
    int num;
    char id[100];
    char str[200];
    struct {
        char val[200];
        int is_string;
    } expr;
}

%token <num> NUMBER
%token <id> ID
%token <str> STRING_LITERAL

%token PRINT RETURN EXIT
%token INT FLOAT CHAR STRING VOID
%token IF ELSE WHILE
%token EQ NEQ GT LT GE LE

%type <expr> expression
%type <num> condition
%type <num> type
%type <expr> statement
%type <expr> block
%type <expr> program

%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

program:
    program statement
    | statement
    ;

statement:
      PRINT '(' expression ')';'
        {
            if (!suppress_output) {
                printf("%s\n", $3.val);
            }
            $$ = $3;
        }

    | RETURN expression ';'
        {
            if (!suppress_output) {
                printf("\प्रत्यावर्तनम्:: %s\n", $2.val);
            }
            $$ = $2;
        }

    | EXIT ';'
        {
            if (!suppress_output) {
                 fprintf(tacFile, "निर्गमनम्: exit()\n");
            }
            exit(0);
        }

    | type ID '=' expression ';'
        {
            setValue($2, $4.val, $4.is_string);
            fprintf(tacFile, "%s = %s\n", $2, $4.val);
            strcpy($$.val, "");
            $$.is_string = 0;
        }

    | ID '=' expression ';'
        {
            setValue($1, $3.val, $3.is_string);
            fprintf(tacFile, "%s = %s\n", $1, $3.val);
            strcpy($$.val, "");
            $$.is_string = 0;
        }

    | type ID ';'
        {
            setValue($2, "", 0);
            strcpy($$.val, "");
            $$.is_string = 0;
        }

    | IF '(' condition ')' {
            in_if_else = 1;
            suppress_output = 1;
        }
        statement ELSE {
            suppress_output = 1;
        } statement {
            suppress_output = 0;
            char* trueLabel = newLabel();
            char* falseLabel = newLabel();
            char* endLabel = newLabel();

            fprintf(tacFile, "IF cond GOTO %s\n", trueLabel);
            fprintf(tacFile, "GOTO %s\n", falseLabel);
            fprintf(tacFile, "%s:\n", trueLabel);

            if ($3) {
                if (!suppress_output)
                    printf("%s\n", $6.val);
                $$ = $6;
            } else {
                fprintf(tacFile, "%s:\n", falseLabel);
                if (!suppress_output)
                    printf("%s\n", $9.val);
                $$ = $9;
            }
            fprintf(tacFile, "GOTO %s\n", endLabel);
            fprintf(tacFile, "%s:\n", endLabel);

            in_if_else = 0;
        }

    | WHILE '(' condition ')' block {
            char* startLabel = newLabel();
            char* endLabel = newLabel();

            fprintf(tacFile, "%s:\n", startLabel);
            if ($3) {
                yy_scan_string($5.val);
                yyparse();
            }
            fprintf(tacFile, "GOTO %s\n", startLabel);
            fprintf(tacFile, "%s:\n", endLabel);

            strcpy($$.val, "");
            $$.is_string = 0;
        }

    | ';'
        {
            strcpy($$.val, "");
            $$.is_string = 0;
        }
    ;

block:
    '{' program '}' {
        $$ = $2;
    }
;

type:
      INT     { $$ = 1; }
    | FLOAT   { $$ = 2; }
    | CHAR    { $$ = 3; }
    | STRING  { $$ = 4; }
    | VOID    { $$ = 0; }
    ;

condition:
      expression EQ expression  { $$ = (strcmp($1.val, $3.val) == 0); }
    | expression NEQ expression { $$ = (strcmp($1.val, $3.val) != 0); }
    | expression GT expression  { $$ = (atoi($1.val) > atoi($3.val)); }
    | expression LT expression  { $$ = (atoi($1.val) < atoi($3.val)); }
    | expression GE expression  { $$ = (atoi($1.val) >= atoi($3.val)); }
    | expression LE expression  { $$ = (atoi($1.val) <= atoi($3.val)); }
    ;

expression:
      STRING_LITERAL {
          strcpy($$.val, $1);
          $$.is_string = 1;
      }

    | ID {
          strcpy($$.val, getValue($1));
          $$.is_string = getType($1);
      }

    | NUMBER {
          sprintf($$.val, "%d", $1);
          $$.is_string = 0;
      }

    | expression '+' expression {
          if ($1.is_string || $3.is_string) {
              strcpy($$.val, $1.val);
              strcat($$.val, $3.val);
              $$.is_string = 1;
          } else {
              int a = atoi($1.val);
              int b = atoi($3.val);
              sprintf($$.val, "%d", a + b);
              $$.is_string = 0;
          }
          fprintf(tacFile, "%s = %s + %s\n", newTemp(), $1.val, $3.val);
      }

    | expression '-' expression {
          int a = atoi($1.val);
          int b = atoi($3.val);
          sprintf($$.val, "%d", a - b);
          $$.is_string = 0;
          fprintf(tacFile, "%s = %s - %s\n", newTemp(), $1.val, $3.val);
      }

    | expression '*' expression {
          int a = atoi($1.val);
          int b = atoi($3.val);
          sprintf($$.val, "%d", a * b);
          $$.is_string = 0;
          fprintf(tacFile, "%s = %s * %s\n", newTemp(), $1.val, $3.val);
      }

    | expression '/' expression {
          int a = atoi($1.val);
          int b = atoi($3.val);
          if (b == 0) {
              yyerror("शून्येन विभाजनं निषिद्धम्");
              sprintf($$.val, "0");
          } else {
              sprintf($$.val, "%d", a / b);
              fprintf(tacFile, "%s = %s / %s\n", newTemp(), $1.val, $3.val);
          }
          $$.is_string = 0;
      }

    | '(' expression ')' {
          strcpy($$.val, $2.val);
          $$.is_string = $2.is_string;
      }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "त्रुटिः: %s\n", s);
}

int main() {
    tacFile = fopen("output_TAC.txt", "w");
    if (!tacFile) {
        printf("Cannot open output file for TAC.\n");
        return 1;
    }
    printf("Sanskrit Code Execution:\n\n");
    yyparse();
    fclose(tacFile);
    return 0;
}
