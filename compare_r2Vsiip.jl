function compare_mismatch(results_dict,validate_dict)
    keys_fm_results = keys(results_dict);
    keys_fm_validate = keys(validate_dict);
    common_keys =  intersect(Set(keys_fm_results),Set(keys_fm_validate));
    valid_results = [];
    mismatch_results = [];
    
    for c_key in common_keys
        (abs(validate_dict[c_key]-results_dict[c_key]) <= 0.0099  ? push!(valid_results,(c_key,validate_dict[c_key])) 
            : push!(mismatch_results,(c_key,results_dict[c_key],validate_dict[c_key])) );
    end
    missing_keys_1 = collect(setdiff(Set(keys_fm_results),Set(keys_fm_validate)));
    missing_keys_1 = [ x for x in missing_keys_1 if !(results_dict[x]==0.0) ];
    in_r_nv = [ results_dict[i] for i in missing_keys_1 ];
    missing_keys_2 = collect(setdiff(Set(keys_fm_validate),Set(keys_fm_results)));
    missing_keys_2 = [ x for x in missing_keys_2 if !(validate_dict[x]==0.0) ];
    in_v_nr = [ validate_dict[i] for i in missing_keys_2 ];
    valid_df = DataFrame(Index =[x[1] for x in valid_results], Value = [x[2] for x in valid_results]);
    mismatch_df= DataFrame(Index = [x[1] for x in mismatch_results], SIIP = [x[2] for x in mismatch_results], R2 = [ x[3] for x in mismatch_results]);
    missing_df1 = DataFrame(Index = missing_keys_1, Value = in_r_nv);
    missing_df2 = DataFrame(Index = missing_keys_2, Value = in_v_nr);
    return Dict("Valid"=>valid_df,"Mismatch"=>mismatch_df, "Additional_in_SIIP"=>missing_df1, "Missing_from_R2"=> missing_df2)
end
    
    
Compare_dict = Dict();
Compare_dict["CAP"] = compare_mismatch(result_dict["CAP"],valid_dict["CAP"]) ; 
Compare_dict["INV"] = compare_mismatch(result_dict["INV"],valid_dict["INV"]);
Compare_dict["INVREFURB"] = compare_mismatch(result_dict["INVREFURB"],valid_dict["INVREFURB"]);
Compare_dict["EXTRA_PRESCRIP"] = compare_mismatch(result_dict["EXTRA_PRESCRIP"],valid_dict["EXTRA_PRESCRIP"]);
Compare_dict["INV_RSC"] = compare_mismatch(result_dict["INV_RSC"],valid_dict["INV_RSC"]);
Compare_dict["GEN"] = compare_mismatch(result_dict["GEN"],valid_dict["GEN"]);
Compare_dict["STORAGE_IN"] = compare_mismatch(result_dict["STORAGE_IN"],valid_dict["STORAGE_IN"]);
Compare_dict["STORAGE_OUT"] = compare_mismatch(result_dict["STORAGE_OUT"],valid_dict["STORAGE_OUT"]);
Compare_dict["STORAGE_LEVEL"] = compare_mismatch(result_dict["STORAGE_LEVEL"],valid_dict["STORAGE_LEVEL"]);
Compare_dict["CURT"] = compare_mismatch(result_dict["CURT"],valid_dict["CURT"]);
Compare_dict["MINGEN"] = compare_mismatch(result_dict["MINGEN"],valid_dict["MINGEN"]);
Compare_dict["FLOW"] = compare_mismatch(result_dict["FLOW"],valid_dict["FLOW"]);
Compare_dict["OPRES_FLOW"] = compare_mismatch(result_dict["OPRES_FLOW"],valid_dict["OPRES_FLOW"]);
Compare_dict["PRMTRADE"] = compare_mismatch(result_dict["PRMTRADE"],valid_dict["PRMTRADE"]);
Compare_dict["OPRES"] = compare_mismatch(result_dict["OPRES"],valid_dict["OPRES"]);
Compare_dict["GasUsed"] = compare_mismatch(result_dict["GasUsed"],valid_dict["GasUsed"]);
Compare_dict["Vgasbinq_national"] = compare_mismatch(result_dict["Vgasbinq_national"],valid_dict["Vgasbinq_national"]);
Compare_dict["Vgasbinq_regional"] = compare_mismatch(result_dict["Vgasbinq_regional"],valid_dict["Vgasbinq_regional"]);
Compare_dict["BIOUSED"] = compare_mismatch(result_dict["BIOUSED"],valid_dict["BIOUSED"]);
Compare_dict["RECS"] = compare_mismatch(result_dict["RECS"],valid_dict["RECS"]);
Compare_dict["ACP_Purchases"] = compare_mismatch(result_dict["ACP_Purchases"],valid_dict["ACP_Purchases"]);
Compare_dict["EMIT"] = compare_mismatch(result_dict["EMIT"],valid_dict["EMIT"]);
Compare_dict["CAPTRAN"] = compare_mismatch(result_dict["CAPTRAN"],valid_dict["CAPTRAN"]);
Compare_dict["INVTRAN"] = compare_mismatch(result_dict["INVTRAN"],valid_dict["INVTRAN"]);
Compare_dict["INVSUBSTATION"] = compare_mismatch(result_dict["INVSUBSTATION"],valid_dict["INVSUBSTATION"]);
Compare_dict["LOAD"] = compare_mismatch(result_dict["LOAD"],valid_dict["LOAD"]);
# Compare_dict[] = compare_mismatch(result_dict[],valid_dict[]);
