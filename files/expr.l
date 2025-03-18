%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#define YY_DECL int yylex()
#define YYSTYPE char*
#include "expr.tab.h"

%}

%%
[ \t]+ ; {printf("htll %s", yytext);}//ignore all whitespace
[ ]*try[ ]+ {yylval = strdup(yytext);; return TRY;}
[ ]*throw[ ]+ {yylval = strdup(yytext); return THROW;}
[ ]*new[ ]+ {yylval = strdup(yytext); return NEW;}
[ ]*catch[ ]* {yylval = strdup(yytext); return CATCH;}
[ ]*print[ ]* {yylval = strdup(yytext); return PRINT;}
\n 	{return '\n';}
[ ]*\.\.\.[ ]* {yylval = strdup(yytext);  return ALL_EX;}
[ ]*"{"[ ]* {yylval = strdup(yytext); return '{';}
[ ]*"}"[ ]* {yylval = strdup(yytext); return '}';}
[ ]*"("[ ]* {yylval = strdup(yytext); return '(';}
[ ]*")"[ ]* {yylval = strdup(yytext);return ')';}
[ ]*";"[ ]* {yylval = strdup(yytext); return ';';}
[ ]*"*"[ ]* {yylval = strdup(yytext); return '*';}
[ ]*const[ ]+ {yylval = strdup(yytext); return CONST;}
[ ]*[a-zA-Z]+[0-9a-zA-Z]*[ ]* {yylval = strdup(yytext); return EX_TYPE;}
[ ]*\'[0-9a-zA-Z]*\'[ ]* {yylval = strdup(yytext); return QUOTES_VALUE;}
[ ]*[0-9a-zA-Z]*[ ]* {yylval = strdup(yytext); return VALUE;}
%% 