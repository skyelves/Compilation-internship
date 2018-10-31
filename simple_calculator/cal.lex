%{
#include"stdio.h"
#include<stdlib.h>
void yyerror(char *);
//#include"1600012805.tab.h"
%}
%%
[0-9]+  { sscanf(yytext,"%lf",&yylval);return NUM;}//match int
[0-9]*\.[0-9]+  { sscanf(yytext,"%lf",&yylval);return NUM;} /*match double*/
"+"  {return ADD;}
"-"  return SUB;
"*"  return MUL;
"/"  return DIV;//all above match operations
[=()]  return *yytext;
"\n"   return CAL;//another line means calculate
";"  return CAL;//";" is used as a sperator
[\t]  ;/*space*/
[a-zA-Z]  {yylval.cv=*yytext;return CHARA;}//match varibles
.  yyerror("Useless character");
%%
int yywrap()
{
    return 1;
}

