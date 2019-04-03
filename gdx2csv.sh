#!/bin/bash

#export PATH=$PATH:"/Applications/GAMS26.1/GAMS Terminal.app/../sysdir" && cd ~
cd ~/Projects/GDX_data/
# Dump Sets
gdxdump ercot_data_20190401.gdx symb=c format=csv noHeader >> Set_C.csv
gdxdump ercot_data_20190401.gdx symb=t format=csv noHeader >> Set_t.csv
gdxdump ercot_data_20190401.gdx symb=i format=csv noHeader >> Set_i.csv
gdxdump ercot_data_20190401.gdx symb=r format=csv noHeader >> Set_r.csv
gdxdump ercot_data_20190401.gdx symb=rscbin format=csv noHeader >> Set_rscbin.csv
gdxdump ercot_data_20190401.gdx symb=h format=csv noHeader >> Set_h.csv
gdxdump ercot_data_20190401.gdx symb=newc format=csv noHeader >> Set_newc.csv
gdxdump ercot_data_20190401.gdx symb=valcap format=csv noHeader >> Set_valcap.csv
gdxdump ercot_data_20190401.gdx symb=rsc_i format=csv noHeader >> Set_rsc_i.csv
gdxdump ercot_data_20190401.gdx symb=initc format=csv noHeader >> Set_initc.csv
gdxdump ercot_data_20190401.gdx symb=yeart format=csv noHeader >> Set_yeart.csv
gdxdump ercot_data_20190401.gdx symb=retireyear format=csv noHeader >> Set_retireyear.csv
gdxdump ercot_data_20190401.gdx symb=refurbtech format=csv noHeader >> Set_refurbtech.csv
gdxdump ercot_data_20190401.gdx symb=pcat format=csv noHeader >> Set_pcat.csv
gdxdump ercot_data_20190401.gdx symb=r_ercot format=csv noHeader >> Set_r_ercot.csv
gdxdump ercot_data_20190401.gdx symb=rs format=csv noHeader >> Set_rs.csv
gdxdump ercot_data_20190401.gdx symb=force_pcat format=csv noHeader >> Set_force_pcat.csv
gdxdump ercot_data_20190401.gdx symb=ict format=csv noHeader >> Set_ict.csv
gdxdump ercot_data_20190401.gdx symb=prescriptivelink format=csv noHeader >> Set_prescriptivelink.csv
gdxdump ercot_data_20190401.gdx symb=tg_i format=csv noHeader >> Set_tg_i.csv
gdxdump ercot_data_20190401.gdx symb=tg format=csv noHeader >> Set_tg.csv
gdxdump ercot_data_20190401.gdx symb=cap_agg format=csv noHeader >> Set_cap_agg.csv
gdxdump ercot_data_20190401.gdx symb=ortype format=csv noHeader >> Set_ortype.csv
gdxdump ercot_data_20190401.gdx symb=vre format=csv noHeader >> Set_vre.csv
gdxdump ercot_data_20190401.gdx symb=m_cf format=csv noHeader >> Set_m_cf.csv
gdxdump ercot_data_20190401.gdx symb=h_szn format=csv noHeader >> Set_h_szn.csv
gdxdump ercot_data_20190401.gdx symb=szn format=csv noHeader >> Set_szn.csv
gdxdump ercot_data_20190401.gdx symb=trtype  format=csv noHeader >> Set_trtype.csv
gdxdump ercot_data_20190401.gdx symb=CSP_Storage  format=csv noHeader >> Set_CSP_Storage.csv
gdxdump ercot_data_20190401.gdx symb=wind  format=csv noHeader >> Set_wind.csv
gdxdump ercot_data_20190401.gdx symb=pv  format=csv noHeader >> Set_pv.csv
gdxdump ercot_data_20190401.gdx symb=rto  format=csv noHeader >> Set_rto.csv
gdxdump ercot_data_20190401.gdx symb=csp1  format=csv noHeader >> Set_csp1.csv
gdxdump ercot_data_20190401.gdx symb=csp2  format=csv noHeader >> Set_csp2.csv
gdxdump ercot_data_20190401.gdx symb=hydro_d  format=csv noHeader >> Set_hydro_d.csv
gdxdump ercot_data_20190401.gdx symb=hour_szn_group  format=csv noHeader >> Set_hour_szn_group.csv
gdxdump ercot_data_20190401.gdx symb=maxload_szn  format=csv noHeader >> Set_maxload_szn.csv
gdxdump ercot_data_20190401.gdx symb=hydro_nd  format=csv noHeader >> Set_hydro_nd.csv
gdxdump ercot_data_20190401.gdx symb=dayhours  format=csv noHeader >> Set_dayhours.csv
gdxdump ercot_data_20190401.gdx symb=r_rto  format=csv noHeader >> Set_r_rto.csv
gdxdump ercot_data_20190401.gdx symb=inertia  format=csv noHeader >> Set_inertia.csv
gdxdump ercot_data_20190401.gdx symb=rsc_agg  format=csv noHeader >> Set_rsc_agg.csv
gdxdump ercot_data_20190401.gdx symb=tranfeas  format=csv noHeader >> Set_tranfeas.csv
gdxdump ercot_data_20190401.gdx symb=vc  format=csv noHeader >> Set_vc.csv
gdxdump ercot_data_20190401.gdx symb=e  format=csv noHeader >> Set_e.csv
gdxdump ercot_data_20190401.gdx symb=AB32_r  format=csv noHeader >> Set_AB32_r.csv
gdxdump ercot_data_20190401.gdx symb=cofire  format=csv noHeader >> Set_cofire.csv
gdxdump ercot_data_20190401.gdx symb=RPSCat  format=csv noHeader >> Set_RPSCat.csv
gdxdump ercot_data_20190401.gdx symb=st  format=csv noHeader >> Set_st.csv
gdxdump ercot_data_20190401.gdx symb=r_st  format=csv noHeader >> Set_r_st.csv
gdxdump ercot_data_20190401.gdx symb=re  format=csv noHeader >> Set_re.csv
gdxdump ercot_data_20190401.gdx symb=cendiv  format=csv noHeader >> Set_cendiv.csv
gdxdump ercot_data_20190401.gdx symb=gb  format=csv noHeader >> Set_gb.csv
gdxdump ercot_data_20190401.gdx symb=gas  format=csv noHeader >> Set_gas.csv
gdxdump ercot_data_20190401.gdx symb=r_cendiv  format=csv noHeader >> Set_r_cendiv.csv
gdxdump ercot_data_20190401.gdx symb=gps  format=csv noHeader >> Set_gps.csv
gdxdump ercot_data_20190401.gdx symb=fuelbin  format=csv noHeader >> Set_fuelbin.csv
gdxdump ercot_data_20190401.gdx symb=bioclass  format=csv noHeader >> Set_bioclass.csv
gdxdump ercot_data_20190401.gdx symb=cofire  format=csv noHeader >> Set_cofire.csv
gdxdump ercot_data_20190401.gdx symb=nexth  format=csv noHeader >> Set_nexth.csv
gdxdump ercot_data_20190401.gdx symb=r_country  format=csv noHeader >> Set_r_country.csv
gdxdump ercot_data_20190401.gdx symb=country  format=csv noHeader >> Set_country.csv
gdxdump ercot_data_20190401.gdx symb=rscfeas  format=csv noHeader >> Set_rscfeas.csv
gdxdump ercot_data_20190401.gdx symb=vc  format=csv noHeader >> Set_vc.csv


# Dump Parameters
gdxdump ercot_data_20190401.gdx symb=m_capacity_exog format=csv noHeader >> Parm_m_capacity_exog.csv
gdxdump ercot_data_20190401.gdx symb=retireyear format=csv noHeader >> Parm_retireyear.csv
gdxdump ercot_data_20190401.gdx symb=retiretech format=csv noHeader >> Parm_retiretech.csv
gdxdump ercot_data_20190401.gdx symb=degrade format=csv noHeader >> Parm_degrade.csv
gdxdump ercot_data_20190401.gdx symb=maxage format=csv noHeader >> Parm_maxage.csv
gdxdump ercot_data_20190401.gdx symb=r_rs format=csv noHeader >> Parm_r_rs.csv
gdxdump ercot_data_20190401.gdx symb=hours  format=csv noHeader >> Parm_hours.csv
gdxdump ercot_data_20190401.gdx symb=m_required_prescriptions format=csv noHeader >> Param_m_required_prescriptions.csv
gdxdump ercot_data_20190401.gdx symb=firstyear_pcat format=csv noHeader >> Param_firstyear_pcat.csv
gdxdump ercot_data_20190401.gdx symb=near_term_cap_limits format=csv noHeader >> Param_near_term_cap_limits.csv
gdxdump ercot_data_20190401.gdx symb=m_avail_retire_exog_rsc format=csv noHeader >> Param_m_avail_retire_exog_rsc.csv
gdxdump ercot_data_20190401.gdx symb=growth_limit_relative format=csv noHeader >> Param_growth_limit_relative.csv
gdxdump ercot_data_20190401.gdx symb=inertia_req  format=csv noHeader >> Param_inertia_req.csv
gdxdump ercot_data_20190401.gdx symb=m_rsc_dat  format=csv noHeader >> Param_m_rsc_dat.csv
gdxdump ercot_data_20190401.gdx symb=resourcescaler  format=csv noHeader >> Param_resourcescaler.csv
gdxdump ercot_data_20190401.gdx symb=m_cv_mar  format=csv noHeader >> Param_m_cv_mar.csv
gdxdump ercot_data_20190401.gdx symb=cf_hyd_szn_adj  format=csv noHeader >> Param_cf_hyd_szn_adj.csv
gdxdump ercot_data_20190401.gdx symb=prm  format=csv noHeader >> Param_prm.csv
gdxdump ercot_data_20190401.gdx symb=trancap_exog  format=csv noHeader >> Param_trancap_exog.csv
gdxdump ercot_data_20190401.gdx symb=INr  format=csv noHeader >> Param_INr.csv
gdxdump ercot_data_20190401.gdx symb=futuretran  format=csv noHeader >> Param_futuretran.csv
gdxdump ercot_data_20190401.gdx symb=trancost  format=csv noHeader >> Param_trancost.csv
gdxdump ercot_data_20190401.gdx symb=batterymandate  format=csv noHeader >> Param_batterymandate.csv
gdxdump ercot_data_20190401.gdx symb=emit_rate_limit  format=csv noHeader >> Param_emit_rate_limit.csv
gdxdump ercot_data_20190401.gdx symb=emit_rate  format=csv noHeader >> Param_emit_rate.csv
gdxdump ercot_data_20190401.gdx symb=RGGI_r  format=csv noHeader >> Param_RGGI_r.csv
gdxdump ercot_data_20190401.gdx symb=AB32Cap  format=csv noHeader >> Param_AB32Cap.csv
gdxdump ercot_data_20190401.gdx symb=offshore_cap_req  format=csv noHeader >> Param_offshore_cap_req.csv
gdxdump ercot_data_20190401.gdx symb=national_rps_frac  format=csv noHeader >> Param_national_rps_frac.csv
gdxdump ercot_data_20190401.gdx symb=RecMap  format=csv noHeader >> Param_RecMap.csv
gdxdump ercot_data_20190401.gdx symb=RecTech  format=csv noHeader >> Param_RecTech.csv
gdxdump ercot_data_20190401.gdx symb=heat_rate  format=csv noHeader >> Param_heat_rate.csv
gdxdump ercot_data_20190401.gdx symb=gaslimit  format=csv noHeader >> Param_gaslimit.csv
gdxdump ercot_data_20190401.gdx symb=gasbinwidth_regional  format=csv noHeader >> Param_Gasbinwidth_regional.csv
gdxdump ercot_data_20190401.gdx symb=Gasbinwidth_national  format=csv noHeader >> Param_Gasbinwidth_national.csv
gdxdump ercot_data_20190401.gdx symb=gasused  format=csv noHeader >> Param_gasused.csv
gdxdump ercot_data_20190401.gdx symb=gaslimit_nat  format=csv noHeader >> Param_gaslimit_nat.csv
gdxdump ercot_data_20190401.gdx symb=numdays  format=csv noHeader >> Param_numdays.csv
gdxdump ercot_data_20190401.gdx symb=storage_eff  format=csv noHeader >> Param_storage_eff.csv
gdxdump ercot_data_20190401.gdx symb=storage_duration  format=csv noHeader >> Param_storage_duration.csv
gdxdump ercot_data_20190401.gdx symb=cost_cap_fin_mult  format=csv noHeader >> Param_cost_cap_fin_mult.csv
gdxdump ercot_data_20190401.gdx symb=biosupply  format=csv noHeader >> Param_biosupply.csv
gdxdump ercot_data_20190401.gdx symb=CSP_SM  format=csv noHeader >> Param_CSP_SM.csv
gdxdump ercot_data_20190401.gdx symb=cost_cap  format=csv noHeader >> Param_cost_cap.csv
gdxdump ercot_data_20190401.gdx symb=CRF_PTC  format=csv noHeader >> Param_CRF_PTC.csv
gdxdump ercot_data_20190401.gdx symb=PTC  format=csv noHeader >> Param_PTC.csv
gdxdump ercot_data_20190401.gdx symb=m_rscfeas  format=csv noHeader >> Param_m_rscfeas.csv
gdxdump ercot_data_20190401.gdx symb=tranfeas  format=csv noHeader >> Param_tranfeas.csv
gdxdump ercot_data_20190401.gdx symb=trancost  format=csv noHeader >> Param_trancost.csv
gdxdump ercot_data_20190401.gdx symb=pvf_onm  format=csv noHeader >> Param_pvf_onm.csv
gdxdump ercot_data_20190401.gdx symb=cost_vom  format=csv noHeader >> Param_cost_vom.csv
gdxdump ercot_data_20190401.gdx symb=cost_fom  format=csv noHeader >> Param_cost_fom.csv
gdxdump ercot_data_20190401.gdx symb=cost_opres  format=csv noHeader >> Param_cost_opres.csv
gdxdump ercot_data_20190401.gdx symb=heat_rate  format=csv noHeader >> Param_heat_rate.csv
gdxdump ercot_data_20190401.gdx symb=fuel_price  format=csv noHeader >> Param_fuel_price.csv
gdxdump ercot_data_20190401.gdx symb=gasprice  format=csv noHeader >> Param_gasprice.csv
gdxdump ercot_data_20190401.gdx symb=gasadder_cd  format=csv noHeader >> Param_gasadder_cd.csv
gdxdump ercot_data_20190401.gdx symb=gasprice_nat_bin  format=csv noHeader >> Param_gasprice_nat_bin.csv
gdxdump ercot_data_20190401.gdx symb=gasmultterm  format=csv noHeader >> Param_gasmultterm.csv
gdxdump ercot_data_20190401.gdx symb=szn_adj_gas  format=csv noHeader >> Param_szn_adj_gas.csv
gdxdump ercot_data_20190401.gdx symb=cendiv_weights  format=csv noHeader >> Param_cendiv_weights.csv
gdxdump ercot_data_20190401.gdx symb=gasbinp_regional  format=csv noHeader >> Param_gasbinp_regional.csv
gdxdump ercot_data_20190401.gdx symb=gasbinp_national  format=csv noHeader >> Param_gasbinp_national.csv
gdxdump ercot_data_20190401.gdx symb=biopricemult  format=csv noHeader >> Param_biopricemult.csv
gdxdump ercot_data_20190401.gdx symb=biosupply  format=csv noHeader >> Param_biosupply.csv
gdxdump ercot_data_20190401.gdx symb=hurdle  format=csv noHeader >> Param_hurdle.csv
gdxdump ercot_data_20190401.gdx symb=emit_tax  format=csv noHeader >> Param_emit_tax.csv
gdxdump ercot_data_20190401.gdx symb=acp_price  format=csv noHeader >> Param_acp_price.csv
gdxdump ercot_data_20190401.gdx symb=InterTransCost  format=csv noHeader >> Param_InterTransCost.csv
gdxdump ercot_data_20190401.gdx symb=distance  format=csv noHeader >> Param_distance.csv
gdxdump ercot_data_20190401.gdx symb=reserve_frac format=csv noHeader >> Parm_reserve_frac.csv
gdxdump ercot_data_20190401.gdx symb=minloadfrac  format=csv noHeader >> Parm_minloadfrac.csv
gdxdump ercot_data_20190401.gdx symb=hours  format=csv noHeader >> Parm_hours.csv
gdxdump ercot_data_20190401.gdx symb=outage  format=csv noHeader >> Parm_outage.csv
gdxdump ercot_data_20190401.gdx symb=storage  format=csv noHeader >> Parm_storage.csv
gdxdump ercot_data_20190401.gdx symb=routes  format=csv noHeader >> Parm_routes.csv
gdxdump ercot_data_20190401.gdx symb=tranloss  format=csv noHeader >> Parm_tranloss.csv
gdxdump ercot_data_20190401.gdx symb=opres_routes  format=csv noHeader >> Parm_opres_routes.csv
gdxdump ercot_data_20190401.gdx symb=orperc  format=csv noHeader >> Parm_orperc.csv
gdxdump ercot_data_20190401.gdx symb=r_rto  format=csv noHeader >> Parm_r_rto.csv
gdxdump ercot_data_20190401.gdx symb=cf_tech  format=csv noHeader >> Parm_cf_tech.csv

