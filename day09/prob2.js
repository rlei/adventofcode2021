const fs = require("fs")

const content = fs.readFileSync(0)

const heightMap = content.toString().trim().split('\n').map(l => [...l].map(n => n - '0'))

const rows = heightMap.length
const cols = heightMap[0].length

const lowPointsMap = Array(rows*cols).fill(0)

for (i = 0; i < cols; i++) {
  lowPointsMap[i] += -1
  lowPointsMap[(rows - 1) * cols + i] += -1
}

for (j = 0; j < rows; j++) {
  lowPointsMap[j * cols] += -1
  lowPointsMap[(j + 1) * cols - 1] += -1
}

heightMap.forEach((row, r) => {
  for (i = 0; i < cols - 1; i++) {
    if (row[i] < row[i + 1]) {
      lowPointsMap[r * cols + i] += -1
    } else if (row[i] > row[i + 1]) {
      lowPointsMap[r * cols + i + 1] += -1
    }
  }
})

for (col = 0; col < cols; col++) {
  for (r = 0; r < rows - 1; r++) {
    if (heightMap[r][col] < heightMap[r + 1][col]) {
      lowPointsMap[r * cols + col] += -1
    } else if (heightMap[r][col] > heightMap[r + 1][col]) {
      lowPointsMap[(r + 1) * cols + col] += -1
    }
  }
}

const basins = []
for (r = 0; r < rows; r++) {
  for (c = 0; c < cols; c++) {
    if (lowPointsMap[r * cols + c] == -4) {
      // the low point itself
      basinSize = [0]
      markBasin(r, c, basinSize)
      basins.push(basinSize[0])
    }
  }
}

basins.sort((a, b) => b - a)

console.log(basins[0] * basins[1] * basins[2])

function markBasin(row, col, basinSizeOut) {
  if (row < 0 || row >= rows || col < 0 || col >= cols) {
    return
  }
  if (heightMap[row][col] == 9 || heightMap[row][col] == -1) {
    // border, or visited
    return
  }
  heightMap[row][col] = -1
  basinSizeOut[0]++
  markBasin(row, col - 1, basinSizeOut)
  markBasin(row, col + 1, basinSizeOut)
  markBasin(row - 1, col, basinSizeOut)
  markBasin(row + 1, col, basinSizeOut)
}
