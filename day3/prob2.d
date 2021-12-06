import std.stdio, std.array, std.algorithm, std.range;

void main()
{
    auto bitmap = stdin
        .byLine
        .map!(l => l.dup.map!(bit => cast(int)(bit - '0')).array)
        .array;

    auto oxygenRating = findOxygenRating(bitmap, 0);
    auto co2Rating = findCo2Rating(bitmap, 0);

    writeln(binArrayToInt(oxygenRating) * binArrayToInt(co2Rating));
}

pure int binArrayToInt(int[] bits) {
    return bits.reduce!`a * 2 + b`;
}

// Apparently this can be further refactored to share impl with findCo2Rating, but it'll be less readable.
// Plus, I'm feeling lazy today XD.
pure int[] findOxygenRating(int[][] bitmap, int offset) {
    if (bitmap.length == 1) {
        return bitmap[0];
    }

    int[int] counts;
    bitmap.each!(bits => counts[bits[offset]]++);
    auto countsArr = counts.byKeyValue().array.multiSort!("a.value > b.value", "a.key > b.key");

    return findOxygenRating(bitmap.filter!(bits => bits[offset] == countsArr[0].key).array, offset + 1);
}

pure int[] findCo2Rating(int[][] bitmap, int offset) {
    if (bitmap.length == 1) {
        return bitmap[0];
    }

    int[int] counts;
    bitmap.each!(bits => counts[bits[offset]]++);
    auto countsArr = counts.byKeyValue().array.multiSort!("a.value < b.value", "a.key < b.key");

    return findCo2Rating(bitmap.filter!(bits => bits[offset] == countsArr[0].key).array, offset + 1);
}

