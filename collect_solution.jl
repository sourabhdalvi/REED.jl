function collect_var_value(var_cont)
    index_key = keys(var_cont.lookup[1]);
    value_dict = Dict();
    for k in index_key
        JuMP.value(var_cont[k]) > 0.0 ? value_dict[k] = JuMP.value(var_cont[k]) : nothing ;
    end
    return value_dict
end
result_dict = Dict();
result_dict["CAP"] = collect_var_value(variables["CAP"]);
result_dict["INV"] = collect_var_value(variables["INV"]);
result_dict["INVREFURB"] = collect_var_value(variables["INVREFURB"]);
result_dict["EXTRA_PRESCRIP"] = collect_var_value(variables["EXTRA_PRESCRIP"]);
result_dict["INV_RSC"] = collect_var_value(variables["INV_RSC"]);

result_dict["GEN"] = collect_var_value(variables["GEN"]);
result_dict["STORAGE_IN"] = collect_var_value(variables["STORAGE_IN"]);
result_dict["STORAGE_OUT"] = collect_var_value(variables["STORAGE_OUT"]);
result_dict["STORAGE_LEVEL"] = collect_var_value(variables["STORAGE_LEVEL"]);
result_dict["CURT"] = collect_var_value(variables["CURT"]);
result_dict["MINGEN"] = collect_var_value(variables["MINGEN"]);
result_dict["FLOW"] = collect_var_value(variables["FLOW"]);
result_dict["OPRES_FLOW"] = collect_var_value(variables["OPRES_FLOW"]);
result_dict["PRMTRADE"] = collect_var_value(variables["PRMTRADE"]);
result_dict["OPRES"] = collect_var_value(variables["OPRES"]);
result_dict["GasUsed"] = collect_var_value(variables["GasUsed"]);
result_dict["Vgasbinq_national"] = collect_var_value(variables["Vgasbinq_national"]);
result_dict["Vgasbinq_regional"] = collect_var_value(variables["Vgasbinq_regional"]);
result_dict["BIOUSED"] = collect_var_value(variables["BIOUSED"]);
result_dict["RECS"] = collect_var_value(variables["RECS"]);
result_dict["ACP_Purchases"] = collect_var_value(variables["ACP_Purchases"]);
result_dict["EMIT"] = collect_var_value(variables["EMIT"]);
result_dict["CAPTRAN"] = collect_var_value(variables["CAPTRAN"]);
result_dict["INVTRAN"] = collect_var_value(variables["INVTRAN"]);
result_dict["INVSUBSTATION"] = collect_var_value(variables["INVSUBSTATION"]);
result_dict["LOAD"] = collect_var_value(variables["LOAD"]);
