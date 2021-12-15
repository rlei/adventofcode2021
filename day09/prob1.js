const fs = require("fs")

const content = fs.readFileSync(0)

const heightMap = content.toString().trim().split('\n').map(l => [...l].map(n => n - '0'))

const rows = heightMap.length
const cols = heightMap[0].length

var lowPointsMap = Array(rows*cols).fill(0)

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

var sumRiskLevels = 0
for (r = 0; r < rows; r++) {
  for (c = 0; c < cols; c++) {
    if (lowPointsMap[r * cols + c] == -4) {
      sumRiskLevels += heightMap[r][c] + 1
    }
  }
}

console.log(sumRiskLevels)
