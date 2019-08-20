# *============================
# * --- OBJECTIVE ---
# *============================
# -----------------------------------------------------------------------

cost_func = zero(JuMP.GenericAffExpr{Float64, JuMP.variable_type(model)});
cost_scale = 1e-6;
# -----------------------------------------------------------------------
# *investment costs
Trans_Intercost = 200000;


for t in set_t
    cs_pc = cost_scale*param_pvf_capital[t];
    for i in set_i2, c in set_newc, r in set_rfeas_cap
        if haskey(dict_valcap,(i,c,r,t))
            ce = (get(param_cost_cap_fin_mult,(i,r,t),0)
                    *get(param_cost_cap,(i,t),0))*cs_pc ;
            JuMP.add_to_expression!(cost_func,ce,variables["INV"][(i,c,r,t)]);
        end
        if in(i,set_refurbtech) & haskey(dict_ict,(i,c,t))
            ce = (get(param_cost_cap_fin_mult,(i,r,t),0)
                    *get(param_cost_cap,(i,t),0))*cs_pc;
            JuMP.add_to_expression!(cost_func,ce,variables["INVREFURB"][(i,c,r,t)]);
        end
        
        for rscbin in set_rscbin
            if in(i,set_rsc_i)  & haskey(set_m_rscfeas,(r,i,rscbin)) & haskey(dict_valcap,(i,c,r,t))
                ce = (param_m_rsc_dat[(r,i,rscbin,"cost")]
                        *param_rsc_fin_mult[(i,r,t)]*cs_pc);
                JuMP.add_to_expression!(cost_func,ce,variables["INV_RSC"][(i,c,r,rscbin,t)]);
            end
        end
    end
    for r in set_rfeas,rr in set_rfeas
        # costs of transmission lines
        for trtype in set_trtype
            if haskey(dict_routes,(r,rr,trtype,t)) 
                ce = (((param_intertranscost[r]+param_intertranscost[rr])/2)
                        *param_distance[(r,rr)]*cs_pc);
                JuMP.add_to_expression!(cost_func,ce,variables["INVTRAN"][(r,rr,trtype,t)]);
            end
        end
         # cost of back-to-back AC-DC-AC interties
        if haskey(dict_routes,(r,rr,"DC",t)) & (t >2020) & (param_INr["$r"] != param_INr["$rr"] )
            ce = Trans_Intercost*cs_pc
            JuMP.add_to_expression!(cost_func,ce,variables["INVTRAN"][(r,rr,"DC",t)]);
        end
    end
    for r in set_rfeas,  vc in set_vc
        if in((r,vc),set_tranfeas)
            ce = param_trancost[(r,"cost",vc)]*cs_pc
            JuMP.add_to_expression!(cost_func,ce,variables["INVSUBSTATION"][(r,vc,t)]);
        end
    end
end


# -----------------------------------------------------------------------
# *===============
# *beginning of operational costs (hence pvf_onm and not pvf_capital)
# *===============


bio_cofire_perc =0.15;

for t in set_t
    cs_po = cost_scale*param_pvf_onm[t];
    for i in set_i2, c in set_c
        for r in set_rfeas_cap
            if haskey(dict_valcap,(i,c,r,t))
                ce = get(param_cost_fom,(i,c,r,t),0)*cs_po ; # fixed O&M costs
                JuMP.add_to_expression!(cost_func,ce,variables["CAP"][(i,c,r,t)]);
            end
        end
        for h in set_h, r in set_rfeas
            if haskey(dict_valgen,(i,c,r,t))
                # variable O&M costs
                ce = param_hours[h]*get(param_cost_vom,(i,c,r,t),0)*cs_po ; 
                JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
                # operating reserve costs
                if (haskey(param_reserve_frac,(i,"reg")) 
                    || in(i,set_storage) || in(i,set_hydro_d))  
                    ortype = "reg";
                    ce = (param_hours[h]*get(param_cost_opres,i,0))*cs_po;
                    JuMP.add_to_expression!(cost_func,ce,variables["OPRES"][(ortype,i,c,r,h,t)]);
                end
                 # cost of coal and nuclear fuel (except coal used for cofiring)
                if !in(i,set_gas) & (i!="biopower") & !in(i,set_cofire) 
                    ce = (get(param_heat_rate,(i,c,r,t),0)*param_hours[h] 
                        *get(param_fuel_price,(i,r,t),0))*cs_po ; 
                    JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
                end
                # cofire coal consumption - cofire bio consumption already accounted for in accounting of BIOUSED
                if in(i,set_cofire)   
                    ce = ((1-bio_cofire_perc)*param_hours[h]*get(param_heat_rate,(i,c,r,t),0)
                        *param_fuel_price[("coal-new",r,t)])*cs_po ;
                    JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
                end
#=
                # *cost of natural gas for SwM_GasCurve = 2 (static natural gas prices) 
                if in(i,set_gas) & (i!="biopower") & !in(i,set_cofire) & haskey(dict_valgen,(i,c,r,t))
                    ce = (param_hours[h]*get(param_heat_rate,(i,c,r,t),0)*param_fuel_price[(i,r,t)])*cs_po ;
                    JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
                end
                # *cost of natural gas for SwM_GasCurve = 1 (national and census division supply curves for natural gas prices)
                # *first - anticipated costs of gas consumption given last year's amount
                if in(i,set_gas) 
                    cendiv = "WSC";
                    ce =  (param_gasmultterm[(cendiv,t)]* param_szn_adj_gas[h] 
                        * param_cendiv_weights[(r,cendiv)]*param_hours[h]
                        *get(param_heat_rate,(i,c,r,t),0))*cs_po;
                    JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
                end
=#
            end
        end
    end
    # cost of natural gas for SwM_GasCurve = 0 
    # (census division supply curves natural gas prices)
    for cendiv in set_cdfeas, gb in set_gb 
        for h in set_h 
            ce = param_hours[h]*param_gasprice[(cendiv,gb,t)]*cs_po;
            JuMP.add_to_expression!(cost_func,ce,variables["GasUsed"][(cendiv,gb,h,t)]);
        end
#=        
# cost of natural gas for SwM_GasCurve = 3 
# (national supply curve for natural gas prices with census division multipliers)
        for h in set_h 
            ce = param_hours[h]*
                (get(param_gasadder_cd,(cendiv,t,h,"REF"),0) + param_gasprice_nat_bin[(gb,t,"REF")])*cs_po;
            JuMP.add_to_expression!(cost_func,ce,variables["GasUsed"][(cendiv,gb,h,t)]);
        end
=#
    end
#=
# SwM_GasCurve = 1 
# second - adjustments based on changes from last year's consumption at the regional and national level
    for fuelbin in set_fuelbin 
        ce = get(param_gasbinp_national,(fuelbin,t),0)*cs_po;
        JuMP.add_to_expression!(cost_func,ce,variables["Vgasbinq_national"][(fuelbin,t)]);
        
        for  cendiv in ["WSC"] 
            ce = get(param_gasbinp_regional,(fuelbin,cendiv,t),0)*cs_po;
            JuMP.add_to_expression!(cost_func,ce,variables["Vgasbinq_regional"][(fuelbin,cendiv,t)]);
        end
    end
=#
    # *biofuel consumption
    for r in set_rfeas, bioclass in set_bioclass 
        ce = (param_biopricemult[(r,bioclass,t)]
            * get(param_biosupply,(r,"cost",bioclass),0)*cs_po); 
        JuMP.add_to_expression!(cost_func,ce,variables["BIOUSED"][(bioclass,r,t)] );
    end
    for r in set_rfeas, rr in set_rfeas, h in set_h, trtype in set_trtype 
         if  haskey(dict_routes,(r,rr,trtype,t))
            ce = get(param_hurdle,(r,rr),0)* param_hours[h]*cs_po ;
            JuMP.add_to_expression!(cost_func,ce,variables["FLOW"][(r,rr,h,trtype,t)]);
        end
    end
    for e in set_e, r in set_rfeas
        ce = get(param_emit_tax,(e,r,t),0)*cs_po;
        JuMP.add_to_expression!(cost_func,ce,variables["EMIT"][(e,r,t)]);
    end
    for RPSCat in set_RPSCat, st in set_stfeas
        if t > param_RPS_StartYear
            ce = param_acp_price[(st,t)]*cs_po
            JuMP.add_to_expression!(cost_func,ce,variables["ACP_Purchases"][(RPSCat,st,t)]);
        end
    end
end
         
# -----------------------------------------------------------------------

# *========================
# * Generation Policy
# *========================

# *Generation policies have their own present value factors (pvf_policy).
# *In sequential mode, generation policy revenue vests entirely in the first solve
# *year that the policy is available, which assumes the generator continues to operate
# *at that level. In intertemporal mode, pvf_policy is equivalent to pvf_onm,
# *except for situations where the policy terminates between solve years.
# *It is best-practice to have a unique vintage for every solve year for a technology that has a gen_pol

for i in set_i2, c in set_c, r in set_rfeas, h in set_h, t in set_t
    if haskey(dict_valgen,(i,c,r,t)) & haskey(param_pvf_policy,(i,c,r,t)) & haskey(param_gen_pol,(i,c,r,t))
        ce = -cost_scale*param_gen_pol[(i,c,r,t)]*param_pvf_policy[(i,c,r,t)]*param_hours[h];
        JuMP.add_to_expression!(cost_func,ce,variables["GEN"][(i,c,r,h,t)]);
    end
end

# -----------------------------------------------------------------------