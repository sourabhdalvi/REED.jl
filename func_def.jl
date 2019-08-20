function collect_const(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = param[1,1]
    return pdict
end

function collect_1D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict{Union{Number, String},Number}();
    nrow,ncol = size(param)
    for row in 1:nrow
        pdict[param[row,1]] = param[row,2] ;
    end
    return pdict
end

function collect_2D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict{NTuple{2,Union{Number, String}},Number}();
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];
        pdict[(a,b)] = param[row,3] ;
    end
    return pdict
end

function collect_3D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict{NTuple{3,Union{Number, String}},Number}();
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];c = param[row,3];
        pdict[(a,b,c)] = param[row,4] ;
    end
    return pdict
end

function collect_4D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict{NTuple{4,Union{Number, String}},Number}();
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];
        pdict[(a,b,c,d)] = param[row,5] ;
    end
    return pdict
end

function collect_5D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict{NTuple{5,Union{Number, String}},Number}();
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = param[row,5];
        pdict[(a,b,c,d,e)] = param[row,6] ;
    end
    return pdict
end

function read_set(csv_path)
    set_ = DataFrames.disallowmissing!(CSV.read(csv_path,header=0));
    return collect(Set(set_.Column1))
end

function read_set_2D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist =  Array{NTuple{2,Union{Number, String}},1}();
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_3D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = Array{NTuple{3,Union{Number, String}},1}();
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_4D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist =  Array{NTuple{4,Union{Number, String}},1}();
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_5D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist =  Array{NTuple{5,Union{Number, String}},1}();
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4],set[row,5]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function collect_set_dict5D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict{NTuple{5,Union{Number, String}},Bool}()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3];d = set_[row,4];e = set_[row,5];
        dict_[(a,b,c,d,e)] = true ;
    end
    return dict_
end
    
function collect_set_dict4D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict{NTuple{4,Union{Number, String}},Bool}()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3];d = set_[row,4];
        dict_[(a,b,c,d)] = true ;
    end
    return dict_
end

function collect_set_dict3D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict{NTuple{3,Union{Number, String}},Bool}()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3]
        dict_[(a,b,c)] = true ;
    end
    return dict_
end

function collect_set_dict2D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict{NTuple{2,Union{Number, String}},Bool}()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];
        dict_[(a,b)] = true ;
    end
    return dict_
end


function combvec(set_a...)
    return vec(collect(Iterators.product(set_a...)))
end

_add_rhs_lhs(m::JuMP.AbstractModel) = (JuMP.GenericAffExpr{Float64, JuMP.variable_type(m)}(),JuMP.GenericAffExpr{Float64, JuMP.variable_type(m)}());


function add_variable_constraints(model,axs)
    _size = length(axs); 
    lb = zeros(_size);
    bm = JuMP.backend(model);
    x = MOI.add_variables(bm, _size)
    MOI.add_constraints(bm,
                        MOI.SingleVariable.(x),
                        MOI.GreaterThan.(lb)
                        )
    var_ref = VariableRef.(model, x);
    return  JuMP.Containers.DenseAxisArray(var_ref,axs)
end

function add_variable_constraints(model,axs,name)
    _size = length(axs); 
    lb = zeros(_size);
    bm = JuMP.backend(model);
    x = MOI.add_variables(bm, _size)
    nam = map(n->"$(name)$(n)", axs)
    MOI.set(bm, MOI.VariableName(), x, nam)
    MOI.add_constraints(bm,
                        MOI.SingleVariable.(x),
                        MOI.GreaterThan.(lb)
                        )
    var_ref = VariableRef.(model, x);
    return  JuMP.Containers.DenseAxisArray(var_ref,axs)
end

function _container_spec(m::M, ax...) where {M <: JuMP.AbstractModel}
    return JuMP.Containers.DenseAxisArray{JuMP.variable_type(m)}(undef, ax...)
end


# function _add_var(m,var_name::Symbol,names)
#     cont = _container_spec(m,names)
#     for (ix,i) in enumerate(names)
#         @inbounds cont.data[ix] = JuMP.@variable(m, lower_bound = 0.0)
#     end
#     return cont
# end

# function _add_var(m::JuMP.AbstractModel,var_name::Symbol,names::Array{String,1})
#     cont = _container_spec(m,names)
#     for (ix,i) in enumerate(names)
#         @inbounds cont.data[ix] = JuMP.@variable(m, 
#                                                 base_name="$(var_name)_$(i)",
#                                                 lower_bound = 0.0)
#     end
#     return cont
# end

#=
julia> @time x = MOI.add_variables(JuMP.backend(model), _size);
  0.260546 seconds (23 allocations: 13.402 MiB, 5.09% gc time)

julia> @time lb = zeros(_size);
  0.001333 seconds (6 allocations: 2.615 MiB)

julia> @time bm = JuMP.backend(model);
  0.000006 seconds (4 allocations: 160 bytes)

julia> @time MOI.add_constraints(
               bm,
               MOI.SingleVariable.(x),
               MOI.GreaterThan.(lb)
           );
  0.168652 seconds (342.77 k allocations: 26.574 MiB, 9.83% gc time)

julia> @time var_ref = VariableRef.(model, x);
  0.021052 seconds (342.73 k allocations: 13.074 MiB, 85.69% gc time)

julia> @time @inbounds cont =  JuMP.Containers.DenseAxisArray(var_ref, str_sets_dict["CAP"]);
  0.163720 seconds (929.97 k allocations: 42.549 MiB, 16.25% gc time)


Benchmark Different Add Variable Methods
1). julia> @time @variable(model,base_name=:CAP,[str_sets_dict["CAP"]],lower_bound = 0);
        20.567083 seconds (22.66 M allocations: 1.283 GiB, 75.60% gc time)

2). julia> @time _add_var(model,:CAP,str_sets_dict["CAP"]);
        5.142402 seconds (9.16 M allocations: 620.408 MiB, 71.94% gc time)

3). julia> @time add_variable_constraints(model,str_sets_dict["CAP"]);
        0.830946 seconds (1.62 M allocations: 98.212 MiB, 46.12% gc time)
=#