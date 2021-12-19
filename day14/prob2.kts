val template = readLine()!!

// skip blank line
readLine()!!

val rules = generateSequence(::readLine)
        .map {
            val (elemPair, insertion) = it.split(" -> ")
            Pair(Pair(elemPair[0], elemPair[1]), insertion[0])
        }
        .toMap()

// prefix and suffix with something to make sure all characters are double counted
var elemPairs = ("_" + template + "_").windowed(2, 1)
        .map { Pair(Pair(it[0], it[1]), 1L) }
        .groupBy({ it.first }, { it.second })
        .mapValues {  (_, counts) -> counts.sum() }

val charCounts = elemPairs.flatMap { (charPair, count) -> listOf(Pair(charPair.first, count), Pair(charPair.second, count)) }
        .groupBy({ it.first }, { it.second })
        .mapValues {  (_, counts) -> counts.sum() / 2 }  // because we've double counted
        .toMutableMap()

charCounts.remove('_')

// A mixture of FP and imperative - forgive my laziness :p
for (i in 1..40) {
    elemPairs = elemPairs.flatMap { (charPair, count) ->
        val (ch1, ch2) = charPair
        if (ch1 == '_' || ch2 == '_') {
            listOf(Pair(charPair, count))
        } else {
            val insertion = rules[charPair]!!
            charCounts.compute(insertion, { _, oldVal -> (oldVal ?: 0) + count })
            listOf(Pair(Pair(ch1, insertion), count), Pair(Pair(insertion, ch2), count))
        }
    }
            .groupBy({ it.first }, { it.second })
            .mapValues { (_, counts) -> counts.sum() }
}

//println(charCounts)
println(charCounts.maxOf { it.value } - charCounts.minOf { it.value })
