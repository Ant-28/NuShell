lexer grammar NewShLexer;




// define keywords



FOR : 'for';
DO : 'do';
DONE : 'done';
WHILE : 'while';
UNTIL : 'until';
SELECT : 'select';
FUNCTION : 'function';
IF : 'if';
THEN : 'then';
ELSE : 'else';
FI : 'fi';
IN : 'in';
CASE : 'case';
ESAC : 'esac';
ELIF : 'elif';
RANGE : 'range';
LEN : 'len''gth'?;
ITEMS : 'items';

DOT : '.';

COMMA : ',';
NUMBER : [0-9]+;
IO_NUMBER : NUMBER;
ID : ([a-zA-Z_\-/0-9])+;
STRING_ID : ([a-zA-Z_\-/]|',')+;
VAR : '$'ID;
FLOAT : ([1-9][0-9]*'.'[0-9]*[1-9])|[0]'.'[1-9]+;
// WORD : ID;


AND_IF : '&&';
OR_IF : '||';
DSEMI : ';;';

AND : '&';

EQ  : '=';
DEQ : '==';
NEQ : '!=';
DLESS : '<<';
DGREAT : '>>';

LT : '<';
GT : '>';

DOLLAR : '$';

LESSAND : '<&';
GREATAND : '>&';

LESSGREAT : '<>';
DLESSDASH : '<<-';

CLOBBER : '>|';

PIPE : '|';

// SEPARATOROP : '&'|';';


SEMI : ';';
NEWLINE : [\r?\n];

CMNT : '#'~[\n]*[\n] -> skip;
SPACE : ' '+ -> skip;
// AMP2 : '&&';
// AMP : '&';

// OR : '||';


// R2ARROW : '>>';
// L2ARROW : '<<';
// RARROW : '>';
// LARROW : '<';

// DOUBLESEMI : ';;';
// SEMI : ';';
// HYPHEN : '-';
// LTAMP : LARROW '&';
// RTAMP : RARROW '&';
// AMPRT : '&' RARROW;
// LRARR : LARROW RARROW;
// LARRPIPE : LARROW '|';
// L2ARRHYPH : L2ARROW HYPHEN;


// ID : ALPHA+;
// ALPHA : [a-zA-Z_];

// NUMS : NUM+;
// NUM : [0-9];

// FLOAT : ([1-9][0-9]*[.]) |  ([1-9][0-9]*[.][0-9]*);

// DELIM : [\n;];
// NL : [\r?\n];

// BLANK : [ \t]+; 




LPAR : '(';

RPAR : ')';

LBRACE : '{';

RBRACE : '}';

BANG : '!';

QUOTE : '"';


ARITH : '+' | '-' | '*' | '/';

// ERROR : .+?;