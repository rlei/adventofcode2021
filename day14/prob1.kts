var template = readLine()!!

// skip blank line
readLine()!!

val rules = generateSequence(::readLine)
    .map {
        val (elemPair, insertion) = it.split(" -> ")
        Pair(elemPair, insertion[0])
    }
    .toMap()

for (i in 1..10) {
    template = String(
        template.windowed(2, 1)
        .map{ charArrayOf(it[0], rules[it]!!, it[1]) }
        .reduce{ a, b -> a + b.sliceArray(1..2) })
}

val counts = template.groupingBy{ it }.eachCount()
//println(counts)

println(counts.maxOf { it.value } - counts.minOf { it.value })
