using Pkg
Pkg.add(["JuMP", "AmplNLWriter", "Bonmin_jll"])
using JuMP, AmplNLWriter, Bonmin_jll

model = Model(() -> AmplNLWriter.Optimizer(Bonmin_jll.amplexe))
@variable(model, 1 <= n <= 1000, Int)
@variable(model, 1 <= sx <= 76, Int)
@variable(model, 1 <= sy <= 162, Int)
@NLconstraint(model, c2, 56 <= (sx+1)*sx/2 <= 76)
@NLconstraint(model, c3, -162 <= (2*sy-n+1)*n/2 <= -134)
@NLconstraint(model, c4, n <= 1000)
@NLobjective(model, Max, sy*(sy + 1)/2)

optimize!(model)

print(solution_summary(model, verbose=true))
