/* cpp-style exceptions analyzer*/

%{  
    #include "ExceptInfo.h"
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #define YYSTYPE char*
    int yylex (void);
    void yyerror (char* s);
    ExceptInfo* ExThrow = NULL;
    ExceptInfo* StrExThrow = NULL;
    ExceptInfo* ExCatch = NULL;
    ExceptInfo* ExPrint = NULL;
    int level = 0;
    
%}

%token TRY
%token THROW
%token NEW
%token CATCH
%token PRINT
%token ALL_EX
%token VALUE
%token QUOTES_VALUE
%token CONST
%token EX_TYPE

%%

input:
    %empty
    | input line
    ;
line: expr '\n' {sprintf($$, "%s", $1) ;
    Terminate(ExThrow, StrExThrow, ExCatch, ExPrint);
    DelExceptInfo(&ExThrow);
    DelExceptInfo(&StrExThrow);
    DelExceptInfo(&ExCatch);
    DelExceptInfo(&ExPrint);
}
;
expr:
    TRY '{' bt '}' c {
    if ($5 != NULL) {
        $$ = (char*)calloc(1, sizeof($1)+ strlen($3)+strlen($5)+2);
        sprintf($$, "%s{%s}%s", $1,$3,$5); 
    }
    else {
        $$ = (char*)calloc(1, sizeof($1)+ strlen($3) + 2);
        sprintf($$, "%s{%s}", $1,$3); 
    }
    if ($3 != NULL) free($3);
    if ($5 != NULL) free($5);
    free($1);}
    ;

c:
    CATCH '(' arg ')' '{' bc '}' c {
                        if ($8 != NULL) {
                            $$ = (char*)calloc(1, strlen($1) + strlen($3) + strlen($6) + strlen($8) + 4);
                            sprintf($$, "%s(%s){%s} %s", $1, $3, $6, $8);
                            free($8);
                        }
                        else {
                            $$ = (char*)calloc(1, strlen($1) + strlen($3) + strlen($6) + 4);
                            sprintf($$, "%s(%s){%s}", $1, $3, $6);
                        } 
                        free($3);
                        free($6);
                        }
    | %empty {$$ = NULL;}
    ;
bt:
    st ';' bt {
        if ($3 != NULL) { $$ = (char*)calloc(1, strlen($1) + strlen($3) + 1);    
        sprintf($$, "%s;%s", $1, $3);
        if ($1!=NULL) free($1);
        free($3);
        }
        else {
            $$ = (char*)calloc(1, strlen($1)+1);
            sprintf($$, "%s;", $1);
            free($1);} 
        }
    | %empty {$$ = NULL;}
    ;
st:
    THROW th { $$ = (char*)calloc(1, sizeof($1) + strlen($2));
    sprintf($$, "%s%s", $1, $2);
    free($1);
    free($2);}
    ;
th: NEW EX_TYPE '('param')' {
    $$ = (char*)calloc(1, strlen($1) + strlen($2) + strlen($4) + 2);
    if (ExThrow == NULL) {
        InitExceptInfo(&ExThrow);
    }
    sprintf($$,"%s%s(%s)", $1, $2, $4);
    trim($2);
    AddExType(ExThrow, $2);
    free($4);
    free($2);
    free($1);}
    | QUOTES_VALUE {$$ = (char*)calloc(1, sizeof($1));
        sprintf($$, "%s", $1);
        if (StrExThrow == NULL) InitExceptInfo(&StrExThrow);
        AddExType(StrExThrow, $1);}
    ;
bc:
    PRINT '('QUOTES_VALUE')' ';' bc {
        if (ExPrint == NULL) {
            InitExceptInfo(&ExPrint);
        }
        if ($6 != NULL) {  $$ = (char*)calloc(1, strlen($1) + strlen($3) + strlen($6) + 3);
            sprintf($$, "%s(%s);%s", $1, $3, $6);
            AddExType(ExPrint, $3);
            ExPrint->level[ExPrint->Size - 1] = level;
            free($1);
            free($3);
            free($6);}
        else { $$ = (char*)calloc(1, strlen($1) + strlen($3) + 3);
        sprintf($$, "%s(%s);", $1, $3);
        AddExType(ExPrint, $3);
        ExPrint->level[ExPrint->Size - 1] = level;
        free($1);
        free($3);}}
    | %empty {$$ = NULL;}
    ;

arg:
    ALL_EX {$$ = (char*)calloc(1, sizeof($1));
    sprintf($$, "%s", $1);
    if (ExCatch == NULL) {
        InitExceptInfo(&ExCatch);
    }
    AddExType(ExCatch, $1);
    AddExType(ExThrow, $1);
    level += 1;
    ExCatch->level[ExCatch->Size - 1] = level;
    ExCatch->IsAll = true; 
    free($1); }
    | CONST EX_TYPE '*' EX_TYPE {
        $$ = (char*)calloc(1, sizeof($1) + sizeof($2) + sizeof($3) + 1);
        sprintf($$, "%s%s*%s", $1, $2, $4);
        char* catch_type = (char*)calloc(1, sizeof($1) + sizeof($2) + 1);
        sprintf(catch_type, "%s%s*", $1, $2);
        if (ExCatch == NULL) {
            InitExceptInfo(&ExCatch);
        }
        AddExType(ExCatch, catch_type);
        level += 1;
        ExCatch->level[ExCatch->Size - 1] = level;
        free(catch_type);
        free($2); 
    }
    | EX_TYPE EX_TYPE 
     {$$ = (char*)calloc(1, sizeof($1) + sizeof($2));
     sprintf($$, "%s%s", $1, $2); 
     if (ExCatch == NULL) {
        InitExceptInfo(&ExCatch);
    }
    trim($1);
    AddExType(ExCatch, $1);
    level += 1;
    ExCatch->level[ExCatch->Size - 1] = level;
    free($1); 
    free($2);}
    ;
param:
    QUOTES_VALUE {
        $$ = (char*)calloc(1, sizeof($1));
        sprintf($$, "%s", $1);
        free($1);}
    | %empty {$$ = NULL;}
    ;
%%


int main(int argc, char **argv) {
    return yyparse();
}

void yyerror(char *s) {
  fprintf(stderr, "error: %s\n", s);
}
