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

static void setBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], Coords from, Coords to);

static int countBits(uint64_t crossBitmap[][I64_LINE_WIDTH]);

static void dump(uint64_t bitmap[][I64_LINE_WIDTH]);

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

    if (from.x == to.x || from.y == to.y || abs(from.x - to.x) == abs(from.y - to.y)) {
      setBits(bitmap, crossBitmap, from, to);
    }
  }

  dump(bitmap);
  dump(crossBitmap);
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

static inline void setBit(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], int x, int y) {
    uint64_t mask = 1ULL << (x & 63);
    if ((bitmap[y][x / 64] & mask) == 0) {
      bitmap[y][x / 64] |= mask;
    } else {
      // already set. this is a cross
      crossBitmap[y][x / 64] |= mask;
    }
}

static inline int sign(int n) {
  return !n ? 0 : ((n > 0) ? 1 : -1);
}

static void setBits(uint64_t bitmap[][I64_LINE_WIDTH], uint64_t crossBitmap[][I64_LINE_WIDTH], Coords from, Coords to) {
  int xInc = sign(to.x - from.x);
  int yInc = sign(to.y - from.y);
  for (int x = from.x, y = from.y; x != to.x + xInc || y != to.y + yInc; x += xInc, y += yInc) {
    setBit(bitmap, crossBitmap, x, y);
  }
}

static void dump(uint64_t bitmap[][I64_LINE_WIDTH]) {
#if 0
  for (size_t i = 0; i < MAX_GRID; i++) {
    for (size_t j = 0; j < I64_LINE_WIDTH; j++) {
      for (int n = 0; n < 64; n++) {
        putchar((bitmap[i][j] >> n) & 1 ? 'X' : '.');
      }
    }
    printf("\n");
  }
  printf("-----------\n");
#endif
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