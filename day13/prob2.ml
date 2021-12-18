let stdin_line_stream =
  Stream.from (fun _ -> try Some (input_line stdin) with End_of_file -> None)

let stream_take_while p stream =
  let rec next i =
    try
      let value = Stream.peek stream in
      match value with
      | None -> Stream.junk stream; None
      | Some(a) when p a -> Stream.junk stream; value
      | _ -> None
    with Stream.Failure -> None in
  Stream.from next

let list_of_stream stream =
    let result = ref [] in
    Stream.iter (fun value -> result := value :: !result) stream;
    List.rev !result

let nth_list n l = List.nth l n

let list_of_2_to_tuple ls = (List.hd ls, List.nth ls 1)

let dots = stdin_line_stream
  |> stream_take_while (fun l -> l <> "")
  |> list_of_stream
  |> List.map(String.split_on_char ',')
  |> List.map(List.map int_of_string)
  |> List.map list_of_2_to_tuple;;

(* blank line *)
Stream.junk stdin_line_stream;;

let instructions = stdin_line_stream
  |> list_of_stream
  |> List.map(String.split_on_char ' ')
  |> List.map(nth_list 2)
  |> List.map(String.split_on_char '=')
  |> List.map list_of_2_to_tuple
  |> List.map(fun (axis, val_str) -> (axis, int_of_string val_str))

let folded =
  List.fold_left
    (fun dots instruction ->
      dots
      |> List.filter(fun (dot_x, dot_y) ->
        match instruction with
          ("y", y_axis) when dot_y == y_axis -> false
        | ("x", x_axis) when dot_x == x_axis -> false
        | _ -> true)
      |> List.map(fun (dot_x, dot_y) ->
        match instruction with
          ("y", y_axis) when dot_y > y_axis -> (dot_x, 2 * y_axis - dot_y)
        | ("x", x_axis) when dot_x > x_axis -> (2 * x_axis - dot_x, dot_y)
        | _ -> (dot_x, dot_y)))
    dots
    instructions
  |> List.sort_uniq compare (* I'm too lazy to use sets here *)

let (max_x, max_y) = List.fold_left (fun max_tuple dot ->
    ((max (fst max_tuple) (fst dot)), (max (snd max_tuple) (snd dot)))) (0, 0) folded

let (width, height) = (max_x + 1, max_y + 1)

let bitmap = Array.make (width * height) '.';;

List.iter (fun (x,y) -> Array.set bitmap (x + y * width) '#') folded;;

Array.iteri (fun offset ch ->
  Printf.printf "%c" ch;
  if ((offset + 1) mod width = 0) then print_endline "";
) bitmap;;
