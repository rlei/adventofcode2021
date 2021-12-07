
var firstLine = Console.ReadLine();
if (firstLine == null) {
  Console.Error.WriteLine("Expected first line to have numbers to draw but is empty");
  Environment.Exit(1);
}
var numbersToDraw = firstLine.Split(',').Select(str => Int32.Parse(str)).ToArray();

// Skip next blank line
Console.ReadLine();

var boards = new List<Board>();
string? line;
while ((line = Console.ReadLine()) != null) {
  string currentBoard = "";
  while (line != null && line.Length > 0) {
    currentBoard = currentBoard + " " + line;
    line = Console.ReadLine();
  }
  boards.Add(new Board(currentBoard.Split(' ', StringSplitOptions.RemoveEmptyEntries).Select(str => Int32.Parse(str)).ToArray()));
}

foreach (var num in numbersToDraw) {
  foreach (var board in boards) {
    if (board.drawNumber(num)) {
      // Bingo
      Console.WriteLine(board.getUnmarkedNumbers().Sum() * num);
      Environment.Exit(0);
    }
  }
}

class Board {
  Dictionary<int, (int, int)> numberToPos = new Dictionary<int, (int, int)>();

  int[] rowBitmap = new int[5];
  int[] colBitmap = new int[5];

  public Board(int[] boardNumbers) {
    if (boardNumbers.Length != 25) {
      throw new SystemException("A board must have exactly 25 numbers");
    }
    int row = 0;
    int col = 0;
    foreach (var num in boardNumbers) {
      numberToPos.Add(num, (row, col));
      if (++col == 5) {
        row++;
        col = 0;
      };
    }
  }

  public bool drawNumber(int num) {
    if (!numberToPos.ContainsKey(num)) {
      return false;
    }

    var (row, col) = numberToPos[num];
    numberToPos.Remove(num);
    rowBitmap[row] |= 1 << col;
    if (rowBitmap[row] == 0x1f) {
      // Bingo
      return true;
    }
    colBitmap[col] |= 1 << row;
    if (colBitmap[col] == 0x1f) {
      // Bingo
      return true;
    }
    return false;
  }

  public IEnumerable<int> getUnmarkedNumbers() {
    return numberToPos.Keys;
  }
}