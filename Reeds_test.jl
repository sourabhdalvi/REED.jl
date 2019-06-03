using JuMP
using Xpress
using CSV
using DataFrames
using JSON
const MOI = JuMP.MathOptInterface;

# ; ./gdx2csv.sh
# ; ./Sgdx2csv.sh
# include("./sets2json.jl")
include("./func_def.jl");
include("./read_data.jl");
include("./read_sets.jl");
include("./reeds_solution.jl");

solver = with_optimizer(Xpress.Optimizer,OUTPUTLOG = 1,MIPTOL=1e-6,FEASTOL=1e-6);
model = Model(solver);
constraints = Dict{String, JuMP.Containers.DenseAxisArray}();
variables = Dict{String, JuMP.Containers.DenseAxisArray}();

include("variables.jl");
include("./constraints_2.jl");
include("Objective.jl");
JuMP.@objective(model, Min, cost_func);

optimize!(model)
println(termination_status(model))


include("./collect_solution.jl");
include("./compare_r2Vsiip.jl");