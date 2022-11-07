%{
	#include <stdio.h>
	#include "Header.h"
	#include <stdlib.h>
     #include <string.h>
     #include <stdbool>
	
int yyerror(const char *s);
int yylex (void);
extern int yylineno;
typedf struct{
     char *nome;
     int token;
}simbolo;
int simbolo_qtd = 0;
simbolo tsimbolos[100] ;
simbolo *simbolo_novo(char *nome, int token);
bool simbolo_existe(char *nome);
void debug();
%}
%union {
      token_args args;
      struct noh *no;
      }
%define parse.error verbose
%token TOK_PRINT TOK_AND TOK_OR TOK_IF TOK_ELSE TOK_WHILE
%token <args> TOK_IDENT TOK_INTEGER TOK_FLOAT
%token TOK_LITERAL
%start program
%type <no> program stmts stmt atribuicao aritmetica
%type <no> logical IF WHILE lfactor lterm
%type <no> term term2 factor
%%

program : stmts {
           noh *program = create_noh(PROGRAM, 1);
           program->children[0] = $1;
           print(program);
           debug();
           }
	;
stmts   : stmts stmt{
          noh *n = $1;
          n = (noh*)realloc(n,sizeof(noh) + sizeof(noh*) * (n->childcount));
          n-> children[n->childcount] = $2;
          n-> childcount++;
          $$ = n;
  }
	| stmt{
	  $$ = create_noh(STMT, 1);
          $$-> children[0] = $1;
          }
	;
stmt : atribuicao{
          $$ = $1;
          //$$ = create_noh(GENERIC, 1);
          //$$-> children[0] = $1;
          }

     | TOK_PRINT aritmetica{
     
          $$ = create_noh(PRINT, 1);
          $$-> children[0] = $2;
          }
     ;
atribuicao : TOK_IDENT '=' aritmetica{

          $$ = create_noh(ASSIGN, 2);
          $$-> children[0] = create_noh(IDENT, 0);
          $$-> children[0]->name = $1.ident;
          $$-> children[1] = $3;
          | IF {$$ = $1;}
          | WHILE {$$ = $1;}
          if (!simbolo_existe($1.ident)){
               simbolo_novo($1.ident, TOK_IDENT)}
               
          }
          ;
IF : TOK_IF '(' logical ')' '{' stmts '}' {
		$$ = create_noh(IF, 2);
		$$->children[0] = $3;
		$$->children[1] = $6;
          }
| TOK_IF '(' logical ')' '{' stmts '}' TOK_ELSE IF{
		$$ = create_noh(IF, 3);
		$$->children[0] = $3;
		$$->children[1] = $6;
		$$->children[2] = $9; 
          }  
| TOK_IF '(' logical ')' '{' stmts '}' TOK_ELSE '{' stmts '}'{
		$$ = create_noh(IF, 3);
		$$->children[0] = $3;
          $$->children[1] = $6;       
		$$->children[2] = $10;                                      
		}
          ;  
WHILE	:TOK_WHILE '(' logical ')' '{' stmts '}'{
		$$ = create_noh(WHILE, 2);
		$$->children[0] = $3;
		$$->children[1] = $6;
          }
		;
logical : logical TOK_OR lterm{
		$$ = create_noh(OR, 2);
		$$->children[0] = $1;     
		$$->children[1] = $3;     
		}
		| lterm{$$ = $1;}
		;
lterm	: lterm TOK_AND lfactor{
		$$ = create_noh(TOK_AND, 2);
		$$->children[0] = $1;
		$$->children[1] = $3;
		}
		lfactor{$$ = $1;}
		;

lfactor : '(' logical ')'{
		$$ = $2;
		}
		| aritmetica '>' aritmetica{
		$$ = create_noh(GT, 2);
		$$->children[0] = $1;
	     $$->children[1] = $3;      
		}
		| aritmetica '<' aritmetica{
		$$ = create_noh(LT, 2);
		$$->children[0]= $1;        
		$$->children[1] = $3;
		}
		| aritmetica '=''=' aritmetica{
		$$ = create_noh(EQ, 2);
		$$->children[0] = $1;
		$$->children[1] = $4;
		}
		| aritmetica '>''=' aritmetica{
		$$ = create_noh(GE, 2);
		$$->children[0] = $1;
		$$->children[1] = $4;
		}
		| aritmetica '<''=' aritmetica{
		$$ = create_noh(LE, 2);
		$$->children[0] = $1;
		$$->children[1] = $4;
		}
		
		| aritmetica '!''=' aritmetica{
          $$ = create_noh(NE, 2);
          $$->children[0] = $1;
          $$->children[1] = $4;
          }
		;


aritmetica : aritmetica '+' term{

          $$ = create_noh(SUM, 2);
          $$-> children[0] = $1;
          $$-> children[1] = $3;
          }
           | aritmetica '-' term{
           
          $$ = create_noh(MINUS, 2);
          $$-> children[0] = $1;
          $$-> children[1] = $3;
          } 
           | term{
          $$ = $1; 
          //$$ = create_noh(GENERIC, 1);
          //$$-> children[0] = $1;
          } 
           ;
term : term '*' term2{
          $$ = create_noh(MULTI, 2);
          $$-> children[0] = $1;
          $$-> children[1] = $3;
          }

     | term '/' term2{
          $$ = create_noh(DIVIDE, 2);
          $$-> children[0] = $1;
          $$-> children[1] = $3;
          }
     | term2{
          $$ = $1;
          //$$ = create_noh(GENERIC, 1);
          //$$-> children[0] = $1;
          }
     ;
term2 : term2 '^' factor{
          $$ = create_noh(POW, 2);
          $$-> children[0] = $1;
          $$-> children[1] = $3;
}
     | factor{
     	  $$ = $1;
          //$$ = create_noh(GENERIC, 1);
          //$$-> children[0] = $1;
     }
     ;  
factor : '(' aritmetica ')'{
               $$ = $2;
		//$$ = create_noh(PAREN, 1);
		//$$-> children[0] = $2;
		}
       | TOK_IDENT{
         $$ = create_noh(IDENT,0);
         $$->name = $1.ident;
         if (!simbolo_existe($1.ident)){
               simbolo_novo($1.ident, TOK_IDENT)
               }
       }
       | TOK_INTEGER{
         $$ = create_noh(INTEGER,0);
         $$->intv = $1.intv;
         }
       | TOK_FLOAT{
         $$ = create_noh(FLOAT,0);
         $$->dblv = $1.dblv;
       }
       ;
%%           
int yyerror(const char *s){
    printf("Lambança, erro na linha %d: %s\n", yylineno,s);
    return 1;
}
simbolo *simbolo_novo(char *nome, int token){
     tsimbolos[simbolo_qtd].nome = nome;
     tsimbolos[simbolo_qtd].token = token;
     simbolo *result = &tsimbolos[simbolo_qtd];
     simbolo_qtd++;
     return result;
}
bool simbolo_existe(char *nome){
     for(i = 0; i < simbolo_qtd; i++){
          if(strcmp(tsimbolos[i].nome, nome == 0))
          return true;
          }
     return false;
     }
void debug() {
     printf("Simbolos: \n");
     for(i = 0; i < simbolo_qtd; i++){
          printf("\t%s\n", tsimbolos[i].nome);
          }
}


          
