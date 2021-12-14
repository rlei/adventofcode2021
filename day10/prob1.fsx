let rec readLines () = seq {
    let line = System.Console.ReadLine()
    if line <> null then
        yield line
        yield! readLines ()
}

let points = Map[(')', 3); (']', 57); ('}', 1197); ('>', 25137);]

let pairs = Map[('(', ')'); ('[', ']'); ('{', '}'); ('<', '>');]

let output =
  readLines()
  |> Seq.map(fun line -> (([], None), line) ||> Seq.fold (
    fun (stack, firstIllegal) ch ->
      match firstIllegal with
      | Some _ -> (stack, firstIllegal) // already found earlier, short circuit
      | None ->
        match ch with
        | left when pairs.ContainsKey left -> (left :: stack, None) // push
        | right ->
          match stack with
          | [] -> (stack, Some right)    // found first illegal (empty stack)
          | top :: tail ->
            match pairs.TryFind top with
            | Some right_ch when right_ch = right -> (tail, None) // matched, pop
            | Some unmatched -> (tail, Some right)  // found first illegal (unmatched right)
            | None -> (tail, Some right)            // Should be impossible
  ))
  |> Seq.map(fun x ->
    match snd x with
    | Some ch -> points.TryFind(ch).Value
    | None -> 0)
  |> Seq.sum

System.Console.WriteLine(output)