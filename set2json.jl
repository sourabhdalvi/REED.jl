using JSON
using CSV
using DataFrames

include("./func_def.jl");
include("./read_data.jl");


str_sets_dict = Dict()
set_icrt = concat_sets(set_i,set_c,set_rfeas_cap,set_t);
str_sets_dict["CAP"] = set_icrt;
str_sets_dict["INV"] = set_icrt;
str_sets_dict["INVREFURB"] = set_icrt;
str_sets_dict["EXTRA_PRESCRIP"] = concat_sets(set_pcat,set_rfeas_cap,set_t);
str_sets_dict["INV_RSC"] = concat_sets(set_rsc_i,set_c,set_rfeas_cap,set_rscbin,set_t);

set_icrht = concat_sets(set_i,set_c,set_rfeas,set_h,set_t);
set_icrht_storage = concat_sets(set_storage,set_c,set_rfeas_cap,set_h,set_t);
str_sets_dict["GEN"] = set_icrht;
str_sets_dict["STORAGE_IN"] = set_icrht_storage;
str_sets_dict["STORAGE_OUT"] = set_icrht_storage;
str_sets_dict["STORAGE_LEVEL"] = set_icrht_storage;
str_sets_dict["CURT"] = concat_sets(set_rfeas,set_h,set_t);
str_sets_dict["MINGEN"] = concat_sets(set_rfeas,set_szn,set_t);

str_sets_dict["FLOW"] = concat_sets(set_rfeas,set_rfeas,set_h,set_trtype,set_t);
str_sets_dict["OPRES_FLOW"] = concat_sets(set_ortype,set_rfeas,set_rfeas,set_h,set_t);
str_sets_dict["PRMTRADE"] = concat_sets(set_rfeas,set_rfeas,set_szn,set_t);

str_sets_dict["OPRES"] = concat_sets(set_ortype,set_i2,set_c,set_rfeas,set_h,set_t);
str_sets_dict["GasUsed"] = concat_sets(set_cendiv,set_gb,set_h,set_t);
str_sets_dict["Vgasbinq_national"] = concat_sets(set_fuelbin,set_t);
str_sets_dict["Vgasbinq_regional"] = concat_sets(set_fuelbin,set_cendiv,set_t);
str_sets_dict["BIOUSED"] = concat_sets(set_bioclass,set_rfeas,set_t);

str_sets_dict["RECS"] = concat_sets(set_RPSCat,set_i2,set_st,set_st,set_t);
str_sets_dict["ACP_Purchases"] = concat_sets(set_RPSCat,set_st,set_t);
str_sets_dict["EMIT"] = concat_sets(set_e,set_rfeas,set_t);

set_rrttr = concat_sets(set_rfeas,set_rfeas,set_trtype,set_t);
str_sets_dict["CAPTRAN"] = set_rrttr;
str_sets_dict["INVTRAN"] = set_rrttr;
str_sets_dict["INVSUBSTATION"] = concat_sets(set_rfeas,set_vc,set_t);
str_sets_dict["LOAD"] = concat_sets(set_rfeas,set_h,set_t);

str_sets_dict["eq_loadcon"] = concat_sets(set_rfeas,set_h,set_t);
temp_tprime = [ t for t in set_t if t <= set_retireyear[1]];
str_sets_dict["eq_cap_init_noret"] = concat_sets(set_i2,set_initc,set_rfeas_cap,temp_tprime);
temp_tprime = [ t for t in set_t if t >= set_retireyear[1]];
str_sets_dict["eq_cap_init_retub"] = concat_sets(set_i2,set_initc,set_rfeas_cap,temp_tprime);
str_sets_dict["eq_cap_init_retmo"] = str_sets_dict["eq_cap_init_retub"];
str_sets_dict["eq_cap_new_noret"] = concat_sets(set_i2,set_newc,set_rfeas_cap,set_t);
str_sets_dict["eq_cap_new_retub"] = concat_sets(set_i2,set_newc,set_rfeas_cap,set_t);
str_sets_dict["eq_cap_new_retmo"] = concat_sets(set_i2,set_newc,set_rfeas_cap,set_t);
str_sets_dict["eq_forceprescription"] = concat_sets(set_pcat,set_rfeas_cap,set_t);
str_sets_dict["eq_neartermcaplimit"] = concat_sets(set_rfeas_cap,set_t);
str_sets_dict["eq_refurblim"] = concat_sets(set_refurbtech,set_rfeas_cap,set_t);
str_sets_dict["eq_rsc_inv_account"] =  concat_sets(set_rsc_i,set_newc,set_rfeas_cap,set_t);
str_sets_dict["eq_rsc_INVlim"] = concat_sets(set_i2,set_rfeas_cap,set_rscbin);
str_sets_dict["eq_growthlimit_relative"] = concat_sets(set_tg,set_t);
str_sets_dict["eq_growthlimit_absolute"] = concat_sets(set_tg,set_t);
str_sets_dict["eq_capacity_limit"] =  concat_sets(set_i2,set_c,set_rfeas,set_h,set_t);
str_sets_dict["eq_curt_gen_balance"] = concat_sets(set_rfeas,set_h,set_t);
str_sets_dict["eq_curtailment"] = concat_sets(set_rfeas,set_h,set_t);
temp_h_szn = [join(collect(tup),"_") for tup in set_h_szn];
str_sets_dict["eq_mingen_lb"] = concat_sets(set_rfeas,temp_h_szn,set_t);
str_sets_dict["eq_mingen_ub"] = str_sets_dict["eq_mingen_lb"];
str_sets_dict["eq_gasct_gencon"] = concat_sets(["gas-ct","gas-ct-nsp"],set_c,set_rfeas,set_t);
str_sets_dict["eq_dhyd_dispatch"] =  concat_sets(set_hydro_d,set_c,set_rfeas,set_szn,set_t);
str_sets_dict["eq_supply_demand_balance"] = concat_sets(set_rfeas,set_h,set_t);
temp_hour_szn = [join(collect(tup),"_") for tup in set_hour_szn_group];
str_sets_dict["eq_minloading"] =  concat_sets(set_i2,set_c,set_rfeas,temp_hour_szn,set_t);
temp_i = [ i for i in set_i2 if !in(i,set_storage) & !in(i,set_hydro_nd)];
temp_st_ori = [join((or,i),"_") for or in (set_ortype), i in (temp_i) if haskey(param_reserve_frac,"$(i)_$(or)")];
str_sets_dict["eq_ORCap"] = concat_sets(temp_st_ori,set_c,set_rfeas,set_h,set_t);
str_sets_dict["eq_OpRes_requirement"] = concat_sets(set_ortype,set_rfeas,set_h,set_t);
str_sets_dict["eq_inertia_requirement"] = concat_sets(set_rto,set_h,set_t);
str_sets_dict["eq_PRMTRADELimit"] = concat_sets(set_rfeas,set_rfeas,set_szn,set_t);
str_sets_dict["eq_reserve_margin"] = concat_sets(set_rfeas,set_szn,set_t);
str_sets_dict["eq_CAPTRAN"] = concat_sets(set_rfeas,set_rfeas,set_trtype,set_t);
str_sets_dict["eq_prescribed_transmission"] = str_sets_dict["eq_CAPTRAN"] ;
str_sets_dict["eq_SubStationAccounting"] = concat_sets(set_rfeas,set_t);
str_sets_dict["eq_INVTRAN_VCLimit"] = concat_sets(set_rfeas,set_vc);
str_sets_dict["eq_transmission_limit"] =concat_sets(set_rfeas,set_rfeas,set_h,set_trtype,set_t);
str_sets_dict["eq_emit_accounting"] = concat_sets(set_e,set_rfeas,set_t);
str_sets_dict["eq_RGGI_cap"] = set_t;
str_sets_dict["eq_AB32_cap"] = set_t;
str_sets_dict["eq_batterymandate"] = concat_sets(set_rfeas,["battery"],set_t);
str_sets_dict["eq_emit_rate_limit"] = concat_sets(set_e,set_rfeas,set_t);
str_sets_dict["eq_annual_cap"] = concat_sets(set_e,set_t);
str_sets_dict["eq_bankborrowcap"] = set_e;
str_sets_dict["eq_REC_Generation"] = concat_sets(set_RPSCat,set_i2,set_stfeas,set_t[2:end]);
str_sets_dict["eq_REC_Requirement"] = concat_sets(set_RPSCat,set_st,set_t);
str_sets_dict["eq_REC_ooslim"] = str_sets_dict["eq_REC_Requirement"];
str_sets_dict["eq_REC_launder"] = str_sets_dict["eq_REC_Requirement"];
str_sets_dict["eq_RPS_OFSWind"] = concat_sets(set_st,set_t);
str_sets_dict["eq_national_rps"] = set_t;
str_sets_dict["eq_gasused"] = concat_sets(set_cdfeas,set_h,set_t);
str_sets_dict["eq_gasbinlimit"] = concat_sets(set_cdfeas,set_gb,set_t);
str_sets_dict["eq_gasbinlimit_nat"] = concat_sets(set_gb,set_t);
str_sets_dict["eq_gasaccounting_regional"] = concat_sets(set_cdfeas,set_t);
str_sets_dict["eq_gasaccounting_national"] = set_t;
str_sets_dict["eq_gasbinlimit_regional"] = concat_sets(set_fuelbin,set_cdfeas,set_t);
str_sets_dict["eq_gasbinlimit_national"] = concat_sets(set_fuelbin,set_t);
str_sets_dict["eq_bioused"] = concat_sets(set_rfeas,set_t);
str_sets_dict["eq_biousedlimit"] = concat_sets(set_bioclass,set_rfeas,set_t);
str_sets_dict["eq_storage_capacity"] = set_icrht_storage;
str_sets_dict["eq_csp_charge"] = concat_sets(set_csp_storage,set_c,set_rfeas,set_h,set_t);
str_sets_dict["eq_csp_gen"] = str_sets_dict["eq_csp_charge"];
str_sets_dict["eq_storage_level"] = concat_sets(set_storage,set_c,set_rfeas,set_h,set_t);
str_sets_dict["eq_storage_balance"] = concat_sets(set_szn,set_storage,set_c,set_rfeas,set_t);
str_sets_dict["eq_storage_thermalres"] = concat_sets(set_thermal_storage,set_c,set_rfeas,set_h,set_t);
set_batcsp = set_csp_storage;
push!(set_batcsp,"battery");
str_sets_dict["eq_storage_duration"] = concat_sets(set_batcsp,set_c,set_rfeas,set_h,set_t);



stringdata = JSON.json(str_sets_dict, 4);
open("Sets.json", "w") do f
        write(f, stringdata)
end