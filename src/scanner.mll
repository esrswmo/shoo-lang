{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "//" { linec lexbuf } (* Single-line Comments *)
| "/*" { comment 0 lexbuf } (* Multi-line Comments *)
| ';' { SEMI }
| '(' { LPAREN }
| ')' { RPAREN }
| '{' { LBRACKET }
| '}' { RBRACKET }
| '[' { LSQBRACE }
| ']' { RSQBRACE }
| '.' { DOT }
| ',' { COMMA }
| ':' { COLON }
| '+' { PLUS }
| '-' { MINUS }
| '*' { TIMES }
| '%' { MOD }
| '/' { DIVIDE }
| "++" { INCREMENT }
| "--" { DECREMENT }
| "==" { EQ }
| '=' { ASSIGN }
| "!=" { NEQ }
| "!" { NOT }
| "<=" { LEQ }
| '<' { LT }
| ">=" { GEQ }
| ">" { GT }
| "&&" { AND }
| "||" { OR }
| "function" { FUNCTION }
| "func" { FUNC }
| "int" { INT }
| "float" { FLOAT }
| "string" { STRING }
| "bool" { BOOL }
| "void" { VOID }
| "return" { RETURN }
| "elif" { ELIF }
| "if" { IF }
| "else" { ELSE }
| "for" { FOR }
| "while" { WHILE }
| "struct" { STRUCT }
| "array" { ARRAY }
| "in" { IN }
| "new" { NEW }
| "true"|"false" as lxm { BOOLLIT(bool_of_string lxm) }
| ['0'-'9']+ as lxm { INTLIT(int_of_string lxm) }
| ['0'-'9']*"."['0'-'9']+ as lxm { FLOATLIT(lxm) }
| ['a'-'z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| ['A'-'Z']['a'-'z' 'A'-'Z' '0'-'9']* as lxm { STRUCTID(lxm) }
| '"' { str (Buffer.create 16) lexbuf }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment level = parse
  "*/" { match level with 0 -> token lexbuf | _ -> comment (level - 1) lexbuf }
| "/*" { comment (level + 1) lexbuf }
| _ { comment level lexbuf }

and linec = parse
  '\n' { token lexbuf }
| _ { linec lexbuf }

and str buf = parse
  '"' { STRLIT(Buffer.contents buf) }
| [^ '"'] { Buffer.add_string buf (Lexing.lexeme lexbuf); str buf lexbuf }
