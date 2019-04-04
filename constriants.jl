# *=========================
# * --- LOAD CONSTRAINT ---
# *=========================
cons_name = "eq_loadcon"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_r,set_h,set_t])

for r in set_r, h in set_h, t in set_t
    constraints["$(cons_name)"][r, h, t] = JuMP.@constraint(model,
        variables["LOAD"][r, h, t]
        ==
        param_can_exports_h["$r"*"_"*"$h"*"_"*"$t"]
        + param_lmnt["$r"*"_"*"$h"*"_"*"$t"]
    )
end

# -----------------------------------------------------------------------

# *====================================
# * -- existing capacity equations --
# *====================================

cons_name = "eq_cap_init_noret"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)
# eq_cap_init_noret
for i in set_i2, c in set_c, r in set_r, t in set_t
    if in(c,set_initc) & (t in set_yeart) & (t <= set_retireyear[1]) &  in((i,c,r,t),set_valcap) # t in set_tmodel, 
        
        constraints["$(cons_name)"][i, c, r, t] = JuMP.@constraint(model, 
            variables["CAP"][i, c, r, t] == param_exo_cap["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_cap_init_retub"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)
# eq_cap_init_retub
for i in set_i2, c in set_c, r in set_r, t in set_t
    if in(c,set_initc) & (t in set_yeart) & (t >= set_retireyear[1]) & in((i,c,r,t),set_retiretech) & in((i,c,r,t),set_valcap)# t in set_tmodel
        
        constraints["$(cons_name)"][i, c, r, t] = JuMP.@constraint(model, 
            variables["CAP"][i, c, r, t] <= param_exo_cap["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"] 
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_cap_init_retmo"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)
# eq_cap_init_retmo
for i in set_i2, c in set_c, r in set_r, t in set_t
    if in(c,set_initc) & in(t,set_yeart) & (t >= set_retireyear[1]) & in((i,c,r,t),set_retiretech) & in((i,c,r,t),set_valcap)
        & haskey(param_exo_cap,"$i"*"_"*"$c"*"_"*"$r"*"_"*"$t") & in(t-2,set_yeart)
        
        constraints["$(cons_name)"][i, c, r, t] = JuMP.@constraint(model, 
            variables["CAP"][i, c, r, t] <= variables["CAP"][i, c, r, t-2] 
        )
    end
end

# *==============================
# * -- new capacity equations --
# *==============================

cons_name = "eq_cap_new_noret"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)

# eq_cap_new_noret
for i in set_i2, c in set_c, r in set_r, t in set_t
    if ((t <= set_retireyear[1]) | !in((i,c,r,t),set_retiretech)) & in(c,set_initc) & in((i,c,r,t),set_valcap)
        constraints["$(cons_name)"][i,c,r,t] = 
            #LHS
            JuMP.@constraint(model, variables["CAP"][i,c,r,t] ==  
            #RHS
            sum([param_degrade["$i"*"_"*"$t"*"_"*"$tt"]*variables["INV"][i,c,r,t] 
                    for tt in set_t if (tt <= t) & in((i,c,t,tt),set_inv_cond) & in((i,c,r,t),set_valcap)])  # tfix
            
            + sum([param_degrade["$i"*"_"*"$t"*"_"*"$tt"]*variables["INVREFURB"][i,c,r,t] 
                for tt in set_t if (tt <= t) & (t-tt < param_maxage[i]) & in((i,c,t),set_ict) & in(i,set_refurbtech) ]) # tfix, SwM_Refurb 
        )
    end
end

# -----------------------------------------------------------------------

# eq_cap_new_retub
cons_name = "eq_cap_new_retub"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)
for i in set_i2, c in set_c, r in set_r, t in set_t
    if (t >= set_retireyear[1]) & in(c,set_initc) &  in((i,c,r,t),set_retiretech) & in((i,c,r,t),set_valcap)
        constraints["$(cons_name)"][i,c,r,t] = JuMP.@constraint(model, 
            #LHS
            variables["CAP"][i,c,r,t] 
            <=  
            #RHS
            sum([param_degrade["$i"*"_"*"$t"*"_"*"$tt"]*variables["INV"][i,c,r,t] 
                for tt in set_t if (tt <= t) & in((i,c,t,tt),set_inv_cond) & in((i,c,r,t),set_valcap) ])  # tfix,
            
            + sum([param_degrade["$i"*"_"*"$t"*"_"*"$tt"]*variables["INVREFURB"][i,c,r,t] 
                for tt in set_t if (tt <= t) & (t-tt < param_maxage[i]) & in((i,c,t),set_ict) & in((i,c,r,t),set_valcap)]) # tfix, SwM_Refurb
            )
    end
end

# -----------------------------------------------------------------------

# eq_cap_new_retmo
cons_name = "eq_cap_new_retmo"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_t)
for i in set_i2, c in set_c, r in set_r, t in set_t
    if (t >= set_retireyear[1]) & in(c,set_initc) & in(t-1,set_yeart) & in((i,c,r,t),set_retiretech) & in((i,c,r,t),set_valcap)
        constraints["$(cons_name)"][i,c,r,t] = 
            #LHS
            JuMP.@constraint(model, variables["CAP"][i,c,r,t] <=  
            #RHS
            sum([param_degrade["$i"*"_"*"$t"*"_"*"$tt"]*variables["CAP"][i,c,r,tt] for tt in set_t if (tt-1) == t]) 
            
            + in((i,c,t,tt),set_inv_cond) ? variables["INV"][i,c,r,t] : 0 # mistake in GAMS ??
            
            + in((i,c,t),set_ict) ? variables["INVREFURB"][i,c,r,t] : 0
            
            ) 
    end
end

# -----------------------------------------------------------------------


# eq_forceprescription
cons_name = "eq_forceprescription"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_pcat,set_r,set_t)



for pcat in set_pcat,  r in set_r, t in set_t
     if in(r,set_rfeas_cap) & in(pcat,set_force_pcat) 
        & (sum([ 1 for i in set_i2, c in set_newc if in((pcat,i),set_prescriptivelink) & in((i,c,r,t),set_valcap) ]) > 0) 
        
        constraints["$(cons_name)"][pcat, r, t] = JuMP.@constraint(model,
        # LHS
        sum([ param_m_required_prescriptions["$pcat"*"_"*"$r"*"_"*"$tt"] for tt in set_t if tt <= t] ) 
            + (t >=  param_firstyear_pcat[pcat]) ? variables["EXTRA_PRESCRIP"][pcat, r, t] : 0 
            ==
        # RHS
        sum([param_degrade["$i"*"_"*"$tt"*"_"*"$t"]*variables["INV"][i,c, r, tt] 
                    for i in set_i2, c in set_newc, tt in set_t if (tt <= t) & in((i, c, t, tt),set_inv_cond) 
                            & in((pcat,i),set_prescriptivelink) & in((i,c,r,t),set_valcap) ]) 
            
        + sum([param_degrade["$i"*"_"*"$tt"*"_"*"$t"]*variables["INVREFURB"][i,c, r, tt] 
                    for i in set_i2, c in set_newc, tt in set_t if (tt <= t) & (t-tt < param_maxage[i]) & in((pcat,i),set_prescriptivelink)
                        & in(i,set_refurbtech) & in((i ,c , t),set_ict) ]) 
        )
    end
end

# -----------------------------------------------------------------------

# eq_neartermcaplimit
cons_name = "eq_neartermcaplimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_r,set_t)
for t in set_t, r in set_r 
    if in(r,set_rfeas_cap) & (sum([1 for rr in set_r if haskey(param_near_term_cap_limits,"Wind"*"_"*"$r"*"_"*"$t")]) > 0 ) 
        & (sum([ 1 for i in set_i2, c in set_c if in((i,c,r,t),set_valcap) &  in(("Wind",i), set_tg_i)]) > 0) # $SwM_NearTermLimits
        constraints["$(cons_name)"][r, t] = JuMP.@constraint(model,
        #LHS
        param_near_term_cap_limits["Wind"*"_"*"$r"*"_"*"$t"] >=
        #RHS
        variables["EXTRA_PRESCRIP"]["wind-ons", r, t]
        )  
    end
end

# -----------------------------------------------------------------------

#eq_refurblim
cons_name = "eq_refurblim"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_r,set_t)


for i in set_i2,  r in set_r,  t in set_t
    if in(r,set_rfeas_cap) & in(i,set_refurbtech) # $SwM_Refurb
        constraints["$(cons_name)"][i, r, t] = JuMP.@constraint(model, 
        #LHS
        sum([ variables["INV"][i, c, r, tt] for c in set_newc, tt in set_t 
            if in((i,c,r,tt),set_m_refurb_cond) & in((i,c,r,t),set_valcap) ])
            
        + sum([ param_m_avail_retire_exog_rsc["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"] for c in set_c, tt in set_t if tt <= t ])
        >=
        #RHS
        sum([ variables["INVREFURB"][i, c, r, tt] for tt in set_t 
                        if (tt <= t) & (t - tt < maxage_dict[i]) & in((i ,c , t),set_ict) ]) 
        )                    
    end
end

# -----------------------------------------------------------------------

# eq_rsc_inv_account 
cons_name = "eq_rsc_inv_account"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_newc,set_r,set_t)
for i in set_i2, c in set_newc, r in set_r, t in set_t
    if in(i,set_rsc_i) & in((i,c,r,t),set_valcap)  
       constraints["$(cons_name)"][i, c, r, t] = JuMP.@constraint(model,
            #LHS
            sum([ variables["INV_RSC"][i, c, r, t] for rscbin in set_rscbin if haskey(param_m_rscfeas,"$r"*"_"*"$i"*"_"*"$rscbin") ])
            ==
            #RHS
            variables["INV"][i, c, r, t] )
    end
end

# -----------------------------------------------------------------------

# eq_rsc_INVlim
cons_name = "eq_rsc_INVlim"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_rfeas_cap,set_rscbin)
for i in set_i2, r in set_rfeas_cap, rscbin in set_rscbin
    if in(i,set_rsc_i) & haskey(param_m_rscfeas,"$r"*"_"*"$i"*"_"*"$rscbin")
        constraints["$(cons_name)"][i, c, r, t] = JuMP.@constraint(model,
            param_m_rsc_dat["$r"*"_"*"$i"*"_"*"$rscbin"*"_cap"]
            >=
            sum([ variables["INV_RSC"][i, c, r, t] for ii in set_i2, c in set_newc, tt in set_t 
                if in((i,c,r,t),set_valcap) & in((i,ii),set_rsc_agg) & haskey(param_resourcescaler,"ii") ]) # tmodel(tt) or tfix(tt)
        )
    end
end

# -----------------------------------------------------------------------

# eq_growthlimit_relative
cons_name = "eq_growthlimit_relative"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_tg,set_t)

for tg in set_tg, t in set_t
    if (t >= 2020) & !(t==set_t[end]) & param_growth_limit_relative[tg] &
        constraints["$(cons_name)"][tg,t] = JuMP.@constraint(model,
            param_growth_limit_relative[tg]*(sum([tt for tt in set_t if (tt == t-1)]) - t ) # why ?
            *sum([variables["CAP"][i,c,r,tt] for i in set_i2,c in set_c r in set_rfeas_cap, tt in set_t if in(i,set_tg_i) & in((i,c,r,t),set_valcap) ])
            >=
            sum([variables["CAP"][i,c,r,t] for i in set_i2,c in set_c, r in set_rfeas_cap if in(i,set_tg_i) & in((i,c,r,t),set_valcap) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_growthlimit_absolute"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_t,set_tg)

for t in set_t, tg in set_tg
    if (t >= 2018) & !(t==set_t[end]) & haskey(param_growth_limit_relative,tg)
        constraints["$(cons_name)"][t,tg] = JuMP.@constraint(model,
            param_growth_limit_relative["$tg"]*(sum([ tt for tt in set_t if (tt == t-2)]) - t)
            >=
            sum([ variables["INV_RSC"][i,c, r, t, rscbin] for i in set_i2, c in set_c, r in set_rfeas_cap, rscbin in set_rscbin 
                        if in((tg,i),set_tg_i) & in((i, c, t, tt),set_inv_cond) & (param_m_rscfeas["$r"*"_"*"$i"*"_"*"$rscbin"] > 0 )]) 
        )
    end
end

# -----------------------------------------------------------------------

# eq_capacity_limit
cons_name = "eq_capacity_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_r,set_h,set_t,
                                                                                        )
for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in(r,set_rfeas_cap) & in((i,c,r,t),set_valcap) & !(in(i,set_storage)) & !(in(i,set_hydro_d)) 
        constraints["$(cons_name)"][i,c,r,h, t] = JuMP.@constraint(model,
            param_outage[i,h] * sum([variables["CAP"][i,c,rr,t] for rr in set_r 
                        if in((r,rr),set_cap_agg) & in((i,c,r,t),set_valcap) & !haskey(param_cf_tech,i) ])
            
            + sum([param_m_cf["$i"*"_"*"$c"*"_"*"$rr"*"_"*"h"*"_"*"t"]*variables["CAP"][i,c,rr,t]  
                    for rr in set_r if in((r,rr),set_cap_agg) & in(rr,set_rfeas_cap) & in((i,c,r,t),set_valcap) & haskey(param_cf_tech,i) ])
            >=
            variables["GEN"][i,c,rr,h,t]
            
            + sum([variables["OPRES"][or,i,c,rr,h,t] for or in ortypes if haskey(param_reserve_frac,"$i"*"_"*"$or")]) # $SwM_OpRes
        )
    end
end

# -----------------------------------------------------------------------

# eq_curt_gen_balance
cons_name = "eq_curt_gen_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rfeas_cap,set_h,set_t)
for r in set_rfeas_cap , h in set_h, t in set_t
    constraints["$(cons_name)"][r, h, t] = JuMP.@constraint(model,
        
        sum([param_m_cf["$i"*"_"*"$c"*"_"*"$rr"*"_"*"h"*"_"*"t"]*variables["CAP"][i ,c ,rr ,t] 
                for i in set_vre, c in set_c, rr in set_rfeas_cap if ((r,rr) in set_cap_agg) & in((i,c,r,t),set_valcap)]) 
        - variables["CURT"][r,h,t]
        >=
        sum([variables["GEN"][i,c,r,h,t] for i in set_vre, c in set_c if in((i,c,r,t),set_valcap) ])  
        + sum([ variables["OPRES"][or,i,c,r,h,t] for or in ortypes,i in set_vre, c in set_c 
                    if haskey(param_reserve_frac,"$i"*"_"*"$or") & in((i,c,r,t),set_valcap) ]) #$SwM_OpRes,
    )
end 

# -----------------------------------------------------------------------

cons_name = "eq_curtailment"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_r,set_h,set_t)
for t in set_t, r in set_rfeas_cap , h in set_h

    constraints["$(cons_name)"][r, h, t] = JuMP.@constraint(model,
        variables["CURT"][r,h,t]
        >=
        sum([param_m_cf["$i"*"_"*"$c"*"_"*"$rr"*"_"*"h"*"_"*"t"]*variables["CAP"][i,c,rr,t]*0 # curt_avg(r,h,t)
                for i in set_vre, c in set_c, rr in set_rfeas_cap if in((r,rr),set_cap_agg) & in((i,c,rr,t),set_valcap) ]) 

        + sum([param_m_cf["$i"*"_"*"$c"*"_"*"$rr"*"_"*"h"*"_"*"t"]*variables["INV"][i,c,r,t]*0 #  curt_marg(i,rr,h,t)
                for i in set_vre, c in set_c, rr in set_rfeas_cap if in((r,rr),set_cap_agg) & in((i,c, t, t),set_inv_cond) & in((i,c,rr,t),set_valcap) ])

        + 0 #surpold(r,h,t)
        + sum([ variables["MINGEN"][r,szn,t] - variables["MINGEN"][r,szn,t-2] for (h,szn) in set_h_szn if (t-2 in set_t)]) * 0 # curt_mingen(r,h,t)
        - sum([ variables["STORAGE_IN"][i,c,r,h,t]*0 for i in set_i2, c for c in set_c if  in((i,c,rr,t),set_valcap) & in(i,set_storage)]) # curt_storage(i,r,h,t)
    )

end

# -----------------------------------------------------------------------

cons_name = "eq_mingen_lb"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rfeas_cap,set_h,set_szn,set_t)
for r in set_rfeas_cap, h in set_h, szn in set_szn, t in set_t
    if ((h,szn) in set_h_szn)
        constraints["$(cons_name)"][r,h,szn,t] = JuMP.@constraint(model,
            variables["MINGEN"][r,szn,t]
            >=
            sum([ variables["GEN"][i,c,r,h,t]* param_minloadfrac["$r"*"_"*"$i"*"_"*"$h"] for i in set_i, c in set_c 
                        if in((i,c,rr,t),set_valcap) & haskey(param_minloadfrac,"$r"*"_"*"$i"*"_"*"$h")]) 
            + 0 # geothermal
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_mingen_ub"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rfeas_cap,set_h,set_szn,set_t)

for r in set_rfeas_cap, h in set_h, szn in set_szn, t in set_t
    if ((h,szn) in set_h_szn)
        constraints["$(cons_name)"][r,h,szn,t] = JuMP.@constraint(model,
            variables["MINGEN"][r,szn,t]
            <=
            sum([ variables["GEN"][i,c,r,h,t] for i in set_i, c in set_c 
                        if in((i,c,rr,t),set_valcap) &  haskey(param_minloadfrac,"$r"*"_"*"$i"*"_"*"$h") ]) 
            + 0 # geothermal
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasct_gencon"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_rfeas_cap,set_t)
for i in set_i2, c in set_c, r in set_rfeas_cap, t in set_t
    if (i == "gas-ct" |i == "gas-ct-nsp") & in((i,c,rr,t),set_valcap)  #$SwM_GasCTGenCon
        constraints["$(cons_name)"][i,c,r,t] = JuMP.@constraint(model,
            # LHS
            sum([variables["GEN"][i,c,r,h,t]*hours_dict["$h"] for h in set_h ])
            <= 
            #RHS
            variables["CAP"][i,c,r,t]*8760*0.004 # gasCT_minCF
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_dhyd_dispatch"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_rfeas_cap,set_szn,set_t)
for i in set_i2, c in set_c, r in set_rfeas_cap, h in set_h, szn in set_szn, t in set_t
    if in((i,c,rr,t),set_valcap) & in(i,set_hydro_d) 
         constraints["$(cons_name)"][i,c,r,szn,t] = JuMP.@constraint(model,
            sum([ hours_dict["$h"]*outage_dict for h in set_h if ((h,szn) in set_h_szn) ])
            >= 
            sum([( variables["GEN"][i,c,r,h,t]+ sum([ variables["OPRES"][or,i,c,r,h,t] for or in ortypes if haskey(param_reserve_frac,"$i"*"_"*"$or")]))
                    for h in set_h if ((h,szn) in set_h_szn) ])
        )
    end
end

# -----------------------------------------------------------------------
# *===============================
# * --- SUPPLY DEMAND BALANCE ---
# *===============================

cons_name = "eq_supply_demand_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rfeas_cap,set_h,set_t)

for r in set_rfeas_cap, h in set_h, t in set_t 
     constraints["$(cons_name)"][r,h,t] = JuMP.@constraint(model,
        sum([ variables["GEN"][i,c,r,h,t] for i in set_i2, c in set_c if !in(i,set_storage) & in((i,c,rr,t),set_valcap) ]) 
        + 0 # geo
        + sum( [ (1-param_tranloss["$rr"*"_"*"$r"])* variables["FLOW"][rr,r,h,t,trtype] for rr in set_rfeas_cap, tr in set_trtype if  in((r,rr,tr,t)set_routes) ])
        
        - sum( [ variables["FLOW"][rr,r,h,t,trtype] for rr in set_rfeas_cap, tr in set_trtype if in((r,rr,tr,t)set_routes) ])
        
        + sum( [variables["STORAGE_OUT"][i,c,r,h,t] for i in set_storage, c in set_c if in((i,c,rr,t),set_valcap) ]) # SwM_Storage
        
        - sum( [variables["STORAGE_IN"][i,c,r,h,t] for i in set_storage, c in set_c if !in(i,set_csp_storage) & in((i,c,rr,t),set_valcap) ]) # SwM_Storage

        ==
        variables["LOAD"][r,h,t]
    )
end

# -----------------------------------------------------------------------
# *=======================================
# * --- MINIMUM LOADING CONSTRAINTS ---
# *=======================================
cons_name = "eq_minloading"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_i2,set_c,set_rfeas_cap,set_h,set_h,set_t)
for i in set_i2, c in set_c, r in set_rfeas_cap, h in set_h, hh in set_h, t in set_t 
    if haskey(param_minloadfrac,"$r"*"_"*"$i"*"_"*"$h") & in((i,c,rr,t),set_valcap)  & in((h,hh),set_hour_szn_group) 
        constraints["$(cons_name)"][i,c,r,h,hh,t] = JuMP.@constraint(model,
            variables["GEN"][i,c,r,h,t]
            >=
            variables["GEN"][i,c,r,hh,t] * param_minloadfrac["$r"*"_"*"$i"*"_"*"$hh"]
        )
    end
end

# # -----------------------------------------------------------------------
# *=======================================
# * --- OPERATING RESERVE CONSTRAINTS ---
# *=======================================
cons_name = "eq_ORCap"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_ortype,set_i2,set_c,set_rfeas_cap,set_h,set_t)

for or in ortype, i in set_i2, c in set_c, r in set_rfeas_cap, h in set_h, hh in set_h, t in set_t 
    if haskey(param_reserve_frac,"$i"*"_"*"$or") & !in(i,set_storage) & in((i,c,rr,t),set_valcap) & !in(i,set_hydro_d) #$SwM_OpRes
        constraints["$(cons_name)"][or,i,c,r,h,t] = JuMP.@constraint(model,
            param_reserve_frac["$i"*"_"*"$or"] * sum( [ variables["GEN"][i,c,r,hh,t] for hh in set_h, szn in set_szn 
                        if in((h,szn),set_h_szn) & in((r,hh,t,szn),set_maxload_szn) ]) #
            >=
            variables["OPRES"][or,i,c,r,h,t]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_OpRes_requirement"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_ortype,set_rfeas_cap,set_h,set_t])

for or in ortype, r in set_rfeas_cap, h in set_h, hh in set_h, t in set_t 
    constraints["$(cons_name)"][or,r,h,t] = JuMP.@constraint(model,
        sum([ variables["OPRES"][or,i,c,r,h,t] for i in set_i, c in set_c 
                    if in((i,c,rr,t),set_valcap) & (haskey(param_reserve_frac,"$i"*"_"*"$or") | in(i,set_storage) | in(i,set_hydro_d)) 
                        & !in(i,set_csp_storage) & !in(i,set_hydro_nd) ]) 
        + 0 # geo
        + sum([ (1-param_tranloss["$rr"*"_"*"$r"])*variables["OPRES_FLOW"][or,rr,r,h,t] for rr in set_rfeas_cap if  & in((r,rr,t),set_opres_routes) ])
        - sum( [ variables["OPRES_FLOW"][or,rr,r,h,t] for rr in set_rfeas_cap if in((r,rr,t),set_opres_routes) ])
        >=
         variables["LOAD"][or,rr,r,h,t] * param_orperc["$or"*"_or_load"]
        + param_orperc["$or"*"_or_wind"] * sum( [variables["GEN"][i,c,r,h,t] for i in set_wind, c in set_c if in((i,c,rr,t),set_valcap) ])
        + param_orperc["$or"*"_or_wind"] * sum( [variables["CAP"][i,c,r,t] for i in set_pv, c in set_c if in((i,c,rr,t),set_valcap) & in(h,set_dayhours) ]) 
    )
end     

# -----------------------------------------------------------------------

cons_name = "eq_inertia_requirement"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rto,set_h,set_t)

for rto in set_rto, h in set_h, t in set_t 
    if (sum([ 1 for r in set_rfeas_cap if in((r,rto),set_r_rto)]) > 0) # SwM_Inertia
        constraints["$(cons_name)"][rto,h,t] = JuMP.@constraint(model,
            sum([ variables["GEN"][i,c,r,h,t] for i in set_i2, c in set_c, r in set_r 
                    if !in(i,set_storage) & in((i,c,rr,t),set_valcap) & in(i,set_inertia) & in((r,rto),set_r_rto) ])
            + 0 # geothermal
            + sum([ variables["STORAGE_OUT"][i,c,r,h,t] for i in set_i2, c in set_c, r in set_r 
                        if in(i,set_storage) & in((i,c,rr,t),set_valcap) & in(i,set_inertia) & in((r,rto),set_r_rto) ])
            >=
            + param_inertia_req["$t"]
            *sum([ variables["LOAD"][r,h,t] 
                    + sum([ variables["STORAGE_IN"][i,c,r,h,t] 
                            for i in set_i2, c in set_c 
                                if in(i,set_storage) & in((i,c,rr,t),set_valcap) & !in(i,set_csp_storage) ])
                    
                    for r in set_r if in((r,rto),set_r_rto) ])
            )
    end
end
                                      
# # -----------------------------------------------------------------------
# *=================================
# * --- PLANNING RESERVE MARGIN ---
# *=================================
cons_name = "eq_PRMTRADELimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_rfeas_cap,set_rfeas_cap,set_szn,set_t)
for r in set_rfeas_cap, rr in set_rfeas_cap, szn in set_szn, t in set_t
    if (sum([ 1 for tr in set_trtype if in((r,rr,trtypes),set_routes)]) > 0) # SwM_ReserveMargin
        constraints["$(cons_name)"][or,r,h,t] = JuMP.@constraint(model,
            sum([ variables["CAPTRAN"][r,rr,tr,t] for tr in set_trtype if in((r,rr,trtypes),set_routes) ])
            >=
            variables["PRMTRADE"][r,rr,szn,t]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_reserve_margin"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_r,set_szn,set_t)

for r in set_rfeas_cap, szn in set_szn, t in set_t #SwM_ReserveMargin
    constraints["$(cons_name)"][r,szn,t] = JuMP.@constraint(model,
        sum([ variables["CAP"][i,c,r,t] for i in set_i2, c in set_c if in((i,c,r,t),set_valcap) & !in(i,set_rsc_i) & !in(i,set_storage)])
        + 0# geothermal
        + sum([ for i in set_i2, rr in set_rfeas_cap if (in(i,set_vre) | in(i,set_storage)) & in((r,rr),set_cap_agg) ]) # cv_old(i,rr,szn,t) set to zero ? why ?
        
        + sum( [ param_m_cv_mar["$i"*"_"*"$r"*"_"*"$szn"*"_"*"$t"]*variables["INV"][i,c,rr,t]  for i in set_i2, c in set_c, rr in set_rfeas_cap 
                    if in((r,rr),set_cap_agg) & (in(i,set_vre) | in(i,set_storage)) & in((i,c,r,t),set_valcap) & in((i,c,t),set_ict) & in((i,c,t,t),set_inv_cond) ])
        
        + sum([ param_exo_cap["distpv_"*"$c"*"_"*"$r"*"_"*"$t"] - param_exo_cap["distpv_"*"$c"*"_"*"$r"*"_"*"$(t-2)"]*param_m_cv_mar["distpv_"*"$r"*"_"*"$szn"*"_"*"$t"]
                for c in set_c if in(("distpv",c,r,t),set_valcap) & in((t-1),set_t) ])
        
        + sum([ variables["CAP"][i,c,rr,t] for i in set_i, c in set_c, r in set_rfeas_cap 
                    if (in(i,set_vre) | in(i,set_storage)) & in((i,c,r,t),set_valcap) & in((r,rr),set_cap_agg) ]) # cv_avg(i,rr,szn,t) set to zero ? why ?
        
        + sum([  variables["GEN"][i,c,r,"h3",t] for i in set_hydro_nd, c in set_c if in((i,c,r,t),set_valcap) ])
        
        + sum([ param_cf_hyd_szn_adj["$i"*"_"*"$szn"*"_"*"$r"]*variables["CAP"][i,c,r,t] for i in set_hydro_d, c in set_c if in((i,c,r,t),set_valcap) ])
        
        + sum([ (1-param_tranloss["$rr"*"_"*"$r"])* variables["PRMTRADE"][rr,r,szn,t] for rr in set_rfeas 
                        if (sum([ 1 for tr in set_trtype if in((rr,r,tr,t),set_routes)]) >0) ])
        
        - sum([ variables["PRMTRADE"][r,rr,szn,t] for rr in set_rfeas if (sum([ 1 for tr in set_trtype if in((r,rr,tr,t),set_routes)]) >0) ])
        
        >=
        (1+param_prm["$r"*"_"*"$t"]) * param_peakdem["$r"*"_"*"$szn"*"_"*"$t"] 
    )
end

# -----------------------------------------------------------------------
# *================================
# * --- TRANSMISSION CAPACITY  ---
# *================================
cons_name = "eq_CAPTRAN"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_rfeas,set_trtype,set_t)

for r in set_rfeas, rr in set_rfeas, trtype in set_trtype, t in set_t
    if in((r,rr,trtype,t),set_routes)
        constraints["$(cons_name)"][r,rr,trtype,t] = JuMP.@constraint(model,
            variables["CAPTRAN"][r,rr,trtype,t]
            ==
            param_trancap_exog["$r"*"_"*"$rr"*"_"*"$trtype"*"_"*"$t"]
            + sum([ variables["INVTRAN"][rr,r,tt,trtype] + variables["INVTRAN"][r,rr,tt,trtype] 
                    for tt in set_t if (tt <= t) & (tt > 2020) & (param_INr["$r"] == param_INr["$rr"]) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_prescribed_transmission"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_rfeas,set_trtype,set_t)

for r in set_rfeas, rr in set_rfeas, trtype in set_trtype, t in set_t
    if in((r,rr,trtype,t),set_routes) & (t<= 2020)
        constraints["$(cons_name)"][r,rr,trtype,t] = JuMP.@constraint(model,
            sum([ param_futuretran["$r"*"_"*"$rr"*"_possible_"*"$tt"*"_"*"$trtype"] + param_futuretran["$rr"*"_"*"$r"*"_possible_"*"$tt"*"_"*"$trtype"]
                    for tt in set_t if (tt <= t) ])
            >=
            sum([ variables["INVTRAN"][r,rr,tt,trtype] + variables["INVTRAN"][rr,r,tt,trtype] for tt in set_t if (tt <= t) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_SubStationAccounting"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_t)

for r in set_rfeas, t in set_t
    constraints["$(cons_name)"][r,t] = JuMP.@constraint(model,
        sum([ variables["INVSUBSTATION"][r,vc,t] for vc in set_vc if in((r,vc),set_tranfeas)])
        ==
        sum([variables["INVTRAN"][rr,r,t,"AC"] for rr in set_rfeas if in((rr,r,"AC",t),set_routes) ])
        +sum([variables["INVTRAN"][r,rr,t,"AC"] for rr in set_rfeas if in((r,rr,"AC",t),set_routes) ])
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_prescribed_transmission"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_vc)

for r in set_rfeas, vc in set_vc
    if in((r,vc),set_tranfeas)
        constraints["$(cons_name)"][r,vc] = JuMP.@constraint(model,
            param_trancost["$r"*"_"*"CAP"*"_"*"$vc"]
            >=
            sum([ variables["INVSUBSTATION"][r,vc,t]  for t in set_t ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_transmission_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_rfeas,set_h,set_t,set_trtype)

for r in set_rfeas, rr in set_rfeas, h in set_h, t in set_t, trtype in set_trtype
    if in((r,rr,trtype,t),set_routes) & in((rr,r,trtype,t),set_routes)
      constraints["$(cons_name)"][r,rr,h,t,trtype] = JuMP.@constraint(model,  
            variables["CAPTRAN"][r,rr,trtype,t]
            >=
            variables["FLOW"][r,rr,h,t,trtype]
            + sum( [ variables["OPRES_FLOW"][ortype,rr,h,t] for ortype in set_ortype if (trtype =="AC") & in((r,rr,t),set_opres_routes)])
        )
    end
end

# -----------------------------------------------------------------------
# *=========================
# * --- CARBON POLICIES ---
# *=========================
bio_cofire_perc =0.15;
cons_name = "eq_emit_accounting"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_e,set_rfeas,set_t)

for e in set_e,  r in set_rfeas, t in set_t
    constraints["$(cons_name)"][e,r,t] = JuMP.@constraint(model,  
        variables["EMIT"][e,r,t]
        ==
        sum([ variables["GEN"][i,c,r,h,t]*param_hours["$h"]*param_emit_rate["$e"*"_"*"$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"] 
                for i in set_i, c in set_c, h in set_h if in((i,c,r,t),set_valcap) & !in(i,set_cofire) ])
        
        + sum([ (1-bio_cofire_perc)*param_hours["$h"]*param_emit_rate["$e"*"_coal-new_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                for i in set_i, c in set_c, h in set_h if in((i,c,r,t),set_valcap) & in(i,set_cofire) ])
    )
end

# -----------------------------------------------------------------------
RGGI_start_yr =2012;
cons_name = "eq_RGGI_cap"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t)

for t in set_t
    if (t >= RGGI_start_yr)
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
           variables["RGGICap"][t] 
            >=
            sum([ variables["EMIT"]["CO2",r,t]  for r in set_rfeas if in(r,set_RGGI_r) ])
        )
    end
end


# -----------------------------------------------------------------------
AB32_start_yr = 2014;
AB32_Import_Emit = 0.334;
cons_name = "eq_AB32_cap"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t)

for t in set_t
    if (t >= AB32_start_yr)
         constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
            param_AB32Cap["$t"]
            >=
            sum([variables["EMIT"]["CO2",r,t] for r in set_rfeas if in(r,set_AB32_r)])
            + sum([ param_hours["$h"]*AB32_Import_Emit* variables["FLOW"][r,rr,h,t,trtype]
                    for h in set_h, r in set_rfeas, rr in set_rfeas, trtype in set_trtype if !in(r,set_AB32_r) & in(rr,set_AB32_r) & in((r,rr,trtype,t),set_routes) ])
        )
    end
end


# -----------------------------------------------------------------------

cons_name = "eq_batterymandate"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_rfeas,set_i2,set_t)

for r in set_rfeas, i in set_i2, t in set_t
    if (i=="battery")
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,
            sum([ variables["CAP"][i,c,r,t] for c in set_c if in((i,c,r,t),set_valcap) ])
            >=
            param_batterymandate["$r"*"_"*"$i"*"_"*"$t"]
        )
    end
end

# -----------------------------------------------------------------------
CarbPolicyStartyear = 2020;
cons_name = "eq_emit_rate_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_e,set_rfeas,set_t)

for e in set_e, r in set_rfeas, t in set_t
    if (t >= CarbPolicyStartyear)  #missing & param_emit_rate_con["$e"*"$r"*"_"*"$t"]
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,
            param_emit_rate_limit["$e"*"$r"*"_"*"$t"]*(
            sum([ param_hours["$h"]*variables["GEN"][i,c,r,h,t]  for i in set_i2, c in set_c, h in set_h 
                        if in((i,c,r,t),set_valcap) & !in(i,set_cofire)])
            
            + sum([ (1-bio_cofire_perc)*param_hours["$h"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i2, c in set_c, h in set_h if in((i,c,r,t),set_valcap) & in(i,set_cofire) ]))
            >=
            variables["EMIT"][e,r,t] 
        )
    end
end


# -----------------------------------------------------------------------
# *==========================
# * --- RPS CONSTRAINTS ---
# *==========================

cons_name = "eq_REC_Generation"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_RPSCat,set_i,set_st,set_t)

for rps in set_RPSCat, i in set_i, st in set_st, t in set_t
    if (st=="TX") & !(t==set_t[1]) & (t > 2016)
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,
            sum([ param_hours["$h"]*variables["GEN"][i,c,r,h,t] for c in set_c, r in set_rfeas, h in set_h 
                        if ((i,c,r,t),set_valcap) & in((rps,st,i,t),set_RecTech) & in((r,st),set_r_st) ])
            >=
            sum([ variables["RECS"][rps,i,st,ast,t] for ast in set_st if  in((i,rps,st,ast,t)set_RecMap)  & (ast=="TX")   ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_RPS_OFSWind"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_st,set_t)

for st in set_st, t in set_t
    if (st=="TX") & param_offshore_cap_req["$st"*"_"*"$t"]
        constraints["$(cons_name)"][st,t] = JuMP.@constraint(model,
            sum([ sum([ variables["CAP"][i,c,rr,t] for i in set_i2, c in set_c, rr in set_r if in((i,c,rr,t),set_valcap) ]) for r in set_r if in((r,st),set_r_st)])
            >=
            param_offshore_cap_req["$st"*"_"*"$t"]
        )
    end
end      

# -----------------------------------------------------------------------

cons_name = "eq_national_rps"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t)

for t in set_t
    if param_national_rps_frac["$t"] 
        constraints["$(cons_name)"][st,t] = JuMP.@constraint(model,
            sum([ variables["CAP"][i,c,r,h,t]* param_hours["$h"] for i in set_i2, c in set_c, r in set_r, h in set_h 
                        if in((i,c,rr,t),set_valcap) & in(i,set_re) ])
            + 0 #geothermal
            >=
            param_national_rps_frac["$t"]*(
            sum([ variables["LOAD"][r,h,t]*param_hours["$h"] for r in set_rfeas, h in set_h])
            + sum([ param_tranloss["$rr"*"_"*"$r"]*variables["FLOW"][rr,r,h,t,trtype]*param_hours["$h"] 
                        for rr in set_rfeas, r in set_rfeas, h in set_h, trtype in set_trtype if in((rr,r,trtype,t),set_routes)])
                
            + sum([ variables["STORAGE_IN"][i,c,r,h,t]*param_hours["$h"] 
                        for i in set_i, c in set_c, r in set_r, t in set_t if in((i,c,r,t),set_valcap) & in(i,set_storage) & !in(i,set_csp_storage) ]) 
                
            + sum([ variables["STORAGE_OUT"][i,c,r,h,t]*param_hours["$h"] 
                        for i in set_i, c in set_c, r in set_r, t in set_t if in((i,c,r,t),set_valcap) & in(i,set_storage) & !in(i,set_csp_storage) ])
            )
        )
    end
end

# -----------------------------------------------------------------------
# *====================================
# * --- FUEL SUPPLY CURVES ---
# *====================================

cons_name = "eq_gasused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_cendiv,set_h,set_t)

for cendiv in set_cendiv, h in set_h, t in set_t
    if (cendiv == "WSC")
        constraints["$(cons_name)"][cendiv,h,t] = JuMP.@constraint(model,
            sum([ variables["gasused"][cendiv,gb,h,t] for gb in set_gb ])
            ==
            sum([ param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                    for i in set_i, c in set_c, r in set_rfeas if in((i,c,r,t),set_valcap) & in(i,set_gas) &  in((r,cendiv),set_r_cendiv)])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_cendiv,set_gb,set_t)

for cendiv in set_cendiv, gb in set_gb, t in set_t
    if (cendiv == "WSC")
        constraints["$(cons_name)"][cendiv,gb,t] = JuMP.@constraint(model,
            sum([ param_gaslimit["$cendiv"*"_"*"$gb"*"_"*"$t"*"_"*"$gps"] for gps in set_gps if (gps=="REF")])
            >=
            sum([ param_hours["$h"]*variables["GASUSED"][cendiv,gb,h,t] for h in set_h])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_nat"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_gb,set_t)

for gb in set_gb, t in set_t
    constraints["$(cons_name)"][gb,t] = JuMP.@constraint(model,
        sum([ param_gaslimit_nat["$gb"*"_"*"$t"*"_"*"$gps"] for gps in set_gps if (gps=="REF") ])
        >=
        sum([ variables["GASUSED"][cendiv,gb,h,t]*param_hours["$h"] for h in set_h, cendiv in set_cendiv if (cendiv=="WSC") ])
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_gasaccounting_regional"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_cendiv,set_t)

for cendiv in set_cendiv, t in set_t
    if (cendiv =="WSC")
        constraints["$(cons_name)"][cendiv,t] = JuMP.@constraint(model,
            sum([ variables["Vgasbinq_regional"][fuelbin,cendiv,t] for fuelbin in set_fuelbin ])
            ==
            sum([ param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t]
                    for i in set_i2, c in set_c, r in set_rfeas, h in set_h if in((i,c,r,t),set_valcap) & in(i,set_gas) & in((r,cendiv),set_r_cendiv) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasaccounting_national"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t)

for t in set_t
    constraints["$(cons_name)"][t] = JuMP.@constraint(model,
        sum([ variables["Vgasbinq_national"][fuelbin,t] for fuelbin in set_fuelbin])
        == 
        sum([ param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t] 
                for i in set_i2, c in set_c, r in set_rfeas, h in set_h if in((i,c,r,t),set_valcap) & in(i,set_gas) ])
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_regional"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_fuelbin,set_cendiv,set_t)

for fuelbin in set_fuelbin, cendiv in set_cendiv, t in set_t
    if (cendiv =="WSC")
        constraints["$(cons_name)"][fuelbin,cendiv,t] = JuMP.@constraint(model,
            param_gasbinwidth_regional["$fuelbin"*"_"*"$cendiv"*"_"*"$t"]
            >=
            variables["Vgasbinq_regional"][fuelbin,cendiv,t]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_national"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_fuelbin,set_t)

for fuelbin in set_fuelbin, t in set_t
    constraints["$(cons_name)"][fuelbin,t] = JuMP.@constraint(model,
        param_gasbinwidth_national["$fuelbin"*"_"*"$t"]
        >=
        variables["Vgasbinq_national"][fuelbin,t]
    )
end

# -----------------------------------------------------------------------
# *===========
# * bio curve
# *===========

bio_cofire_perc=0.15;
cons_name = "eq_bioused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_r,set_t)

for r in set_rfeas, t in set_t
    constraints["$(cons_name)"][r,t] = JuMP.@constraint(model,
        sum([ variables["BIOUSED"][bioclass,r,t] for bioclass in set_bioclass])
        ==
        sum([ param_hours["$h"]*param_heat_rate["biopower_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"]["biopower",c,r,h,t]  
                for c in set_c, h in set_h if in(("biopower",c,r,t),set_valcap) ])
        
        + sum([ bio_cofire_perc*param_hours["$h"]*param_heat_rate["$i"*"_"*"$c"*"_"*"$r"*"_"*"$t"]*variables["GEN"][i,c,r,h,t]
                for i in set_i2, c in set_c, h in set_h if in(i,set_cofire) & in((i,c,r,t),set_valcap)])
        )
end
# -----------------------------------------------------------------------

cons_name = "eq_biousedlimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_bioclass,set_rfeas,set_t)

for bioclass in set_bioclass, r in set_rfeas, t in set_t
    constraints["$(cons_name)"][bioclass,r,t] = JuMP.@constraint(model,
        param_biosupply["$r"*"_CAP"*"_"*"$bioclass"]
        >=
        variables["BIOUSED"][bioclass,r,t]
    )
end

# -----------------------------------------------------------------------
# *============================
# * --- STORAGE CONSTRAINTS ---
# *============================

cons_name = "eq_storage_capacity"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap) & in(i,set_storage) 
        constraints["$(cons_name)"][i,c,r,h,t] = JuMP.@constraint(model,
            sum([ variables["CAP"][i,c,rr,t]*param_outage["$i"*"_"*"$h"] for rr in set_rfeas if in((i,c,r,t),set_valcap) & in(rr,set_rfeas_cap) & in((r,rr),set_cap_agg) ])
            >=
            variables["STORAGE_OUT"][i,c,r,h,t]
            +  !in(i,set_csp_storage) ? variables["STORAGE_IN"][i,c,r,h,t] : 0
            + sum([ variables["OPRES"][ortype,i,c,r,h,t] for ortype in set_ortype if !in(i,set_csp_storage) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_csp_charge"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap) & in(i,set_csp_storage) 
        constraints["$(cons_name)"][i,c,r,h,t] = JuMP.@constraint(model,
            sum([ variables["CAP"][i,c,r,t]*param_csp_sm["$i"]* param_m_cf["$i"*"_"*"$c"*"_"*"$rr"*"_"*"$t"] 
                    for rr in set_rfeas if in((r,rr),set_cap_agg & in((i,c,r,t),set_valcap) )])
            ==
            variables["STORAGE_IN"][i,c,r,h,t]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_csp_gen"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap)
        constraints["$(cons_name)"][i,c,r,h,t] = JuMP.@constraint(model,
            variables["GEN"][i,c,r,h,t]
            ==
            variables["STORAGE_OUT"][i,c,r,h,t]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_level"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap)  & in(i,set_csp_storage) 
        constraints["$(cons_name)"][i,c,r,h,t] = JuMP.@constraint(model,
            sum([ variables["STORAGE_LEVEL"][i,c,r,hh,t] for hh in set_h if in(hh,set_nexth) ])
            ==
            variables["STORAGE_LEVEL"][i,c,r,h,t]
            + ((variables["STORAGE_IN"][i,c,r,h,t] - variables["STORAGE_OUT"][i,c,r,h,t])*param_hours["$h"])/
            sum([param_numdays["$szn"] for szn in set_szn if in((h,szn),set_h_szn) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_szn,set_i2,set_c,set_r,set_t)

for szn in set_szn,i in set_i2, c in set_c, r in set_r, t in set_t
    if in((i,c,r,t),set_valcap) & in(i,storage)
        constraints["$(cons_name)"][szn,i,c,r,t] = JuMP.@constraint(model,
            param_storage_eff["$i"]* sum([ param_hours["$h"]*variables["STORAGE_IN"][i,c,r,h,t] for h in set_h if in((h,szn),set_h_szn) ])
            ==
            sum([param_hours["$h"]*variables["STORAGE_OUT"][i,c,r,h,t] for h in set_h if n((h,szn),set_h_szn) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_thermalres"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap) & (i=="ice")
        constraints["$(cons_name)"][szn,i,c,r,t] = JuMP.@constraint(model,
            variables["STORAGE_IN"][i,c,r,h,t]
            >=
            sum([ variables["OPRES"][ortype,i,c,r,h,t] for ortype in set_ortype])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_duration"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_i2,set_c,set_r,set_h,set_t)

for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    if in((i,c,r,t),set_valcap) & ((i=="battery") | in(i,set_csp_storage))
        constraints["$(cons_name)"][szn,i,c,r,t] = JuMP.@constraint(model,
            sum([ param_storage_duration["$i"]*variables["CAP"][i,c,rr,t] for rr in set_rfeas if in((i,c,r,t),set_valcap) & in((r,rr),set_cap_agg) ])
            >=
             !in(i,set_csp_storage) ? variables["STORAGE_IN"][i,c,r,h,t]*param_hours["$h"]/sum([param_numdays["$szn"] for szn in set_szn if in((h,szn),set_h_szn) ]) : 0
            +  in(i,set_csp_storage) ? variables["STORAGE_LEVEL"][i,c,r,h,t] : 0
        )
    end
end
