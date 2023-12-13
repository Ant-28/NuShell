parser grammar NewShParser;





options {tokenVocab=NewShLexer;}


word : ID;

arith_expr    returns [String result]: a=(ID|NUMBER) EQ expr {$result = "((" + $a.text + $EQ.text + $expr.result + "))"};
for_loop_expr : ID EQ expr;
expr returns [String result]  : a=(ID | NUMBER) ARITH b=(ID | NUMBER)  expr2 {$result =  $a.text + $ARITH.text + $b.text + $expr2.result};
expr2 returns [String result] : ARITH a=(ID | NUMBER) expr2 {$result = $ARITH.text + $a.text + $expr2.result } | /*empty */ {$result = ""} ;



assign returns [String result]: a=ID EQ b=(ID|NUMBER) {$result = $a.text + "=" + $b.text}
        | c=ID EQ  d=filename           {$result = $c.text +"=" + $d.result};
for_assign returns [String result]: a=ID EQ b=(ID|NUMBER) {$result = $a.text + "=" + $b.text}
        | c=ID EQ  d=filename           {$result = $c.text +"=" + $d.result};
program          : linebreak complete_commands linebreak
                 | linebreak
                 ;
complete_commands: complete_commands newline_list complete_command
                 |                                complete_command
                 ;
complete_command : nlist separator_op
                 | nlist
                 ;
nlist             : nlist separator_op and_or
                 |                   and_or
                 ;
and_or           :                         pipeline
                 | and_or AND_IF linebreak pipeline
                 | and_or OR_IF  linebreak pipeline
                 ;
pipeline         :      pipe_sequence
                 | BANG pipe_sequence
                 ;
pipe_sequence    :                             command
                 | pipe_sequence PIPE linebreak command
                 ;
command          : simple_command
                 | compound_command
                 | compound_command redirect_list
                 | function_definition
                 ;
compound_command : brace_group
                 | subshell
                 | for_clause
                 | case_clause
                 | if_clause
                 | while_clause
                 | until_clause
                 | select_clause
                 ;
subshell         : LPAR compound_list RPAR
                 ;
compound_list    : linebreak (term)
                 | linebreak (term) separator
                //  | linebreak (error_term) separator
                 ;

// error_term       : ERROR;
term             : term separator and_or
                 | ID separator and_or
                 |                and_or
                 ;
for_clause       : custom_for_clause
                 | FOR name                                         do_or_brace
                 | FOR name                          sequential_sep do_or_brace
                 | FOR name linebreak (in_n | word)  sequential_sep do_or_brace
                 | FOR name linebreak (in_n | word)  wordlist  sequential_sep do_or_brace
                
                 ;
custom_for_clause returns [String result] : FOR LPAR for_assign SEMI for_comparison? SEMI for_loop_expr SEMI? RPAR (SEMI* | newline_list) brace_group
{$result = $FOR.text + "(( " + $for_assign.result + $SEMI.text + $for_comparison.text + $SEMI.text + $for_loop_expr.text + " ))\n" }
| FOR LPAR? ID IN RANGE LPAR a=(NUMBER|FLOAT) COMMA b=(NUMBER|FLOAT) COMMA c=(NUMBER|FLOAT) RPAR RPAR? (SEMI* | newline_list) brace_group {$result = $FOR.text + " " + $ID.text + " " + $IN.text + " $(seq " + $a.text + " " + $b.text + " " + $c.text + " )\n"   }
| FOR LPAR? ID IN for_array_items RPAR? (SEMI* | newline_list) brace_group {$result = $FOR.text + " " + $ID.text + " " + $IN.text + " " + $for_array_items.result + "\n"};


// custom_for_clause returns [String result] : FOR LPAR assign SEMI comparison? SEMI loop_expr RPAR
// {$result = $FOR.text + "(( " + $assign.result + ";" + $comparison.text +  ";" + ";" + " ))"}
// ;


select_clause    : SELECT name                                         do_or_brace
                 | SELECT name                          sequential_sep do_or_brace
                 | SELECT name linebreak (in_n | word)  sequential_sep do_or_brace
                 | SELECT name linebreak (in_n | word)  wordlist  sequential_sep do_or_brace
                 ;



do_or_brace : (do_group | brace_group);

name             : ID                     /* Apply rule 5 */
                 ;
in_n             : IN                       /* Apply rule 6 */
                 ;

wordlist returns [String result] : a=(ID|NUMBER) b=wordlist {$result = $a.text + " " + $b.result}| a=(ID|NUMBER) {$result = $a.text};
// wordlist returns [String result]         : a=(WORD|NUMBER) wordlist2 {$result = " " + $a.text  + " " +  $wordlist2.text + " " }
//                                                 |  a=(WORD|NUMBER)    {$result = " " + $a.text + " " }         ;
// wordlist2 returns [String result] : a=(WORD|NUMBER) b=wordlist2 {$result = " " + $a.text + " " + $b.result + " "}
//                                         | /* empty */{$result =  " "};
case_clause      : CASE ID linebreak in_n linebreak case_list    ESAC
                 | CASE ID linebreak in_n linebreak case_list_ns ESAC
                 | CASE ID linebreak in_n linebreak              ESAC
                 ;
case_list_ns     : case_list case_item_ns
                 |           case_item_ns
                 ;
case_list        : case_list case_item
                 |           case_item
                 ;
case_item_ns     :     pattern RPAR linebreak
                 |     pattern RPAR compound_list
                 | LPAR pattern RPAR linebreak
                 | LPAR pattern RPAR compound_list
                 ;
case_item        :     pattern RPAR linebreak     DSEMI linebreak
                 |     pattern RPAR compound_list DSEMI linebreak
                 | LPAR pattern RPAR linebreak     DSEMI linebreak
                 | LPAR pattern RPAR compound_list DSEMI linebreak
                 ;
pattern          :             ID         /* Apply rule 4 */
                 | pattern PIPE ID         /* Do not apply rule 4 */
                 ;
if_clause        : IF compound_list THEN compound_list else_part FI
                 | IF compound_list THEN compound_list           FI
                 | custom_if_clause
                 ;
else_part        : ELIF compound_list THEN compound_list
                 | ELIF compound_list THEN compound_list else_part
                 | ELSE compound_list
                 ;
while_clause     : WHILE compound_list do_group
                  | custom_while_clause
                 ;

custom_while_clause returns [String result] : WHILE LPAR? for_comparison SEMI? RPAR?  (SEMI* | newline_list) brace_group_mod
{$result = $WHILE.text + "(( " + $for_comparison.text + " ))"}
;
custom_if_clause returns [String result] : IF LPAR? for_comparison RPAR? (SEMI*|newline_list) brace_group
{$result = $IF.text + "(( " + $for_comparison.text + " ))"}
;
until_clause     : UNTIL compound_list do_group
                 ;
function_definition : FUNCTION? ID LPAR RPAR linebreak function_body
                 ;
function_body    : compound_command                /* Apply rule 9 */
                 | compound_command redirect_list  /* Apply rule 9 */
                 ;
fname            : ID                            /* Apply rule 8 */;
brace_group      : LBRACE compound_list RBRACE
                 ;
brace_group_mod : LBRACE compound_list RBRACE ;
                 
do_group         : DO compound_list DONE           /* Apply rule 6 */
                 ;
simple_command   : cmd_prefix cmd_word cmd_suffix
                 | cmd_prefix cmd_word
                 | cmd_prefix
                 | cmd_name cmd_suffix
                 | cmd_name
                 | array_ops
                 ;
cmd_name         : ID                   /* Apply rule 7a */
                 ;
cmd_word         : ID | assign                  /* Apply rule 7b */
                 ;
cmd_prefix       :            io_redirect
                 | cmd_prefix io_redirect
                 |            (assign | array_defn | arith_expr | array_ops)
                 | cmd_prefix (assign | array_defn | arith_expr | array_ops)
                 ;
cmd_suffix       :            io_redirect
                 | cmd_suffix io_redirect
                 |            (filename | cmd_suffix_2)
                 | cmd_suffix (filename | cmd_suffix_2)
                 ;
cmd_suffix_2     : ID | VAR | array_ops;
redirect_list    :               io_redirect
                 | redirect_list io_redirect
                 ;
io_redirect      :           io_file
                 | IO_NUMBER io_file
                 |           io_here
                 | IO_NUMBER io_here
                 ;
io_file          : LT      filename
                 | LESSAND   filename
                 | GT       filename
                 | GREATAND  filename
                 | DGREAT    filename
                 | LESSGREAT filename
                 | CLOBBER   filename
                 ;
filename returns [String result] : 
                   ID DOT b=filename? {$result = $ID.text + $DOT.text + $b.result if $b.result is not None else ""}
                 | DOT b=filename {$result = $DOT.text + $b.result if $b.result is not None else ""}
                 | ID {$result = $ID.text}
                          /* separate from IDs */
                 ;
io_here          : DLESS     here_end
                 | DLESSDASH here_end
                 ;
here_end         : ID                      /* Apply rule 3 */
                 ;
newline_list     :              NEWLINE
                 | newline_list NEWLINE
                 ;
linebreak        : newline_list
                 | /* empty */
                 ;
separator_op     : AND | SEMI;
separator        : separator_op linebreak
                 | newline_list
                 ;
sequential_sep   : SEMI linebreak
                 | newline_list
                 ;


for_comparison returns [String result]: ID a=(LT | GT | DEQ | NEQ) b=(ID | NUMBER) {$result = $ID.text + $a.text + $b.text };

array_defn  returns [String result]: ID EQ array {$result = $ID.text + $EQ.text + $array.result};
array returns [String result] : LPAR wordlist? RPAR {$result = $LPAR.text + $wordlist.result + $RPAR.text};

array_ops returns [String result] :       array_length {$result = $array_length.result}
                | array_items {$result = $array_items.result};

array_length returns [String result] : a=(ID|VAR) DOT LEN LPAR RPAR {$result = "${#" + ($a.text if $a.text[0] != '$' else $a.text[1:]) + "[@]" + "}"};

// this doesn't
array_items  returns [String result] : a=(ID|VAR) DOT ITEMS LPAR RPAR {$result = "${" + ($a.text if $a.text[0] != '$' else $a.text[1:]) + "[@]" + "}"};

// this has an ignorable parent 
for_array_items  returns [String result] : a=(ID|VAR) DOT ITEMS LPAR RPAR {$result = "${" + ($a.text if $a.text[0] != '$' else $a.text[1:]) + "[@]" + "}"};


// old grammar, for reference:

// <FOR-COMMAND> :  for <WORD> <NEWLINE-LIST> do <COMPOUND-LIST> done
//             |  for <WORD> <NEWLINE-LIST> '{' <COMPOUND-LIST> '}'
//             |  for <WORD> ';' <NEWLINE-LIST> do <COMPOUND-LIST> done
//             |  for <WORD> ';' <NEWLINE-LIST> '{' <COMPOUND-LIST> '}'
//             |  for <WORD> <NEWLINE-LIST> in <WORD-LIST> <LIST-TERMINATOR>
//                    <NEWLINE-LIST> do <COMPOUND-LIST> done
//             |  for <WORD> <NEWLINE-LIST> in <WORD-LIST> <LIST-TERMINATOR>
//                    <NEWLINE-LIST> '{' <COMPOUND-LIST> '}'

// <SELECT-COMMAND> :  select <WORD> <NEWLINE-LIST> do <LIST> done
//                    |  select <WORD> <NEWLINE-LIST> '{' <LIST> '}'
//                    |  select <WORD> ';' <NEWLINE-LIST> do <LIST> done
//                    |  select <WORD> ';' <NEWLINE-LIST> '{' LIST '}'
//                    |  select <WORD> <NEWLINE-LIST> in <WORD-LIST>
//                            <LIST-TERMINATOR> <NEWLINE-LIST> do <LIST> done
//                    |  select <WORD> <NEWLINE-LIST> in <WORD-LIST>
//                            <LIST-TERMINATOR> <NEWLINE-LIST> '{' <LIST> '}'

// <CASE-COMMAND> :  case <WORD> <NEWLINE-LIST> in <NEWLINE-LIST> esac
//                  |  case <WORD> <NEWLINE-LIST> in <CASE-CLAUSE-SEQUENCE>
//                          <NEWLINE-LIST> esac
//                  |  case <WORD> <NEWLINE-LIST> in <CASE-CLAUSE> esac

// <FUNCTION-DEF> :  <WORD> LPAR RPAR <NEWLINE-LIST> <GROUP-COMMAND>
//                  |  function <WORD> LPAR RPAR <NEWLINE-LIST> <GROUP-COMMAND>
//                  |  function <WORD> <NEWLINE-LIST> <GROUP-COMMAND>

// <SUBSHELL> :  LPAR <COMPOUND-LIST> RPAR

// <IF-COMMAND> : if <COMPOUND-LIST> then <COMPOUND-LIST> fi
//           | if <COMPOUND-LIST> then <COMPOUND-LIST> else <COMPOUND-LIST> fi
//           | if <COMPOUND-LIST> then <COMPOUND-LIST> <ELIF-CLAUSE> fi

// <GROUP-COMMAND> :  '{' <LIST> '}'

// <ELIF-CLAUSE> : elif <COMPOUND-LIST> then <COMPOUND-LIST>
//            | elif <COMPOUND-LIST> then <COMPOUND-LIST> else <COMPOUND-LIST>
//            | elif <COMPOUND-LIST> then <COMPOUND-LIST> <ELIF-CLAUSE>

// <CASE-CLAUSE> :  <PATTERN-LIST>
//                 |  <CASE-CLAUSE-SEQUENCE> <PATTERN-LIST>

// <PATTERN-LIST> :  <NEWLINE-LIST> <PATTERN> RPAR <COMPOUND-LIST>
//                  |  <NEWLINE-LIST> <PATTERN> RPAR <NEWLINE-LIST>
//                  |  <NEWLINE-LIST> LPAR <PATTERN> RPAR <COMPOUND-LIST>
//                  |  <NEWLINE-LIST> LPAR <PATTERN> RPAR <NEWLINE-LIST>

// <CASE-CLAUSE-SEQUENCE> :  <PATTERN-LIST> ';;'
//                          |  <CASE-CLAUSE-SEQUENCE> <PATTERN-LIST> ';;'

// <PATTERN> :  <WORD>
//             |  <PATTERN> '|' <WORD>




// <COMPOUND-LIST> :  <LIST>
//                   |  <NEWLINE-LIST> <LIST1>

// <LIST0> :   <LIST1> '\n' <NEWLINE-LIST>
//            |  <LIST1> '&' <NEWLINE-LIST>
//            |  <LIST1> ';' <NEWLINE-LIST>

// <LIST1> :   <LIST1> '&&' <NEWLINE-LIST> <LIST1>
//            |  <LIST1> '||' <NEWLINE-LIST> <LIST1>
//            |  <LIST1> '&' <NEWLINE-LIST> <LIST1>
//            |  <LIST1> ';' <NEWLINE-LIST> <LIST1>
//            |  <LIST1> '\n' <NEWLINE-LIST> <LIST1>
//            |  <PIPELINE-COMMAND>

// <LIST-TERMINATOR> : '\n'
//                    |  ';'

// <NEWLI

// NE-LIST> :
//                   |  <NEWLINE-LIST> '\n'

// <SIMPLE-LIST> :  <SIMPLE-LIST1>
//                 |  <SIMPLE-LIST1> '&'
//                 |  <SIMPLE-LIST1> ';'

// <SIMPLE-LIST1> :  <SIMPLE-LIST1> '&&' <NEWLINE-LIST> <SIMPLE-LIST1>
//                  |  <SIMPLE-LIST1> '||' <NEWLINE-LIST> <SIMPLE-LIST1>
//                  |  <SIMPLE-LIST1> '&' <SIMPLE-LIST1>
//                  |  <SIMPLE-LIST1> ';' <SIMPLE-LIST1>
//                  |  <PIPELINE-COMMAND>

// <PIPELINE-COMMAND> : <PIPELINE>
//                     |  '!' <PIPELINE>
//                     |  <TIMESPEC> <PIPELINE>
//                     |  <TIMESPEC> '!' <PIPELINE>
//                     |  '!' <TIMESPEC> <PIPELINE>

// <PIPELINE> :
//           <PIPELINE> '|' <NEWLINE-LIST> <PIPELINE>
//        |  <COMMAND>

// <TIME-OPT> : '-p'

// <TIMESPEC> :  time
//              |  time <TIME-OPT>



