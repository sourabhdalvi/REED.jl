## Sets
set_t = read_set("../GDX_data/Set_t.csv");
set_c = read_set("../GDX_data/Set_C.csv");
set_i = read_set("../GDX_data/Set_i.csv");
set_r = read_set("../GDX_data/Set_r.csv");
set_h = read_set("../GDX_data/Set_h.csv");
set_tg = read_set("../GDX_data/Set_tg.csv");
set_rscbin = read_set("../GDX_data/Set_rscbin.csv");
set_rsc_i = read_set("../GDX_data/Set_rsc_i.csv");
set_newc = read_set("../GDX_data/Set_newc.csv");
set_initc = read_set("../GDX_data/Set_initc.csv");
set_yeart = read_set("../GDX_data/Set_yeart.csv");
set_retireyear = read_set("../GDX_data/Set_retireyear.csv");
set_pcat = read_set("../GDX_data/Set_pcat.csv");
set_r_ercot = read_set("../GDX_data/Set_r_ercot.csv");
set_rs = read_set("../GDX_data/Set_rs.csv");
set_retireyear = read_set("../GDX_data/Set_retireyear.csv");
set_refurbtech = read_set("../GDX_data/Set_refurbtech.csv");
set_ortype = read_set("../GDX_data/Set_ortype.csv");
set_vre = read_set("../GDX_data/Set_vre.csv");
set_szn = read_set("../GDX_data/Set_szn.csv");
set_storage = read_set("../GDX_data/Parm_storage.csv");
set_trtype = read_set("../GDX_data/Set_trtype.csv");
set_csp_storage = read_set("../GDX_data/Set_CSP_Storage.csv");
set_wind = read_set("../GDX_data/Set_wind.csv");
set_pv = read_set("../GDX_data/Set_pv.csv");
set_rto = read_set("../GDX_data/Set_rto.csv");
set_csp1 = read_set("../GDX_data/Set_csp1.csv");
set_csp2 = read_set("../GDX_data/Set_csp2.csv");
set_hydro_d = read_set("../GDX_data/Set_hydro_d.csv");

set_ban_i = Set(["ice","hydro","upv_10","mhkwave","caes","other","unknown" ]);
set_bannew_i = Set(["can-imports", "hydro", "distpv", "lfill-gas", "geothermal", "Ocean", 
                    "cofireold", "caes", "coal-IGCC", "CoalOldScr", "CoalOldUns", "biopower", 
                    "csp-ns", "HydEND", "HydED" ]);

set_valcap = read_set_4D("../GDX_data/Set_valcap.csv");
set_force_pcat = read_set_2D("../GDX_data/Set_force_pcat.csv");
set_ict =  read_set_3D("../GDX_data/Set_ict.csv");
set_prescriptivelink = read_set_2D("../GDX_data/Set_prescriptivelink.csv");
set_tg_i = read_set_2D("../GDX_data/Set_tg_i.csv");
set_cap_agg =  read_set_2D("../GDX_data/Set_cap_agg.csv");
set_h_szn = read_set_2D("../GDX_data/Set_h_szn.csv");
set_routes = read_set_4D("../GDX_data/Parm_routes.csv");
set_opres_routes = read_set_3D("../GDX_data/Parm_opres_routes.csv");
set_hour_szn_group = read_set_2D("../GDX_data/Set_hour_szn_group.csv");
set_maxload_szn = read_set_4D("../GDX_data/Set_maxload_szn.csv");
set_hydro_nd = read_set("../GDX_data/Set_hydro_nd.csv");
set_dayhours = read_set("../GDX_data/Set_dayhours.csv");
set_r_rto = read_set_2D("../GDX_data/Set_r_rto.csv");
set_inertia = read_set("../GDX_data/Set_inertia.csv");
set_rsc_agg = read_set_2D("../GDX_data/Set_rsc_agg.csv");
set_vc = read_set("../GDX_data/Set_vc.csv");
set_tranfeas = read_set("../GDX_data/Set_tranfeas.csv");
set_e =read_set("../GDX_data/Set_e.csv");
set_AB32_r = read_set("../GDX_data/Set_AB32_r.csv");
set_cofire = read_set("../GDX_data/Set_cofire.csv");
set_RPSCat = read_set("../GDX_data/Set_RPSCat.csv");
set_st = read_set("../GDX_data/Set_st.csv");
set_r_st = read_set("../GDX_data/Set_r_st.csv");
set_re = read_set("../GDX_data/Set_re.csv");
set_cendiv = read_set("../GDX_data/Set_cendiv.csv");
set_gb = read_set("../GDX_data/Set_gb.csv");
set_gas = read_set("../GDX_data/Set_gas.csv");
set_r_cendiv = read_set_2D("../GDX_data/Set_r_cendiv.csv");
set_gps = read_set("../GDX_data/Set_gps.csv");
set_bioclass = read_set("../GDX_data/Set_bioclass.csv");
set_country = read_set("../GDX_data/Set_country.csv");
set_r_country = read_set("../GDX_data/Set_r_country.csv");
set_rscfeas = read_set_4D("../GDX_data/Set_rscfeas.csv");
set_vc = read_set("../GDX_data/Set_vc.csv");
set_tranfeas = read_set_2D("../GDX_data/Param_tranfeas.csv");
set_RGGI_r =  read_set("../GDX_data/Param_RGGI_r.csv");
set_RecTech = read_set_4D("../GDX_data/Param_RecTech.csv");
set_RecMap = read_set_5D("../GDX_data/Param_RecMap.csv");


# Param
param_exo_cap = collect_4D("../GDX_data/Parm_m_capacity_exog.csv");
param_degrade = collect_3D("../GDX_data/Parm_degrade.csv");
param_maxage = collect_1D("../GDX_data/Parm_maxage.csv");
param_r_rs = collect_2D("../GDX_data/Parm_r_rs.csv");
param_m_required_prescriptions =  collect_3D("../GDX_data/Param_m_required_prescriptions.csv");
param_firstyear_pcat = collect_1D("../GDX_data/Param_firstyear_pcat.csv");
param_near_term_cap_limits = collect_3D("../GDX_data/Param_near_term_cap_limits.csv");
param_m_avail_retire_exog_rsc = collect_4D("../GDX_data/Param_m_avail_retire_exog_rsc.csv");
param_growth_limit_relative = collect_1D("../GDX_data/Param_growth_limit_relative.csv");
param_reserve_frac = collect_2D("../GDX_data/Parm_reserve_frac.csv");
param_m_cf = collect_5D("../GDX_data/Set_m_cf.csv");
param_minloadfrac = collect_3D("../GDX_data/Parm_minloadfrac.csv");
param_hours = collect_1D("../GDX_data/Parm_hours.csv");
param_outage = collect_2D("../GDX_data/Parm_outage.csv");
param_orperc = collect_2D("../GDX_data/Parm_orperc.csv");
param_cf_tech = collect_1D("../GDX_data/Parm_cf_tech.csv");
param_tranloss= collect_1D("../GDX_data/Parm_tranloss.csv");
param_inertia_req = collect_1D("../GDX_data/Param_inertia_req.csv");
param_m_rsc_dat = collect_4D("../GDX_data/Param_m_rsc_dat.csv");
param_resourcescaler = collect_1D("../GDX_data/Param_resourcescaler.csv");
param_m_cv_mar = collect_4D("../GDX_data/Param_m_cv_mar.csv");
param_futuretran = collect_5D("../GDX_data/Param_futuretran.csv");
param_INr = collect_1D("../GDX_data/Param_INr.csv");
param_trancap_exog =collect_4D("../GDX_data/Param_trancap_exog.csv");
param_prm =collect_2D("../GDX_data/Param_prm.csv");
param_cf_hyd_szn_adj = collect_3D("../GDX_data/Param_cf_hyd_szn_adj.csv");
param_trancost = collect_3D("../GDX_data/Param_cf_hyd_szn_adj.csv");
param_emit_rate = collect_5D("../GDX_data/Param_emit_rate.csv");
param_AB32Cap = collect_1D("../GDX_data/Param_AB32Cap.csv");
param_batterymandate = collect_3D("../GDX_data/Param_batterymandate.csv");
param_emit_rate_limit = collect_3D("../GDX_data/Param_emit_rate_limit.csv");
aram_offshore_cap_req = collect_2D("../GDX_data/Param_offshore_cap_req.csv");
param_national_rps_frac = collect_1D("../GDX_data/Param_national_rps_frac.csv");
param_heat_rate = collect_4D("../GDX_data/Param_heat_rate.csv");
param_gaslimit = collect_4D("../GDX_data/Param_gaslimit.csv");
param_gaslimit_nat = collect_3D("../GDX_data/Param_gaslimit_nat.csv");
param_gasbinwidth_regional = collect_3D("../GDX_data/Param_Gasbinwidth_regional.csv");
param_gasbinwidth_national = collect_2D("../GDX_data/Param_Gasbinwidth_national.csv");
param_biosupply = collect_3D("../GDX_data/Param_biosupply.csv");
param_csp_sm = collect_1D("../GDX_data/Param_CSP_SM.csv");
param_numdays = collect_1D("../GDX_data/Param_numdays.csv");
param_storage_eff = collect_1D("../GDX_data/Param_storage_eff.csv");
param_storage_duration = collect_1D("../GDX_data/Param_storage_duration.csv");
param_m_rscfeas = collect_3D("../GDX_data/Param_m_rscfeas.csv");
param_can_exports_h = collect_3D("../GDX_data/Param_can_exports_h.csv");
param_lmnt = collect_3D("../GDX_data/Param_lmnt.csv");

#Cost
param_cost_cap_fin_mult = collect_3D("../GDX_data/Param_cost_cap_fin_mult.csv");
param_cost_cap = collect_2D("../GDX_data/Param_cost_cap.csv");
param_CRF_PTC = collect_1D("../GDX_data/Param_CRF_PTC.csv");
param_ptc = collect_3D("../GDX_data/Param_PTC.csv");
param_intertranscost = collect_1D("../GDX_data/Param_InterTransCost.csv");
param_distance = collect_2D("../GDX_data/Param_distance.csv");
param_trancost =  collect_3D("../GDX_data/Param_trancost.csv");
param_pvf_onm = collect_1D("../GDX_data/Param_pvf_onm.csv");
param_cost_vom =  collect_4D("../GDX_data/Param_cost_vom.csv");
param_cost_fom =  collect_4D("../GDX_data/Param_cost_fom.csv");
param_cost_opres = collect_1D("../GDX_data/Param_cost_opres.csv");
param_heat_rate = collect_4D("../GDX_data/Param_heat_rate.csv");
param_fuel_price = collect_3D("../GDX_data/Param_fuel_price.csv");
param_gasprice  = collect_4D("../GDX_data/Param_gasprice.csv");
param_gasprice_nat_bin =  collect_3D("../GDX_data/Param_gasprice_nat_bin.csv");
param_gasadder_cd =  collect_3D("../GDX_data/Param_gasadder_cd.csv");
param_gasmultterm =  collect_2D("../GDX_data/Param_gasmultterm.csv");
param_szn_adj_gas = collect_1D("../GDX_data/Param_szn_adj_gas.csv");
param_cendiv_weights = collect_2D("../GDX_data/Param_cendiv_weights.csv");
param_gasbinp_regional = collect_3D("../GDX_data/Param_gasbinp_regional.csv");
param_gasbinp_national = collect_2D("../GDX_data/Param_gasbinp_national.csv");
param_biosupply = collect_3D("../GDX_data/Param_biosupply.csv");
param_biopricemult= collect_3D("../GDX_data/Param_biopricemult.csv");
param_hurdle = collect_2D("../GDX_data/Param_hurdle.csv");
param_emit_tax = collect_3D("../GDX_data/Param_emit_tax.csv");
param_acp_price = collect_2D("../GDX_data/Param_acp_price.csv");

set_t = Set([2010,2012,2014,2016,2018,2020]);

set_retiretech = Set([(i,c,r,t) for i in set_i, c in set_c, r in set_r, t in set_t 
            if  in(i,Set(["CoalOldScr","CoalOldUns","Gas-GG","Gas-CT"])) &  in(c,set_initc) & !in(i,set_ban_i)]);
set_inv_cond = Set([(i,c,t,tt) for i in set_i, c in set_newc, t in set_t, tt in set_t  
                if (!in(i,set_bannew_i) & !in(i,set_ban_i) & (tt <= t) & in((i,c,tt),set_ict) & (t-tt <= param_maxage[i])) # missing Tmodel_new
                | ((i=="csp-ns") & (tt == 2010) & (t-tt <= param_maxage[i]) & in((i,c,tt),set_ict) )]);
set_i2 = Set([i for i in set_i if !in(i,set_ban_i)]);

set_rfeas = Set([ r for r in set_r if in(r,set_r_ercot) ]);

set_rfeas_cap = Set([ r for r in set_rfeas, rs in set_rs if (sum([ 1 for rr in set_rfeas if haskey(param_r_rs,"$r"*"_"*"$rs")]) > 0) & !(r=="sk") ]);

set_m_refurb_cond = Set([(i,c,r,t) for i in set_i2, c in set_newc, r in set_r, t in set_t, tt in set_t
                        if in(i,set_refurbtech) & (tt <= t) & (t-tt > param_maxage[i]) 
                            & in((i,c,tt),set_ict) 
                            & in((i,c,r,t),set_valcap) & in((i,c,r,tt),set_valcap) ]);
