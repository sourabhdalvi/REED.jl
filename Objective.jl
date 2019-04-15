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

for t in set_t
    for i in set_i2, c in set_newc, r in set_rfeas
        if haskey(dict_valcap,join((i,c,r,t),"_"))
            cond_sum_1 = [country for country in set_country if (sum([1 for rr in set_rfeas if haskey(dict_cap_agg,"$(r)_$(rr)") & in((rr,country),set_r_country)])) > 0 ];
            comp_1 = !isempty(cond_sum_1) ? sum([param_ptc["$(country)_$(t)_$(i)"] for country in cond_sum_1 ]) : 0 ;
            cond_sum_2 = sum([ 0 for rr in set_rfeas if haskey(dict_cap_agg,"$(r)_$(rr)") & in(i,set_vre) ]);

            cost_ = variables["INV"][join((i,c,r,t),"_")] * 
                    ( param_cost_cap_fin_mult["$(r)_$(i)_$(t)"]*get(param_cost_cap,"$(i)_$(t)",0) 
                    - (SwM_PTC *(1/param_CRF_PTC[t] ) * (1/(1-TaxRate)))
                        * comp_1
                        * sum([param_hours["$h"]*(1 - ( 0 + cond_sum_2 )) * get(param_m_cf,"$(i)_$(c)_$(r)_$(h)_$(t)",0)  for h in set_h])
                    );
            JuMP.add_to_expression!(cost_func,cost_);
            if in(i,set_refurbtech)
                cond_sum_1 = [country for country in set_country if (sum([1 for rr in set_rfeas if haskey(dict_cap_agg,"$(r)_$(rr)") & in((rr,country),set_r_country)])) > 0 ];
                comp_1 = !isempty(cond_sum_1) ? sum([param_ptc["$(country)_$(t)_$(i)"] for country in cond_sum_1 ]) : 0 ;
                cond_sum_2 = sum([ 0 for rr in set_rfeas if haskey(dict_cap_agg,"$(r)_$(rr)") & in(i,set_vre) ]);
                cost_ = variables["INVREFURB"][join((i,c,r,t),"_")]
                        *(param_cost_cap_fin_mult["$(r)_$(i)_$(t)"]*get(param_cost_cap,"$(i)_$(t)",0) 
                        - (SwM_PTC *(1/param_CRF_PTC[t] ) * (1/(1-TaxRate)))
                        * comp_1
                        * sum([param_hours["$h"]*(1 - ( 0 + cond_sum_2 )) * get(param_m_cf,"$(i)_$(c)_$(r)_$(h)_$(t)",0)  for h in set_h])
                        );
                JuMP.add_to_expression!(cost_func,cost_);
            end
        end
        for rscbin in set_rscbin
            if in(i,set_rsc_i) & haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)") & haskey(dict_valcap,join((i,c,r,t),"_"))
                cost_ = variables["INV_RSC"][join((i,c,r,t,rscbin),"_")] * param_m_rsc_dat["$(r)_$(i)_$(rscbin)_cost"];
                JuMP.add_to_expression!(cost_func,cost_);
            end
        end
    end
    for r in set_rfeas,rr in set_rfeas
        for trtype in set_trtype
            if haskey(dict_routes,join((r,rr,trtype,t),"_")) # costs of transmission lines
                cost_ = ((param_intertranscost["$r"]+param_intertranscost["$rr"])/2)  * variables["INVTRAN"][join((r,rr,t,trtype),"_")] * param_distance["$(r)_$(rr)"];
                JuMP.add_to_expression!(cost_func,cost_);
            end
        end
        if haskey(dict_routes,join((r,rr,"DC",t),"_")) & t >2020 & (param_INr["$r"] != param_INr["$rr"] ) # cost of back-to-back AC-DC-AC interties
            cost_ = Trans_Intercost*variables["INVTRAN"][join((r,rr,t,"DC"),"_")]
            JuMP.add_to_expression!(cost_func,cost_);
        end
    end
    for r in set_rfeas,  vc in set_vc
        if in((r,vc),set_tranfeas)
            cost_ = param_trancost["$(r)_cost_$(vc)"]*variables["INVSUBSTATION"][join((r,vc,t),"_")]
            JuMP.add_to_expression!(cost_func,cost_);
        end
    end
end


# -----------------------------------------------------------------------
# *===============
# *beginning of operational costs (hence pvf_onm and not pvf_capital)
# *===============

cost_scale = 1;
bio_cofire_perc =0.15;

for t in set_t
    for i in set_i2, c in set_c, r in set_rfeas, h in set_h
        if haskey(dict_valcap,join((i,c,r,t),"_"))
            cost_ = (get(param_cost_vom,"$(i)_$(c)_$(r)_$(t)",0)*variables["GEN"][join((i,c,r,h,t),"_")] # variable O&M costs
                    + get(param_cost_fom,"$(i)_$(c)_$(r)_$(t)",0) *variables["CAP"][join((i,c,r,t),"_")])*cost_scale*param_pvf_onm[t] ; # fixed O&M costs
            JuMP.add_to_expression!(cost_func,cost_);
            
            if !in(i,set_gas) & (i!="biopower") & !in(i,set_cofire) # cost of coal and nuclear fuel (except coal used for cofiring)
                cost_ = (get(param_heat_rate,"$(i)_$(c)_$(r)_$(t)",0)*param_hours["$h"] 
                            *get(param_fuel_price,"$(i)_$(r)_$(t)",0)*variables["GEN"][join((i,c,r,h,t),"_")])*cost_scale*param_pvf_onm[t] ; 
                JuMP.add_to_expression!(cost_func,cost_);
            end
            
            if in(i,set_cofire) # cofire coal consumption - cofire bio consumption already accounted for in accounting of BIOUSED
                cost_ = ((1-bio_cofire_perc)*param_hours["$h"]*get(param_heat_rate,"$(i)_$(c)_$(r)_$(t)",0)
                    *param_fuel_price["coal-new_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")])*cost_scale*param_pvf_onm[t] ;
                JuMP.add_to_expression!(cost_func,cost_);
            end
            if haskey(param_cost_opres,"$i") # operating reserve costs
                ortype = "reg";
                cost_ = (param_hours["$h"]*param_cost_opres["$i"]*variables["OPRES"][join((ortype,i,c,r,h,t),"_")])*cost_scale*param_pvf_onm[t];
                JuMP.add_to_expression!(cost_func,cost_);
            end
            if in(i,set_gas) & (i!="biopower") & !in(i,set_cofire)  # *cost of natural gas for SwM_GasCurve = 2 (static natural gas prices) 
                cost_ =  (param_hours["$h"]*get(param_heat_rate,"$(i)_$(c)_$(r)_$(t)",0)*param_fuel_price["$(i)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")])*cost_scale*param_pvf_onm[t] ;
                JuMP.add_to_expression!(cost_func,cost_);
            end
            # *cost of natural gas for SwM_GasCurve = 1 (national and census division supply curves for natural gas prices)
            # *first - anticipated costs of gas consumption given last year's amount
            if in(i,set_gas) 
                cendiv = "WSC";
                cost_ =  (param_gasmultterm["$(cendiv)_$(t)"]* param_szn_adj_gas["$h"] * param_cendiv_weights["$(r)_$(cendiv)"] 
                    *param_hours["$h"]*get(param_heat_rate,"$(i)_$(c)_$(r)_$(t)",0)*variables["GEN"][join((i,c,r,h,t),"_")])*cost_scale*param_pvf_onm[t];
                JuMP.add_to_expression!(cost_func,cost_);
            end
        end
    end
    for cendiv in ["WSC"], gb in set_gb # *second - adjustments based on changes from last year's consumption at the regional and national level
        cost_ = (sum([ param_hours["$h"]*variables["GasUsed"][join((cendiv,gb,h,t),"_")]  for h in set_h ])
                    *sum([ param_gasprice["$(cendiv)_$(gb)_$(t)_$(gps)"] for gps in ["REF"]  ]))*cost_scale*param_pvf_onm[t];
        JuMP.add_to_expression!(cost_func,cost_);
        
        for h in set_h
            cost_ = (param_hours["$h"]*variables["GasUsed"][join((cendiv,gb,h,t),"_")]
                    *sum([ (get(param_gasadder_cd,"$(cendiv)_$(t)_$(h)_$(gps)",0) + param_gasprice_nat_bin["$(gb)_$(t)_$(gps)"]) for gps in ["REF"] ]))*cost_scale*param_pvf_onm[t];
            JuMP.add_to_expression!(cost_func,cost_);
        end
    end

    for fuelbin in set_fuelbin # *second - adjustments based on changes from last year's consumption at the regional and national level
        cost_ = (get(param_gasbinp_national,"$(fuelbin)_$(t)",0)*variables["Vgasbinq_national"][join((fuelbin,t),"_")])*cost_scale*param_pvf_onm[t];
        JuMP.add_to_expression!(cost_func,cost_);
        
        for  cendiv in ["WSC"] 
            cost_ = (get(param_gasbinp_regional,"$(fuelbin)_$(cendiv)_$(t)",0)*variables["Vgasbinq_regional"][join((fuelbin,cendiv,t),"_")])*cost_scale*param_pvf_onm[t];
            JuMP.add_to_expression!(cost_func,cost_);
        end
    end
    for r in set_rfeas, bioclass in set_bioclass # *biofuel consumption
        cost_ = (param_biopricemult["$(r)_$(bioclass)_$(t)"]*variables["BIOUSED"][join((bioclass,r,t),"_")] * get(param_biosupply,"$(r)_cost_$(bioclass)",0))*cost_scale*param_pvf_onm[t]; 
        JuMP.add_to_expression!(cost_func,cost_);
    end
    for r in set_rfeas, rr in set_rfeas, h in set_h, trtype in set_trtype 
         if  haskey(dict_routes,join((r,rr,trtype,t),"_"))
            cost_ = (get(param_hurdle,"$(r)_$(rr)",0)*variables["FLOW"][join((r,rr,h,t,trtype),"_")]* param_hours["$h"])*cost_scale*param_pvf_onm[t] ;
            JuMP.add_to_expression!(cost_func,cost_);
        end
    end
    for e in set_e, r in set_rfeas
        cost_ = (variables["EMIT"][join((e,r,t),"_")]*get(param_emit_tax,"$(e)_$(r)_$(t)",0))*cost_scale*param_pvf_onm[t];
        JuMP.add_to_expression!(cost_func,cost_);
    end
    for RPSCat in set_RPSCat, st in ["TX"]
        cost_ = (variables["ACP_Purchases"][join((RPSCat,st,t),"_")]*param_acp_price["$(st)_$(t)"])*cost_scale*param_pvf_onm[t]
        JuMP.add_to_expression!(cost_func,cost_);
    end
end
         
# -----------------------------------------------------------------------
