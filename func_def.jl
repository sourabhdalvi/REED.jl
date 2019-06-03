function read_set(csv_path)
    set_ = DataFrames.disallowmissing!(CSV.read(csv_path,header=0));
    return collect(Set(set_.Column1))
end

function collect_1D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        pdict[param[row,1]] = param[row,2] ;
    end
    return pdict
end

function collect_2D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];
        pdict["$a"*"_"*"$b"] = param[row,3] ;
    end
    return pdict
end

function collect_3D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];c = param[row,3];
        pdict["$a"*"_"*"$b"*"_"*"$c"] = param[row,4] ;
    end
    return pdict
end

function collect_4D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];
        pdict["$a"*"_"*"$b"*"_"*"$c"*"_"*"$d"] = param[row,5] ;
    end
    return pdict
end

function collect_5D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = param[row,5];
        pdict["$a"*"_"*"$b"*"_"*"$c"*"_"*"$d"*"_"*"$e"] = param[row,6] ;
    end
    return pdict
end

function read_set_2D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_3D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_4D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_5D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4],set[row,5]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function collect_set_dict5D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3];d = set_[row,4];e = set_[row,5];
        dict_["$(a)_$(b)_$(c)_$(d)_$(e)"] = true ;
    end
    return dict_
end
    
function collect_set_dict4D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3];d = set_[row,4];
        dict_["$(a)_$(b)_$(c)_$(d)"] = true ;
    end
    return dict_
end

function collect_set_dict3D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3]
        dict_["$(a)_$(b)_$(c)"] = true ;
    end
    return dict_
end

function collect_set_dict2D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];
        dict_["$(a)_$(b)"] = true ;
    end
    return dict_
end
    
function concat_sets(set_a::Array{String,1},set_b::Union{Array{String},Array{Int64}})
    str_set = Vector{String}();
    for a in set_a, b in set_b
        push!(str_set,a*"_$(b)")
    end
    return str_set
end

function concat_sets(set_a::Array{String},set_b::Array{String},set_c::Union{Array{String},Array{Int64}})
    str_set = Vector{String}();
    for a in set_a, b in set_b, c in set_c
        push!(str_set,a*"_"*b*"_$(c)")
    end
    return str_set
end

function concat_sets(set_a::Array{String},set_b::Array{String},set_c::Array{String},set_d::Union{Array{String},Array{Int64}})
    str_set = Vector{String}();
    for a in set_a, b in set_b, c in set_c, d in set_d
        push!(str_set,a*"_"*b*"_"*c*"_$(d)")
    end
    return str_set
end

function concat_sets(set_a::Array{String,1},set_b::Array{String,1},set_c::Array{String,1},set_d::Array{String,1},set_e::Union{Array{String,1},Array{Int64,1}})
    str_set = Vector{String}();
    for a in set_a, b in set_b, c in set_c, d in set_d, e in set_e
        push!(str_set,a*"_"*b*"_"*c*"_"*d*"_$(e)")
    end
    return str_set
end

function concat_sets(set_a::Array{String},set_b::Array{String},set_c::Array{String},set_d::Array{String},set_e::Array{String},set_f::Union{Array{String},Array{Int64}})
    str_set = Vector{String}();
    for a in set_a, b in set_b, c in set_c, d in set_d, e in set_e, f in set_f
        push!(str_set,a*"_"*b*"_"*c*"_"*d*"_"*e*"_$(f)")
    end
    return str_set
end
    
function var_const(m,var_name,names)
    size = length(names); 
    var = MOI.add_variables(JuMP.backend(m),size);
    for (nam,v) in zip(names,var)
        nam="$(var_name)_"*nam;
        MOI.set(JuMP.backend(m), MOI.VariableName(), v, nam)
        MOI.add_constraint(JuMP.backend(m), MOI.SingleVariable(v),MOI.GreaterThan(0.0))
    end
    var_ref = VariableRef[VariableRef(m, v) for v in MOI.VectorOfVariables(var).variables];
    cont =  JuMP.Containers.DenseAxisArray(var_ref, names);
    return cont
    println("Variable = $(var_name) add to the JuMP model")
end

#=
@benchmark var_const(m,:CAP,a) 

BenchmarkTools.Trial: 
  memory estimate:  31.78 MiB
  allocs estimate:  855520
  --------------
  minimum time:     98.758 ms (11.21% GC)
  median time:      116.127 ms (22.46% GC)
  mean time:        265.604 ms (8.72% GC)
  maximum time:     2.398 s (1.72% GC)
  --------------
  samples:          19
  evals/sample:     1

=#

