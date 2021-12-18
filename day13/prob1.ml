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

let dots = stdin_line_stream
  |> stream_take_while (fun l -> l <> "")
  |> list_of_stream
  |> List.map(String.split_on_char ',')
  |> List.map(List.map int_of_string)
  |> List.map(fun dot -> let x :: [y] = dot in (x, y));;

(* blank line *)
Stream.junk stdin_line_stream;;

let instruction = stdin_line_stream
  |> Stream.next
  |> String.split_on_char ' '
  |> nth_list 2
  |> String.split_on_char '='
  |> (fun ls -> let axis :: [value] = ls in
    (axis, int_of_string value));;

let folded = dots
  |> List.filter(fun (dot_x, dot_y) ->
    match instruction with
    | ("y", y_axis) when dot_y == y_axis -> false
    | ("x", x_axis) when dot_x == x_axis -> false
    | _ -> true)
  |> List.map(fun (dot_x, dot_y) ->
    match instruction with
    | ("y", y_axis) when dot_y > y_axis -> (dot_x, 2 * y_axis - dot_y)
    | ("x", x_axis) when dot_x > x_axis -> (2 * x_axis - dot_x, dot_y)
    | _ -> (dot_x, dot_y))
  |> List.sort_uniq compare (* I'm too lazy to use sets here *)
  (* |> List.iter(fun x -> Printf.printf "%d,%d\n" (fst x) (snd x));; *)
  |> List.length;;

Printf.printf "%d" folded;;
