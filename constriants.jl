
# *=========================
# * --- LOAD CONSTRAINT ---
# *=========================

function eq_loadcon()
    cons_name = "eq_loadcon";
    set_ = str_sets_dict["$(cons_name)"] ;

    b = [ haskey(param_can_exports_h,s) ? param_load_exog[s] + param_can_exports_h[s] : param_load_exog[s] for s in set_];
    cont_ = JuMP.@constraint(model, base_name=set_,  variables["LOAD"].data[1:end] .== b[1:end]);
    constraints["eq_loadcon"] =JuMP.Containers.DenseAxisArray(cont_,set_);
end

# -----------------------------------------------------------------------

# *====================================
# * -- existing capacity equations --
# *====================================

function eq_cap_init_noret()
    cons_name = "eq_cap_init_noret";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for icrt in str_sets_dict["$(cons_name)"] 
            constraints["$(cons_name)"][icrt] = JuMP.@constraint(model, 
                variables["CAP"][icrt] == param_exo_cap[icrt] 
            )
            set_name(constraints["$(cons_name)"][icrt],"$(cons_name)$(icrt)");
    end
end

# -----------------------------------------------------------------------
# *==============================
# * -- new capacity equations --
# *==============================

function eq_cap_new_noret()
    cons_name = "eq_cap_new_noret"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (i,c,r,t) in str_sets_dict["$(cons_name)"]
        rhs = JuMP.GenericAffExpr{Float64, JuMP.variable_type(model)}();
        for tt in set_t
            if (tt <= t) && haskey(dict_inv_cond,(i,c,t,tt)) && haskey(dict_valcap,(i,c,r,tt))
                JuMP.add_to_expression!(rhs,param_degrade[(i,tt,t)]* variables["INV"][(i,c,r,tt)]);
            end
            if (tt <= t) && (t - tt < param_maxage[i]) && haskey(dict_ict,(i,c,tt)) && in(i,set_refurbtech) 
                JuMP.add_to_expression!(rhs,param_degrade[(i,tt,t)]* variables["INVREFURB"][(i,c,r,tt)]);
            end
        end

        constraints["$(cons_name)"][(i,c,r,t)]  = JuMP.@constraint(model, 
            variables["CAP"][(i,c,r,t)]  ==  rhs);
        set_name(constraints["$(cons_name)"][(i,c,r,t)],"$(cons_name)($(i),$(c),$(r),$(t))");
    end
end
# -----------------------------------------------------------------------

function eq_forceprescription()
    cons_name = "eq_forceprescription"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]["eq"]);


    for (pcat,r,t) in str_sets_dict["$(cons_name)"]["eq"] 
        v_EXTRA_PRESCRIP = (t >=  param_firstyear_pcat[pcat]) ? variables["EXTRA_PRESCRIP"][(pcat,r,t)] : 0 ;
        valid_sum = str_sets_dict["eq_forceprescription"]["rhs_1"][(pcat,r,t)];
        rhs_1 = !isempty(valid_sum) ? sum([variables["CAP"][(ii,c,rr,tt)]  for (ii,c,rr,tt) in valid_sum]) : 0 ;

        constraints["$(cons_name)"][(pcat,r,t)] = JuMP.@constraint(model,
            get(param_m_required_prescriptions,(pcat,r,t),0) + v_EXTRA_PRESCRIP == rhs_1  
            );
        set_name(constraints["$(cons_name)"][(pcat,r,t)],"$(cons_name)($(pcat),$(r),$(t))");
    end
end
# -----------------------------------------------------------------------

# eq_neartermcaplimit
function eq_neartermcaplimit()
    cons_name = "eq_neartermcaplimit";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"] );

    for (r,t) in str_sets_dict["$(cons_name)"]
        constraints["$(cons_name)"][(r, t)] = JuMP.@constraint(model,
            get(param_near_term_cap_limits,("WIND",r,t),0) >= variables["EXTRA_PRESCRIP"][("wind-ons", r, t)]
        ) ;
        set_name(constraints["$(cons_name)"][(r,t)],"$(cons_name)($(r),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_refurblim()
    cons_name = "eq_refurblim"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (i,r,t) in str_sets_dict["$(cons_name)"]   
        (lhs,rhs) = _add_rhs_lhs(model);

        for (c,tt) in Iterators.product(set_newc,set_t)
            if haskey(dict_m_refurb_cond,(i,c,r,t,tt)) && haskey(dict_valcap,(i,c,r,tt))
                JuMP.add_to_expression!(lhs,variables["INV"][(i,c,r,tt)]);
            end
            if (tt <= t)
                if haskey(param_m_avail_retire_exog_rsc,(i,c,r,tt))
                    JuMP.add_to_expression!(lhs,param_m_avail_retire_exog_rsc[(i,c,r,tt)]);
                end
                if (t - tt < param_maxage[i]) &&  haskey(dict_ict,(i,c,tt))
                    JuMP.add_to_expression!(rhs,variables["INVREFURB"][(i,c,r,tt)]);
                end
            end
        end

        constraints["$(cons_name)"][(i,r,t)] = JuMP.@constraint(model, 
            lhs >= rhs
        );
        set_name(constraints["$(cons_name)"][(i,r,t)],"$(cons_name)($(i),$(r),$(t))");
    end
end

# -----------------------------------------------------------------------

# eq_rsc_inv_account 
function eq_rsc_inv_account()
    cons_name = "eq_rsc_inv_account"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
    for (i,c,r,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for rscbin in (set_rscbin)
            if haskey(set_m_rscfeas,(r,i,rscbin))
                JuMP.add_to_expression!(lhs,variables["INV_RSC"][(i,c,r,rscbin,t)]);
            end
        end
        constraints["$(cons_name)"][(i,c,r,t)] = JuMP.@constraint(model,
            lhs == variables["INV"][(i,c,r,t)] 
        );
        set_name(constraints["$(cons_name)"][(i,c,r,t)],"$(cons_name)($(i),$(c),$(r),$(t))");
    end
end
# -----------------------------------------------------------------------

# eq_rsc_INVlim
function eq_rsc_INVlim()
    cons_name = "eq_rsc_INVlim"
    constraints["eq_rsc_INVlim"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
    for (r,i,rscbin,t) in str_sets_dict["eq_rsc_INVlim"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (ii,c,tt) in Iterators.product(set_i,set_newc,filter(tt-> tt <= t,set_t)) 
            if haskey(dict_valcap,(ii,c,r,tt)) && in((i,ii),set_rsc_agg)
                JuMP.add_to_expression!(rhs,variables["INV_RSC"][(ii,c,r,rscbin,tt)]*param_resourcescaler[ii]);
            end
        end
        isempty(rhs.terms) ? continue : nothing ;
        if in(i,set_geo_undisc)
            JuMP.add_to_expression!(lhs,get(param_m_rsc_dat,(r,i,rscbin,"cap"),0) * get(param_geo_discovery,t,0));
        else
            JuMP.add_to_expression!(lhs,get(param_m_rsc_dat,(r,i,rscbin,"cap"),0));
        end
        
        constraints["eq_rsc_INVlim"][(r,i,rscbin,t)] = JuMP.@constraint(model,lhs >= rhs);
        set_name(constraints["eq_rsc_INVlim"][(r,i,rscbin,t)],"eq_rsc_INVlim($(r),$(i),$(rscbin),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_capacity_limit()
    cons_name = "eq_capacity_limit"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);
    for (i,c,r,h,t) in str_sets_dict["$(cons_name)"]   
        (lhs,rhs) = _add_rhs_lhs(model);
        for rr in (set_rfeas_cap) 
            if haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t)) && !in(i,set_cf_tech)
                JuMP.add_to_expression!(lhs,variables["CAP"][(i,c,rr,t)]*param_outage[(i,h)]);
            end
            if haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t)) && in(i,set_cf_tech)
                JuMP.add_to_expression!(lhs,get(param_m_cf,(i,c,rr,h,t),0)*variables["CAP"][(i,c,rr,t)]);
            end
        end
        for or in (set_ortype) 
            if haskey(param_reserve_frac,(i,or))
                JuMP.add_to_expression!(rhs,variables["OPRES"][(or,i,c,r,h,t)]);
            end
        end
        
        constraints["$(cons_name)"][(i,c,r,h,t)] = JuMP.@constraint(model,
        lhs >= variables["GEN"][(i,c,r,h,t)] + rhs);
        set_name(constraints["$(cons_name)"][(i,c,r,h,t)],"$(cons_name)($(i),$(c),$(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_curt_gen_balance()
    cons_name = "eq_curt_gen_balance"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
    for (r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_vre,set_c) 
            if haskey(dict_valgen,(i,c,r,t))
                JuMP.add_to_expression!(rhs,variables["GEN"][(i,c,r,h,t)]);
            end
            for rr in set_rfeas_cap
                if haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t))
                    JuMP.add_to_expression!(lhs,get(param_m_cf,(i,c,rr,h,t),0)*variables["CAP"][(i,c,rr,t)]);
                end
            end
            for or in set_ortype
                if haskey(param_reserve_frac,(i,or)) 
                    JuMP.add_to_expression!(rhs,variables["OPRES"][(or,i,c,r,h,t)]);
                end
            end
        end
        
        constraints["$(cons_name)"][(r,h,t)] = JuMP.@constraint(model,
            lhs - variables["CURT"][(r,h,t)]  >= rhs
        );
        set_name(constraints["$(cons_name)"][(r,h,t)],"$(cons_name)($(r),$(h),$(t))");
    end 
end

# -----------------------------------------------------------------------

function eq_curtailment()
    cons_name = "eq_curtailment"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);
    for (r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c,rr) in Iterators.product(set_vre,set_c,set_rfeas_cap)
            if haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t))
                JuMP.add_to_expression!(rhs,get(param_m_cf,(i,c,rr,h,t),0)
                                            *get(param_curt_int,(i,rr,h,t),0)
                                            ,variables["CAP"][(i,c,rr,t)]);
                if haskey(dict_inv_cond,(i,c,t,t))
                    JuMP.add_to_expression!(rhs,get(param_m_cf,(i,c,rr,h,t),0)
                                                *get(param_curt_marg,(i,rr,h,t),0)
                                                ,variables["INV"][(i,c,rr,t)]
                                                );
                end
            end
        end
        for (hh,szn) in (set_h_szn), tt in (set_t)
            if (t-2 == tt) && (h == hh)
                JuMP.add_to_expression!(rhs,(variables["MINGEN"][(r,szn,t)] 
                                            - variables["MINGEN"][(r,szn,tt)])
                                            *get(param_curt_mingen,(r,h,t),0));
            end
        end
        for (i,c) in Iterators.product(set_storage,set_c) 
            if  haskey(dict_valgen,(i,c,r,t))
                JuMP.add_to_expression!(rhs,get(param_curt_storage,(i,r,h,t),0),-variables["STORAGE_IN"][(i,c,r,h,t)]);
            end
        end
        
        constraints["$(cons_name)"][(r,h,t)]  = JuMP.@constraint(model,
            variables["CURT"][(r,h,t)]  >= rhs + get(param_surpold,(r,h,t),0) + get(param_curt_excess,(r,h,t),0)
        );
        set_name(constraints["$(cons_name)"][(r,h,t)],"$(cons_name)($(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_mingen_lb()
    cons_name = "eq_mingen_lb";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (r,h,szn,t) in str_sets_dict["$(cons_name)"]  
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_i,set_c)
            if haskey(dict_valgen,(i,c,r,t))
                JuMP.add_to_expression!(rhs,variables["GEN"][(i,c,r,h,t)]* get(param_minloadfrac,(r,i,h),0));
            end
        end
        constraints["$(cons_name)"][(r,h,szn,t)] = JuMP.@constraint(model,
            variables["MINGEN"][(r,szn,t)] >=  rhs );
        set_name(constraints["$(cons_name)"][(r,h,szn,t)],"$(cons_name)($(r),$(h),$(szn),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_mingen_ub()
    cons_name = "eq_mingen_ub";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (r,h,szn,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_i,set_c)
            if haskey(dict_valgen,(i,c,r,t))  && haskey(param_minloadfrac,(r,i,h))
                JuMP.add_to_expression!(rhs,variables["GEN"][(i,c,r,h,t)]);
            end
        end

        constraints["$(cons_name)"][(r,h,szn,t)] = JuMP.@constraint(model,
            variables["MINGEN"][(r,szn,t)] <= rhs);
        set_name(constraints["$(cons_name)"][(r,h,szn,t)],"$(cons_name)($(r),$(h),$(szn),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_dhyd_dispatch()
cons_name = "eq_dhyd_dispatch"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
    
    for (i,c,r,szn,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        lhs_c = 0;
        for h in (set_h)
            if in((h,szn),set_h_szn) 
                JuMP.add_to_expression!(rhs,param_hours[h],variables["GEN"][(i,c,r,h,t)]);
                for or in (set_ortype)
                    if haskey(param_reserve_frac,(i,or))
                        JuMP.add_to_expression!(rhs,param_hours[h],variables["OPRES"][(or,i,c,r,h,t)]);
                    end
                end
                lhs_c += param_hours[h]*param_outage[(i,h)] ;
            end
        end
        lhs_a = (get(param_cfhist_hyd,(r,t,szn,i),0) * get(param_cf_hyd_szn_adj,(i,szn,r),0) 
                * get(param_cf_hyd,(i,szn,r),0)) * lhs_c;
        JuMP.add_to_expression!(lhs,lhs_a, variables["CAP"][(i,c,r,t)]) ; 
        constraints["$(cons_name)"][(i,c,r,szn,t)] = JuMP.@constraint(model, lhs >=  rhs);
        set_name(constraints["$(cons_name)"][(i,c,r,szn,t)],"$(cons_name)($(i),$(c),$(r),$(szn),$(t))");
    end
end

# -----------------------------------------------------------------------
# *===============================
# * --- SUPPLY DEMAND BALANCE ---
# *===============================

function eq_supply_demand_balance()
    cons_name = "eq_supply_demand_balance"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_i,set_c) 
            if haskey(dict_valgen,(i,c,r,t))
                if !in(i,set_storage)
                    JuMP.add_to_expression!(lhs,variables["GEN"][(i,c,r,h,t)])
                else 
                    JuMP.add_to_expression!(lhs,variables["STORAGE_OUT"][(i,c,r,h,t)]);
                end
            end
            if haskey(dict_valcap,(i,c,r,t)) & in(i,set_storage) 
                if !in(i,set_csp_storage)
                    JuMP.add_to_expression!(lhs,-variables["STORAGE_IN"][(i,c,r,h,t)])
                end
            end
        end
        for (rr,tr) in Iterators.product(set_rfeas,set_trtype) 
            if  haskey(dict_routes,(rr,r,tr,t))
                JuMP.add_to_expression!(lhs,(1-param_tranloss[(rr,r)]),variables["FLOW"][(rr,r,h,tr,t)]);
            end
            if haskey(dict_routes,(r,rr,tr,t))
                JuMP.add_to_expression!(lhs,-variables["FLOW"][(r,rr,h,tr,t)]);
            end
        end

        constraints["$(cons_name)"][(r,h,t)] = JuMP.@constraint(model,
            lhs == variables["LOAD"][(r,h,t)] );
        set_name(constraints["$(cons_name)"][(r,h,t)],"$(cons_name)($(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------
# *=======================================
# * --- MINIMUM LOADING CONSTRAINTS ---
# *=======================================

function eq_minloading()
    cons_name = "eq_minloading"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
    for (i,c,r,h,hh,t) in str_sets_dict["$(cons_name)"]
        constraints["$(cons_name)"][(i,c,r,h,hh,t)] = JuMP.@constraint(model,
            variables["GEN"][(i,c,r,h,t)]
            >=
            variables["GEN"][(i,c,r,hh,t)] * get(param_minloadfrac,(r,i,hh),0)
        )
        set_name(constraints["$(cons_name)"][(i,c,r,h,hh,t)],"$(cons_name)($(i),$(c),$(r),$(h),$(hh),$(t))");
    end
end

# -----------------------------------------------------------------------
# *=======================================
# * --- OPERATING RESERVE CONSTRAINTS ---
# *=======================================

function eq_ORCap()
    cons_name = "eq_ORCap"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (or,i,c,r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (hh,szn) in Iterators.product(set_h,set_szn) 
            if in((h,szn),set_h_szn) && haskey(dict_maxload_szn,(r,hh,t,szn))
                JuMP.add_to_expression!(lhs,variables["GEN"][(i,c,r,hh,t)]);
            end
        end
        constraints["$(cons_name)"][(or,i,c,r,h,t)] = JuMP.@constraint(model,
            param_reserve_frac[(i,or)] * lhs  >= variables["OPRES"][(or,i,c,r,h,t)]);
        set_name(constraints["$(cons_name)"][(or,i,c,r,h,t)],"$(cons_name)($(or),$(i),$(c),$(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_OpRes_requirement()
    cons_name = "eq_OpRes_requirement"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

    for (or,r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_i,set_c)
            if haskey(dict_valgen,(i,c,r,t))
                if ((haskey(param_reserve_frac,(i,or)) || in(i,set_storage) || in(i,set_hydro_d)) 
                    && !in(i,set_hydro_nd))
                    JuMP.add_to_expression!(lhs,variables["OPRES"][(or,i,c,r,h,t)]);
                end
                if in(i,set_wind)
                    JuMP.add_to_expression!(rhs,get(param_orperc,(or,"or_wind"),0),variables["GEN"][(i,c,r,h,t)])
                end
                if in(i,set_pv) && in(h,set_dayhours)
                    JuMP.add_to_expression!(rhs,get(param_orperc,(or,"or_pv"),0),variables["CAP"][(i,c,r,t)])
                end
            end
        end
        for rr in (set_rfeas)
            if haskey(dict_opres_routes,(rr,r,t))
                JuMP.add_to_expression!(lhs,(1-param_tranloss[(rr,r)]),variables["OPRES_FLOW"][(or,rr,r,h,t)]);
            end
            if haskey(dict_opres_routes,(r,rr,t))
                JuMP.add_to_expression!(lhs,-1,variables["OPRES_FLOW"][(or,r,rr,h,t)]);
            end
        end
        JuMP.add_to_expression!(rhs,get(param_orperc,(or,"or_load"),0),variables["LOAD"][(r,h,t)]);
        constraints["$(cons_name)"][(or,r,h,t)] = JuMP.@constraint(model,
            lhs  >= rhs);
        set_name(constraints["$(cons_name)"][(or,r,h,t)],"$(cons_name)($(or),$(r),$(h),$(t))");
    end   
end  

# -----------------------------------------------------------------------
# *=================================
# * --- PLANNING RESERVE MARGIN ---
# *=================================

function eq_PRMTRADELimit()
    cons_name = "eq_PRMTRADELimit";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]["eq"]);
    for (r,rr,szn,t) in str_sets_dict["$(cons_name)"]["eq"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for tr in str_sets_dict["$(cons_name)"]["lhs"][(r,rr,t)]
            JuMP.add_to_expression!(lhs,1,variables["CAPTRAN"][(r,rr,tr,t)])
        end
        constraints["$(cons_name)"][(r,rr,szn,t)] = JuMP.@constraint(model,
            lhs >= variables["PRMTRADE"][(r,rr,szn,t)]);
        set_name(constraints["$(cons_name)"][(r,rr,szn,t)],"$(cons_name)($(r),$(rr),$(szn),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_reserve_margin()
    cons_name = "eq_reserve_margin"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,szn,t) in str_sets_dict["$(cons_name)"] #SwM_ReserveMargin
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c) in Iterators.product(set_i,set_c) 
            if haskey(dict_valgen,(i,c,r,t))
                if  (!in(i,set_vre) 
                    && !in(i,set_storage) && !in(i, set_hydro))
                    JuMP.add_to_expression!(lhs,variables["CAP"][(i,c,r,t)]);
                end
                if in(i,set_hydro_nd)
                    JuMP.add_to_expression!(lhs,variables["GEN"][(i,c,r,"h3",t)]);
                end
                if in(i,set_hydro_d)
                    JuMP.add_to_expression!(lhs,get(param_cf_hyd_szn_adj,(i,szn,r),0)
                            *get(param_cf_hyd,(i,szn,r),0),variables["CAP"][(i,c,r,t)]);
                end
            end
            for rr in set_rfeas_cap
                if haskey(dict_cap_agg,(r,rr)) && haskey(dict_valcap,(i,c,rr,t)) && (in(i,set_vre) || in(i,set_storage)) 
                    if (haskey(dict_ict,(i,c,t))
                        && haskey(dict_inv_cond,(i,c,t,t)) )
                        JuMP.add_to_expression!(lhs,get(param_m_cc_mar,(i,rr,szn,t),0),variables["INV"][(i,c,rr,t)]);
                    end
                    JuMP.add_to_expression!(lhs,get(param_cc_int,(i,c,rr,szn,t),0) ,variables["CAP"][(i,c,rr,t)]); 
                end
            end
        end
        for (i,rr) in Iterators.product(set_i,set_rfeas_cap)
            if ((in(i,set_vre) | in(i,set_storage)) && haskey(dict_cap_agg,(r,rr)))
                JuMP.add_to_expression!(lhs,get(param_cc_old,(i,rr,szn,t),0));
                JuMP.add_to_expression!(lhs,get(param_cc_excess,(i,rr,szn,t),0));
            end
        end
        for c in (set_c) 
            if haskey(dict_valcap,("distPV",c,r,t))

            end
        end
        for rr in (set_rfeas), tr in set_trtype
            if haskey(dict_routes,(rr,r,tr,t))
                JuMP.add_to_expression!(lhs,(1-param_tranloss[(rr,r)]),variables["PRMTRADE"][(rr,r,szn,t)]);
            end
            if haskey(dict_routes,(r,rr,tr,t))
                JuMP.add_to_expression!(lhs,-1,variables["PRMTRADE"][(r,rr,szn,t)]);
            end
        end
        for c in (set_c)
            if haskey(dict_valcap,("distPV",c,r,t))
                JuMP.add_to_expression!(lhs,(get(param_exo_cap,("distPV",c,r,t),0)  - get(param_exo_cap,("distPV",c,r,t-2),0))
                                            *get(param_m_cc_mar,("distPV",r,szn,t),0));
            end
        end

        constraints["$(cons_name)"][(r,szn,t)] = JuMP.@constraint(model,
            lhs >= (1+param_prm[(r,t)]) * param_peakdem[(r,szn,t)]);
        set_name(constraints["$(cons_name)"][(r,szn,t)],"$(cons_name)($(r),$(szn),$(t))");
    end
end 
# -----------------------------------------------------------------------
# *================================
# * --- TRANSMISSION CAPACITY  ---
# *================================

function eq_CAPTRAN()
    cons_name = "eq_CAPTRAN"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,rr,trtype,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for tt in (set_t)
            if (tt <= t) && (tt > 2020) && (param_INr[r] == param_INr[rr])
                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(rr,r,tt,trtype)]);
                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(r,rr,tt,trtype)]);
            end
        end
        JuMP.add_to_expression!(rhs,param_trancap_exog[(r,rr,trtype,t)]);
        JuMP.add_to_expression!(lhs,1,variables["CAPTRAN"][(r,rr,trtype,t)]);
        constraints["$(cons_name)"][(r,rr,trtype,t)] = JuMP.@constraint(model, lhs == rhs)
        set_name(constraints["$(cons_name)"][(r,rr,trtype,t)],"$(cons_name)($(r),$(r),$(trtype),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_prescribed_transmission()
    cons_name = "eq_prescribed_transmission"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,rr,trtype,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for tt in set_t
            if (tt <= t)
                JuMP.add_to_expression!(lhs,get(param_futuretran,(r,rr,"possible",tt,trtype),0));
                JuMP.add_to_expression!(lhs,get(param_futuretran,(rr,r,"possible",tt,trtype),0));

                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(r,rr,trtype,tt)]);
                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(rr,r,trtype,tt)]);
            end
        end
        constraints["$(cons_name)"][(r,rr,trtype,t)] = JuMP.@constraint(model,lhs >= rhs);
        set_name(constraints["$(cons_name)"][(r,rr,trtype,t)],"$(cons_name)($(r),$(r),$(trtype),$(t))");
    end
end

# -----------------------------------------------------------------------
function eq_SubStationAccounting()
    cons_name = "eq_SubStationAccounting"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for rr in (set_rfeas)
            if haskey(dict_routes,(r,rr,"AC",t))
                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(r,rr,"AC",t)]);
            end
            if haskey(dict_routes,(rr,r,"AC",t))
                JuMP.add_to_expression!(rhs,1,variables["INVTRAN"][(rr,r,"AC",t)]);
            end
        end
        for vc in set_vc
            if in((r,vc),set_tranfeas)
                JuMP.add_to_expression!(lhs,1,variables["INVSUBSTATION"][(r,vc,t)]);
            end
        end
        constraints["$(cons_name)"][(r,t)] = JuMP.@constraint(model, lhs == rhs)
        set_name(constraints["$(cons_name)"][(r,t)],"$(cons_name)($(r),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_INVTRAN_VCLimit()
    cons_name = "eq_INVTRAN_VCLimit"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,vc) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        JuMP.add_to_expression!(lhs,get(param_trancost,(r,"cap",vc),0));
        for t in (set_t)
            JuMP.add_to_expression!(lhs,1,variables["INVSUBSTATION"][(r,vc,t)]);
        end
        constraints["$(cons_name)"][(r,vc)] = JuMP.@constraint(model, lhs >= rhs);
        set_name(constraints["$(cons_name)"][(r,vc)],"$(cons_name)($(r),$(vc))");
    end
end

# -----------------------------------------------------------------------

function eq_transmission_limit()
    cons_name = "eq_transmission_limit"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,rr,h,trtype,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for ortype in (set_ortype)
            if (trtype =="AC") && haskey(dict_opres_routes,(r,rr,t))
                JuMP.add_to_expression!(rhs,1,variables["OPRES_FLOW"][(ortype,r,rr,h,t)]);
            end
        end
        JuMP.add_to_expression!(rhs,1,variables["FLOW"][(r,rr,h,trtype,t)]);
        JuMP.add_to_expression!(lhs,1,variables["CAPTRAN"][(r,rr,trtype,t)]);
        constraints["$(cons_name)"][(r,rr,h,trtype,t)] = JuMP.@constraint(model, lhs >= rhs)
        set_name(constraints["$(cons_name)"][(r,rr,h,trtype,t)],"$(cons_name)($(r),$(rr),$(h),$(trtype),$(t))");
    end
end

# -----------------------------------------------------------------------
# *=========================
# * --- CARBON POLICIES ---
# *=========================

function eq_emit_accounting()
    bio_cofire_perc =0.15;
    cons_name = "eq_emit_accounting";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (e,r,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for  (i,c,h) in Iterators.product(set_i,set_c,set_h)  
            if haskey(dict_valgen,(i,c,r,t))
                if !in(i,set_cofire)
                    JuMP.add_to_expression!(rhs,param_hours[h]*
                                            get(param_emit_rate,(e,i,c,r,t),0)
                                            ,variables["GEN"][(i,c,r,h,t)]);
                else
                    JuMP.add_to_expression!(rhs,(1-bio_cofire_perc)*param_hours[h]*
                                            get(param_emit_rate,(e,"coal-new",c,r,t),0)
                                            ,variables["GEN"][(i,c,r,h,t)]);
                end
            end
        end
        JuMP.add_to_expression!(lhs,variables["EMIT"][(e,r,t)])
        constraints["$(cons_name)"][(e,r,t)] = JuMP.@constraint(model, lhs == rhs );
        set_name(constraints["$(cons_name)"][(e,r,t)],"$(cons_name)($(e),$(r),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_RGGI_cap()
    RGGI_start_yr =2012;
    cons_name = "eq_RGGI_cap";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for t in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for r in filter(r-> in(r,set_rfeas),set_RGGI_r)
            JuMP.add_to_expression!(rhs,1,variables["EMIT"][("CO2",r,t)])
        end
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
            param_RGGICap[t] >= rhs );
        set_name(constraints["$(cons_name)"][t],"$(cons_name)($t)");
    end
end
# -----------------------------------------------------------------------

function  eq_AB32_cap()
    AB32_start_yr = 2014;
    AB32_Import_Emit = 0.334;
    cons_name = "eq_AB32_cap";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for t in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for rr in (set_AB32_r) 
            if in(rr,set_rfeas)
                JuMP.add_to_expression!(rhs,1,variables["EMIT"][("CO2",rr,t)]);
            end
            for (h,r,trtype) in Iterators.product(set_h,set_rfeas,set_trtype) 
                if !in(r,set_AB32_r) && in(rr,set_rfeas) && haskey(dict_routes,(r,rr,trtype,t))
                    JuMP.add_to_expression!(rhs,param_hours[h]*AB32_Import_Emit,variables["FLOW"][(r,rr,h,t,trtype)]);
                end
            end
        end

        constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
            param_AB32Cap[t] >= rhs);
        set_name(constraints["$(cons_name)"][t],"$(cons_name)($t)");
    end
end

# -----------------------------------------------------------------------

function eq_batterymandate()
    cons_name = "eq_batterymandate";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,i,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for c in (set_c)
            if haskey(dict_valcap,(i,c,r,t))
                JuMP.add_to_expression!(lhs,1,variables["CAP"][(i,c,r,t)]);
            end
        end
        constraints["$(cons_name)"][(r,i,t)] = JuMP.@constraint(model,
            lhs >= get(param_batterymandate,(r,i,t),0)
        );
        set_name(constraints["$(cons_name)"][(r,i,t)],"$(cons_name)($(r),$(i),$(t))");
    end
end
# -----------------------------------------------------------------------
# *==========================
# * --- RPS CONSTRAINTS ---
# *==========================

function eq_REC_Generation()
    cons_name = "eq_REC_Generation";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (rps,i,st,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (c,r,h) in Iterators.product(set_c,set_rfeas,set_h)
            if haskey(dict_valgen,(i,c,r,t)) && haskey(dict_RecTech,(rps,st,i,t)) && in((r,st),set_r_st)
                JuMP.add_to_expression!(lhs,param_RPSTechMult[(i,st)]*param_hours[h],variables["GEN"][(i,c,r,h,t)]);
            end
        end
        for ast in set_stfeas 
            if  haskey(dict_RecMap,(i,rps,st,ast,t))
                JuMP.add_to_expression!(rhs,1,variables["RECS"][(rps,i,st,ast,t)])
            end
        end
        constraints["$(cons_name)"][(rps,i,st,t)] = JuMP.@constraint(model,lhs >= rhs);
        set_name(constraints["$(cons_name)"][(rps,i,st,t)],"$(cons_name)($(rps),$(i),$(st),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_REC_Requirement()
    distloss = 1.053;
    cons_name = "eq_REC_Requirement"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (rps,st,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,ast) in Iterators.product(set_i,set_stfeas)
            if haskey(dict_RecMap,(i,rps,ast,st,t))
                JuMP.add_to_expression!(lhs,1,variables["RECS"][(rps,i,ast,st,t)]);
            end
            if haskey(dict_RecMap,(i,"RPS_Bundled",ast,st,t)) && (st != ast) && (rps == "RPS_All")
                JuMP.add_to_expression!(lhs,1,variables["RECS"][("RPS_Bundled",i,ast,st,t)]);
            end
        end
        for r in set_rfeas, h in set_h
            if in((r,st),set_r_st) 
                for c in set_c
                    if haskey(dict_valgen,("distPV",c,r,t)) 
                        JuMP.add_to_expression!(rhs,-get(param_RecPerc,(rps,st,t),0)*param_hours[h],variables["GEN"][("distPV",c,r,h,t)]);
                    end
                end
                JuMP.add_to_expression!(rhs,(get(param_RecPerc,(rps,st,t),0)*param_hours[h])/distloss,variables["LOAD"][(r,h,t)]);
            end
            
        end
        JuMP.add_to_expression!(lhs,variables["ACP_Purchases"][(rps,st,t)]);
        constraints["$(cons_name)"][(rps,st,t)] = JuMP.@constraint(model,
            lhs >= rhs);
        set_name(constraints["$(cons_name)"][(rps,st,t)],"$(cons_name)($(rps),$(st),$(t))");
    end
end

# -----------------------------------------------------------------------
# exports must be less than RECS generated

function eq_REC_launder()
    cons_name = "eq_REC_launder"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (rps,st,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c,r,h) in Iterators.product(set_i,set_c,set_rfeas,set_h)
            if (in((r,st),set_r_st) && haskey(dict_RecTech,(rps,st,i,t)) 
                && haskey(dict_valgen,(i,c,r,t)))
                JuMP.add_to_expression!(lhs,param_hours[h],variables["GEN"][(i,c,r,h,t)]);
            end
        end
        for (i,ast) in Iterators.product(set_i,set_stfeas)
            if haskey(dict_RecMap,(i,rps,ast,st,t)) && (ast != st)
                JuMP.add_to_expression!(lhs,1,variables["RECS"][(rps,i,st,ast,t)]);
            end
        end

        constraints["$(cons_name)"][(rps,st,t)] = JuMP.@constraint(model,
            lhs >= rhs);
        set_name(constraints["$(cons_name)"][(rps,st,t)],"$(cons_name)($(rps),$(st),$(t))");
    end
end 

# -----------------------------------------------------------------------
# *====================================
# * --- FUEL SUPPLY CURVES ---
# *====================================

function eq_gasused()
    cons_name = "eq_gasused"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (cendiv,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for (i,c,r)  in Iterators.product(set_gas,set_c,set_rfeas) 
            if haskey(dict_valgen,(i,c,r,t))  &&  in((r,cendiv),set_r_cendiv)
                JuMP.add_to_expression!(rhs,param_heat_rate[(i,c,r,t)],variables["GEN"][(i,c,r,h,t)]);
            end
        end
        for gb in (set_gb)
            JuMP.add_to_expression!(lhs,1, variables["GasUsed"][(cendiv,gb,h,t)]);
        end
        constraints["$(cons_name)"][(cendiv,h,t)] = JuMP.@constraint(model, lhs == rhs);
        set_name(constraints["$(cons_name)"][(cendiv,h,t)],"$(cons_name)($(cendiv),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_gasbinlimit()
    cons_name = "eq_gasbinlimit";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (cendiv,gb,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for h in (set_h)
            JuMP.add_to_expression!(rhs,param_hours[h],variables["GasUsed"][(cendiv,gb,h,t)]);
        end
        constraints["$(cons_name)"][(cendiv,gb,t)] = JuMP.@constraint(model,
            param_gaslimit[(cendiv,gb,t)] >= rhs);
        set_name(constraints["$(cons_name)"][(cendiv,gb,t)],"$(cons_name)($(cendiv),$(gb),$(t))");
    end
end 

# -----------------------------------------------------------------------
# *===========
# * bio curve
# *===========

function eq_bioused()
    bio_cofire_perc=0.15;
    cons_name = "eq_bioused";
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (r,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for c in set_c, h in set_h
            if haskey(dict_valgen,("biopower",c,r,t))
                JuMP.add_to_expression!(rhs,param_hours[h]*
                    get(param_heat_rate,("biopower",c,r,t),0),variables["GEN"][("biopower",c,r,h,t)])
            end
            for i in set_cofire
                if  haskey(dict_valgen,(i,c,r,t))
                    JuMP.add_to_expression!(rhs,bio_cofire_perc*param_hours[h]*get(param_heat_rate,(i,c,r,t),0),
                        variables["GEN"][(i,c,r,t)]);
                end
            end
        end
        for bioclass in (set_bioclass)
            JuMP.add_to_expression!(lhs,1,variables["BIOUSED"][(bioclass,r,t)]);
        end
        constraints["$(cons_name)"][(r,t)] = JuMP.@constraint(model, lhs == rhs);
        set_name(constraints["$(cons_name)"][(r,t)],"$(cons_name)($(r),$(t))");
    end
end 

# -----------------------------------------------------------------------

function eq_biousedlimit()
    cons_name = "eq_biousedlimit"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (bioclass,r,t) in str_sets_dict["$(cons_name)"]
        constraints["$(cons_name)"][(bioclass,r,t)] = JuMP.@constraint(model,
            get(param_biosupply,(r,"cap",bioclass),0) >= variables["BIOUSED"][(bioclass,r,t)]
        );
        set_name(constraints["$(cons_name)"][(bioclass,r,t)],"$(cons_name)($(bioclass),$(r),$(t))");
    end
end 

# -----------------------------------------------------------------------
# *============================
# * --- STORAGE CONSTRAINTS ---
# *============================

function eq_storage_capacity()
    cons_name = "eq_storage_capacity"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (i,c,r,h,t) in str_sets_dict["$(cons_name)"]       
        (lhs,rhs) = _add_rhs_lhs(model);
        for rr in (set_rfeas_cap)
            if haskey(dict_valcap,(i,c,rr,t))  && haskey(dict_cap_agg,(r,rr))
                JuMP.add_to_expression!(lhs,param_outage[(i,h)],variables["CAP"][(i,c,rr,t)]);
            end
        end
        for or in set_ortype
            JuMP.add_to_expression!(rhs,1, variables["OPRES"][(or,i,c,r,h,t)]);
        end
        !in(i,set_csp_storage) ? JuMP.add_to_expression!(rhs,1, variables["STORAGE_IN"][(i,c,r,h,t)]) : nothing;
        JuMP.add_to_expression!(rhs,1, variables["STORAGE_OUT"][(i,c,r,h,t)]);
        constraints["$(cons_name)"][(i,c,r,h,t)] = JuMP.@constraint(model, lhs >= rhs );
        set_name(constraints["$(cons_name)"][(i,c,r,h,t)],"$(cons_name)($(i),$(c),$(r),$(h),$(t))");
    end
end 

# -----------------------------------------------------------------------

function eq_storage_level()
    cons_name = "eq_storage_level"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (i,c,r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for hh in set_h 
            if in((h,hh),set_nexth)
                JuMP.add_to_expression!(lhs,1,variables["STORAGE_LEVEL"][(i,c,r,hh,t)]);
            end
        end
        JuMP.add_to_expression!(rhs,1,variables["STORAGE_LEVEL"][(i,c,r,h,t)]);
        JuMP.add_to_expression!(rhs,param_storage_eff[(i,t)]
            *param_hours_daily[h],variables["STORAGE_IN"][(i,c,r,h,t)]);
        JuMP.add_to_expression!(rhs,-param_hours_daily[h],variables["STORAGE_OUT"][(i,c,r,h,t)]);

        constraints["$(cons_name)"][(i,c,r,h,t)] = JuMP.@constraint(model, lhs == rhs);
        set_name(constraints["$(cons_name)"][(i,c,r,h,t)],"$(cons_name)($(i),$(c),$(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

function eq_storage_duration()
    cons_name = "eq_storage_duration"
    constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

    for (i,c,r,h,t) in str_sets_dict["$(cons_name)"]
        (lhs,rhs) = _add_rhs_lhs(model);
        for rr in (set_rfeas_cap)
            if haskey(dict_valcap,(i,c,rr,t)) && haskey(dict_cap_agg,(r,rr))
                JuMP.add_to_expression!(lhs,param_storage_duration[i],variables["CAP"][(i,c,rr,t)]);
            end
        end
        JuMP.add_to_expression!(rhs,1,variables["STORAGE_LEVEL"][(i,c,r,h,t)])
        constraints["$(cons_name)"][(i,c,r,h,t)] = JuMP.@constraint(model, lhs >= rhs );
        set_name(constraints["$(cons_name)"][(i,c,r,h,t)],"$(cons_name)($(i),$(c),$(r),$(h),$(t))");
    end
end

# -----------------------------------------------------------------------

print("eq_loadcon"); @time eq_loadcon();
print("eq_cap_init_noret"); @time  eq_cap_init_noret();
print("eq_cap_new_noret"); @time  eq_cap_new_noret();
print("eq_forceprescription"); @time  eq_forceprescription();
print("eq_neartermcaplimit"); @time  eq_neartermcaplimit();
print("eq_refurblim"); @time  eq_refurblim();

print("eq_rsc_inv_account"); @time  eq_rsc_inv_account();
print("eq_rsc_INVlim"); @time  eq_rsc_INVlim();
print("eq_capacity_limit"); @time  eq_capacity_limit();
print("eq_curt_gen_balance"); @time  eq_curt_gen_balance();
print("eq_curtailment"); @time  eq_curtailment();
print("eq_mingen_lb"); @time  eq_mingen_lb();
print("eq_mingen_ub"); @time  eq_mingen_ub();

print("eq_dhyd_dispatch"); @time  eq_dhyd_dispatch();
print("eq_supply_demand_balance"); @time  eq_supply_demand_balance();
print("eq_minloading"); @time  eq_minloading();
print("eq_ORCap"); @time  eq_ORCap();
print("eq_OpRes_requirement"); @time  eq_OpRes_requirement();
print("eq_PRMTRADELimit"); @time  eq_PRMTRADELimit();
print("eq_reserve_margin"); @time  eq_reserve_margin();
print("eq_CAPTRAN"); @time  eq_CAPTRAN();
print("eq_prescribed_transmission"); @time  eq_prescribed_transmission();
print("eq_SubStationAccounting"); @time  eq_SubStationAccounting();
print("eq_INVTRAN_VCLimit"); @time  eq_INVTRAN_VCLimit();
print("eq_transmission_limit"); @time  eq_transmission_limit();
print("eq_emit_accounting"); @time  eq_emit_accounting();
# print("eq_RGGI_cap"); @time  eq_RGGI_cap();
# print("eq_AB32_cap"); @time  eq_AB32_cap();
# print("eq_batterymandate"); @time  eq_batterymandate();
print("eq_REC_Generation"); @time  eq_REC_Generation();
print("eq_REC_Requirement"); @time  eq_REC_Requirement();
print("eq_REC_launder"); @time  eq_REC_launder();
print("eq_gasused"); @time  eq_gasused()
print("eq_gasbinlimit"); @time  eq_gasbinlimit();
print("eq_bioused"); @time  eq_bioused();
print("eq_biousedlimit"); @time  eq_biousedlimit();
print("eq_storage_capacity"); @time  eq_storage_capacity();
print("eq_storage_level"); @time  eq_storage_level();
print("eq_storage_duration"); @time  eq_storage_duration();
