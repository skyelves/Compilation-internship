%{
#include"globals.h"
int yyerror(char * s);
%}

%union
{
	Node * node;	
}

%type<node> Goal Defn VarDefn VarDecl FuncDefn FuncDecl MainFunc MainBlock Decl Decls Type Statement Statements Expression BasicOp LogicOp UnaryOp Identifier Arg Identifiers INTEGER ASSIGN MYAND MYOR LT GT EQU UNEQU PLUS TIMES OVER MOD
%token<node> MYINT MYIF MYELSE MYWHILE MYMAIN MYRETURN COMMENT COMMA SEMI LP RP LSB RSB LB RB ERROR
%token<node> NUM ID
%token<node> MINUS

%nonassoc IFX

%left ASSIGN
%left MYAND
%left MYOR
%left LT
%left GT
%left EQU
%left UNEQU
%left PLUS
%left TIMES
%left OVER
%left MOD

%right<node> MYNOT//unary operations, how to deal with '-'?

%%
//comments have not achieved

Goal: Defn MainFunc {
	Node *p=new_node("Goal",$1->lineno);p->nodekind=goal;
	$1->nodekind=defn;insert(p,$1);
	$2->nodekind=mainfunc;insert(p,$2);
	root=(Node *)malloc(sizeof(Node *));
	root=p;
	$$=p;
};

Defn: Defn VarDefn{
	Node *p=new_node("Defn",$1->lineno);p->nodekind=defn;
	$1->nodekind=defn;insert(p,$1);
	$2->nodekind=vardefn;insert(p,$2);
	$$=p;
}//( VarDefn | FuncDefn | FuncDecl ) *
| Defn FuncDefn{
	Node *p=new_node("Defn",$1->lineno);p->nodekind=defn;
	$1->nodekind=defn;insert(p,$1);
	$2->nodekind=funcdefn;insert(p,$2);
	$$=p;
}
| Defn FuncDecl{
	Node *p=new_node("Defn",$1->lineno);p->nodekind=defn;
	$1->nodekind=defn;insert(p,$1);
	$2->nodekind=funcdecl;insert(p,$2);
	$$=p;
}
|{Node *p=new_node("NULL",0);p->nodekind=null;$$=p;}
;

VarDefn: Type Identifier SEMI{
	Node *p=new_node("VarDefn",$1->lineno);p->nodekind=vardefn;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=semi;insert(p,$3);
	$$=p;
}
| Type Identifier LSB INTEGER RSB SEMI{
	Node *p=new_node("VarDefn",$1->lineno);p->nodekind=vardefn;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=lsb;insert(p,$3);
	$4->nodekind=integer;insert(p,$4);
	$$=p;
};

VarDecl: Type Identifier{
	Node *p=new_node("VarDecl",$1->lineno);p->nodekind=vardecl;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$$=p;
}
| Type Identifier LSB RSB{
	Node *p=new_node("VarDecl",$1->lineno);p->nodekind=vardecl;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=lsb;insert(p,$3);
	$4->nodekind=rsb;insert(p,$4);
	$$=p;
}
| Type Identifier LSB INTEGER RSB{
	Node *p=new_node("VarDecl",$1->lineno);p->nodekind=vardecl;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=lsb;insert(p,$3);
	$4->nodekind=integer;insert(p,$4);
	$5->nodekind=rsb;insert(p,$5);
	$$=p;
};//Type Identifier '['INTEGER?']'

FuncDefn: Type Identifier LP Decl RP LB MainBlock RB{
	Node *p=new_node("FuncDefn",$1->lineno);p->nodekind=funcdefn;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=lp;insert(p,$3);
	$4->nodekind=decl;insert(p,$4);
	$5->nodekind=rp;insert(p,$5);
	$6->nodekind=lb;insert(p,$6);
	$7->nodekind=mainblock;insert(p,$7);
	$8->nodekind=rb;insert(p,$8);
	$$=p;
};

FuncDecl: Type Identifier LP Decl RP SEMI{
	Node *p=new_node("FuncDecl",$1->lineno);p->nodekind=funcdecl;
	$1->nodekind=type;insert(p,$1);
	$2->nodekind=identifier;insert(p,$2);
	$3->nodekind=lp;insert(p,$3);
	$4->nodekind=decl;insert(p,$4);
	$5->nodekind=rp;insert(p,$5);
	$6->nodekind=semi;insert(p,$6);
	$$=p;
};

MainFunc: MYINT MYMAIN LP RP LB MainBlock RB{
	Node *p=new_node("MainFunc",$1->lineno);p->nodekind=mainfunc;
	$1->nodekind=INT;insert(p,$1);
	$2->nodekind=MAIN;insert(p,$2);
	$3->nodekind=lp;insert(p,$3);
	$4->nodekind=rp;insert(p,$4);
	$5->nodekind=lb;insert(p,$5);
	$6->nodekind=mainblock;insert(p,$6);
	$7->nodekind=rb;insert(p,$7);
	$$=p;
};

MainBlock: MainBlock FuncDecl{
	Node *p=new_node("MainBlock",$1->lineno);p->nodekind=mainblock;
	$1->nodekind=mainblock;insert(p,$1);
	$2->nodekind=funcdecl;insert(p,$2);
	$$=p;
} // (FuncDecl | Statement)*
| MainBlock Statement{
	Node *p=new_node("MainBlock",$1->lineno);p->nodekind=mainblock;
	$1->nodekind=mainblock;insert(p,$1);
	$2->nodekind=statement;insert(p,$2);
	$$=p;
}
|{Node *p=new_node("NULL",0);p->nodekind=null;$$=p;}
;

Decl: Decls{
	Node *p=new_node("Decl",$1->lineno);p->nodekind=decl;
	$1->nodekind=decls;insert(p,$1);
	$$=p;
} // (VarDecl (',' VarDecl)*)?
|{Node *p=new_node("NULL",0);p->nodekind=null;$$=p;}
;

Decls: VarDecl{
	Node *p=new_node("Decls",$1->lineno);p->nodekind=decls;
	$1->nodekind=vardecl;insert(p,$1);
	$$=p;
} // (VarDecl (',' VarDecl)*)
| Decls COMMA VarDecl{
	Node *p=new_node("Decls",$1->lineno);p->nodekind=decls;
	$1->nodekind=decls;insert(p,$1);
	$2->nodekind=comma;insert(p,$2);
	$3->nodekind=vardecl;insert(p,$3);
	$$=p;
};

Type: MYINT{
	Node *p=new_node("Type",$1->lineno);p->nodekind=type;
	$1->nodekind=INT;insert(p,$1);
	$$=p;
};

Statement: LB Statements RB{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=lb;insert(p,$1);
	$2->nodekind=statements;insert(p,$2);
	$3->nodekind=rb;insert(p,$3);
	$$=p;
}
| MYIF LP Expression RP Statement %prec IFX{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=IF;insert(p,$1);
	$2->nodekind=lp;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=rp;insert(p,$4);
	$5->nodekind=statement;insert(p,$5);
	$$=p;
}
| MYIF LP Expression RP Statement MYELSE Statement{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=IF;insert(p,$1);
	$2->nodekind=lp;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=rp;insert(p,$4);
	$5->nodekind=statement;insert(p,$5);
	$6->nodekind=ELSE;insert(p,$6);
	$7->nodekind=statement;insert(p,$7);
	$$=p;
} // IF '(' Expression ')' Statement (ELSE Statement)?
| MYWHILE LP Expression RP Statement{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=WHILE;insert(p,$1);
	$2->nodekind=lp;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=rp;insert(p,$4);
	$5->nodekind=statement;insert(p,$5);
	$$=p;
}
| Identifier ASSIGN Expression SEMI{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=identifier;insert(p,$1);
	$2->nodekind=assign;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=semi;insert(p,$4);
	$$=p;
}
| Identifier LSB Expression RSB ASSIGN Expression SEMI{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=identifier;insert(p,$1);
	$2->nodekind=lsb;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=rsb;insert(p,$4);
	$5->nodekind=assign;insert(p,$5);
	$6->nodekind=expression;insert(p,$6);
	$7->nodekind=semi;insert(p,$7);
	$$=p;
}
| VarDefn{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=vardefn;insert(p,$1);
	$$=p;
}
| MYRETURN Expression SEMI{
	Node *p=new_node("Statement",$1->lineno);p->nodekind=statement;
	$1->nodekind=RETURN;insert(p,$1);
	$2->nodekind=expression;insert(p,$2);
	$3->nodekind=semi;insert(p,$3);
	$$=p;
};

Statements: Statements Statement{
	Node *p=new_node("Statements",$1->lineno);p->nodekind=statements;
	$1->nodekind=statements;insert(p,$1);
	$2->nodekind=statement;insert(p,$2);
	$$=p;
} // (Statement)*
|{Node *p=new_node("NULL",0);p->nodekind=null;$$=p;}
;

Expression: Expression BasicOp Expression{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=expression;insert(p,$1);
	$2->nodekind=basicop;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$$=p;
}
| Expression LogicOp Expression{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=expression;insert(p,$1);
	$2->nodekind=logicop;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$$=p;
}
| Identifier LSB Expression RSB{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=identifier;insert(p,$1);
	$2->nodekind=lsb;insert(p,$2);
	$3->nodekind=expression;insert(p,$3);
	$4->nodekind=rsb;insert(p,$4);
	$$=p;
}
| Identifier{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=identifier;insert(p,$1);
	$$=p;
}
| Identifier LP Arg RP{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=identifier;insert(p,$1);
	$2->nodekind=lp;insert(p,$2);
	$3->nodekind=arg;insert(p,$3);
	$4->nodekind=rp;insert(p,$4);
	$$=p;
}
| INTEGER{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=integer;insert(p,$1);
	$$=p;
}
| UnaryOp Expression{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=unaryop;insert(p,$1);
	$2->nodekind=expression;insert(p,$2);
	$$=p;
}
| LP Expression RP{
	Node *p=new_node("Expression",$1->lineno);p->nodekind=expression;
	$1->nodekind=lp;insert(p,$1);
	$2->nodekind=expression;insert(p,$2);
	$3->nodekind=rp;insert(p,$3);
	$$=p;
};

BasicOp: PLUS{
	Node *p=new_node("BasicOp",$1->lineno);p->nodekind=basicop;
	$1->nodekind=plus;insert(p,$1);
	$$=p;
}
| MINUS{
	Node *p=new_node("BasicOp",$1->lineno);p->nodekind=basicop;
	$1->nodekind=minus;insert(p,$1);
	$$=p;
}
| TIMES{
	Node *p=new_node("BasicOp",$1->lineno);p->nodekind=basicop;
	$1->nodekind=times;insert(p,$1);
	$$=p;
}
| OVER{
	Node *p=new_node("BasicOp",$1->lineno);p->nodekind=basicop;
	$1->nodekind=over;insert(p,$1);
	$$=p;
}
| MOD{
	Node *p=new_node("BasicOp",$1->lineno);p->nodekind=basicop;
	$1->nodekind=mod;insert(p,$1);
	$$=p;
};

LogicOp: MYAND{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=AND;insert(p,$1);
	$$=p;
}
| MYOR{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=OR;insert(p,$1);
	$$=p;
}
| LT{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=lt;insert(p,$1);
	$$=p;
}
| EQU{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=equ;insert(p,$1);
	$$=p;
}
| GT{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=gt;insert(p,$1);
	$$=p;
}
| UNEQU{
	Node *p=new_node("LogicOp",$1->lineno);p->nodekind=logicop;
	$1->nodekind=unequ;insert(p,$1);
	$$=p;
};

UnaryOp: MYNOT{
	Node *p=new_node("UnaryOp",$1->lineno);p->nodekind=unaryop;
	$1->nodekind=NOT;insert(p,$1);
	$$=p;
}
| MINUS{
	Node *p=new_node("UnaryOp",$1->lineno);p->nodekind=unaryop;
	$1->nodekind=minus;insert(p,$1);
	$$=p;
};

Identifier: ID{
	Node *p=new_node("Identifier",$1->lineno);p->nodekind=identifier;
	$1->nodekind=id;insert(p,$1);
	$$=p;
};

Arg: Identifiers{
	Node *p=new_node("Arg",$1->lineno);p->nodekind=arg;
	$1->nodekind=identifiers;insert(p,$1);
	$$=p;
}//(Identifier (',' Identifier)*)?
|{Node *p=new_node("NULL",0);p->nodekind=null;$$=p;}
;

Identifiers: Identifier{
	Node *p=new_node("Identifiers",$1->lineno);p->nodekind=identifiers;
	$1->nodekind=identifier;insert(p,$1);
	$$=p;
}//(Identifier (',' Identifier)*
| INTEGER{
	Node *p=new_node("Identifiers",$1->lineno);p->nodekind=identifiers;
	$1->nodekind=integer;insert(p,$1);
	$$=p;
}
| Identifiers COMMA Identifier{
	Node *p=new_node("Identifiers",$1->lineno);p->nodekind=identifiers;
	$1->nodekind=identifiers;insert(p,$1);
	$2->nodekind=comma;insert(p,$2);
	$3->nodekind=identifier;insert(p,$3);
	$$=p;
}
| Identifiers COMMA INTEGER{
	Node *p=new_node("Identifiers",$1->lineno);p->nodekind=identifiers;
	$1->nodekind=identifiers;insert(p,$1);
	$2->nodekind=comma;insert(p,$2);
	$3->nodekind=integer;insert(p,$3);
	$$=p;
};

INTEGER: NUM{
	Node *p=new_node("INTEGER",$1->lineno);p->nodekind=integer;
	$1->nodekind=num;insert(p,$1);
	$$=p;
};


%%

#include"lex.yy.c"

int yyerror(char * s)
{
	printf("Syntax error at line %d:%s\n",lineno,s);
  	printf("Current token: ");
  	printf("%d\n",yychar);
  	Error = TRUE;
  	return 0;
}


int main(int argc,char *argv[])
{

	FILE* fin=NULL;
     extern FILE* yyin;
     fin=fopen(argv[1],"r");
     if(fin==NULL)
     { 
         printf("cannot open reading file.\n");
         return -1;
     }
     yyin=fin;

    yyparse();
    print_Tree(root);
	fclose(fin);
	return 0;
}


