import 'dart:collection';
import 'dart:convert';
import 'dart:io';

main() {
  var caves = HashMap<String, HashSet<String>>();
  String? line;
  while ((line = stdin.readLineSync(encoding: utf8, retainNewlines: false)) !=
      null) {
    var pair = line!.split('-');
    addCavePair(caves, pair[0], pair[1]);
    addCavePair(caves, pair[1], pair[0]);
  }

  var smallCaves = caves.keys.where((cave) => isSmallCave(cave));
  var smallCavesVisited = {for (var cave in smallCaves) cave: false};
  var paths = Set<List<String>>();
  traverse(caves, smallCavesVisited, 'start', paths, []);
  // print(paths);
  print(paths.length);
}

bool isSmallCave(String cave) {
  return cave.codeUnitAt(0) >= 'a'.codeUnitAt(0);
}

void traverse(
    Map<String, Set<String>> caves,
    Map<String, bool> smallCavesVisited,
    String current,
    Set<List<String>> paths,
    List<String> currentPath) {
  Map<String, bool> smallCavesVisitedCopy = smallCavesVisited;
  if (isSmallCave(current)) {
    if (smallCavesVisited[current]!) {
      // dead end
      return;
    }
    // copy on write
    smallCavesVisitedCopy = {...smallCavesVisited};
    smallCavesVisitedCopy[current] = true;
  }
  currentPath.add(current);
  if (current == "end") {
    paths.add(currentPath);
    // print("path ${currentPath}");
    return;
  }
  var nextCaves = caves[current]!;

  nextCaves.forEach((next) {
    traverse(caves, smallCavesVisitedCopy, next, paths, [...currentPath]);
  });
}

void addCavePair(Map<String, Set<String>> caves, String from, String to) {
  caves.putIfAbsent(from, () => HashSet());
  caves[from]!.add(to);
}
