import std.stdio, std.array, std.algorithm, std.range;

void main()
{
    auto bitmap = stdin
        .byLine
        .map!(l => l.dup)
        .array
        .transposed;
    auto rows = bitmap.front.walkLength;

    auto gamma_bits = bitmap 
        .map!(bin => bin.map!(bit => bit - '0').sum)
        .map!(n => n * 2 > rows ? 1 : 0)
        .array;

    auto gamma = gamma_bits.reduce!((num, bit) => num * 2 + bit);
    auto epsilon = 2 ^^ gamma_bits.length - 1 - gamma;
    writeln(gamma * epsilon);
}
