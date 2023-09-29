(* This file is part of DBL, released under MIT license.
 * See LICENSE for details.
 *)

(** Main module of the parser *)

(* Author: Piotr Polesiuk, 2023 *)

type fname = string

let with_in_channel ?pos fname func =
  match open_in fname with
  | chan ->
    begin match func chan with
    | result -> close_in_noerr chan; result
    | exception Sys_error msg ->
      close_in_noerr chan;
      Error.fatal (Error.cannot_read_file ?pos ~fname msg)
    | exception ex ->
      close_in_noerr chan;
      raise ex
    end
  | exception Sys_error msg ->
    Error.fatal (Error.cannot_open_file ?pos ~fname msg)

let parse_file ?pos fname =
  with_in_channel ?pos fname (fun chan ->
    let lexbuf = Lexing.from_channel chan in
    lexbuf.Lexing.lex_curr_p <-
      { lexbuf.Lexing.lex_curr_p with
        Lexing.pos_fname = fname
      };
    try YaccParser.file Lexer.token lexbuf with
    | Parsing.Parse_error ->
      Error.fatal (Error.unexpected_token
        (Position.of_pp
          lexbuf.Lexing.lex_start_p
          lexbuf.Lexing.lex_curr_p)
        (Lexing.lexeme lexbuf)))
  |> Desugar.tr_program
