%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "Header.h"
	#include "calc.tab.h"
	
%}	

%option yylineno
D [0-9]
L [A-Za-z_]


%%

[ \t\r\n]			{                      }

"print"			{return TOK_PRINT;}
"*" 				{return '*';}
"="				{return '=';}
"+"				{return '+';}
"-"				{return '-';}
"("				{return '(';}
")"				{return ')';}
"/"				{return '/';}
"^"				{return '^';}

{D}+				{yylval.args.intv = atoi(yytext);
				 return TOK_INTEGER;}
{D}+\.{D}+			{yylval.args.dblv = atof(yytext);
				 return TOK_FLOAT;}
{L}({L}|{D})*			{yylval.args.ident = strndup(yytext, yyleng);
				 return TOK_IDENT;}

.				{printf("Lambão, caracter invalido: %c.\n",yytext[0]);}
%%
int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){
	if (argc <= 1)
	{	
		printf("%s [file]\n",argv[0]);
		return 1;
	}
	FILE *f = fopen(argv[1],"r");
	yyin = f;
	yyparse();
	fclose(f);
	
	return 0;

}
