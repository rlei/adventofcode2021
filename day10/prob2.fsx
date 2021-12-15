let rec readLines () = seq {
    let line = System.Console.ReadLine()
    if line <> null then
        yield line
        yield! readLines ()
}

// Note there's no need to "complete" the left brackets to their right counter parts
// then look up their points. It's essentially a left -> point mapping.
let points = Map[('(', 1L); ('[', 2L); ('{', 3L); ('<', 4L);]

let pairs = Map[('(', ')'); ('[', ']'); ('{', '}'); ('<', '>');]

let scores =
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
  |> Seq.filter(fun (stack, firstIllegal) -> not(List.isEmpty(stack)) && firstIllegal = None)
  |> Seq.map(fun (stack, _) ->
    stack |> List.fold (fun sum left -> sum * 5L + points.TryFind(left).Value) 0L)
  |> Seq.toArray
  |> Array.sort

printfn "%d" scores[scores.Length / 2]
