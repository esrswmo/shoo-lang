open OUnit2

let check input =
  let lexbuf = Lexing.from_string input in
  let program = Parser.program Scanner.token lexbuf in
  let _ = Semant.check_program program in
  ""

(* Variable Reference *)

let ref_int_undec _ =
  let f = fun () -> check "int x = 1; x + y;" in
  assert_raises (Semant.Undeclared_reference "undeclared reference y") f
  

(* Variable Assignment *)

let asn_int_int _ = assert_equal "" (check "int x; x = 5;")
let asn_bool_bool _ = assert_equal "" (check "bool b; b = false;")
let asn_str_str _ = assert_equal "" (check "string s; s = \"abs\";")

let asn_int_str _ =
  let f = fun () -> check "int x; x = \"foo\";" in
  assert_raises (Semant.Type_mismatch "type mismatch error") f

let asn_int_bool _ =
  let f = fun () -> check "int i; i = true;" in
  assert_raises (Semant.Type_mismatch "type mismatch error") f

let asn_bool_int _ =
  let f = fun () -> check "bool b; b = 48;" in
  assert_raises (Semant.Type_mismatch "type mismatch error") f


(* Binary Operators *)
let binop_int_int _ = assert_equal "" (check "int x = 1; int y = 2; x + y;")

let binop_bool_int _ =
  let f = fun () -> check "bool b = true; int x = 3; b + x; " in
  assert_raises (Semant.Type_mismatch "Type mismatch across binary operator") f


(* Unary Operators *)
let unop_neg_int _ = assert_equal "" (check "int x = 1; int y = -x;")
let unop_not_bool _ = assert_equal "" (check "bool x = true; bool y = !x;")

let unop_not_int _ =
  let f = fun () -> check "int x = 1; int y = !x; " in
  assert_raises (Semant.Type_mismatch "Type mismatch for unary operator") f
  
let unop_neg_str _ =
  let f = fun () -> check "string x = \"str\"; bool y = -x; " in
  assert_raises (Semant.Type_mismatch "Type mismatch for unary operator") f

(* Postfix Unary Operators *)
let unop_inc_int _ = assert_equal "" (check "int x = 1; int y = 3 + x++;")

let unop_dec_str _ =
  let f = fun () -> check "string x = \"str\"; bool y = x--; " in
  assert_raises (Semant.Type_mismatch "Type mismatch for unary operator") f
  

(* If Statement *)

let if_stat_empty _ = assert_equal "" (check "if (true) {} ")
let if_stat_empty_else _ = assert_equal "" (check "if (false) {} else {} ")

let if_not_bool _ = 
  let f = fun () -> check "if (3 + 4) {} " in
  assert_raises (Failure("expected Boolean expression")) f
  

(* For Loop *)
let for_stat_empty _ = assert_equal "" (check "for (int i = 0; true; i++) {} ")

let for_not_bool _ = 
  let f = fun () -> check "for (int i = 0; 3 + 4; i++) {} " in
  assert_raises (Failure("expected Boolean expression")) f


(* Function Declaration *)

let func_dec_int _ = assert_equal "" (check "function foo() int { return 0; }")

let fcall_valid _ = assert_equal "" (check "function foo() int { return 0; } foo();")

let fcall_invalid _ =
  let f = fun () -> check "foo();" in
  assert_raises (Semant.Undeclared_reference "undeclared reference foo") f

let assign_to_global _ = assert_equal "" (check "\
string x;\
function foo() int {\
  x = \"foo\";\
  return 1;\
}\
foo();\
println(x);")

let shadow_global _ = assert_equal "" (check "\
int x;\
function foo() int {\
  int x;\
  x = 5;\
  return 1;\
}")

let empty_struct_decl _ = assert_equal "" (check "\
struct Empty {}\
")

let simple_struct_decl _ = assert_equal "" (check "\
struct BankAccount {\
  int number;\
  int balance = 0;\
}\
")

let simple_struct_init _ = assert_equal "" (check "\
struct BankAccount {\
  int number;\
  int balance = 0;\
}\
")

let literal_struct_init _ = assert_equal "" (check "\
struct BankAccount {\
  int number;\
  int balance = 0;\
}\
BankAccount foo = {\
  number = 0;\
  balance = 0;\
};\
")

let new_struct_init _ = assert_equal "" (check "\
struct BankAccount {\
  int number;\
  int balance = 0;\
}\
BankAccount foo = new(BankAccount);
")

let struct_as_member _ = assert_equal "" (check "\
struct Foo {}\
struct Bar {\
  Foo x;\
}\
")

let struct_duplicate_decl _ =
  let f = fun () -> check "struct Foo { int number; int number; }" in
  assert_raises (Failure "number already declared in struct Foo") f

let recursive_struct _ =
  let f = fun () -> check "struct Recursive { Recursive x; }" in
  assert_raises (Failure "illegal recursive struct Recursive") f

let tests =
  "Semantic checker" >:::
  [
    (* Variable Reference *)
    "Undeclared int" >:: ref_int_undec;
  
    (* Variable Assignment *)
    "Int to int assignment" >:: asn_int_int;
    "Bool to bool assignment" >:: asn_bool_bool;
    "String to string assignment" >:: asn_str_str;
    "String to int assignment" >:: asn_int_str;
    "Bool to int assignment" >:: asn_int_bool;
    "Int to bool assignment" >:: asn_bool_int;
    
    (* Binary Operators *)
    "Binop between int and int" >:: binop_int_int;
    "Binop between bool and int" >:: binop_bool_int;
    
    (* Unary Operators *)
    "Unop for int negation" >:: unop_neg_int;
    "Unop for bool negation" >:: unop_not_bool;
    "Unop for not int" >:: unop_not_int;
    "Unop for string negation" >:: unop_neg_str;
    
    (* Postfix Unary Operators *)
    "Unop for int increment" >:: unop_inc_int;
    "Unop for string decrement" >:: unop_dec_str;
    
    (* If Statement *)
    "If statement with empty block" >:: if_stat_empty;
    "If statement with empty block and an else" >:: if_stat_empty_else;
    "If statement without conditions" >:: if_not_bool;
    
    (* For Loop *)
    "For loop with empty block" >:: for_stat_empty;
    "For loop without conditions" >:: for_not_bool;
    
    (* Function Declaration *)
    "Function declaration that returns int" >:: func_dec_int;

    "Valid function call" >:: fcall_valid;
    "Missing function call" >:: fcall_invalid;

    "Assign to a global variable inside a function" >:: assign_to_global;
    "Shadow a global variable inside a function" >:: shadow_global;

    "Empty struct declaration" >:: empty_struct_decl;
    "Simple struct declaration" >:: simple_struct_decl;
    "Literal struct initialization" >:: literal_struct_init;
    "Initialize struct using new" >:: new_struct_init;
    "Duplicate struct member" >:: struct_duplicate_decl;
    "Recursive struct" >:: recursive_struct;
    "Struct as struct member" >:: struct_as_member;
  ]
