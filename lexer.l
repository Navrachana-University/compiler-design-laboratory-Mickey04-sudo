%{
#include "parser.tab.h"
#include <string.h>
#include <stdio.h>
%}

%%

"मुद्रय"            { return PRINT; }
"प्रत्यावर्तय"       { return RETURN; }
"निर्गच्छ"           { return EXIT; }

"रिक्त"             { return VOID; }
"पूर्णांक"          { return INT; }
"दशमांश"           { return FLOAT; }
"वर्ण"              { return CHAR; }
"सूत्र"              { return STRING; }

"यदि"               { return IF; }
"अन्यथा"            { return ELSE; }
"यदा"               { return WHILE; }    

"=="                { return EQ; }
"!="                { return NEQ; }
">="                { return GE; }
"<="                { return LE; }
">"                 { return GT; }
"<"                 { return LT; }

"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
";"                 { return ';'; }
"="                 { return '='; }

"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }

[०-९]+ {
    char ascii_num[100];   ## conversion unicode to ascii code conversion
    int i = 0, j = 0;

    while (yytext[i] != '\0') {
        if (strncmp(&yytext[i], "०", 3) == 0) { ascii_num[j++] = '0'; i += 3; }
        else if (strncmp(&yytext[i], "१", 3) == 0) { ascii_num[j++] = '1'; i += 3; }
        else if (strncmp(&yytext[i], "२", 3) == 0) { ascii_num[j++] = '2'; i += 3; }
        else if (strncmp(&yytext[i], "३", 3) == 0) { ascii_num[j++] = '3'; i += 3; }
        else if (strncmp(&yytext[i], "४", 3) == 0) { ascii_num[j++] = '4'; i += 3; }
        else if (strncmp(&yytext[i], "५", 3) == 0) { ascii_num[j++] = '5'; i += 3; }
        else if (strncmp(&yytext[i], "६", 3) == 0) { ascii_num[j++] = '6'; i += 3; }
        else if (strncmp(&yytext[i], "७", 3) == 0) { ascii_num[j++] = '7'; i += 3; }
        else if (strncmp(&yytext[i], "८", 3) == 0) { ascii_num[j++] = '8'; i += 3; }
        else if (strncmp(&yytext[i], "९", 3) == 0) { ascii_num[j++] = '9'; i += 3; }
        else { break; }
    }

    ascii_num[j] = '\0';
    yylval.num = atoi(ascii_num);
    return NUMBER;
}

[अ-हँ-ॿ]+ {
    strcpy(yylval.id, yytext);
    return ID;
}

\"[^\"]*\" {
    strncpy(yylval.str, yytext + 1, yyleng - 2); 
    yylval.str[yyleng - 2] = '\0';
    return STRING_LITERAL;
}

[ \t\r\n]+     ;   // Ignore whitespace

.   { printf("Unrecognized char: %s\n", yytext); return yytext[0]; }

%%

int yywrap() {
    return 1;
}
