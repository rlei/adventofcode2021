#!/bin/env python3

from heapq import heappush, heappop
import sys


def wrap_add(a, b):
  n = a + b
  if n > 9:
    n -= 9
  return n


def neighbours(y, x, height, width):
  if (y > 0):
    yield y - 1, x
  if (x > 0):
    yield y, x - 1
  if (y < height - 1):
    yield y + 1, x
  if (x < width - 1):
    yield y, x + 1


def dijkstra(risk_map):
  w, h = len(risk_map[0]), len(risk_map)
  # Python 3's in is unbounded, but sys.maxsize will serve our purpose for Day 15's input range
  cost_map = [[sys.maxsize for x in range(w)] for y in range(h)]
  cost_map[0][0] = 0

  visited = set()
  pq = []
  heappush(pq, (0, (0, 0)))

  while len(pq) > 0:
    (cost, (y, x)) = heappop(pq)
    visited.add((y, x))

    for ny, nx in neighbours(y, x, h, w):
      if (ny, nx) not in visited:
        old_cost = cost_map[ny][nx]
        new_cost = cost_map[y][x] + risk_map[ny][nx]
        if new_cost < old_cost:
            heappush(pq, (new_cost, (ny, nx)))
            cost_map[ny][nx] = new_cost

  return cost_map


def repeat_map(small_risk_map):
  sw, sh = len(small_risk_map[0]), len(small_risk_map)
  w, h = sw * 5, sh * 5

  risk_map = [[0 for x in range(w)] for y in range(h)]

  for tile_y in range(0, 5):
    for tile_x in range(0, 5):
      for y, row in enumerate(small_risk_map):
        risk_map[tile_y * sh + y][tile_x * sw : (tile_x + 1) * sw] = [wrap_add(n, tile_x + tile_y) for n in row]

  return risk_map


if __name__ == "__main__":
  risk_map = [[ord(n) - ord('0') for n in line.strip()] for line in sys.stdin.readlines()]

  if len(sys.argv) > 1 and sys.argv[1] == '-2':
    risk_map = repeat_map(risk_map)

  cost_map = dijkstra(risk_map)

  print(cost_map[-1][-1])
