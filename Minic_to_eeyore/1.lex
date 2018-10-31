%{
#include"globals.h"

Node * newnode(char *name,int line);
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z_]
identifier  {letter}+({digit}|{letter})*
newline     \n
whitespace  [ \t]+

%%

"int"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYINT;}
"if"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYIF;}
"else"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYELSE;}
"while"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYWHILE;}
"main"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYMAIN;}
"return"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYRETURN;}

"&&"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYAND;}
"||"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYOR;}
"=="	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return EQU;}
"!="	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return UNEQU;}
"<"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return LT;}
">"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return GT;}
\/\/[^\n]*	{yylval.node=new_node(yytext,lineno);}
"!"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MYNOT;}
"-"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MINUS;}
"+"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return PLUS;}
"*"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return TIMES;}
"/"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return OVER;}
"%"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return MOD;}
"="	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return ASSIGN;}
","	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return COMMA;}
";"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return SEMI;}
"("	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return LP;}//left parenthesis
")"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return RP;}//right parenthesis
"["	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return LSB;}//left square backet
"]"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return RSB;}//right square backet
"{"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return LB;}//left brace
"}"	{fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return RB;}//right brace

{number}	{
	fprintf(stderr,"%s ",yytext);
				int _val=0;
				sscanf(yytext,"%d",&_val);
				yylval.node=new_nodenum(yytext,lineno,_val);
				return NUM;
			}
{identifier}    {fprintf(stderr,"%s ",yytext);yylval.node=new_node(yytext,lineno);return ID;}
{newline}       {fprintf(stderr,"%s ",yytext);lineno++;}
{whitespace}    {fprintf(stderr,"%s ",yytext);/* skip whitespace */}
.	{printf("Errors occur in lex!\n");return ERROR;}//error

%%



int yywrap()
{
	return 1;
}


