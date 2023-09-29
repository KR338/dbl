(* This file is part of DBL, released under MIT license.
 * See LICENSE for details.
 *)

(** Node of the abstract syntax tree *)

(* Author: Piotr Polesiuk, 2023 *)

type 'a node = {
  pos  : Position.t;
  data : 'a
}

module Export = struct
  type nonrec 'a node = 'a node = {
    pos  : Position.t;
    data : 'a
  }
end
