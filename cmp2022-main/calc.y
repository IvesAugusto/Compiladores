%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "header.h"

int yyerror(const char *s);
int yylex (void);

//#define YYERROR_VERBOSE 1
extern int yylineno;

%}

%union {
	token_args args;
	struct noh *no;
}

%define parse.error verbose

%token TOK_PRINT 
%token <args> TOK_IDENT TOK_INTEGER TOK_FLOAT
%token TOK_LITERAL

%type <no> program stmts stmt atribuicao aritmetica
%type <no> term term2 factor

%start program

%%

program : stmts {
			  noh *program = create_noh(PROGRAM, 1);
			  program->children[0] = $1;

			  print(program);
			  debug();

			  // chamada da arvore abstrata
			  // chamada da verificao semântica
			  visitor_leaf_first(&program, check_declared_vars);
			  
			  // chamada da geração de código
			  visitor_leaf_first(&program, code_generate);
		  }
        ;

stmts : stmts stmt {
			noh *n = $1;
			n = (noh*)realloc(n,
				sizeof(noh) +
				sizeof(noh*) * n->childcount);
			n->children[n->childcount] = $2;
			n->childcount++;
			$$ = n;
		}
      | stmt {
	  		$$ = create_noh(STMT, 1);
			$$->children[0] = $1;
		}
	  ;

stmt : atribuicao {
	  		$$ = $1;
	   }
     | TOK_PRINT aritmetica {
	  		$$ = create_noh(PRINT, 1);
			$$->children[0] = $2;
	   }
     ;

atribuicao : TOK_IDENT '=' aritmetica {
	  			$$ = create_noh(ASSIGN, 2);
				noh *aux = create_noh(IDENT, 0);
				aux->name = $1.ident;
				$$->children[0] = aux;
				$$->children[1] = $3;   
				if (!simbolo_existe($1.ident))
					simbolo_novo($1.ident, TOK_IDENT);
	   		 }
           ;

aritmetica : aritmetica '+' term {
	  			$$ = create_noh(SUM, 2);
				$$->children[0] = $1;
				$$->children[1] = $3;	   
	   		 }
		   | aritmetica '-' term {
	  			$$ = create_noh(MINUS, 2);
				$$->children[0] = $1;
				$$->children[1] = $3;	   
	   		 }
           | term {
		  		$$ = $1;
	   		 }
		   ;

term : term '*' term2 {
	  		$$ = create_noh(MULTI, 2);
			$$->children[0] = $1;
			$$->children[1] = $3;	   
	   }
     | term '/' term2 {
	  		$$ = create_noh(DIVIDE, 2);
			$$->children[0] = $1;
			$$->children[1] = $3;	   
	   }
     | term2 {
	  		$$ = $1;
	   }
	 ;

term2 : term2 '^' factor {
	  		$$ = create_noh(POW, 2);
			$$->children[0] = $1;
			$$->children[1] = $3;
		}
      | factor {
	  		$$ = $1;
	  	}
	  ;

factor : '(' aritmetica ')' {
			$$ = $2;
		 }
       | TOK_IDENT {
	   		$$ = create_noh(IDENT, 0);
			$$->name = $1.ident;
			if (!simbolo_existe($1.ident))
				simbolo_novo($1.ident, TOK_IDENT);
	     }
	   | TOK_INTEGER {
	   		$$ = create_noh(INTEGER, 0);
			$$->intv = $1.intv;
	   	 }
	   | TOK_FLOAT {
	   		$$ = create_noh(FLOAT, 0);
			$$->dblv = $1.dblv;
	   	 }
	   ;


%%





int yyerror(const char *s) {
	printf("Erro na linha %d: %s\n", yylineno, s);
	return 1;
}


