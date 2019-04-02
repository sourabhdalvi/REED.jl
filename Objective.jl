# *============================
# * --- OBJECTIVE ---
# *============================
# -----------------------------------------------------------------------

cost_func = zero(JuMP.GenericAffExpr{Float64, JuMP.variable_type(model)});

# -----------------------------------------------------------------------
# *investment costs
SwM_PTC = 1;
TaxRate = 0.257;
Trans_Intercost = 200000;
cost_ =  sum([ sum([variables["INV"][i,c,r,t]* (param_cost_cap_fin_mult["$r"*"_"*"$i"*"_"*"$t"]*param_cost_cap["$i"*"_"*"$t"]  # Inv Cost
            
                    - (SwM_PTC *(1/param_CRF_PTC ) * (1/(1-TaxRate)))# PTC Cost

                    * sum([param_ptc["$country"*"_"*"$t"*"_"*"$i"] for country in set_country 
                            if (sum([1 for rr in set_r if in((rr,r),set_cap_agg) & in((r,country),set_r_country)]) > 0) ])

                    * sum([ param_hours["$h"]*(1- ( 0 + sum([ 0 for rr in set_r if in((rr,r),set_cap_agg) & in(i,set_vre) ]))) * param_m_cf["$i"*"_"*"$c"*"_"*"$r"*"_"*"$h"*"_"*"$t"] 
                        for h in set_h]) # missing curt_(mrg,avg)
                    )
                for i in set_i2, c in set_newc, r in set_r if in((i,c,r,t),set_valcap) ])

            + sum([ variables["INV_RSC"][i,c,r,rscbin,t]*param_m_rsc_dat["$r"*"_"*"$i"*"_"*"$rscbin"*"_cost"] 
                for i in set_rsc_i, c in set_newc, r in set_r, rscbin in set_rscbin 
                    if haskey(param_m_rscfeas,"$r"*"_"*"$i"*"_"*"$rscbin") & in((i,c,r,t),set_valcap)])

            + sum([ (param_cost_cap_fin_mult["$r"*"_"*"$i"*"_"*"$t"]*param_cost_cap["$i"*"_"*"$t"]
                
                    - (SwM_PTC *(1/param_CRF_PTC ) * (1/(1-TaxRate)))# PTC Cost
                
                    * sum([param_ptc["$country"*"_"*"$t"*"_"*"$i"] for country in set_country 
                            if (sum([1 for rr in set_r if in((rr,r),set_cap_agg) & in((r,country),set_r_country)]) > 0) ])
                    
                    * sum([ param_hours["$h"]*(1- ( 0 + sum([ 0 for rr in set_r if in((rr,r),set_cap_agg)  ]))) * param_m_cf["$i"*"_"*"$c"*"_"*"$r"*"_"*"$h"*"_"*"$t"] 
                        for h in set_h ]))*variables["InvRefurb"][i,c,r,t]  # missing curt_(mrg,avg)
                
                for i in set_refurbtech, c in set_c, r in set_r if in((i,c,t),set_ict)])
        
# *costs of transmission lines
            + sum([ ((param_intertranscost["$r"]+param_intertranscost["$rr"])/2) * variables["InvTran"][r,rr,t,trtype] * param_distance["$r"*"_"*"$rr"]
                for r in set_rfeas, rr in set_rfeas, trtypr in set_trtypr if in((r,rr,trtype,t),set_routes) ])
        
# *costs of substations
            + sum([ param_trancost["$r"*"_cost_"*"$vc"]*variables["InvSubstation"][r,vc,t] for r in set_rfeas, vc in set_vc if in((r,vc),set_tranfeas) ])
        
# *cost of back-to-back AC-DC-AC interties
            + sum([ Trans_Intercost*variables["InvTran"][r,rr,t,"DC"] for r in set_rfeas, rr in set_rfeas 
                    if in((r,rr,"DC",t),set_routes) & t >2020 & (param_INr["$r"] != param_INr["$rr"] ) ])
        
        for t in set_t ])



JuMP.add_to_expression!(cost_func,cost_)

# -----------------------------------------------------------------------
# *===============
# *beginning of operational costs (hence pvf_onm and not pvf_capital)
# *===============

cost_scale = 1;
bio_cofire_perc =0.15;
cost_ = sum([ (
# *variable O&M costs
            sum([param_cost_vom["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t]  
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h if in((i,c,r,t), set_valcap)])
# *fixed O&M costs
            + sum([param_cost_fom["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"] *variables["CAP"][i,c,r,t]  
                    for i in set_i2, c in set_c, r in set_r if in((i,c,r,t), set_valcap) ])
            
            
# *operating reserve costs
            +sum([ param_hours["$h"]*param_cost_opres["$i"]*variables["OPRES"][ortype,i,c,r,h,t]  
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h, ortype in set_ortype 
                        if in((i,c,r,t), set_valcap) & haskey(param_cost_opres,"$i") $ (ortype =="reg")])
            
# *cost of coal and nuclear fuel (except coal used for cofiring)
            + sum([ param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*param_hours["$h"]
                    *param_fuel_price["$i"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h 
                        if in((i,c,r,t), set_valcap) & !in(i,set_gas) & (i!="biopower") & !in(i,set_cofire) 
                                & haskey(param_heat_rate,"$i"*"_"*"$c"*"_"*"$r"*"_"*"$t")])
            
# *cofire coal consumption - cofire bio consumption already accounted for in accounting of BIOUSED
            +sum([ (1-bio_cofire_perc)*param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]
                    *param_fuel_price["coal-new_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h 
                        if in((i,c,r,t), set_valcap) & in(i,set_cofire) & haskey(param_heat_rate,"$i"*"_"*"$c"*"_"*"$r"*"_"*"$t")  ])
            
# *cost of natural gas for SwM_GasCurve = 2 (static natural gas prices)          
            +sum([ param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]
                    *param_fuel_price["$i"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h 
                        if in((i,c,r,t), set_valcap) & in(i,set_gas) & haskey(param_heat_rate,"$i"*"_"*"$c"*"_"*"$r"*"_"*"$t") 
                            & (i!="biopower") & !in(i,set_cofire)  ])
            
# *cost of natural gas for SwM_GasCurve = 0 (census division supply curves natural gas prices)
            +sum([ sum([ param_hours["$h"]*variables["GasUsed"][cendiv,gb,h,t]  for h in set_h ])
                    *sum([ param_gasprice["$cendiv"*"_"*"$gb"*"_"*"$t"*"_"*"$gps"] for gps in set_gps if gps=="REF"])
                    for cendiv in set_cendiv, gb in set_gb if (cendiv ="WSC") ])
            
# *cost of natural gas for SwM_GasCurve = 3 (national supply curve for natural gas prices with census division multipliers)
            + sum([ param_hours["$h"]*variables["GasUsed"][cendiv,gb,h,t]
                    *sum([ (param_gasadder_cd["$cendiv"*"_"*"$t"*"_"*"$h"*"_"*"$gps"] + param_gasprice_nat_bin["$gb"*"_"*"$t"*"_"*"$gps"]) for gps in set_gps if gps=="REF"])
                    for h in set_h, cendiv in set_cendiv, gb in set_gb if (cendiv ="WSC")])
            
# *cost of natural gas for SwM_GasCurve = 1 (national and census division supply curves for natural gas prices)
# *first - anticipated costs of gas consumption given last year's amount
            + sum([ param_gasmultterm["$cendiv"*"_"*"$t"]* param_szn_adj_gas["$h"] * param_cendiv_weights["$r"*"_"*"$cendiv"]
                    param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i2, r in set_rfeas, c in set_c, cendiv in set_cendiv, h in set_h 
                        if in((i,c,r,t), set_valcap) & in(i,set_gas) & (cendiv ="WSC") ])
            
# *second - adjustments based on changes from last year's consumption at the regional and national level
            + sum([ param_gasbinp_regional["$fuelbin"*"_"*"cendiv"*"_"*"$t"]*variables["Vgasbinq_regional"][fuelbin,cendiv,t]
                    for fuelbin in set_fuelbin, cendiv in set_cendiv if (cendiv ="WSC")])
            
            + sum([ param_gasbinp_national["$fuelbin"*"_"*"$t"]*variables["Vgasbinq_national"][fuelbin,t] for fuelbin in set_fuelbin])
            
# *biofuel consumption
            + sum([param_biopricemult["$r"*"_"*"$bioclass"*"_"*"$t"]*variables["BIOUSED"][bioclass,r,t] * param_biosupply["$r"*"_cost_"*"$bioclass"]  
                    for r in set_rfeas, bioclass in set_bioclass])
# *plus international hurdle costs
            + sum([param_hurdle["$r"*"_"*"$rr"]*variables["FLOW"][r,rr,h,t,trtype]* param_hours["$h"]
                    for r in set_rfeas, rr in set_rfeas, h in set_h, trtype in set_trtype 
                        if in((r,rr,trtype,t),set_routes) & haskey(param_hurdle,"$r"*"_"*"$rr")])
            
# *plus any taxes on emissions
            + sum([ variables["EMIT"][e,r,t]*param_emit_tax["$e"*"_"*"$r"*"_"*"$t"] for e in set_e, r in set_r])
            
# *plus ACP purchase costs
            + sum([ variables["ACP_Purchases"][RPSCat,st,t]*param_acp_price["$st"*"_"*"$t"] for RPSCat in set_RPSCat, st in set_st if (st=="TX")])
        )*cost_scale*param_pvf_onm["$t"] for t in set_t ])

JuMP.add_to_expression!(cost_func,cost_)

# -----------------------------------------------------------------------
