
# *=========================
# * --- LOAD CONSTRAINT ---
# *=========================
cons_name = "eq_loadcon";
set_ = str_sets_dict["$(cons_name)"] ;
constraints["$(cons_name)"] =JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_);

for s in set_
     constraints["$(cons_name)"][s]  = JuMP.@constraint(model, 
        variables["LOAD"][s] 
        ==
        get(param_load_exog,"$s",0) + get(param_can_exports_h,"$s",0)
        )
end

# -----------------------------------------------------------------------

# *====================================
# * -- existing capacity equations --
# *====================================

cons_name = "eq_cap_init_noret";
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for i in set_i2, c in set_initc, r in set_rfeas_cap, t in set_t
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & (!haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)") | (t <= set_retireyear[1]) )
        
        constraints["$(cons_name)"][join((i, c, r, t),"_")] = JuMP.@constraint(model, 
            variables["CAP"][join((i, c, r, t),"_")] == param_exo_cap["$(i)_$(c)_$(r)_$(t)"] 
        )
    end
end

# -----------------------------------------------------------------------
# *==============================
# * -- new capacity equations --
# *==============================

cons_name = "eq_cap_new_noret"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for i in (set_i2), c in (set_newc), r in (set_rfeas), t in (set_t)
    if ((t <= set_retireyear[1]) | !haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)")) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 

        valid_tt_1 = [tt for tt in set_t 
                if (tt <= t) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(tt)")];

        valid_tt_2 = [ tt for tt in set_t 
                if (tt <= t) & (t-tt < param_maxage[i]) & haskey(dict_ict,"$(i)_$(c)_$(tt)") & in(i,set_refurbtech) ];

        rhs_1 = !isempty(valid_tt_1) ? sum([ param_degrade["$(i)_$(tt)_$(t)"]*variables["INV"][join((i,c,r,tt),'_')]  for tt in valid_tt_1 ]) : 0 ;
        rhs_2 = !isempty(valid_tt_2) ? sum([ param_degrade["$(i)_$(tt)_$(t)"]*variables["INVREFURB"][join((i,c,r,tt),'_')] for tt in valid_tt_2 ]) : 0 ;
        
        constraints["$(cons_name)"][join((i,c,r,t),'_')]  = 
            #LHS
            JuMP.@constraint(model, 
            variables["CAP"][join((i,c,r,t),'_')]  ==  
            #RHS
            rhs_1 + rhs_2
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_forceprescription"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);


for pcat in (set_pcat), r in (set_rfeas), t in (set_t)
    valid_cond1 = sum([ 1 for i in set_i2, c in set_newc if in((pcat,i),set_prescriptivelink) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ]);
    if  ( valid_cond1 > 0) & in((pcat,t),set_force_pcat)
       
       v_EXTRA_PRESCRIP = (t >=  param_firstyear_pcat[pcat]) ? variables["EXTRA_PRESCRIP"][join((pcat,r,t),"_")] : 0 ;
       valid_sum2 = [ (i,c) for i in (set_i2),c in (set_newc) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  & in((pcat,i),set_prescriptivelink) ];
       
       rhs_1 = !isempty(valid_sum2) ? sum([variables["CAP"][join((i,c,r,t),"_")]  for (i,c) in valid_sum2]) : 0 ;
 
       constraints["$(cons_name)"][join((pcat,r,t),"_")] = JuMP.@constraint(model,
       # LHS
           get(param_m_required_prescriptions,"$(pcat)_$(r)_$(t)",0)
           + v_EXTRA_PRESCRIP
           ==
       # RHS
           rhs_1  
       );
   end
end


# -----------------------------------------------------------------------
cons_name = "eq_refurblim"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for i in (set_refurbtech),  r in (set_rfeas_cap),  t in (set_t)        
    valid_sum_1 = [ (c,tt) for c in (set_newc), tt in (set_t) 
                    if haskey(dict_m_refurb_cond,"$(i)_$(c)_$(r)_$(t)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(tt)") ];

    valid_sum_2 = [(c,tt) for c in set_c, tt in set_t if tt <= t & haskey(param_m_avail_retire_exog_rsc,"$(i)_$(c)_$(r)_$(tt)") ] ;

    valid_sum_3 = [ (c,tt) for  c in set_c, tt in (set_t) 
                    if (tt <= t) & (t - tt < param_maxage[i]) & haskey(dict_ict,"$(i)_$(c)_$(t)") ];

    lhs_1 = !isempty(valid_sum_1) ? sum([ variables["INV"][join((i,c,r,tt),"_")] for (c,tt) in valid_sum_1 ]) : 0 ;
    lhs_2 = !isempty(valid_sum_2) ? sum([ param_m_avail_retire_exog_rsc["$(i)_$(c)_$(r)_$(tt)"] for (c,tt) in valid_sum_2 ]) : 0 ;
    rhs_1 = !isempty(valid_sum_3) ? sum([ variables["INVREFURB"][join((i,c,r,tt),"_")] for (c,tt) in valid_sum_3 ])  : 0 ;

    constraints["$(cons_name)"][join((i,r,t),"_")] = JuMP.@constraint(model, 
        #LHS
        lhs_1 + lhs_2
        >=
        #RHS
        rhs_1
    )                    
end

# -----------------------------------------------------------------------

# eq_rsc_inv_account 
cons_name = "eq_rsc_inv_account"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
for i in (set_rsc_i), c in (set_newc), r in (set_rfeas), t in (set_t)
    if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        
        valid_sum_1 = [rscbin for rscbin in (set_rscbin) if haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)")];
        lhs_1 = !isempty(valid_sum_1) ? sum([ variables["INV_RSC"][join((i,c,r,rscbin,t),"_")] for rscbin in valid_sum_1 ]) : 0 ;
       constraints["$(cons_name)"][join((i,c,r,t),"_")] = JuMP.@constraint(model,
            #LHS
            lhs_1
            ==
            #RHS
            variables["INV"][join((i,c,r,t),"_")] 
        )
    end
end

# -----------------------------------------------------------------------

# eq_rsc_INVlim
cons_name = "eq_rsc_INVlim"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
# temp_cont = Array{ConstraintRef,1}(); 
for i in (set_i2), r in (set_rfeas_cap), rscbin in (set_rscbin)
    
    if in(i,set_rsc_i) & haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)") 
        
        valid_sum_1 = [ (ii,c,tt) for ii in (set_i2), c in (set_newc), tt in (set_t) 
                            if haskey(dict_valcap,"$(ii)_$(c)_$(r)_$(tt)")  & in((i,ii),set_rsc_agg) & haskey(param_resourcescaler,"$ii") ];
        rhs_1 = !isempty(valid_sum_1) ? sum([ variables["INV_RSC"][join((ii,c,r,rscbin,tt),"_")] for (ii,c,tt) in valid_sum_1 ]) : continue ;
        constraints["$(cons_name)"][join((i,r,rscbin),"_")] = JuMP.@constraint(model,
            get(param_m_rsc_dat,"$(r)_$(i)_$(rscbin)_cap",0)
            >=
            rhs_1 # tmodel(tt) or tfix(tt)
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_capacity_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);
for i in (set_i2), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") & !(in(i,set_storage)) & !(in(i,set_hydro_d)) 
        
        val_sum_1 = [ rr for rr in (set_rfeas_cap) 
                        if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)") & !in(i,set_cf_tech)];
        
        val_sum_2 = [ rr for rr in (set_rfeas_cap) 
                        if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)") & in(i,set_cf_tech) ];
        
        val_sum_3 = [ or for or in (set_ortype) if haskey(param_reserve_frac,"$(i)_$(or)") ]
        
        lhs_1 = !isempty(val_sum_1) ? sum([variables["CAP"][join((i,c,rr,t),"_")]  for rr in val_sum_1 ]) : 0 ;
        lhs_2 = !isempty(val_sum_2) ? sum([get(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)",0)*variables["CAP"][join((i,c,rr,t),"_")]  for rr in val_sum_2 ]) : 0 ;
        rhs_3 = !isempty(val_sum_3) ? sum([variables["OPRES"][join((or,i,c,r,h,t),"_")] for or in val_sum_3 ]) : 0 ;
        
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            
            (param_outage["$(i)_$(h)"]*lhs_1) + lhs_2
            >=
            variables["GEN"][join((i,c,r,h,t),"_")] + rhs_3 # $SwM_OpRes
        )
    end
end


# -----------------------------------------------------------------------

cons_name = "eq_curt_gen_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
for r in (set_rfeas) , h in (set_h), t in (set_t)
        
    val_sum_1 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")];

    val_sum_2 = [ (i,c) for i in (set_vre), c in (set_c) 
                    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    
    val_sum_3 = [ (or,i,c) for or in (set_ortype), i in (set_vre),c in (set_c) 
                    if haskey(param_reserve_frac,"$(i)_$(or)") & haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ]; #$SwM_OpRes,

    lhs_1 = !isempty(val_sum_1) ? sum([get(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)",0)*variables["CAP"][join((i,c,rr,t),"_")] for (i,c,rr) in val_sum_1 ]) : 0 ;
    rhs_1 = !isempty(val_sum_2) ? sum([variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_2 ]) : 0 ;
    rhs_2 = !isempty(val_sum_3) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for (or,i,c) in val_sum_3 ]) : 0 ;
    
    constraints["$(cons_name)"][join((r,h,t),"_")] = JuMP.@constraint(model,
        lhs_1 - variables["CURT"][join((r,h,t),"_")] 
        >=
        rhs_1 + rhs_2 
    )
end 

# -----------------------------------------------------------------------

cons_name = "eq_curtailment"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);
for r in (set_rfeas), h in (set_h), t in (set_t)
    val_sum_1 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")];

    val_sum_2 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if (haskey(dict_cap_agg,"$(r)_$(rr)")  & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)")
                        & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")  )];
    val_sum_3 = [(h,szn,tt)  for (h,szn) in (set_h_szn), tt in (set_t) if (t-2 == tt) ];
    val_sum_4 = [ (i,c) for i in (set_storage), c in (set_c) if  haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];

    rhs_1 = !isempty(val_sum_1) ? sum([get(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)",0)*0*variables["CAP"][join((i,c,rr,t),"_")]# curt_avg(r,h,t)
                for (i,c,rr) in val_sum_1 ])  : 0 ;
    rhs_2 = !isempty(val_sum_2) ? sum([get(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)",0)*variables["INV"][join((i,c,r,t),"_")]*0 #  curt_marg(i,rr,h,t)
                for (i,c,rr)  in val_sum_2 ])  : 0 ;
    rhs_3 = !isempty(val_sum_3) ? sum([ variables["MINGEN"][join((r,szn,t),"_")] - variables["MINGEN"][join((r,szn,tt),"_")] for (h,szn,tt) in val_sum_3 ])*0 : 0 ; # curt_mingen(r,h,t)
    rhs_4 = !isempty(val_sum_4) ? sum([ variables["STORAGE_IN"][join((i,c,r,h,t),"_")]*0 for (i,c) in val_sum_4 ]) : 0 ;  # curt_storage(i,r,h,t) 
    
    constraints["$(cons_name)"][join((r,h,t),"_")]  = JuMP.@constraint(model,
        variables["CURT"][join((r,h,t),"_")] 
        >=
        rhs_1 + rhs_2+ rhs_3 - rhs_4 + 0 #surpold(r,h,t)
    )
end


# -----------------------------------------------------------------------

cons_name = "eq_mingen_lb";
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), (h,szn) in (set_h_szn), t in (set_t)        
    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    rhs_1 = !isempty(val_sum_1) ?  sum([ variables["GEN"][join((i,c,r,h,t),"_")]* get(param_minloadfrac,"$(r)_$(i)_$(h)",0) for (i,c) in val_sum_1 ]) : 0 ;

    constraints["$(cons_name)"]["$(r)_$(h)_$(szn)_$(t)"] = JuMP.@constraint(model,
        variables["MINGEN"][join((r,szn,t),"_")]
        >=
        rhs_1 
        + 0 # geothermal
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_mingen_ub";
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for r in set_rfeas, (h ,szn) in set_h_szn, t in set_t
    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)")  & haskey(param_minloadfrac,"$(r)_$(i)_$(h)") ];
    rhs_1 = !isempty(val_sum_1) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_1 ]) : 0 ;
    constraints["$(cons_name)"][join((r,h,szn,t),"_")] = JuMP.@constraint(model,
        variables["MINGEN"][join((r,szn,t),"_")]
        <=
        rhs_1 
        + 0 ) # geothermal
    
end

# -----------------------------------------------------------------------

cons_name = "eq_dhyd_dispatch"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
for i in (set_hydro_d),c in (set_c), r in (set_rfeas), szn in (set_szn), t in (set_t)
    
    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") 
        
        val_sum_0 = [h for h in (set_h) if in((h,szn),set_h_szn) ];
        val_sum_1 = [ or for or in (set_ortype) if haskey(param_reserve_frac,"$(i)_$(or)")];
        
        inner_sum(h) = !isempty(val_sum_1) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for or in val_sum_1]) : 0 ;
        lhs_1 = !isempty(val_sum_0) ? sum([ param_hours["$h"]*param_outage["$(i)_$(h)"] for h in val_sum_0 ]) : 0 ;
        lhs_2 = (get(param_cfhist_hyd,"$(r)_$(t)_$(szn)_$(i)",0) * get(param_cf_hyd_szn_adj,"$(i)_$(szn)_$(r)",0) 
                * get(param_cf_hyd,"$(i)_$(szn)_$(r)",0) * variables["CAP"][join((i,c,r,t),"_")]) ; 
        rhs_1 = !isempty(val_sum_0) ? sum([ param_hours["$h"]*(variables["GEN"][join((i,c,r,h,t),"_")] + inner_sum(h)) for h in val_sum_0 ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,r,szn,t),"_")] = JuMP.@constraint(model,
            
            lhs_1*lhs_2
            >= 
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------
# *===============================
# * --- SUPPLY DEMAND BALANCE ---
# *===============================

cons_name = "eq_supply_demand_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);


for r in (set_rfeas), h in (set_h), t in (set_t) 
    
    val_sum_0 = [(i,c) for i in (set_i2), c in (set_c) if !in(i,set_storage) & haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_1 = [(rr,tr) for rr in (set_rfeas), tr in (set_trtype) if  haskey(dict_routes,"$(rr)_$(r)_$(tr)_$(t)") ];
    val_sum_2 = [ (rr,tr) for rr in (set_rfeas), tr in (set_trtype) if  haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")  ];
    
    val_sum_3 = [ (i,c) for i in  (set_storage), c in (set_c) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    
    val_sum_4 = [ (i,c) for i in  (set_storage), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_csp_storage) ];
    
    lhs_1 = !isempty(val_sum_0) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_0 ])  : 0 ;
    lhs_2 = !isempty(val_sum_1) ? sum( [ (1-param_tranloss["$(rr)_$(r)"])* variables["FLOW"][join((rr,r,h,tr,t),"_")] for (rr,tr) in val_sum_1 ]) : 0 ;
    lhs_3 = !isempty(val_sum_2) ? sum( [ variables["FLOW"][join((r,rr,h,tr,t),"_")] for (rr,tr) in val_sum_2 ])  : 0 ;
    lhs_4 = !isempty(val_sum_3) ? sum( [ variables["STORAGE_OUT"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_3 ])  : 0 ;# SwM_Storage 
    lhs_5 = !isempty(val_sum_4) ? sum( [ variables["STORAGE_IN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_4 ])   : 0 ;# SwM_Storage
    
    constraints["$(cons_name)"][join((r,h,t),"_")] = JuMP.@constraint(model,
        lhs_1 + lhs_2  - lhs_3 + lhs_4 - lhs_5      + 0 # geo
        ==
        variables["LOAD"][join((r,h,t),"_")]
    )
end

# -----------------------------------------------------------------------
# *=======================================
# * --- MINIMUM LOADING CONSTRAINTS ---
# *=======================================

cons_name = "eq_minloading"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
for i in (set_i2), c in (set_c), r in (set_rfeas), (h,hh) in (set_hour_szn_group), t in (set_t) 
    if haskey(param_minloadfrac,"$(r)_$(i)_$(hh)") & haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") 
        
        constraints["$(cons_name)"][join((i,c,r,h,hh,t),"_")] = JuMP.@constraint(model,
            variables["GEN"][join((i,c,r,h,t),"_")]
            >=
            variables["GEN"][join((i,c,r,hh,t),"_")] * get(param_minloadfrac,"$(r)_$(i)_$(hh)",0)
        )
    end
end

# -----------------------------------------------------------------------
# *=======================================
# * --- OPERATING RESERVE CONSTRAINTS ---
# *=======================================
cons_name = "eq_ORCap"
temp_i = [ i for i in set_i2 if !in(i,set_storage_no_csp) & !in(i,set_hydro_nd)];
temp_ori = [ (or,i) for or in (set_ortype), i in (temp_i) if haskey(param_reserve_frac,"$(i)_$(or)") ];
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);


for (or,i) in temp_ori, c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if  haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") 
        
        val_sum_1 = [ (hh,szn) for hh in set_h, szn in set_szn if in((h,szn),set_h_szn) & haskey(dict_maxload_szn,"$(r)_$(hh)_$(t)_$(szn)") ];
        lhs_1 = !isempty(val_sum_1) ? sum( [ variables["GEN"][join((i,c,r,hh,t),"_")] for (hh,szn) in val_sum_1 ]) : 0 ;
        
        constraints["$(cons_name)"][join((or,i,c,r,h,t),"_")] = JuMP.@constraint(model,
            
            param_reserve_frac["$(i)_$(or)"] * lhs_1  #
            >=
            variables["OPRES"][join((or,i,c,r,h,t),"_")]
        );
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_OpRes_requirement"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);

for or in (set_ortype), r in (set_rfeas), h in (set_h), t in (set_t) 
    
    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) 
                    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") & (haskey(param_reserve_frac,"$(i)_$(or)") | in(i,set_storage) | in(i,set_hydro_d)) 
                        & !in(i,set_hydro_nd)];
    val_sum_2 = [ rr for rr in (set_rfeas) if   haskey(dict_opres_routes,"$(rr)_$(r)_$(t)")];
    val_sum_3 = [ rr for rr in (set_rfeas) if   haskey(dict_opres_routes,"$(r)_$(rr)_$(t)")];
    val_sum_4 = [ (i,c) for i in (set_wind), c in (set_c) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_5 = [ (i,c) for i in (set_pv), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(h,set_dayhours) ];
    
    lhs_1 = !isempty(val_sum_1) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for (i,c) in val_sum_1 ])  : 0 ;
    lhs_2 = !isempty(val_sum_2) ? sum([ (1-param_tranloss["$(rr)_$(r)"])*variables["OPRES_FLOW"][join((or,rr,r,h,t),"_")] for rr in val_sum_2 ]) : 0 ;
    lhs_3 = !isempty(val_sum_3) ? sum( [ variables["OPRES_FLOW"][join((or,r,rr,h,t),"_")] for rr in val_sum_3 ])  : 0 ;
    rhs_1 = !isempty(val_sum_4) ? sum( [variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_4 ])  : 0 ;
    rhs_2 = !isempty(val_sum_5) ? sum( [variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_5 ]) : 0 ;
    
    
    constraints["$(cons_name)"][join((or,r,h,t),"_")] = JuMP.@constraint(model,
        lhs_1 + lhs_2 - lhs_3 + 0 # geo
        >=
         variables["LOAD"][join((r,h,t),"_")] * get(param_orperc,"$(or)_or_load",0)
        + get(param_orperc,"$(or)_or_wind",0) * rhs_1
        + get(param_orperc,"$(or)_or_pv",0) * rhs_2
    )
end     

# -----------------------------------------------------------------------
# *=================================
# * --- PLANNING RESERVE MARGIN ---
# *=================================
cons_name = "eq_PRMTRADELimit";
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, str_sets_dict["$(cons_name)"]);
for r in (set_rfeas), rr in (set_rfeas), szn in (set_szn), t in (set_t)
    
    val_sum_1 = [ tr for tr in (set_trtype) if haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")];
    if !isempty(val_sum_1) # SwM_ReserveMargin
        
        lhs_1 = sum([ variables["CAPTRAN"][join((r,rr,tr,t),"_")] for tr in val_sum_1 ]) 
        constraints["$(cons_name)"][join((r,rr,szn,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
            >=
            variables["PRMTRADE"][join((r,rr,szn,t),"_")]
        );
    end
end

# # -----------------------------------------------------------------------

cons_name = "eq_reserve_margin"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), szn in (set_szn), t in (set_t) #SwM_ReserveMargin

    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_rsc_i) & !in(i,set_storage)] ;

    val_sum_2 = [ (i,rr) for i in (set_i2), rr in (set_rfeas_cap) if  (in(i,set_vre) | in(i,set_storage)) & haskey(dict_cap_agg,"$(r)_$(rr)") ];

    val_sum_3 = [ (i,c,rr) for i in (set_i2), c in (set_c), rr in (set_rfeas_cap)
                    if ( haskey(dict_cap_agg,"$(r)_$(rr)") & (in(i,set_vre) | in(i,set_storage)) 
                        & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)") & haskey(dict_ict,"$(i)_$(c)_$(t)") & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)") ) ];

    val_sum_4 = [ c for c in (set_c) if haskey(dict_valcap,"distPV_$(c)_$(r)_$(t)")];

    val_sum_5 = [ (i,c,r) for i in (set_i2), c in (set_c), rr in (set_rfeas_cap)
                    if ((in(i,set_vre) | in(i,set_storage)) & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")  & haskey(dict_cap_agg,"$(r)_$(rr)"))];

    val_sum_6 = [ (i,c) for i in (set_hydro_nd), c in (set_c) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_7 = [ (i,c) for i in (set_hydro_d), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_8 = [ rr for rr in (set_rfeas) if (sum([ 1 for tr in set_trtype if haskey(dict_routes,"$(rr)_$(r)_$(tr)_$(t)")]) >0)];
    val_sum_9 = [ rr for rr in (set_rfeas) if (sum([ 1 for tr in set_trtype if haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")]) >0)];

    lhs_1 = !isempty(val_sum_1) ? sum([ variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_1 ])  :  0 ; 
    lhs_2 = !isempty(val_sum_2) ? sum([ 0 for (i,rr) in val_sum_2 ]) :  0 ; # cv_old(i,rr,szn,t) set to zero ? why ?
    lhs_3 = !isempty(val_sum_3) ? sum([ get(param_m_cv_mar,"$(i)_$(rr)_$(szn)_$(t)",0)*variables["INV"][join((i,c,rr,t),"_")]  for (i,c,rr) in val_sum_3 ]) :  0 ; 
    lhs_4 = !isempty(val_sum_4) ? sum([ get(param_exo_cap,"distPV_$(c)_$(r)_$(t)",0)  - get(param_exo_cap,"distPV_$(c)_$(r)_$(t-2)",0)  for c in val_sum_4 ]) : 0; 
    lhs_5 = !isempty(val_sum_5) ? sum([ variables["CAP"][join((i,c,rr,t),"_")]*0 for (i,c,rr) in val_sum_5 ]) :  0 ; # cv_avg(i,rr,szn,t) set to zero ? why ? 
    lhs_6 = !isempty(val_sum_6) ? sum([  variables["GEN"][join((i,c,r,"h3",t),"_")] for (i,c) in val_sum_6 ]) :  0 ;  # "h3" => 6
    lhs_7 = !isempty(val_sum_7) ? sum([ param_cf_hyd_szn_adj["$(i)_$(szn)_$(r)"]*variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_7 ])  :  0 ; 
    lhs_8 = !isempty(val_sum_8) ? sum([ (1-param_tranloss["$(rr)_$(r)"])* variables["PRMTRADE"][join((rr,r,szn,t),"_")] for rr in val_sum_8 ]) :  0 ; 
    lhs_9 = !isempty(val_sum_9) ? sum([ variables["PRMTRADE"][join((r,rr,szn,t),"_")] for rr in val_sum_9 ]) :  0 ; 


    constraints["$(cons_name)"][join((r,szn,t),"_")] = JuMP.@constraint(model,

        lhs_1 + lhs_2 + lhs_3 + lhs_4*get(param_m_cv_mar,"distPV_$(r)_$(szn)_$(t)",0) + lhs_5 + lhs_6 + lhs_7 + lhs_8 - lhs_9
        + 0# geothermal
        >=
        (1+param_prm["$(r)_$(t)"]) * param_peakdem["$(r)_$(szn)_$(t)"]
    )
end

# -----------------------------------------------------------------------
# *================================
# * --- TRANSMISSION CAPACITY  ---
# *================================
cons_name = "eq_CAPTRAN"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas),rr in (set_rfeas), trtype in (set_trtype),t in (set_t)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)")
        val_sum_1 = [ tt  for tt in (set_t) if (tt <= t) & (tt > 2020) & (param_INr["$r"] == param_INr["$rr"])];
        rhs_1 = !isempty(val_sum_1) ? sum([ variables["INVTRAN"][join((rr,r,tt,trtype),"_")] + variables["INVTRAN"][join((r,rr,tt,trtype),"_")] 
                    for tt in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,trtype,t),"_")] = JuMP.@constraint(model,
            variables["CAPTRAN"][join((r,rr,trtype,t),"_")]
            ==
            param_trancap_exog["$(r)_$(rr)_$(trtype)_$(t)"]
            + rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_prescribed_transmission"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), rr in (set_rfeas), trtype in (set_trtype), t in (set_t)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)") & (t<= 2020)
        val_sum_1 = [ tt  for tt in set_t if (tt <= t)];
        val_sum_2 = [ tt for tt in (set_t) if (tt <= t)];
    
        lhs_1 = !isempty(val_sum_1) ? sum([ get(param_futuretran,"$(r)_$(rr)_possible_$(tt)_$(trtype)",0) + get(param_futuretran,"$(rr)_$(r)_possible_$(tt)_$(trtype)",0) for tt in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2) ? sum([ variables["INVTRAN"][join((r,rr,trtype,tt),"_")] + variables["INVTRAN"][join((rr,r,trtype,tt),"_")] for tt in val_sum_2 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,trtype,t),"_")] = JuMP.@constraint(model,
            lhs_1
            >=
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_SubStationAccounting"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), t in (set_t)
    val_sum_1 = [ vc for vc in set_vc if in((r,vc),set_tranfeas)]; 
    val_sum_2 = [rr for rr in (set_rfeas) if haskey(dict_routes,"$(r)_$(rr)_AC_$(t)")];
    val_sum_3 = [rr for rr in (set_rfeas) if haskey(dict_routes,"$(r)_$(rr)_AC_$(t)")];

    lhs_1 = !isempty(val_sum_1) ? sum([ variables["INVSUBSTATION"][join((r,vc,t),"_")] for vc in val_sum_1]) : 0 ;
    rhs_1 = !isempty(val_sum_2) ? sum([variables["INVTRAN"][join((rr,r,"AC",t),"_")] for rr in val_sum_2 ])  : 0 ;
    rhs_2 = !isempty(val_sum_3) ? sum([variables["INVTRAN"][join((r,rr,"AC",t),"_")] for rr in val_sum_3 ]) : 0 ;
    constraints["$(cons_name)"][join((r,t),"_")] = JuMP.@constraint(model,
        lhs_1
        ==
        rhs_1 + rhs_2
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_INVTRAN_VCLimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), vc in (set_vc)
    if in((r,vc),set_tranfeas)

        constraints["$(cons_name)"][join((r,vc),"_")] = JuMP.@constraint(model,

            get(param_trancost,"$(r)_cap_$(vc)",0)
            >=
            sum([ variables["INVSUBSTATION"][join((r,vc,t),"_")]  for t in (set_t) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_transmission_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);


for r in (set_rfeas), rr in (set_rfeas), h in (set_h), t in (set_t), trtype in (set_trtype)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)") & haskey(dict_routes,"$(rr)_$(r)_$(trtype)_$(t)")
       
        val_sum_1 = [ortype for ortype in (set_ortype) if (trtype =="AC") & haskey(dict_opres_routes,"$(r)_$(rr)_$(t)") ];
        
        rhs_1 = !isempty(val_sum_1) ? sum( [ variables["OPRES_FLOW"][join((ortype,r,rr,h,t),"_")] for ortype in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,h,trtype,t),"_")] = JuMP.@constraint(model,  
            variables["CAPTRAN"][join((r,rr,trtype,t),"_")]
            >=
            variables["FLOW"][join((r,rr,h,trtype,t),"_")]
            + rhs_1
        )
    end
end

# -----------------------------------------------------------------------
# *=========================
# * --- CARBON POLICIES ---
# *=========================
bio_cofire_perc =0.15;
cons_name = "eq_emit_accounting"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for e in (set_e),  r in (set_rfeas), t in (set_t)
    val_sum_0 = [ (i,c,h) for i in (set_i2), c in (set_c), h in (set_h)  if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_cofire)]; 
    val_sum_1 = [ (i,c,h) for i in (set_cofire), c in (set_c), h in (set_h) if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ]; 

    rhs_1 = !isempty(val_sum_0) ?  sum([ variables["GEN"][join((i,c,r,h,t),"_")]*param_hours["$h"]*get(param_emit_rate,"$(e)_$(i)_$(c)_$(r)_$(t)",0) for (i,c,h) in val_sum_0 ]) : 0 ;
    rhs_2 = !isempty(val_sum_1) ? sum([ (1-bio_cofire_perc)*param_hours["$h"]*get(param_emit_rate,"$(e)_coal-new_$(c)_$(r)_$(t)",0)*variables["GEN"][join((i,c,r,h,t),"_")] for (i,c,h) in val_sum_1 ]) : 0 ;
    constraints["$(cons_name)"][join((e,r,t),"_")] = JuMP.@constraint(model,  
        
        variables["EMIT"][join((e,r,t),"_")]
        ==
        rhs_1 + rhs_2 
    )
end


# -----------------------------------------------------------------------
# *====================================
# * --- FUEL SUPPLY CURVES ---
# *====================================

cons_name = "eq_gasused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for cendiv in (set_cdfeas), h in (set_h), t in (set_t)
    val_sum_1 = [ (i,c,r) for i in (set_gas), c in (set_c), r in (set_rfeas) 
                    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)")  &  in((r,cendiv),set_r_cendiv)];
    lhs_1 = !isempty(set_gb) ? sum([ variables["GasUsed"][join((cendiv,gb,h,t),"_")] for gb in (set_gb) ]) : 0 ;
    
    rhs_1 = !isempty(val_sum_1) ? sum([ param_heat_rate["$(i)_$(c)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")] 
                for (i,c,r) in val_sum_1 ]) : 0 ;
    
    constraints["$(cons_name)"][join((cendiv,h,t),"_")] = JuMP.@constraint(model,
        lhs_1 == rhs_1            
    );
end


# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for cendiv in (set_cdfeas), gb in (set_gb), t in (set_t)

    rhs_1 = !isempty(set_h) ? sum([ param_hours["$h"]*variables["GasUsed"][join((cendiv,gb,h,t),"_")] for h in (set_h)]) : 0 ;
    constraints["$(cons_name)"][join((cendiv,gb,t),"_")] = JuMP.@constraint(model,

        param_gaslimit["$(cendiv)_$(gb)_$(t)"]
        >=
        rhs_1
    )
end

# -----------------------------------------------------------------------
# *===========
# * bio curve
# *===========

bio_cofire_perc=0.15;
cons_name = "eq_bioused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for r in (set_rfeas), t in (set_t)
    val_sum_1 = [ (i,c,h) for i in (set_cofire), c in (set_c), h in (set_h) if  haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_2 = [ (c,h) for c in set_c, h in set_h if haskey(dict_valgen,"biopower_$(c)_$(r)_$(t)")];
    
    rhs_1 = !isempty(val_sum_1) ? sum([ bio_cofire_perc*param_hours["$h"]*param_heat_rate["$(i)_$(c)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")]
                for (i,c,h) in val_sum_1 ]) : 0 ;
    rhs_2 =  !isempty(val_sum_2) ? sum([ param_hours["$h"]*param_heat_rate["biopower_$(c)_$(r)_$(t)"]*variables["GEN"][join(("biopower",c,r,h,t),"_")]  
                for (c,h) in val_sum_2 ]) : 0 ;
    constraints["$(cons_name)"][join((r,t),"_")] = JuMP.@constraint(model,
        
        sum([ variables["BIOUSED"][join((bioclass,r,t),"_")] for bioclass in (set_bioclass)])
        ==
        rhs_2 + rhs_1
        )
end
# -----------------------------------------------------------------------

cons_name = "eq_biousedlimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for bioclass in (set_bioclass), r in (set_rfeas), t in (set_t)
    
    constraints["$(cons_name)"][join((bioclass,r,t),"_")] = JuMP.@constraint(model,
        
        get(param_biosupply,"$(r)_cap_$(bioclass)",0)
        >=
        variables["BIOUSED"][join((bioclass,r,t),"_")]
    )
end

# -----------------------------------------------------------------------
# *============================
# * --- STORAGE CONSTRAINTS ---
# *============================

cons_name = "eq_storage_capacity"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for i in (set_storage), c in (set_c),r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") 
        
        val_sum_1 = !in(i,set_csp_storage) ? variables["STORAGE_IN"][join((i,c,r,h,t),"_")] : 0;
        val_sum_0 = [ rr for rr in (set_rfeas_cap) if haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")  & haskey(dict_cap_agg,"$(r)_$(rr)")];
        
        lhs_1 = !isempty(val_sum_0) ? sum([ variables["CAP"][join((i,c,rr,t),"_")]*param_outage["$(i)_$(h)"] for rr in val_sum_0 ]) : 0 ;
        rhs_1 = !isempty(set_ortype) ? sum([ variables["OPRES"][join((ortype,i,c,r,h,t),"_")] for ortype in set_ortype ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
            >=
            variables["STORAGE_OUT"][join((i,c,r,h,t),"_")]
            + val_sum_1
            + rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_level"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for i in (set_storage), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)")
        val_sum_1 = [  hh for hh in set_h if in((h,hh),set_nexth)];
        val_sum_2 = [ szn for szn in set_szn if in((h,szn),set_h_szn)];
        
        lhs_1 = !isempty(val_sum_1)  ? sum([ variables["STORAGE_LEVEL"][join((i,c,r,hh,t),"_")] for hh in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2)  ?  sum([param_numdays["$szn"] for szn in val_sum_2 ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            lhs_1
            ==
            variables["STORAGE_LEVEL"][join((i,c,r,h,t),"_")]
            + ((variables["STORAGE_IN"][join((i,c,r,h,t),"_")] - variables["STORAGE_OUT"][join((i,c,r,h,t),"_")])*param_hours["$h"])/rhs_1
        );
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,str_sets_dict["$(cons_name)"]);

for szn in (set_szn),i in (set_storage), c in (set_c), r in (set_rfeas),t in (set_t)
    if haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)") 
        val_sum_1 = [ h for h in (set_h) if in((h,szn),set_h_szn)];
        lhs_1 = !isempty(val_sum_1 )  ?  sum([ param_hours["$h"]*variables["STORAGE_IN"][join((i,c,r,h,t),"_")]  for h in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_1 )  ?  sum([param_hours["$h"]*variables["STORAGE_OUT"][join((i,c,r,h,t),"_")]  for h in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((szn,i,c,r,t),"_")] = JuMP.@constraint(model,
            param_storage_eff["$(i)_$(t)"]* lhs_1
            ==
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

## Fixing unsed variables
for i in set_i2, r in (set_rfeas_cap), t in (set_t)
    if !in(i,set_pcat)
        JuMP.@constraint(model, variables["EXTRA_PRESCRIP"][join((i,r,t),"_")] == 0.0)
    end
    for c in (set_c)
        if !haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")
            JuMP.@constraint(model,variables["INV"][join((i,c,r,t),"_")] == 0.0)
            JuMP.@constraint(model,variables["CAP"][join((i,c,r,t),"_")] == 0.0)

        end
    end
end

for i in set_i2, c in (set_c), r in (set_rfeas), t in (set_t) , h in set_h
    if !haskey(dict_valgen,"$(i)_$(c)_$(r)_$(t)")
        JuMP.@constraint(model,variables["GEN"][join((i,c,r,h,t),"_")] == 0.0)
        for or in set_ortype
            JuMP.@constraint(model,variables["OPRES"][join((or,i,c,r,h,t),"_")] == 0.0)
        end
    end
end
