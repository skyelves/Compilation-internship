#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
//#include<stack>

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

//extern FILE* source; /* source code text file */
//extern FILE* listing; /* listing output text file */
//extern FILE* code; /* code text file for TM simulator */

int lineno=1;

/**************************************************/
/***********   Syntax tree for parsing ************/
/**************************************************/

typedef enum {goal,defn,vardefn,vardecl,funcdefn,funcdecl,mainfunc,
mainblock,decl,decls,type,statement,statements,expression,identifier,
arg,identifiers,integer,null,semi,comma,lsb,rsb,lp,rp,lb,rb,assign,
basicop,logicop,unaryop,plus,minus,times,over,mod,
AND,OR,lt,gt,equ,
unequ,NOT,id,num,
INT,IF,ELSE,WHILE,RETURN,MAIN} NODEKIND;

/* ExpType is used for type checking */
typedef enum {Void,Int,Bool} EXPTYPE;

#define MAXNAMELEN 20

typedef struct treeNode
{
	struct treeNode * child;
	struct treeNode * sibling;
	NODEKIND nodekind;
	int childno;
	int lineno;
	int col;
	int val;
	int isbegin;
	char name[MAXNAMELEN];
	EXPTYPE type; /* for type checking of exps */
} Node;

Node * root=NULL;

Node * new_node(char * _name,int _lineno)
{	
	Node *p = (Node*)malloc(sizeof(Node)); 
	if(p==NULL)
	{
		printf("Error:out of memory!\n");
		exit(1);
	}
	strncpy(p->name,_name,MAXNAMELEN);
	p->lineno=_lineno;
	p->col=0;//have not achieved
	p->child=NULL;
	p->sibling=NULL;
	p->childno=0;
	p->isbegin=0;
	return p;
}

Node * new_nodenum(char * _name,int _lineno,int _val)
{	
	Node *p = (Node*)malloc(sizeof(Node)); 
	if(p==NULL)
	{
		printf("Error:out of memory!\n");
		exit(1);
	}
	strncpy(p->name,_name,MAXNAMELEN);
	p->lineno=_lineno;
	p->col=0;//have not achieved
	p->val=_val;
	p->child=NULL;
	p->sibling=NULL;
	p->childno=0;
	p->isbegin=0;
	return p;
}

void insert(Node * parent,Node * _child)
{
	if(_child==NULL)
		return;
	if(parent->childno==0)
	{
		parent->child=_child;
		_child->isbegin=1;
		parent->childno++;
	}
	else
	{
		Node *temp=parent->child;
		while(temp->sibling!=NULL)
			temp=temp->sibling;
		temp->sibling=_child;
		_child->isbegin=0;
		parent->childno++;
	}
}

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

/* Error = TRUE prevents further passes if an error occurs */
int Error; 


/**************************************************/
/****************  Print the tree *****************/
/**************************************************/

int varcnt=0;//varibles num
int localcnt=0;//local varibles
int jmpcnt=0;
int tempcnt=0;//temporary varibles i defied
char varname[MAXNAMELEN][5000]={0};
char localname[MAXNAMELEN][5000]={0};
int isarray[5000]={0};
int expstack[5000]={0};
int exptop=0;//top of expstack

int getexp()
{
	exptop--;
	return expstack[exptop];
}

void pushexp(int t)
{
	expstack[exptop]=t;
	exptop++;
	return;
}

void print_Tree(Node * root)
{
	if(root->nodekind==null||root->childno==0)
		return;
	//printf("%s %d\n",root->name,root->childno);
	NODEKIND root_nodekind=root->nodekind;
	if(root_nodekind==goal)
	{
		Node *p=root->child;
		if(root->childno==1)
			print_Tree(p);
		else
		{
			print_Tree(p);
			print_Tree(p->sibling);
		}
	}
	else if(root_nodekind==defn)
	{
		Node *p=root->child;
		print_Tree(p);
		print_Tree(p->sibling);
	}
	else if(root_nodekind==vardefn)
	{
		if(root->childno==3)
		{
			printf("var T%d\n",varcnt);
			memset(varname[varcnt],0,MAXNAMELEN*sizeof(char));
			strcpy(varname[varcnt],root->child->sibling->child->name);
			isarray[varcnt]=0;
			varcnt++;
		}
		else
		{
			int len=(root->child->sibling->sibling->sibling->child->val)*4;
			printf("var %d T%d\n",len,varcnt);
			memset(varname[varcnt],0,MAXNAMELEN*sizeof(char));
			strcpy(varname[varcnt],root->child->sibling->child->name);
			isarray[varcnt]=len;
			varcnt++;
		}
	}
	else if(root_nodekind==funcdecl)
	{
		memset(varname[varcnt],0,MAXNAMELEN*sizeof(char));
		strcpy(varname[varcnt],root->child->sibling->child->name);
		isarray[varcnt]=0;
		varcnt++;
		return;
	}
	else if(root_nodekind==funcdefn)
	{
		int argnum=0;
		//find out the number of args
		Node *decl=root->child->sibling->sibling->sibling;
		if(decl->childno>0)
		{
			decl=decl->child;//decls
			argnum++;
			while(decl->childno>1)
			{
				decl=decl->child;
				argnum++;
			}
		}
		localcnt=argnum;
		decl=root->child->sibling->sibling->sibling;
		if(decl->childno>0)
		{
			localcnt--;
			decl=decl->child;//decls
			Node *q=decl->child;
			if(decl->childno>1)
				q=q->sibling->sibling;//vardecl
			strcpy(localname[localcnt],q->child->sibling->child->name);
			while(decl->childno>1)
			{
				localcnt--;
				decl=decl->child;
				q=decl->child;
				if(decl->childno>1)
					q=q->sibling->sibling;//vardecl
				strcpy(localname[localcnt],q->child->sibling->child->name);
			}
		}
		//printf("%d\n",argnum);
		//for(int i=0;i<argnum;i++)
		//	printf("%s\n",localname[i]);
		localcnt=argnum;
		printf("f_%s [%d]\n",root->child->sibling->child->name,argnum);
		print_Tree(root->child->sibling->sibling->sibling->sibling->sibling->sibling);
		printf("end f_%s\n",root->child->sibling->child->name);
		memset(localname,0,sizeof(localname));
		localcnt=0;
	}
	else if(root_nodekind==mainfunc)
	{
		printf("f_main [0]\n");
		print_Tree(root->child->sibling->sibling->sibling->sibling->sibling);
		printf("end f_main\n");
	}
	else if(root_nodekind==mainblock)
	{
		Node *p=root->child;
		print_Tree(p);
		//printf("%s\n",p->sibling->child->name);
		print_Tree(p->sibling);
	}
	else if(root_nodekind==statements)
	{
		//printf("-------------------------hello\n");
		Node *p=root->child;
		print_Tree(p);
		print_Tree(p->sibling);
	}
	else if(root_nodekind==statement)
	{
		Node *p=root->child;
		if(p->nodekind==lb)
		{
			//printf("%s\n",p->sibling->name);
			print_Tree(p->sibling);
		}
		else if(p->nodekind==IF)
		{
			if(root->childno==5)
			{
				//printf("------------------1");
				print_Tree(p->sibling->sibling);
				printf("var t%d\n",tempcnt);
				printf("t%d = t%d\n",tempcnt,getexp());
				tempcnt++;
				printf("if t%d == 0 goto l%d\n",tempcnt-1,jmpcnt);
				int towhere=jmpcnt;
				jmpcnt++;
				print_Tree(p->sibling->sibling->sibling->sibling);
				printf("l%d:\n",towhere);
			}
			else
			{
				//printf("-------------------2");
				print_Tree(p->sibling->sibling);
				printf("var t%d\n",tempcnt);
				printf("t%d = t%d == 0\n",tempcnt,getexp());
				tempcnt++;
				printf("if t%d == 0 goto l%d\n",tempcnt-1,jmpcnt);
				jmpcnt++;
				print_Tree(p->sibling->sibling->sibling->sibling->sibling->sibling);
				printf("goto l%d\nl%d:\n",jmpcnt,jmpcnt-1);
				int towhere=jmpcnt;
				jmpcnt++;
				print_Tree(p->sibling->sibling->sibling->sibling);
				printf("l%d:\n",towhere);
			}
		}
		else if(p->nodekind==WHILE)
		{
			printf("l%d:\n",jmpcnt);
			int towhere1=jmpcnt;
			jmpcnt++;
			print_Tree(p->sibling->sibling);
			printf("var t%d\n",tempcnt);
			printf("t%d = t%d\n",tempcnt,getexp());
			tempcnt++;
			printf("if t%d == 0 goto l%d\n",tempcnt-1,jmpcnt);
			int towhere2=jmpcnt;
			jmpcnt++;
			print_Tree(p->sibling->sibling->sibling->sibling);
			printf("goto l%d\nl%d:\n",towhere1,towhere2);
		}
		else if(p->nodekind==identifier)
		{
			int varid=varcnt;
			int islocal=0;//in the funcdefn
			for(varid=localcnt;varid>=0;varid--)
			{
				if(strcmp(p->child->name,localname[varid])==0)
					{islocal=1;break;}
			}
			if(!islocal)
				for(varid=varcnt;varid>=0;varid--)
				{
					if(strcmp(p->child->name,varname[varid])==0)
						break;
				}
			if(varid<0)
				{printf("Varible not defied!\n");exit(1);}
			if(p->sibling->nodekind==assign)
			{
				if(isarray[varid]>0)
				{printf("Varible not int!\n");exit(1);}
				print_Tree(p->sibling->sibling);
				if(islocal)
					printf("p%d = t%d\n",varid,getexp());
				else
					printf("T%d = t%d\n",varid,getexp());
			}
			else
			{
				if(isarray[varid]==0)
				{printf("Varible not array!\n");exit(1);}
				print_Tree(p->sibling->sibling);
				print_Tree(p->sibling->sibling->sibling->sibling->sibling);
				int temp2=getexp();
				int temp1=getexp();
				printf("var t%d\n",tempcnt);
				tempcnt++;
				printf("t%d = 4 * t%d\n",tempcnt-1,temp1);
				if(islocal)
					printf("p%d [t%d] = t%d\n",varid,tempcnt-1,temp2);
				else
					printf("T%d [t%d] = t%d\n",varid,tempcnt-1,temp2);
			}
		}
		else if(p->nodekind==vardefn)
			print_Tree(p);
		else if(p->nodekind==RETURN)
		{
			print_Tree(p->sibling);
			printf("return t%d\n",getexp());
		}
	}
	else if(root_nodekind==expression)
	{
		Node *p=root->child;
		if(p->nodekind==expression)
		{
			print_Tree(p);
			print_Tree(p->sibling->sibling);
			int temp1=0,temp2=0;
			temp2=getexp();
			temp1=getexp();
			printf("var t%d\n",tempcnt);
			printf("t%d = t%d %s t%d\n",tempcnt,temp1,p->sibling->child->name,temp2);
			pushexp(tempcnt);
			tempcnt++;
		}
		else if(p->nodekind==identifier)
		{
			if(root->childno==1)//Identifier
			{
				int varid=varcnt;
				int islocal=0;//in the funcdefn
				for(varid=localcnt;varid>=0;varid--)
				{
					if(strcmp(p->child->name,localname[varid])==0)
						{islocal=1;break;}
				}
				if(!islocal)
					for(varid=varcnt;varid>=0;varid--)
					{
						if(strcmp(p->child->name,varname[varid])==0)
							break;
					}
				if(varid<0)
					{printf("Varible not defied!\n");exit(1);}
				else
				{
					printf("var t%d\n",tempcnt);
					if(islocal)
						printf("t%d = p%d\n",tempcnt,varid);
					else
						printf("t%d = T%d\n",tempcnt,varid);
					pushexp(tempcnt);
					tempcnt++;
				}
			}
			else if(p->sibling->nodekind==lp)//Identifier LP Arg RP
			{
				printf("var t%d\n",tempcnt);
				print_Tree(p->sibling->sibling);
				printf("t%d = call f_%s\n",tempcnt,p->child->name);
				pushexp(tempcnt);
				tempcnt++;
			}
			else//Identifier LSB Expression RSB
			{
				int varid=varcnt;
				int islocal=0;//in the funcdefn
				for(varid=localcnt;varid>=0;varid--)
				{
					if(strcmp(p->child->name,localname[varid])==0)
						{islocal=1;break;}
				}
				if(!islocal)
					for(varid=varcnt;varid>=0;varid--)
					{
						if(strcmp(p->child->name,varname[varid])==0)
							break;
					}
				if(varid<0)
					{printf("Varible not defied!\n");exit(1);}
				if(isarray[varid]==0)
					{printf("Varible not array!\n");exit(1);}
				print_Tree(p->sibling->sibling);
				printf("var t%d\n",tempcnt);
				tempcnt++;
				printf("t%d = t%d\n",tempcnt-1,getexp());
				printf("var t%d\n",tempcnt);
				tempcnt++;
				printf("t%d = 4 * t%d\n",tempcnt-1,tempcnt-2);
				printf("var t%d\n",tempcnt);
				if(islocal)
					printf("t%d = p%d [t%d]\n",tempcnt,varid,tempcnt-1);
				else
					printf("t%d = T%d [t%d]\n",tempcnt,varid,tempcnt-1);
				pushexp(tempcnt);
				tempcnt++;
			}
		}
		else if(p->nodekind==integer)
		{
			printf("var t%d\n",tempcnt);
			printf("t%d = %d\n",tempcnt,p->child->val);
			pushexp(tempcnt);
			tempcnt++;
		}
		else if(p->nodekind==unaryop)
		{
			print_Tree(p->sibling);
			printf("var t%d\n",tempcnt);
			printf("t%d = %st%d\n",tempcnt,p->child->name,getexp());
			pushexp(tempcnt);
			tempcnt++;
		}
		else if(p->nodekind==lp)
		{
			print_Tree(p->sibling);
			printf("var t%d\n",tempcnt);
			printf("t%d = t%d\n",tempcnt,getexp());
			pushexp(tempcnt);
			tempcnt++;
		}
	}
	else if(root_nodekind==arg)
	{
		if(root->childno==0)
			return;
		print_Tree(root->child);
	}
	else if(root_nodekind==identifiers)
	{
		Node *p=root->child;
		if(root->childno==1)
		{
			if(p->nodekind==integer)
				printf("param %d\n",p->child->val);
			else
			{
				int varid=varcnt;
				int islocal=0;//in the funcdefn
				for(varid=localcnt;varid>=0;varid--)
				{
					if(strcmp(p->child->name,localname[varid])==0)
						{islocal=1;break;}
				}
				if(!islocal)
					for(varid=varcnt;varid>=0;varid--)
					{
						if(strcmp(p->child->name,varname[varid])==0)
							break;
					}
				if(varid<0)
					{printf("Varible not defied!\n");exit(1);}
				if(islocal)
					printf("param p%d\n",varid);
				else
					printf("param T%d\n",varid);
			}
		}
		else
		{
			print_Tree(p);
			p=p->sibling->sibling;
			if(p->nodekind==integer)
				printf("param %d\n",p->child->val);
			else
			{
				int varid=varcnt;
				int islocal=0;//in the funcdefn
				for(varid=localcnt;varid>=0;varid--)
				{
					if(strcmp(p->child->name,localname[varid])==0)
						{islocal=1;break;}
				}
				if(!islocal)
					for(varid=varcnt;varid>=0;varid--)
					{
						if(strcmp(p->child->name,varname[varid])==0)
							break;
					}
				if(varid<0)
					{printf("Varible not defied!\n");exit(1);}
				if(islocal)
					printf("param p%d\n",varid);
				else
					printf("param T%d\n",varid);
			}
		}
	}
	return;
}
/*
typedef enum {goal,defn,vardefn,funcdefn,funcdecl,mainfunc,
mainblock,statement,statements
expression,arg,identifiers,
vardecl,decl,decls,type,,identifier,
integer,null,semi,comma,lsb,rsb,lp,rp,lb,rb,assign,
basicop,logicop,unaryop,plus,minus,times,over,mod,
AND,OR,lt,gt,equ,
unequ,NOT,id,num,
INT,IF,ELSE,WHILE,RETURN,MAIN} NODEKIND;
*/

#endif
