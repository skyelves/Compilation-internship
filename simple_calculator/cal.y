%{
#include<ctype.h>
#include"stdio.h"
int yylex(void);
int i=0;
void yyerror(char *);
double vars[52]={0};//store varibles a-zA-Z
%}
%token<dv> NUM//match int and double
%token<cv> CHARA//match varibles
%token ADD SUB MUL DIV CAL
%type<dv> expr
%union
{
    double dv;
    char cv;
}//change the type of YYSTYPE dv to store num and cv to store charactor
%left ADD SUB
%left MUL DIV
%right NEG//match negative numbers such as -1
%%
lines:lines expr CAL {printf("%f\n",$2);}//calculate line
| lines CAL //empty line
| lines stat CAL //assign varibles
|;//empty ;
expr: NUM 
| CHARA {
    if(islower($1))  
	i = $1 - 'a';  
    else  
	i = $1 - 'A'+26;
    $$=vars[i];//find where the varible is
} 
| expr MUL expr{$$=$1*$3;} 
| expr DIV expr{$$=$1/$3;}
| expr ADD expr{$$=$1+$3;} 
| expr SUB expr{$$=$1-$3;}//above all are some calculations
| '(' expr ')'{$$=$2;}//match '(' and ')'
| SUB expr %prec NEG {$$=-$2;};//negative is prior
stat:CHARA '=' expr
{
    if(islower($1))  
	i = $1 - 'a';  
    else  
	i = $1 - 'A'+26;
    vars[i] = $3;
};//operations to assign varibles such as "a = 1"
%%
#include"lex.yy.c"
void yyerror(char *str)
{
    printf("%s\n",str);
}//error function
int main()
{
    printf("Note:All varibles(a-zA-Z) are assigned to 0 now. Ctrl+D to exit\n");
    printf("---------------------------------------------------------------------\n");
    yyparse();
    return 0;
}
