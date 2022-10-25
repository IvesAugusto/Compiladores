all:
	flex lexico.l
	bison -d calc.y
	gcc calc.tab.c lex.yy.c Header.c -o cmpives
	

