#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_GRID 1000
#define I64_LINE_WIDTH ((MAX_GRID + 63) / 64)

typedef struct {
  int x;
  int y;
} Coords;

static Coords scanCoords(const char *p);

static void setYBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], int x, int y1, int y2);

static void setXBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], int y, int x1, int x2);

static int countBits(uint64_t crossBitmap[][I64_LINE_WIDTH]);

int main()
{
  uint64_t bitmap[MAX_GRID][I64_LINE_WIDTH] = {0};
  uint64_t crossBitmap[MAX_GRID][I64_LINE_WIDTH] = {0};
  char lineBuf[50];

  while (fgets(lineBuf, sizeof(lineBuf), stdin) != NULL) {
    char *arrow = strstr(lineBuf, " -> ");
    if (arrow == NULL) {
      fprintf(stderr, "Invalid input line missing ->: %s", lineBuf);
      exit(1);
    }

    *arrow = '\0';
    Coords from = scanCoords(lineBuf);
    Coords to = scanCoords(arrow + 4);

    if (from.x == to.x) {
      setYBits(bitmap, crossBitmap, from.x, from.y, to.y);
    } else if (from.y == to.y) {
      setXBits(bitmap, crossBitmap, from.y, from.x, to.x);
    }
  }

  printf("%d\n", countBits(crossBitmap));
  return 0;
}

static Coords scanCoords(const char *p) {
  char *comma = strchr(p, ',');
  if (comma == NULL) {
      fprintf(stderr, "Invalid coordinates %s", p);
      exit(2);
  }
  *comma = '\0';

  Coords ret;
  ret.x = strtol(p, NULL, 10);
  ret.y = strtol(comma + 1, NULL, 10);
  if (ret.x < 0 || ret.y < 0 || ret.x >= MAX_GRID || ret.y >= MAX_GRID) {
      fprintf(stderr, "Too small or too large coordinates %d,%d\n", ret.x, ret.y);
      exit(2);
  }
  return ret;
}

static void setYBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], int x, int y1, int y2) {
  int yStart = y1 < y2 ? y1 : y2;
  int yEnd = y1 > y2 ? y1 : y2;
  for (int y = yStart; y <= yEnd; y++) {
    uint64_t mask = 1ULL << (y & 63);
    if (bitmap[x][y / 64] & mask) {
      // already set. this is a cross
      crossBitmap[x][y / 64] |= mask;
    } else {
      bitmap[x][y / 64] |= mask;
    }
  }
}

static void setXBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], int y, int x1, int x2) {
  int xStart = x1 < x2 ? x1 : x2;
  int xEnd = x1 > x2 ? x1 : x2;

  uint64_t mask = 1ULL << (y & 63);
  for (int x = xStart; x <= xEnd; x++) {
    if (bitmap[x][y / 64] & mask) {
      // already set. this is a cross
      crossBitmap[x][y / 64] |= mask;
    } else {
      bitmap[x][y / 64] |= mask;
    }
  }
}

static int countBits(uint64_t crossBitmap[][I64_LINE_WIDTH]) {
  int numBits = 0;
  for (size_t i = 0; i < MAX_GRID; i++) {
    for (size_t j = 0; j < I64_LINE_WIDTH; j++) {
      numBits += __builtin_popcountll(crossBitmap[i][j]);
    }
  }
  return numBits;
}
