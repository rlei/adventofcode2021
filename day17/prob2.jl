xr = 56:76
yr = -162:-134
# xr = 20:30
# yr = -10:-5

function test(sx, sy, n)
  y_end = (2 * sy - n + 1) * n / 2
  if (n <= sx)
      x_end = (2 * sx - n + 1) * n / 2
  else
      x_end = (sx + 1) * sx / 2
  end
  if ((x_end in xr) && (y_end in yr))
    return true
  end
  return false
end

# Coarse but safe ranges for x/y velocities
max_sx = maximum(xr)
max_sy = max(abs(minimum(yr)), abs(maximum(yr)))
max_n = max_sy * 2 + 1

answers = 0
for sy in (-max_sy):max_sy
  for sx in 0:max_sx
    for n in 0:max_n
      if (test(sx, sy, n))
        # println(sx, ",", sy)
        global answers = answers + 1
        break
      end
    end
  end
end

println("answers found ", answers)
