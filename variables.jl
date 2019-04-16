function concat_sets(axs...)
        str_set = [join(collect(tup),"_") for tup in vec(collect(Base.product(axs...)))];
        return str_set
end
    
function var_const(m,var_name,names)
    size = length(names); 
    var = MOI.add_variables(JuMP.backend(m),size);
    for (nam,v) in zip(names,var)
        nam="$(var_name)_"*nam;
        MOI.set(JuMP.backend(m), MOI.VariableName(), v, nam)
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
    
    function variable_constructor(model,var_name,str_set)
        con =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, str_set);
        for (ix,s) in enumerate(str_set)
            con.data[ix] = JuMP.@variable(model, base_name="$s",start = 0.0, binary=false)
        end
        return con;
        println("Variable = $(var_name) add to the JuMP model")
    end
    
    #=
    
    BenchmarkTools.Trial: 
      memory estimate:  27.86 MiB
      allocs estimate:  1197699
      --------------
      minimum time:     147.769 ms (0.00% GC)
      median time:      3.522 s (54.81% GC)
      mean time:        8.918 s (87.93% GC)
      maximum time:     23.085 s (93.54% GC)
      --------------
      samples:          3
      evals/sample:     1
    =#


    set_icrt = concat_sets(set_i,set_c,set_rfeas_cap,set_t);
    variables["CAP"] = var_const(model,:CAP,set_icrt);
    variables["INV"] = var_const(model,:INV,set_icrt);
    variables["INVREFURB"] = var_const(model,:INVREFURB,set_icrt)
    variables["EXTRA_PRESCRIP"] = var_const(model,:EXTRA_PRESCRIP,concat_sets(set_pcat,set_rfeas_cap,set_t));
    variables["INV_RSC"] = var_const(model,:INV_RSC,concat_sets(set_rsc_i,set_c,set_rfeas_cap,set_t,set_rscbin));
    
    set_icrht = concat_sets(set_i,set_c,set_rfeas_cap,set_h,set_t);
    variables["GEN"] = var_const(model,:GEN,set_icrht);
    variables["STORAGE_IN"] = var_const(model,:STORAGE_IN,set_icrht);
    variables["STORAGE_OUT"] = var_const(model,:STORAGE_OUT,set_icrht);
    variables["STORAGE_LEVEL"] = var_const(model,:STORAGE_LEVEL,set_icrht);
    variables["CURT"] = var_const(model,:CURT,concat_sets(set_rfeas,set_h,set_t));
    variables["MINGEN"] = var_const(model,:MINGEN,concat_sets(set_rfeas,set_szn,set_t));
    
    
    variables["FLOW"] = var_const(model,:FLOW,concat_sets(set_rfeas,set_rfeas,set_h,set_t,set_trtype));
    variables["OPRES_FLOW"] = var_const(model,:OPRES_FLOW,concat_sets(set_ortype,set_rfeas,set_rfeas,set_h,set_t));
    variables["PRMTRADE"] = var_const(model,:PRMTRADE,concat_sets(set_rfeas,set_rfeas,set_szn,set_t));
    
    variables["OPRES"] = var_const(model,:OPRES,concat_sets(set_ortype,set_i2,set_c,set_rfeas,set_h,set_t));
    variables["GasUsed"] = var_const(model,:GasUsed,concat_sets(set_cendiv,set_gb,set_h,set_t));
    variables["Vgasbinq_national"] = var_const(model,:Vgasbinq_national,concat_sets(set_fuelbin,set_t));
    variables["Vgasbinq_regional"] = var_const(model,:Vgasbinq_regional,concat_sets(set_fuelbin,set_cendiv,set_t));
    variables["BIOUSED"] = var_const(model,:BIOUSED,concat_sets(set_bioclass,set_rfeas,set_t));
    
    variables["RECS"] = var_const(model,:RECS,concat_sets(set_RPSCat,set_i2,set_st,set_st,set_t));
    variables["ACP_Purchases"] =  var_const(model,:ACP_Purchases,concat_sets(set_RPSCat,set_st,set_t));
    variables["EMIT"] = var_const(model,:EMIT,concat_sets(set_e,set_rfeas,set_t));
    
    set_rrttr = concat_sets(set_rfeas,set_rfeas,set_t,set_trtype);
    variables["CAPTRAN"] = var_const(model,:CAPTRAN,set_rrttr);
    variables["INVTRAN"] = var_const(model,:INVTRAN,set_rrttr);
    variables["INVSUBSTATION"] = var_const(model,:INVSUBSTATION,concat_sets(set_rfeas,set_vc,set_t));
    
    variables["LOAD"] = var_const(model,:LOAD,concat_sets(set_rfeas,set_h,set_t));
    # variable_constructor(model,variables,:var_name,set_);
    
    
    
    
    
    
    
    
    
    
    