%option noyywrap nodefault yylineno case-insensitive

%{

 struct symbol{
 	char *name;
 	struct ref *reflist;
 };

 struct ref{
 	struct ref *next;
 	char *filename;
 	int flags;
 	int lineno;
 };

struct hashLink{
	char *linkHash;
};

 #define NHASH 9997

 struct hashLink hashNomes[500];
 struct symbol symtab[NHASH];
 struct symbol *lookup(char*);
 void addref(int, char *, char*,int);
 char *extractTitle(char*);
 char *extractTitleWork(char*);
 char *extractName(char *);
 char *extractAutor(char *);
 char *extractLink(char *);
 char *extractTitleAff(char*);
 char *extractLinkAff(char *);
 char *extractAutorAff(char *);
 char *insereLista(FILE *);
 int procuraLista(char *);

 char *curfilename; /*nome do arquivo corrente*/
 char *palavra1;
 char *palavra2;
 char *palavra3;
 char *palavra4;
 char *link2;
 char *autor;
 char *nomefic;
 char *nameficWork;
 FILE *fileArq;
 char *lista; //1-2jae, 2-thiam, 3- markjin, 4-mx, 5-seventeen, 6-bts
 int fave;
 int pos;


%}

NUM [0-9] 
LETRAS [a-zA-Z]
SIMB [\-\_]

LINKAO3 "https\:\/\/archiveofourown\.org\/works\/"
LINKAO32 "http\:\/\/archiveofourown\.org\/works\/"
LINKAO3_NUM ({LINKAO3}|{LINKAO32}){NUM}*


LINKAFFAUTOR "profile\/view\/"({NUM})*



SIM2 ["\n" | "\t" | "\ " | "\-" | "(" | ")" | "\&" | "?" | "!" | "’" | "." | "," | "\'" | "\_" | "|" | "\/" | "´" | ":"]

NAMEFICWORK "<a href\=\"\/works\/"{NUM}*"\">"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*

NAMEFICLINKAFF "foreword\-link\"><a href\=\""(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*

NAMEFICAFF "class\=\"title title--main\">"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*

NAMEFIC "<title>"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*

NAMEFIC2 "<h2 class\=\"title heading\">"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*

NAMEAUTOR "href\=\"\/users\/".*"\/pseuds\/"

AUTORAFF "Author(s)<\/span><a"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*"\=\""(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*"\">"(({SIM2}*{LETRAS}*{NUM}*)*{SIM2}*)*


%%

{NAMEFICWORK} {extractTitleWork(yytext);}

{LINKAO3_NUM} {extractLink(yytext);}

{NAMEFIC2} {extractTitle(yytext);}

{NAMEAUTOR} {extractAutor(yytext);
			if(fave == 1){
				if(procuraLista(link2) == 1){
					printf("Fic já existe.\n");
				}else{
					fprintf(fileArq,"*(%s) [%s] (%s)⭐\n",nomefic,link2,autor);
				}
			}
			else{
				if(procuraLista(link2) == 1){
					printf("Fic já existe.\n");
				}else{
					fprintf(fileArq,"*(%s) [%s] (%s) \n",nomefic,link2,autor);
				}
			}
		fclose(fileArq);}


{NAMEFICAFF} {extractTitleAff(yytext);
			}

{AUTORAFF} {extractAutorAff(yytext);}

{NAMEFICLINKAFF} {extractLinkAff(yytext);
			if(fave == 1){
				if(procuraLista(link2) == 1){
					printf("Fic já existe.\n");
				}else{
					fprintf(fileArq,"*(%s) [%s] (%s)⭐\n",nomefic,link2,autor);
				}
			}else{
				if(procuraLista(link2) == 1){
					printf("Fic já existe.\n");
				}else{
					fprintf(fileArq,"*(%s) [%s] (%s) \n",nomefic,link2,autor);
				}
			}
		fclose(fileArq);}

.|\n 		



%%

/*funcoes em C*/

static unsigned symhash(char *sym){
	unsigned int hash =0;
	unsigned c;

	while(c = *sym++){
		hash = hash*9^c;
	}

return hash;
}

struct symbol *lookup(char *sym){
	struct symbol *sp = &symtab[symhash(sym)%NHASH];
	int scount = NHASH;

	while(--scount>= 0){
		if(sp->name && !strcasecmp(sp->name,sym))
			return sp;

			if(!sp->name){ 
				sp->name = strdup(sym); //nova entrada
				sp->reflist = 0;
				//printf("entra aqui??");
				return sp;
			}

			if(++sp >= symtab+NHASH){
				sp = symtab; //tenta a prox entrada
			}
	}

	fputs("overflow na tab simbolos \n",stderr);
	abort();
}

void addref(int lineno, char *filename, char *word, int flags){

	struct ref *r;
	struct symbol *sp = lookup(word);

	if(sp->reflist && sp->reflist->lineno == lineno && sp->reflist->filename == filename)
		return;

	r = malloc(sizeof(struct ref));

	if(!r){
		fputs("sem espaço \n",stderr);
		abort();
	}

	r->next = sp->reflist;
	r->filename = filename;
	r->flags = flags;
	sp->reflist = r;

}

static int symcompare(const void *xa, const void *xb){

	const struct symbol *a = xa;
	const struct symbol *b = xb;

	if(!a->name){
		if(!b->name)
			return 0;
	return 1;
	}

	if(!b->name)
		return -1;


	return strcmp(a->name, b->name);

}

void printrefs(){ /* ordenação da tabela*/

	struct symbol *sp, *sp_aux;

	qsort(symtab, NHASH, sizeof(struct symbol), symcompare);

	for(sp == symtab; sp->name && sp<symtab+NHASH; sp++){
		char *prevfn = NULL; //ultimo arquivo impresso
	

	struct ref *rp = sp->reflist;
	struct ref *rpp = 0;
	struct ref *rpn;

	do{
		rpn = rp->next;
		rp->next = rpp;
		rpp = rp;
		rp = rpn;
	}while(rp);


	printf("%10s", sp->name);

	for(rp = rpp; rp; rp = rp->next){
		
		if(rp->filename == prevfn){

			printf("%d", rp->lineno);
		}else{
			printf(" %s:%d", rp->filename, rp->lineno);
			prevfn = rp->filename;
		}
	}

	printf("\n");
	}
}


char *extractTitle(char *title){
	int i,j;
	int aux = 0;
	int tam = strlen(title)-27;
	nomefic = malloc(sizeof(char)*tam);
	char resto[100];

	
	for(j = 0; j < strlen(title)-1; j++){
		resto[j] = title[j];
	}
	

	for(i = 33; i < strlen(title)-5; i++){

		nomefic[aux] = resto[i];
		//printf("%c", nomefic[aux]);
		aux++;
	}

return nomefic;
}

char *extractTitleAff(char *title){
	int i,j;
	int aux = 0;
	int tam = strlen(title)-27;
	nomefic = malloc(sizeof(char)*tam);
	char resto[100];

	
	for(j = 0; j < strlen(title)-1; j++){
		resto[j] = title[j];
	}
	
	

	for(i = 27; i < strlen(title); i++){

		nomefic[aux] = resto[i];
		//printf("%c", nomefic[aux]);
		aux++;
	}

return nomefic;
}



char *extractTitleWork(char *titleWork){
	int i,j;
	int aux = 0;
	int tam = strlen(titleWork)-27;
	nameficWork = malloc(sizeof(char)*tam);
	char resto[100];

	
	for(j = 0; j < strlen(titleWork); j++){
		resto[j] = titleWork[j];
	}

	for(i = 26; i <strlen(titleWork); i++){

		nameficWork[aux] = resto[i];
		//printf("%c", nameficWork[aux]);
		aux++;
	}
	nomefic = nameficWork;
return nomefic;
}

char *extractAutor(char *autoryy){	
	int i;
	int tam = strlen(autoryy)-8;
	int aux = 0;
	autor = malloc(sizeof(char)*tam);
	

	for(i = 13; i < tam; i++){
		autor[aux] = autoryy[i];
		
		//printf("%c", autor[aux]);
		aux++;
	}

return autor;
}

char *extractAutorAff(char *autoryy){	
	int i;
	int tam = strlen(autoryy);
	int aux = 0;
	autor = malloc(sizeof(char)*tam);
	

	for(i = 47; i < strlen(autoryy); i++){
		autor[aux] = autoryy[i];
		
		//printf("%c", autor[aux]);
		aux++;
	}

return autor;
}

char *extractLink(char *linkyy){	
	int i;
//	int tam = strlen(linkyy)-8;
	int aux = 0;
	link2 = malloc(sizeof(char)*strlen(linkyy));
	

	for(i = 0; i < strlen(linkyy); i++){
		link2[aux] = linkyy[i];
		
		aux++;
	}

return link2;
}

char *extractLinkAff(char *linkyy){	
	int i;
//	int tam = strlen(linkyy);
	int aux = 0;
	link2 = malloc(sizeof(char)*strlen(linkyy));
	char *conc = malloc(sizeof(char)*strlen(linkyy));
	
	

	for(i = 24; i < strlen(linkyy)-7; i++){
		link2[aux] = linkyy[i];
		
		aux++;
	}
	strcat(conc,"http://www.asianfanfics.com");
	strcat(conc,link2);
	//printf("link %s", conc);
	link2 = conc;
return link2;
}


char *insereLista(FILE *file){
	
	int j = 0;
	pos = 0;
	char linha[500];
	char *temp;
	rewind(file);

	while(fscanf(file,"%s",linha) != EOF){

		if(strlen(linha) > 40){
			temp = malloc(sizeof(linha));
			strcpy(temp,linha);
			hashNomes[pos].linkHash = temp;
			pos++;
		}
	}

}

int procuraLista(char *linktabela){
	int count = pos-1;
	int i,j=0;
	char *result = malloc(sizeof(char)*42);

	strcat(result,"[");
	strcat(result,linktabela);
	strcat(result,"]");

	while(count > 0){

		if(strcmp(result,hashNomes[count].linkHash) == 0){
			return 1;
		}
		count--;
	}
}

int main(argc,argv) int argc; char **argv;
{

	int i;
	lista = malloc(sizeof(char));
	char *nomeArquivo = malloc(sizeof(char)*15);

	printf("Qual lista?\n\n1-2jae \t\t2-thiam \t\t3-markjin\n4-mx \t\t5-seventeen \t\t6-BTS \n7-Markson \t8-Jinson \t\t9-MarkJinSon\n10-Markjae \t11-Meanie \t\t12-Jinhan\n13-Eunhae \n\n");
	scanf("%c",&lista[0]);
	strcat(nomeArquivo,"listography/");
	strcat(nomeArquivo,(char*)&lista[0]);
	strcat(nomeArquivo,".txt");
	
	fileArq = fopen(nomeArquivo,"a+");

	printf("Digite 1 (um) para favoritar. \n\n ");
	scanf("%d",&fave);

	insereLista(fileArq);


	if(argc <2){
		curfilename = "(stdin)";
		yylineno = 1;
		yylex();
	}else{
		for(i = 1; i < argc; i++){
			FILE *f = fopen(argv[i],"r");

			if(!f){
				perror(argv[i]);
				return(1);
			}

			curfilename = argv[i];

			yyrestart(f);
			yylineno = 1;
			yylex();
			fclose(f);
		}

		
	printrefs();
	}

return 0;
}
