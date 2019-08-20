
str_sets_dict = Dict();
set_icrt = combvec(set_i,set_c,set_rfeas_cap,set_t);
str_sets_dict["CAP"] = filter(x-> haskey(dict_valcap,x), set_icrt);
str_sets_dict["INV"] = filter(x-> haskey(dict_valcap,x), combvec(set_i,set_newc,set_rfeas_cap,set_t));
str_sets_dict["INVREFURB"] = filter(x-> haskey(dict_ict,x[[1,2,4]]), 
                                combvec(set_refurbtech,set_c,set_rfeas_cap,set_t));
str_sets_dict["EXTRA_PRESCRIP"] = combvec(set_pcat,set_rfeas_cap,set_t);
str_sets_dict["INV_RSC"] = filter(x-> haskey(set_m_rscfeas,x[[3,1,4]]),
                                combvec(set_rsc_i,set_c,set_rfeas_cap,set_rscbin,set_t));

set_icrht = combvec(set_i,set_c,set_rfeas,set_h,set_t);
set_icrht_storage = combvec(set_storage,set_c,set_rfeas_cap,set_h,set_t);
str_sets_dict["GEN"] = filter(x-> haskey(dict_valgen,x[[1,2,3,5]]), set_icrht);
str_sets_dict["STORAGE_IN"] = filter(x-> haskey(dict_valgen,x[[1,2,3,5]]), set_icrht_storage);
str_sets_dict["STORAGE_OUT"] = str_sets_dict["STORAGE_IN"];
str_sets_dict["STORAGE_LEVEL"] = str_sets_dict["STORAGE_IN"];
str_sets_dict["CURT"] = combvec(set_rfeas,set_h,set_t);
str_sets_dict["MINGEN"] = combvec(set_rfeas,set_szn,set_t);

str_sets_dict["FLOW"] = combvec(set_rfeas,set_rfeas,set_h,set_trtype,set_t);
str_sets_dict["OPRES_FLOW"] = combvec(set_ortype,set_rfeas,set_rfeas,set_h,set_t);
str_sets_dict["PRMTRADE"] = combvec(set_rfeas,set_rfeas,set_szn,set_t);

str_sets_dict["OPRES"] = filter( x-> haskey(dict_valgen,x[[2,3,4,6]]) 
                                && (haskey(param_reserve_frac,x[[2,1]]) 
                                || in(x[2],set_storage) || in(x[2],set_hydro_d)),
                                combvec(set_ortype,set_i,set_c,set_rfeas,set_h,set_t));

str_sets_dict["GasUsed"] = combvec(set_cendiv,set_gb,set_h,set_t);
str_sets_dict["Vgasbinq_national"] = combvec(set_fuelbin,set_t);
str_sets_dict["Vgasbinq_regional"] = combvec(set_fuelbin,set_cendiv,set_t);
str_sets_dict["BIOUSED"] = combvec(set_bioclass,set_rfeas,set_t);

str_sets_dict["RECS"] = combvec(set_RPSCat,set_i,set_stfeas,set_stfeas,set_t);
str_sets_dict["ACP_Purchases"] = combvec(set_RPSCat,set_st,set_t);
str_sets_dict["EMIT"] = combvec(set_e,set_rfeas,set_t);

set_rrttr = combvec(set_rfeas,set_rfeas,set_trtype,set_t);
str_sets_dict["CAPTRAN"] = set_rrttr;
str_sets_dict["INVTRAN"] = set_rrttr;
str_sets_dict["INVSUBSTATION"] = combvec(set_rfeas,set_vc,set_t);
str_sets_dict["LOAD"] = combvec(set_rfeas,set_h,set_t);

#Constraints 
str_sets_dict["eq_loadcon"] = combvec(set_rfeas,set_h,set_t);
str_sets_dict["eq_cap_init_noret"] = filter( x -> ((x[4]<= set_retireyear[1]) | !haskey(dict_retiretech,x))
                                                    && haskey(dict_valcap,x),
                                                    combvec(set_i,set_initc,set_rfeas_cap,set_t));

str_sets_dict["eq_cap_init_retub"] = filter( x -> haskey(dict_valcap,x) 
                                            && ((x[4]>= set_retireyear[1]) && haskey(dict_retiretech,x))
                                            ,combvec(set_i,set_initc,set_rfeas_cap,set_t));

str_sets_dict["eq_cap_init_retmo"] = str_sets_dict["eq_cap_init_retub"];

# *==============================
# * -- new capacity equations --
# *==============================
str_sets_dict["eq_cap_new_noret"] = filter( x -> ((x[4]<= set_retireyear[1]) || !haskey(dict_retiretech,x)) 
                                    && haskey(dict_valcap,x),combvec(set_i,set_newc,set_rfeas_cap,set_t));

str_sets_dict["eq_cap_new_retub"] = filter( x -> ((x[4]>= set_retireyear[1]) && haskey(dict_retiretech,x))
                                        && haskey(dict_valcap,x),combvec(set_i,set_newc,set_rfeas_cap,set_t));
str_sets_dict["eq_cap_new_retmo"] = str_sets_dict["eq_cap_new_retub"];

str_sets_dict["eq_forceprescription"] =Dict();
str_sets_dict["eq_forceprescription"]["rhs_1"] = Dict((pcat,r,t) => [(i,c,r,t) for (i,c) in combvec(set_i,set_newc) 
                                                                        if haskey(dict_valcap,(i,c,r,t)) 
                                                                        && in((pcat,i),set_prescriptivelink) ]
                                                        for (pcat,r,t) in combvec(set_pcat,set_rfeas_cap,set_t));
str_sets_dict["eq_forceprescription"]["eq"] = filter(x -> !isempty(str_sets_dict["eq_forceprescription"]["rhs_1"][x]) && in(x[[1,3]],set_force_pcat)
                                                        ,combvec(set_pcat,set_rfeas_cap,set_t) ) ;

                                                        
str_sets_dict["eq_neartermcaplimit"] = (!isempty(param_near_term_cap_limits) ? 
                                        filter( x-> (sum([1 for i in set_onswind, c in set_c if haskey(dict_valcap,(i,c,x[1],x[2])) ]) > 0)
                                        ,combvec(set_rfeas_cap,set_t)) : 0); 

str_sets_dict["eq_refurblim"] = combvec(set_refurbtech,set_rfeas_cap,set_t);

str_sets_dict["eq_rsc_inv_account"] =  filter(x -> haskey(dict_valcap,x), combvec(set_rsc_i,set_newc,set_rfeas_cap,set_t));

str_sets_dict["eq_rsc_INVlim"] = filter( x -> haskey(set_m_rscfeas,x[[1,2,3]]),combvec(set_rfeas_cap,set_rsc_i,set_rscbin,set_t));

str_sets_dict["eq_growthlimit_relative"] = filter( x -> haskey(param_growth_limit_relative,x[1]) 
                                                        && (x[2] >= 2020) && !(x[2] == set_t[end]) 
                                                        , combvec(set_tg,set_t));

str_sets_dict["eq_growthlimit_absolute"] = filter(x-> (x[2] >= 2018) && !(x[2] ==set_t[end]) 
                                                        && haskey(param_growth_limit_absolute,x[1]), 
                                                        combvec(set_tg,set_t));

temp_i = filter(i-> !in(i,set_storage) && !in(i,set_hydro_d), set_i);
str_sets_dict["eq_capacity_limit"] =  filter(x->haskey(dict_valgen,x[[1,2,3,5]]), 
                                                combvec(temp_i,set_c,set_rfeas,set_h,set_t));

str_sets_dict["eq_curt_gen_balance"] = combvec(set_rfeas,set_h,set_t);

str_sets_dict["eq_curtailment"] = combvec(set_rfeas,set_h,set_t);

str_sets_dict["eq_mingen_lb"] = filter(x-> in((x[2],x[3]),set_h_szn), combvec(set_rfeas,set_h,set_szn,set_t));
str_sets_dict["eq_mingen_ub"] = str_sets_dict["eq_mingen_lb"];

str_sets_dict["eq_gasct_gencon"] = filter(x -> haskey(dict_valgen,x), combvec(["gas-ct","gas-ct-nsp"],set_c,set_rfeas,set_t));

str_sets_dict["eq_dhyd_dispatch"] =  filter(x -> haskey(dict_valgen,x[[1,2,3,5]]), combvec(set_hydro_d,set_c,set_rfeas,set_szn,set_t));

str_sets_dict["eq_supply_demand_balance"] = combvec(set_rfeas,set_h,set_t);

str_sets_dict["eq_minloading"] =  filter(x-> in(x[[4,5]],set_hour_szn_group) && haskey(dict_valgen,x[[1,2,3,6]])
                                        && haskey(param_minloadfrac,x[[3,1,5]])
                                        ,combvec(set_i,set_c,set_rfeas,set_h,set_h,set_t));

str_sets_dict["eq_ORCap"] = filter(x-> haskey(param_reserve_frac,x[[2,1]]) 
                                        && haskey(dict_valgen,x[[2,3,4,6]])
                                        && !in(x[2],set_storage_no_csp)
                                        && !in(x[2], set_hydro_nd),
                                        combvec(set_ortype,set_i,set_c,set_rfeas,set_h,set_t));

str_sets_dict["eq_OpRes_requirement"] = combvec(set_ortype,set_rfeas,set_h,set_t);

temp_rto = collect(Set([tup[2] for tup in set_r_rto ]));
str_sets_dict["eq_inertia_requirement"] = combvec(temp_rto,set_h,set_t);

str_sets_dict["eq_PRMTRADELimit"] = Dict();
str_sets_dict["eq_PRMTRADELimit"]["lhs"] = Dict((r,rr,t) => [ tr for tr in set_trtype if haskey(dict_routes,(r,rr,tr,t))] 
                                        for (r,rr,t) in combvec(set_rfeas,set_rfeas,set_t))
str_sets_dict["eq_PRMTRADELimit"]["eq"] = filter( x-> !isempty(str_sets_dict["eq_PRMTRADELimit"]["lhs"][x[[1,2,4]]]),
                                                combvec(set_rfeas,set_rfeas,set_szn,set_t));

str_sets_dict["eq_reserve_margin"] = combvec(set_rfeas,set_szn,set_t);

str_sets_dict["eq_CAPTRAN"] = filter(x-> haskey(dict_routes,x) ,combvec(set_rfeas,set_rfeas,set_trtype,set_t));

str_sets_dict["eq_prescribed_transmission"] = filter(x-> haskey(dict_routes,x) && (x[4] <= 2020)  
                                                ,combvec(set_rfeas,set_rfeas,set_trtype,set_t));

str_sets_dict["eq_SubStationAccounting"] = combvec(set_rfeas,set_t);

str_sets_dict["eq_INVTRAN_VCLimit"] = filter(x-> in(x,set_tranfeas), combvec(set_rfeas,set_vc));

str_sets_dict["eq_transmission_limit"] =filter(x-> (haskey(dict_routes,x[[1,2,4,5]]) || haskey(dict_routes,x[[2,1,4,5]]) )
                                ,combvec(set_rfeas,set_rfeas,set_h,set_trtype,set_t));

str_sets_dict["eq_emit_accounting"] = combvec(set_e,set_rfeas,set_t);
str_sets_dict["eq_RGGI_cap"] = filter(x -> (x >= param_RGGI_start_yr), set_t);
str_sets_dict["eq_AB32_cap"] = filter(x -> (x >= param_AB32_start_yr), set_t);

str_sets_dict["eq_batterymandate"] = filter(x-> haskey(param_batterymandate,x) 
                                        && haskey(dict_valcap_irt,x[[2,1,3]]),
                                        combvec(set_rfeas,["battery"],set_t)); 

str_sets_dict["eq_emit_rate_limit"] = filter(x -> (x[3] >= param_CarbPolicyStartyear)
                                                && in(x,set_emit_rate_con) 
                                                ,combvec(set_e,set_rfeas,set_t));
                                                
temp_emit_cap = [tup for tup in keys(param_emit_cap)];
str_sets_dict["eq_annual_cap"] = combvec(temp_emit_cap);

str_sets_dict["eq_bankborrowcap"] =Dict();
str_sets_dict["eq_bankborrowcap"]["lhs_1"] = Dict(e => [t for t in set_t if haskey(param_emit_cap,(e,t))] for e in set_e);
str_sets_dict["eq_bankborrowcap"]["eq"] = filter(x-> haskey(str_sets_dict["eq_bankborrowcap"]["lhs_1"],x),set_e); 

str_sets_dict["eq_REC_Generation"] = filter( x-> (x[4] >= param_RPS_StartYear), 
                                                combvec(set_RPSCat,set_i,set_stfeas,set_t[2:end]));

temp_rps = [rps for rps in set_RPSCat if "RPS_Bundled" != rps];
str_sets_dict["eq_REC_Requirement"] = filter(x-> (x[3] >= param_RPS_StartYear)
                                                && haskey(dict_RecStates,x) 
                                                ,combvec(temp_rps,set_stfeas,set_t[2:end]));

str_sets_dict["eq_REC_BundleLimit"] =Dict();
str_sets_dict["eq_REC_BundleLimit"]["lhs_1"] = Dict((st,ast,t) 
                                                => [(i,"RPS_Bundled",st,ast,t) for i in set_i 
                                                        if haskey(dict_RecMap,(i,"RPS_Bundled",st,ast,t))]
                                                for st in set_stfeas, ast in set_stfeas, t in set_t);
str_sets_dict["eq_REC_BundleLimit"]["eq"] = filter(x-> (x[1] != x[2]) && (x[4] >= param_RPS_StartYear) 
                                                        && haskey(str_sets_dict["eq_REC_BundleLimit"]["rhs_1"],x)
                                                        ,combvec(set_stfeas,set_stfeas,set_t));

str_sets_dict["eq_REC_unbundledLimit"] = filter( x-> haskey(param_RPS_unbundled_limit,x[1]) 
                                                && (x[2] >= param_RPS_StartYear)
                                                        ,combvec(set_stfeas,set_t));

str_sets_dict["eq_REC_ooslim"] = filter( x-> haskey(dict_RecStates,x) 
                                        && (x[3] >= param_RPS_StartYear) && (x[3] >= 2016)
                                        ,combvec(set_RPSCat,set_stfeas,set_t[2:end]));

str_sets_dict["eq_REC_launder"] = str_sets_dict["eq_REC_ooslim"];

str_sets_dict["eq_RPS_OFSWind"] = Dict();
str_sets_dict["eq_RPS_OFSWind"]["lhs_1"] = Dict((st,t) =>
                                                [ (i,c,rr,t) for r in set_rfeas_cap, i in set_ofswind, c in set_c, rr in set_rfeas_cap 
                                                        if in((r,st),set_r_st) && haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t)) ] 
                                                                for st in set_stfeas, t in set_t);
str_sets_dict["eq_RPS_OFSWind"]["eq"] = filter(x-> haskey(str_sets_dict["eq_RPS_OFSWind"]["lhs_1"],x),
                                                collect(keys(param_offshore_cap_req)));
str_sets_dict["eq_national_rps"] = filter(x-> haskey(param_national_rps_frac,x),set_t);

str_sets_dict["eq_gasused"] = combvec(set_cdfeas,set_h,set_t);
str_sets_dict["eq_gasbinlimit"] = combvec(set_cdfeas,set_gb,set_t);
str_sets_dict["eq_gasbinlimit_nat"] = combvec(set_gb,set_t);
str_sets_dict["eq_gasaccounting_regional"] = combvec(set_cdfeas,set_t);
str_sets_dict["eq_gasaccounting_national"] = set_t;
str_sets_dict["eq_gasbinlimit_regional"] = combvec(set_fuelbin,set_cdfeas,set_t);
str_sets_dict["eq_gasbinlimit_national"] = combvec(set_fuelbin,set_t);

str_sets_dict["eq_bioused"] = combvec(set_rfeas,set_t);
str_sets_dict["eq_biousedlimit"] = combvec(set_bioclass,set_rfeas,set_t);

str_sets_dict["eq_storage_capacity"] = filter(x-> haskey(dict_valgen,x[[1,2,3,5]]) 
                                                ,set_icrht_storage);
str_sets_dict["eq_csp_charge"] = filter( x-> haskey(dict_valgen,x[[1,2,3,5]]), 
                                        combvec(set_csp_storage,set_c,set_rfeas,set_h,set_t));
str_sets_dict["eq_csp_gen"] = str_sets_dict["eq_csp_charge"];
str_sets_dict["eq_storage_level"] = str_sets_dict["eq_storage_capacity"] ;
str_sets_dict["eq_storage_thermalres"] = filter( x-> haskey(dict_valgen,x[[1,2,3,5]]),
                                                combvec(set_thermal_storage,set_c,set_rfeas,set_h,set_t));
set_batcsp = deepcopy(set_csp_storage);
push!(set_batcsp,"battery");
str_sets_dict["eq_storage_duration"] = filter(x-> haskey(dict_valgen,x[[1,2,3,5]]),
                                                combvec(set_batcsp,set_c,set_rfeas,set_h,set_t));
