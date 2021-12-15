:- use_module(library(clpfd)).

digit_segs(0, [a, b, c, e, f, g]).
digit_segs(1, [c, f]).
digit_segs(2, [a, c, d, e, g]).
digit_segs(3, [a, c, d, f, g]).
digit_segs(4, [b, c, d, f]).
digit_segs(5, [a, b, d, f, g]).
digit_segs(6, [a, b, d, e, f, g]).
digit_segs(7, [a, c, f]).
digit_segs(8, [a, b, c, d, e, f, g]).
digit_segs(9, [a, b, c, d, f, g]).

digit(Digit, Segs) :- permutation(Segs, Sorted), digit_segs(Digit, Sorted).

assoc_get(Assoc, Key, Val) :- get_assoc(Key, Assoc, Val).

map_string_codes(M, Str, Vars) :-
  string_codes(Str, Codes),
  maplist(assoc_get(M), Codes, Vars).

% proof of concept
decode_digit(Digit, RenamedSegStr) :-
  all_distinct([N0, N1, N2, N3, N4, N5, N6, N7, N8, N9]),

  digit(N0, [A,C,E,D,G,F,B]),
  digit(N1, [C,D,F,B,E]),
  digit(N2, [G,C,D,F,A]),
  digit(N3, [F,B,C,A,D]),
  digit(N4, [D,A,B]),
  digit(N5, [C,E,F,A,B,D]),
  digit(N6, [C,D,F,G,E,B]),
  digit(N7, [E,A,F,B]),
  digit(N8, [C,A,G,E,D,B]),
  digit(N9, [A,B]),

  string_codes(RenamedSegStr, RenamedSegs),
  all_distinct(RenamedSegs),
  % chars 'a'-'g' => variables A-G
  list_to_assoc([97-A, 98-B, 99-C, 100-D, 101-E, 102-F, 103-G], SegAssoc),
  map_string_codes(SegAssoc, RenamedSegStr, SegVars),

  digit(Digit, SegVars).

% accepts ten digit patterns and solve the others in ToSolve
decode_digits(Xs, TenDigits, ToSolve) :-
  % not directly used. prefixed with '_' to shut off "Singleton variables" warnings.
  Ns = [_N0, _N1, _N2, _N3, _N4, _N5, _N6, _N7, _N8, _N9],
  all_distinct(Ns),

  % chars 'a'-'g' => variables A-G. Same '_' prefixes for "Singleton variables" warnings.
  list_to_assoc([97-_A, 98-_B, 99-_C, 100-_D, 101-_E, 102-_F, 103-_G], SegAssoc),

  % ["abc", "abcde", ...] => [[A,B,C], [A,B,C,D,E], ...]
  maplist(map_string_codes(SegAssoc), TenDigits, TenDigitsVars),

  % digit(N0, [A,B,C]), digit(N1, [A,B,C,D,E]), ...
  maplist(digit, Ns, TenDigitsVars),

  % similarly, but now try to solve the other inputs
  maplist(map_string_codes(SegAssoc), ToSolve, ToSolveVars),
  maplist(digit, Xs, ToSolveVars).

decode_line(Line, Xs) :-
  split_string(Line, "|", " ", [H|[L]]),
  split_string(H, " ", " ", TenDigits),
  split_string(L, " ", " ", ToSolve),
  decode_digits(Xs, TenDigits, ToSolve),
  writeln(Xs).

read_file(Stream, []) :-
    at_end_of_stream(Stream).

read_file(Stream, [X|L]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, X),
    read_file(Stream, L).

solve(Stream, Results) :-
  read_file(Stream, Lines),
  close(Stream),
  maplist(decode_line, Lines, Results).

test :-
    open('testinput.txt', read, Stream),
    solve(Stream, _AllDigits).
    % write(AllDigits), nl.

is_in_1478(X) :-
  member(X, [1,4,7,8]).

prob1 :-
  solve(user_input, Results),
  maplist(include(is_in_1478), Results, Xs),
  maplist(length, Xs, Lengths),
  sumlist(Lengths, Sum),
  writeln(Sum).

to_decimal(A, B, N) =>
  N is A + B * 10.

list_to_decimal(Ls, Dec) =>
  foldl(to_decimal, Ls, 0, Dec).

prob2 :-
  solve(user_input, Results),
  maplist(list_to_decimal, Results, Decimals),
  sumlist(Decimals, Sum),
  writeln(Sum).
