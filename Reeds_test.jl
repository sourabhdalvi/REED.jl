using JuMP
using Gurobi
using CSV
#; ./gdx2csv.sh
include("./func_def.jl")
include("./read_data.jl")

model = Model(with_optimizer(Gurobi.Optimizer));
constraints = Dict{String, JuMP.Containers.DenseAxisArray}();
variables = Dict{String, JuMP.Containers.DenseAxisArray}();

include("./create_var.jl")
include("./constraint.jl")
include("./Objective.jl")

JuMP.@objective(model, Min, cost_func)

@time optimize!(m)
println(termination_status(m))
