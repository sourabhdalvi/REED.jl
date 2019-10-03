using Revise
using JuMP
using Xpress
using CSV
using DataFrames
using JSON
const MOI = JuMP.MathOptInterface;
using MathOptFormat

# ; ./gdx2csv.sh
# ; ./resultsgdx2csv.sh

@time include("./func_def.jl");
@time include("./read_data.jl");
@time include("./Rcsv2json.jl");

# cached = MOIU.CachingOptimizer(JuMP._MOIModel{Float64}(), optimizer)
# optimizer = Xpress.Optimizer(OUTPUTLOG = 1,MIPTOL=1e-6,FEASTOL=1e-6);
# model = direct_model(optimizer);

solver = with_optimizer(Xpress.Optimizer,OUTPUTLOG = 1,MIPTOL=1e-6,FEASTOL=1e-6);
model = Model(solver);
constraints = Dict{String, JuMP.Containers.DenseAxisArray}();
variables = Dict{String, JuMP.Containers.DenseAxisArray}();

@time include("variables.jl");
@time include("constriants.jl");
@time include("Objective.jl");
@time JuMP.@objective(model, Min, cost_func);

@time optimize!(model)
println(termination_status(model))
