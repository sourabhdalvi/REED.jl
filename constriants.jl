# *=========================
# * --- LOAD CONSTRAINT ---
# *=========================

set_ =  concat_sets(set_rfeas,set_h,set_t);
b = [ haskey(param_can_exports_h,"$s") ? param_lmnt["$s"] + param_can_exports_h["$s"] : param_lmnt["$s"] for s in set_];

cont_ = JuMP.@constraint(model,   variables["LOAD"].data[1:end] .== b[1:end]);

constraints["eq_loadcon"] =JuMP.Containers.DenseAxisArray(cont_,set_);

# -----------------------------------------------------------------------

# *====================================
# * -- existing capacity equations --
# *====================================

temp_tprime = [ t for t in set_t if t <= set_retireyear[1]];
set_ =  concat_sets(set_i2,set_initc,set_rfeas,temp_tprime);
keys_ = keys(dict_valcap);
f_set_ = filter( x-> in(x,keys_), set_);
b = [param_exo_cap[s] for s in f_set_];
A = [variables["CAP"][s] for s in f_set_];

cont_ = JuMP.@constraint(model,   A[1:end] .== b[1:end]);
constraints["eq_cap_init_noret"] = JuMP.Containers.DenseAxisArray(cont_,f_set_);

# -----------------------------------------------------------------------

temp_tprime = [ t for t in set_t if t >= set_retireyear[1]];
set_ =  concat_sets(set_i2,set_initc,set_rfeas,temp_tprime);
keys_1 = keys(dict_valcap); keys_2 = keys(dict_retiretech);
f_set_ = filter( x-> in(x,keys_1) && in(x,keys_2) , set_);
b = [param_exo_cap[s] for s in f_set_];
A = [variables["CAP"][s] for s in f_set_];
cont_ = JuMP.@constraint(model,   A[1:end] .<= b[1:end]);
constraints["eq_cap_init_retub"] = JuMP.Containers.DenseAxisArray(cont_,f_set_);

# -----------------------------------------------------------------------

f_set_2 = [s[1:end-4]*string(parse(Int,s[end-3:end])-2) for s in f_set_];
b = [variables["CAP"][s] for s in f_set_2];
A = [variables["CAP"][s] for s in f_set_];

cont_ = JuMP.@constraint(model,   A[1:end] .<= b[1:end]);
constraints["eq_cap_init_retmo"] = JuMP.Containers.DenseAxisArray(cont_,f_set_);

# *==============================
# * -- new capacity equations --
# *==============================

cons_name = "eq_cap_new_noret"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_initc,set_rfeas,set_t));
# eq_cap_new_noret
# f_set = [(i,c,r,t) for i in (set_i2), c in (set_initc), r in (set_rfeas), t in (set_t) 
# if ((t <= set_retireyear[1]) | !haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)")) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ]
# lhs_1 = [variables["CAP"][join((i,c,r,t),'_')] for (i,c,r,t) in f_set ];

# valid_tt_1 = [ (i,c,r,t) for (i,c,r,t) in f_set 
#                 if (tt <= t) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(tt)")];
# rhs_1 = [param_degrade["$(i)_$(tt)_$(t)"]*variables["INV"][join((i,c,r,tt),'_')] for (i,c,r,t) in valid_tt_1 ];

# cont_ = JuMP.@constraint(model,   lhs_1 .== rhs_1 + rhs_2);

for i in (set_i2), c in (set_initc), r in (set_rfeas), t in (set_t)

    if ((t <= set_retireyear[1]) | !haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)")) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 

        valid_tt_1 = [tt for tt in set_t 
                if (tt <= t) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(tt)")];

        valid_tt_2 = [ tt for tt in set_t 
                if (tt <= t) & (t-tt < param_maxage[i]) & haskey(dict_ict,"$(i)_$(c)_$(tt)") & haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(tt)") ];

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

# eq_cap_new_retub
cons_name = "eq_cap_new_retub"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_initc,set_rfeas,set_t));
for i in set_i2, c in set_initc, r in set_rfeas, t in set_t
    
    if (t >= set_retireyear[1]) &  haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")
        
        valid_tt_1 = [tt for tt in (set_t) if (tt <= t) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
        valid_tt_2 = [tt for tt in (set_t) if (tt <= t) & (t-tt < param_maxage[i]) & haskey(dict_ict,"$(i)_$(c)_$(t)") ];
        
        constraints["$(cons_name)"][join((i,c,r,t),'_')] = JuMP.@constraint(model, 
            #LHS
            variables["CAP"][join((i,c,r,t),'_')]
            <=  
            #RHS
            sum([param_degrade["$(i)_$(tt)_$(t)"]*variables["INV"][join((i,c,r,tt),'_')] 
                for tt in valid_tt_1 ])  # tfix,
            
            + sum([param_degrade["$(i)_$(tt)_$(t)"]*variables["INVREFURB"][join((i,c,r,tt),'_')] 
                for tt in valid_tt_2 ]) # tfix, SwM_Refurb
            );
    end
end

# -----------------------------------------------------------------------

# eq_cap_new_retmo
cons_name = "eq_cap_new_retmo"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_c,set_rfeas,set_t));
for i in (set_i2), c in (set_initc), r in (set_rfeas), t in (set_t)
    
    if (t >= set_retireyear[1]) & in(t-2,set_yeart) & haskey(dict_retiretech,"$(i)_$(c)_$(r)_$(t)")  & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")
        
        v_INV =  haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)") ? variables["INV"][join((i,c,r,t),'_')]  : 0 ;
        
        v_INVREFURB = haskey(dict_ict,"$(i)_$(c)_$(t)") ? variables["INVREFURB"][join((i,c,r,t),'_')]  : 0 ;
        
        val_sum_1 = [ tt for tt in (set_t) if (tt-2) == t & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")];
        
        constraints["$(cons_name)"][join((i,c,r,t),'_')]  = 
            #LHS
            JuMP.@constraint(model, variables["CAP"][join((i,c,r,t),'_')]  <=  
            #RHS
            sum([param_degrade["$(i)_$(tt)_$(t)"]*variables["CAP"][join((i,c,r,tt),'_')]  for tt in val_sum_1 ]) 
            
            + v_INV
            
            + v_INVREFURB
            
            ) 
    end
end


# -----------------------------------------------------------------------


# eq_forceprescription
cons_name = "eq_forceprescription"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_pcat,set_rfeas_cap,set_t));


for pcat in (set_pcat), r in (set_rfeas_cap), t in (set_t)
    valid_cond1 = sum([ 1 for i in set_i2, c in set_newc if in((pcat,i),set_prescriptivelink) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ]);
    if  ( valid_cond1 > 0) & in((pcat,t),set_force_pcat)
       
       v_EXTRA_PRESCRIP = (t >=  param_firstyear_pcat[pcat]) ? variables["EXTRA_PRESCRIP"][join((pcat,r,t),"_")] : 0 ;
       valid_tt = [ tt for tt in (set_t) if tt <= t ];
       valid_sum2 = [ (i,c,tt) 
                       for i in (set_i2),c in (set_newc), tt in (set_t) 
                       if ((tt <= t) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(tt)")
                           & in((pcat,i),set_prescriptivelink) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") )];
       valid_sum3 = [ (i,c,tt) 
                       for i in (set_i2), c in (set_newc), tt in (set_t) 
                       if ( (tt <= t) & (t-tt < param_maxage[i]) & in((pcat,i),set_prescriptivelink) 
                         & in(i,set_refurbtech)  &  haskey(dict_ict,"$(i)_$(c)_$(t)") )];
       
       lhs_1 = !isempty(valid_tt) ? sum([ get(param_m_required_prescriptions,"$(pcat)_$(r)_$(tt)",0) for tt in valid_tt ] ) : 0 ;
       rhs_1 = !isempty(valid_sum2) ? sum([param_degrade["$(i)_$(tt)_$(t)"]*variables["INV"][join((i,c,r,tt),"_")]  for (i,c,tt) in valid_sum2]) : 0 ;
       rhs_2 = !isempty(valid_sum3) ? sum([param_degrade["$(i)_$(tt)_$(t)"]*variables["INVREFURB"][join((i,c,r,tt),"_")] for (i,c,tt) in valid_sum3]) : 0 ; 
       constraints["$(cons_name)"][join((pcat,r,t),"_")] = JuMP.@constraint(model,
       # LHS
           lhs_1
           + v_EXTRA_PRESCRIP
           ==
       # RHS
           rhs_1 + rhs_2 
       );
   end
end


# -----------------------------------------------------------------------

# eq_neartermcaplimit
cons_name = "eq_neartermcaplimit";
constraints["$(cons_name)"] = JuMP.Containers.SparseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas_cap,set_t) );
for r in set_rfeas_cap, t in set_t 
    val_cond_1 = (sum([1 for rr in set_rfeas_cap if haskey(param_near_term_cap_limits,"Wind_$(r)_$(t)")]) > 0 )
    val_cond_2 = (sum([ 1 for i in set_i2, c in set_c if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") &  in(("Wind",i), set_tg_i)]) > 0) ; 
    if   val_cond_1 > 0  & val_cond_2 # $SwM_NearTermLimits
        constraints["$(cons_name)"][join((r, t),"_")] = JuMP.@constraint(model,
        #LHS
        get(param_near_term_cap_limits,"Wind_$(r)_$(t)",0) >=
        #RHS
        variables["EXTRA_PRESCRIP"][join(("wind-ons", r, t),"_")]
        )  
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_refurblim"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_rfeas_cap,set_t));

for i in (set_i2),  r in (set_rfeas_cap),  t in (set_t)
    if  in(i,set_refurbtech) # $SwM_Refurb
        
        valid_sum_1 = [ (c,tt)
                        for c in (set_newc), tt in (set_t) 
                        if haskey(dict_m_refurb_cond,"$(i)_$(c)_$(r)_$(tt)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
        
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
end

# -----------------------------------------------------------------------

# eq_rsc_inv_account 
cons_name = "eq_rsc_inv_account"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_newc,set_rfeas,set_t));
for i in (set_rsc_i), c in (set_newc), r in (set_rfeas), t in (set_t)
    if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        
        valid_sum_1 = [rscbin for rscbin in (set_rscbin) if haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)")];
        lhs_1 = !isempty(valid_sum_1) ? sum([ variables["INV_RSC"][join((i,c,r,t,rsc),"_")] for rsc in valid_sum_1 ]) : 0 ;
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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_rfeas_cap,set_rscbin));
for i in (set_i2), r in (set_rfeas_cap), rscbin in (set_rscbin)
    
    if in(i,set_rsc_i) & haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)") 
        
        valid_sum_1 = [ (ii,c,tt) for ii in (set_i2), c in (set_newc), tt in (set_t) 
                            if haskey(dict_valcap,"$(ii)_$(c)_$(r)_$(tt)")  & in((i,ii),set_rsc_agg) & haskey(param_resourcescaler,"$ii") ];
        rhs_1 = !isempty(valid_sum_1) ? sum([ variables["INV_RSC"][join((ii,c,r,tt,rscbin),"_")] for (ii,c,tt) in valid_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((i,r,rscbin),"_")] = JuMP.@constraint(model,
            get(param_m_rsc_dat,"$(r)_$(i)_$(rscbin)_cap",0)
            >=
            rhs_1 # tmodel(tt) or tfix(tt)
        )
    end
end

# -----------------------------------------------------------------------

# eq_growthlimit_relative
cons_name = "eq_growthlimit_relative"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_tg,set_t));

for tg in (set_tg), t in (set_t)
    
    if (t >= 2020) & !(t == set_t[end]) & haskey(param_growth_limit_relative,tg) 
        
        val_sum_1 = [ tt for tt in set_t if (tt == t-2) ];
        val_sum_2 = [ (i,c,r,tt) 
                    for i in (set_i2),c in (set_c), r in (set_rfeas_cap), tt in (set_t) 
                        if in((tg,i),set_tg_i) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(tt)")];
        val_sum_3 = [ (i,c,r) 
                    for i in (set_i2),c in (set_c),r in (set_rfeas_cap) 
                        if in((tg,i),set_tg_i) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")];
        lhs_1 = !isempty(val_sum_1) ? param_growth_limit_relative[tg]*(sum([tt for tt in val_sum_1 ]) - t ) : 0 ;# why ?
        lhs_2 = !isempty(val_sum_2) ? sum([variables["CAP"][join((i,c,r,tt),"_")] for (i,c,r,tt) in val_sum_2 ]) : 0;
        rhs_1 = !isempty(val_sum_3) ? sum([variables["CAP"][join((i,c,r,t),"_")] for (i,c,r) in val_sum_3 ]) : 0 ;
        constraints["$(cons_name)"][join((tg,t),"_")] = JuMP.@constraint(model,
            
            lhs_1 * lhs_2
            >=
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_growthlimit_absolute"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_t,set_tg));

for tg in (set_tg), t in (set_t)
    
    if (t >= 2018) & !(t==set_t[end]) & haskey(param_growth_limit_relative,tg)
        val_sum_1 = [ tt for tt in set_t if (tt == t-2) ];
        val_sum_2 = [ (i,c,r,rscbin) for i in (set_i2), c in (set_c), r in (set_rfeas_cap), rscbin in (set_rscbin) 
                        if in((tg,i),set_tg_i) & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)") & haskey(param_m_rscfeas,"$(r)_$(i)_$(rscbin)") ];
        lhs_1 = !isempty(val_sum_1) ? (sum([ tt for tt in val_sum_1 ]) - t) : 0 ;
        rhs_1 = !isempty(val_sum_2) ? sum([ variables["INV_RSC"][join((i,c,r,t,rscbin),"_")] for (i,c,r,rscbin) in val_sum_2 ]) : 0 ;
        
        constraints["$(cons_name)"][join((t,tg),"_")] = JuMP.@constraint(model,
            param_growth_limit_relative["$tg"]*lhs_1
            >=
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

# eq_capacity_limit
cons_name = "eq_capacity_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_c,set_rfeas,set_h,set_t));
for i in (set_i2), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !(in(i,set_storage)) & !(in(i,set_hydro_d)) 
        
        val_sum_1 = [ rr for rr in (set_rfeas) 
                        if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !haskey(param_cf_tech,i)];
        
        val_sum_2 = [ rr for rr in (set_rfeas_cap) 
                        if ( haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(rr,set_rfeas_cap)
                        & haskey(param_cf_tech,i) & haskey(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)") ) ];
        
        val_sum_3 = [ or for or in (set_ortype) if haskey(param_reserve_frac,"$(i)_$(or)") ]
        
        lhs_1 = !isempty(val_sum_1) ? sum([variables["CAP"][join((i,c,rr,t),"_")]  for rr in val_sum_1 ]) : 0 ;
        lhs_2 = !isempty(val_sum_2) ? sum([param_m_cf["$(i)_$(c)_$(rr)_$(h)_$(t)"]*variables["CAP"][join((i,c,rr,t),"_")]  for rr in val_sum_2 ]) : 0 ;
        rhs_3 = !isempty(val_sum_3) ? sum([variables["OPRES"][join((or,i,c,r,h,t),"_")] for or in val_sum_3 ]) : 0 ;
        
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            
            param_outage["$(i)_$(h)"] * lhs_1 + lhs_2
            >=
            variables["GEN"][join((i,c,r,h,t),"_")] + rhs_3 # $SwM_OpRes
        )
    end
end


# -----------------------------------------------------------------------

# eq_curt_gen_balance
cons_name = "eq_curt_gen_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas,set_h,set_t));
for r in (set_rfeas) , h in (set_h), t in (set_t)
        
    val_sum_1 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if (haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
                    & haskey(param_m_cf,"$(i)_$(c)_$(rr)_$(h)_$(t)") )];

    val_sum_2 = [ (i,c) for i in (set_vre), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    
    val_sum_3 = [ (or,i,c) for or in (set_ortype), i in (set_vre),c in (set_c) 
                    if haskey(param_reserve_frac,"$(i)_$(or)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ]; #$SwM_OpRes,

    lhs_1 = !isempty(val_sum_1) ? sum([param_m_cf["$(i)_$(c)_$(rr)_$(h)_$(t)"]*variables["CAP"][join((i,c,rr,t),"_")] for (i,c,rr) in val_sum_1 ]) : 0 ;
    rhs_1 = !isempty(val_sum_2) ? sum([variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_2 ]) : 0 ;
    rhs_2 = !isempty(val_sum_3) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for (or,i,c) in val_sum_3 ]) : 0 ;
    
    constraints["$(cons_name)"][join((r,h,t),"_")] = JuMP.@constraint(model,
        lhs_1
        - variables["CURT"][join((r,h,t),"_")] 
        >=
        rhs_1 + rhs_2 
    )
end 

# -----------------------------------------------------------------------

cons_name = "eq_curtailment"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_h,set_t));
for r in (set_rfeas), h in (set_h), t in (set_t)
    val_sum_1 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if haskey(dict_cap_agg,"$(r)_$(rr)") & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")];

    val_sum_2 = [ (i,c,rr) for i in (set_vre), c in (set_c), rr in (set_rfeas_cap) 
                    if (haskey(dict_cap_agg,"$(r)_$(rr)")  & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)")
                        & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")  )];
    val_sum_3 = [(h,szn,tt)  for (h,szn) in (set_h_szn), tt in (set_t) if (t-2 == tt) ];
    val_sum_4 = [ (i,c) for i in (set_storage), c in (set_c) if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];

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

cons_name = "eq_mingen_lb"
temp_h_szn = [join(collect(tup),"_") for tup in set_h_szn];
constraints["eq_mingen_lb"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas,temp_h_szn,set_t));
for r in (set_rfeas), (h,szn) in (set_h_szn), t in (set_t)        
    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    rhs_1 = !isempty(val_sum_1) ?  sum([ variables["GEN"][join((i,c,r,h,t),"_")]* get(param_minloadfrac,"$(r)_$(i)_$(h)",0) for (i,c) in val_sum_1 ]) : 0 ;

    constraints["eq_mingen_lb"]["$(r)_$(h)_$(szn)_$(t)"] = JuMP.@constraint(model,
        variables["MINGEN"][join((r,szn,t),"_")]
        >=
        rhs_1 
        + 0 # geothermal
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_mingen_ub";
temp_h_szn = [join(collect(tup),"_") for tup in set_h_szn];
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas,temp_h_szn,set_t));

for r in set_rfeas, (h ,szn) in set_h_szn, t in set_t
    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  & haskey(param_minloadfrac,"$r"*"_"*"$i"*"_"*"$h") ];
    rhs_1 = !isempty(val_sum_1) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_1 ]) : 0 ;
    constraints["$(cons_name)"][join((r,h,szn,t),"_")] = JuMP.@constraint(model,
        variables["MINGEN"][join((r,szn,t),"_")]
        <=
        rhs_1 
        + 0 ) # geothermal
    
end

# -----------------------------------------------------------------------

cons_name = "eq_gasct_gencon"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_c,set_rfeas,set_t));
gasCT_minCF = 0.004;
for i in (["gas-ct","gas-ct-nsp"]), c in (set_c), r in (set_rfeas), t in (set_t)
    if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  #$SwM_GasCTGenCon
        
        constraints["$(cons_name)"][join((i,c,r,t),"_")] = JuMP.@constraint(model,
            # LHS
            sum([variables["GEN"][join((i,c,r,h,t),"_")]*hours_dict["$h"] for h in set_h ])
            <= 
            #RHS
            variables["CAP"][join((i,c,r,t),"_")]*8760*gasCT_minCF
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_dhyd_dispatch"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_hydro_d,set_c,set_rfeas,set_szn,set_t));
for i in (set_hydro_d),c in (set_c), r in (set_rfeas), szn in (set_szn), t in (set_t)
    
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        
        val_sum_0 = [h for h in (set_h) if in((h,szn),set_h_szn) ];
        val_sum_1 = [ or for or in (set_ortype) if haskey(param_reserve_frac,"$(i)_$(or)")];
        
        inner_sum(h) = !isempty(val_sum_1) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for or in val_sum_1]) : 0 ;
        lhs_1 = !isempty(val_sum_0) ? sum([ param_hours["$h"]*param_outage["$(i)_$(h)"] for h in val_sum_0 ]) : 0 ;

        rhs_1 = !isempty(val_sum_0) ? sum([( variables["GEN"][join((i,c,r,h,t),"_")] + inner_sum(h)) for h in val_sum_0 ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,r,szn,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas,set_h,set_t));


for r in (set_rfeas), h in (set_h), t in (set_t) 
    
    val_sum_0 = [(i,c) for i in (set_i2), c in (set_c) if !in(i,set_storage) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_1 = [(rr,tr) for rr in (set_rfeas), tr in (set_trtype) if  haskey(dict_routes,"$(rr)_$(r)_$(tr)_$(t)") ];
    val_sum_2 = [ (rr,tr) for rr in (set_rfeas), tr in (set_trtype) if  haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")  ];
    
    val_sum_3 = [ (i,c) for i in  (set_storage), (ic,c) in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(i,set_storage) ];
    
    val_sum_4 = [ (i,c) for i in  (set_storage), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_csp_storage) ];
    
    lhs_1 = !isempty(val_sum_0) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_0 ])  : 0 ;
    lhs_2 = !isempty(val_sum_1) ? sum( [ (1-param_tranloss["$(rr)_$(r)"])* variables["FLOW"][join((rr,r,h,t,tr),"_")] for (rr,tr) in val_sum_1 ]) : 0 ;
    lhs_3 = !isempty(val_sum_2) ? sum( [ variables["FLOW"][join((r,rr,h,t,tr),"_")] for (rr,tr) in val_sum_2 ])  : 0 ;
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
temp_hour_szn = [join(collect(tup),"_") for tup in set_hour_szn_group];
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_i2,set_c,set_rfeas,temp_hour_szn,set_t));
for i in (set_i2), c in (set_c), r in (set_rfeas), 
    (h,hh) in (set_hour_szn_group), t in (set_t) 
    
    if haskey(param_minloadfrac,"$(r)_$(i)_$(h)") & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        
        constraints["$(cons_name)"][join((i,c,r,h,hh,t),"_")] = JuMP.@constraint(model,
            variables["GEN"][join((i,c,r,h,t),"_")]
            >=
            variables["GEN"][join((i,c,r,hh,t),"_")] * param_minloadfrac["$(r)_$(i)_$(hh)"]
        )
    end
end

# # -----------------------------------------------------------------------
# *=======================================
# * --- OPERATING RESERVE CONSTRAINTS ---
# *=======================================
cons_name = "eq_ORCap"
temp_i = [ i for i in set_i2 if !in(i,set_storage) & !in(i,set_hydro_d)];
temp_ori = [ (or,i) for or in (set_ortype), i in (temp_i) if haskey(param_reserve_frac,"$(i)_$(or)") ];
temp_st_ori = [join((or,i),"_") for or in (set_ortype), i in (temp_i) if haskey(param_reserve_frac,"$(i)_$(or)")];
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(temp_st_ori,set_c,set_rfeas,set_h,set_t));


for (or,i) in temp_ori, c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  #$SwM_OpRes
        
        val_sum_1 = [ (hh,szn) for (hh,szn) in set_h_szn if haskey(dict_maxload_szn,"$(r)_$(hh)_$(t)_$(szn)") ];
        lhs_1 = !isempty(val_sum_1) ? sum( [ variables["GEN"][join((i,c,r,hh,t),"_")] for (hh,szn) in val_sum_1 ]) : 0 ;
        
        constraints["eq_ORCap"][join((or,i,c,r,h,t),"_")] = JuMP.@constraint(model,
            
            param_reserve_frac["$(i)_$(or)"] * lhs_1  #
            >=
            variables["OPRES"][join((or,i,c,r,h,t),"_")]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_OpRes_requirement"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_ortype,set_rfeas,set_h,set_t));

for or in (set_ortype), r in (set_rfeas), h in (set_h), t in (set_t) 
    
    val_sum_1 = [ (i,c) for i in (set_i), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & (haskey(param_reserve_frac,"$(i)_$(or)") | in(i,set_storage) | in(i,set_hydro_d)) 
                        & !in(i,set_csp_storage) & !in(i,set_hydro_nd)];
    val_sum_2 = [ rr for rr in (set_rfeas) if   haskey(dict_opres_routes,"$(rr)_$(r)_$(t)")];
    val_sum_3 = [ rr for rr in (set_rfeas) if   haskey(dict_opres_routes,"$(r)_$(rr)_$(t)")];
    val_sum_4 = [ (i,c) for i in (set_wind), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_5 = [ (i,c) for i in (set_pv), c in (set_c) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(h,set_dayhours) ];
    
    lhs_1 = !isempty(val_sum_1) ? sum([ variables["OPRES"][join((or,i,c,r,h,t),"_")] for (i,c) in val_sum_1 ])  : 0 ;
    lhs_2 = !isempty(val_sum_2) ? sum([ (1-param_tranloss["$(rr)_$(r)"])*variables["OPRES_FLOW"][join((or,rr,r,h,t),"_")] for rr in val_sum_2 ]) : 0 ;
    lhs_3 = !isempty(val_sum_3) ? sum( [ variables["OPRES_FLOW"][join((or,r,rr,h,t),"_")] for rr in val_sum_3 ])  : 0 ;
    rhs_1 = !isempty(val_sum_4) ? sum( [variables["GEN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_4 ])  : 0 ;# SwM_Storage 
    rhs_2 = !isempty(val_sum_5) ? sum( [variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_5 ]) : 0 ;# SwM_Storage
    
    
    constraints["$(cons_name)"][join((or,r,h,t),"_")] = JuMP.@constraint(model,
        lhs_1 + lhs_2 - lhs_3 + 0 # geo
        >=
         variables["LOAD"][join((r,h,t),"_")] * get(param_orperc,"$(or)_or_load",0)
        + get(param_orperc,"$(or)_or_wind",0) * rhs_1
        + get(param_orperc,"$(or)_or_wind",0) * rhs_2
    )
end     

# -----------------------------------------------------------------------

cons_name = "eq_inertia_requirement"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rto,set_h,set_t));

for rto in (set_rto), h in (set_h), t in (set_t) 
    val_sum_1 = [ (i,c,r) for i in (set_inertia), c in (set_c), r in (set_rfeas) 
                if !in(i,set_storage) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(i,set_inertia) & in((r,rto),set_r_rto) ];

    val_sum_2 = [ (i,c,r) for i in (set_storage), c in (set_c), r in (set_rfeas) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in(i,set_inertia) & in((r,rto),set_r_rto)];
    val_sum_3(r) = [ (i,c) for i in (set_storage), c in (set_c)
                            if in(i,set_storage) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_csp_storage) ];
    val_sum_4 = [r for r in (set_rfeas) if in((r,rto),set_r_rto)];
    
    lhs_1  = !isempty(val_sum_1) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")] for (i,c,r) in val_sum_1 ]) : 0 ;
    lhs_2  = !isempty(val_sum_2) ? sum([ variables["STORAGE_OUT"][join((i,c,r,h,t),"_")] for (i,c,r) in val_sum_2 ]) : 0 ;
    
    rhs_1  = !isempty(val_sum_4) ? sum([ (!isempty(val_sum_3(r)) ? variables["LOAD"][join((r,h,t),"_")] + sum([ variables["STORAGE_IN"][join((i,c,r,h,t),"_")] for (i,c) in val_sum_3(r) ]) : variables["LOAD"][join((r,h,t),"_")])   for r in val_sum_4 ]) : 0 ; 
    
    constraints["$(cons_name)"][join((rto,h,t),"_")] = JuMP.@constraint(model,
        lhs_1
        + 0 # geothermal
        + lhs_2
        >=
        + param_inertia_req[t]*rhs_1
        )
end
                                      
# # -----------------------------------------------------------------------
# *=================================
# * --- PLANNING RESERVE MARGIN ---
# *=================================
cons_name = "eq_PRMTRADELimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, concat_sets(set_rfeas,set_rfeas,set_szn,set_t));
for r in (set_rfeas), rr in (set_rfeas), szn in (set_szn), t in (set_t)
    if (sum([ 1 for tr in set_trtype if haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")]) > 0) # SwM_ReserveMargin
        
        val_sum_1 = [ tr for tr in (set_trtype) if haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")];
        lhs_1 = !isempty(val_sum_1) ? sum([ variables["CAPTRAN"][join((r,rr,t,tr),"_")] for tr in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,szn,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
            >=
            variables["PRMTRADE"][join((r,rr,szn,t),"_")]
        );
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_reserve_margin"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_szn,set_t));

for r in (set_rfeas), szn in (set_szn), t in (set_t) #SwM_ReserveMargin

    val_sum_1 = [ (i,c) for i in (set_i2), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_rsc_i) & !in(i,set_storage)] ;

    val_sum_2 = [ (i,rr) for i in (set_i2), rr in (set_rfeas_cap) if ( (in(i,set_vre) | in(i,set_storage)) & haskey(dict_cap_agg,"$(r)_$(rr)") )];

    val_sum_3 = [ (i,c,rr) for i in (set_i2), c in (set_c), rr in (set_rfeas_cap)
                    if ( haskey(dict_cap_agg,"$(r)_$(rr)") & (in(i,set_vre) | in(i,set_storage)) 
                        & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & haskey(dict_ict,"$(i)_$(c)_$(t)") & haskey(dict_inv_cond,"$(i)_$(c)_$(t)_$(t)") ) ];

    val_sum_4 = [ c for c in (set_c) if haskey(dict_valcap,"distpv_$(c)_$(r)_$(t)") & in((t-2),set_t)];

    val_sum_5 = [ (i,c,r) for i in (set_i2), c in (set_c), rr in (set_rfeas_cap)
                    if ((in(i,set_vre) | in(i,set_storage)) & haskey(dict_valcap,"$(i)_$(c)_$(rr)_$(t)")  & haskey(dict_cap_agg,"$(r)_$(rr)"))];

    val_sum_6 = [ (i,c) for i in (set_hydro_nd), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_7 = [ (i,c) for i in (set_hydro_d), c in (set_c) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_8 = [ rr for rr in (set_rfeas) if (sum([ 1 for tr in set_trtype if haskey(dict_routes,"$(rr)_$(r)_$(tr)_$(t)")]) >0)];
    val_sum_9 = [ rr for rr in (set_rfeas) if (sum([ 1 for tr in set_trtype if haskey(dict_routes,"$(r)_$(rr)_$(tr)_$(t)")]) >0)];

    lhs_1 = !isempty(val_sum_1) ? sum([ variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_1 ])  :  0 ; 
    lhs_2 = !isempty(val_sum_2) ? sum([ 0 for (i,rr) in val_sum_2 ]) :  0 ; # cv_old(i,rr,szn,t) set to zero ? why ?
    lhs_3 = !isempty(val_sum_3) ? sum( [ get(param_m_cv_mar,"$(i)_$(r)_$(szn)_$(t)",0)*variables["INV"][join((i,c,rr,t),"_")]  for (i,c,rr) in val_sum_3 ]) :  0 ; 
    lhs_4 = !isempty(val_sum_4) ? sum([ get(param_exo_cap,"distpv_$(c)_$(r)_$(t)",0)  - get(param_exo_cap,"distpv_$(c)_$(r)_$(t-2)",0) * get(param_m_cv_mar,"distpv_$(r)_$(szn)_$(t)",0) for c in val_sum_4 ]) : 0 ; 
    lhs_5 = !isempty(val_sum_5) ? sum([ variables["CAP"][join((i,c,rr,t),"_")]*0 for (i,c,rr) in val_sum_5 ]) :  0 ; # cv_avg(i,rr,szn,t) set to zero ? why ? 
    lhs_6 = !isempty(val_sum_6) ? sum([  variables["GEN"][join((i,c,r,"h3",t),"_")] for (i,c) in val_sum_6 ]) :  0 ;  # "h3" => 6
    lhs_7 = !isempty(val_sum_7) ? sum([ param_cf_hyd_szn_adj["$(i)_$(szn)_$(r)"]*variables["CAP"][join((i,c,r,t),"_")] for (i,c) in val_sum_7 ])  :  0 ; 
    lhs_8 = !isempty(val_sum_8) ? sum([ (1-param_tranloss["$(rr)_$(r)"])* variables["PRMTRADE"][join((rr,r,szn,t),"_")] for rr in val_sum_8 ]) :  0 ; 
    lhs_9 = !isempty(val_sum_9) ? sum([ variables["PRMTRADE"][join((r,rr,szn,t),"_")] for rr in val_sum_9 ]) :  0 ; 


    constraints["$(cons_name)"][join((r,szn,t),"_")] = JuMP.@constraint(model,

        lhs_1 + lhs_2 + lhs_3 + lhs_4 + lhs_5 + lhs_6 + lhs_7 + lhs_8 + lhs_9
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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_rfeas,set_trtype,set_t));

for r in (set_rfeas),rr in (set_rfeas), trtype in (set_trtype),t in (set_t)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)")
        val_sum_1 = [ tt  for tt in (set_t) if (tt <= t) & (tt > 2020) & (param_INr["$r"] == param_INr["$rr"])];
        rhs_1 = !isempty(val_sum_1) ? sum([ variables["INVTRAN"][join((rr,r,tt,trtype),"_")] + variables["INVTRAN"][join((r,rr,tt,trtype),"_")] 
                    for tt in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,trtype,t),"_")] = JuMP.@constraint(model,
            variables["CAPTRAN"][join((r,rr,t,trtype),"_")]
            ==
            param_trancap_exog["$(r)_$(rr)_$(trtype)_$(t)"]
            + rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_prescribed_transmission"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_rfeas,set_trtype,set_t));

for r in (set_rfeas), rr in (set_rfeas), trtype in (set_trtype), t in (set_t)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)") & (t<= 2020)
        val_sum_1 = [ tt  for tt in set_t if (tt <= t)];
        val_sum_2 = [ tt for tt in (set_t) if (tt <= t)];
    
        lhs_1 = !isempty(val_sum_1) ? sum([ get(param_futuretran,"$(r)_$(rr)_possible_$(tt)_$(trtype)",0) + get(param_futuretran,"$(rr)_$(r)_possible_$(tt)_$(trtype)",0) for tt in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2) ? sum([ variables["INVTRAN"][join((r,rr,tt,trtype),"_")] + variables["INVTRAN"][join((rr,r,tt,trtype),"_")] for tt in val_sum_2 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,trtype,t),"_")] = JuMP.@constraint(model,
            lhs_1
            >=
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_SubStationAccounting"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_t));

for r in (set_rfeas), t in (set_t)
    val_sum_1 = [ vc for vc in set_vc if in((r,vc),set_tranfeas)]; 
    val_sum_2 = [rr for rr in (set_rfeas) if haskey(dict_routes,"$(r)_$(rr)_AC_$(t)")];
    val_sum_3 = [rr for rr in (set_rfeas) if haskey(dict_routes,"$(r)_$(rr)_AC_$(t)")];

    lhs_1 = !isempty(val_sum_1) ? sum([ variables["INVSUBSTATION"][join((r,vc,t),"_")] for vc in val_sum_1]) : 0 ;
    rhs_1 = !isempty(val_sum_2) ? sum([variables["INVTRAN"][join((rr,r,t,"AC"),"_")] for rr in val_sum_2 ])  : 0 ;
    rhs_2 = !isempty(val_sum_3) ? sum([variables["INVTRAN"][join((r,rr,t,"AC"),"_")] for rr in val_sum_3 ]) : 0 ;
    constraints["$(cons_name)"][join((r,t),"_")] = JuMP.@constraint(model,
        lhs_1
        ==
        rhs_1 + rhs_2
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_prescribed_transmission"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_vc));

for r in (set_rfeas), vc in (set_vc)
    if in((r,vc),set_tranfeas)

        constraints["$(cons_name)"][join((r,vc),"_")] = JuMP.@constraint(model,

            get(param_trancost,"$(r)_CAP_$(vc)",0)
            >=
            sum([ variables["INVSUBSTATION"][join((r,vc,t),"_")]  for t in (set_t) ])
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_transmission_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_rfeas,set_h,set_t,set_trtype));


for r in (set_rfeas), rr in (set_rfeas), h in (set_h), t in (set_t), trtype in (set_trtype)
    if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)") & haskey(dict_routes,"$(rr)_$(r)_$(trtype)_$(t)")
       
        val_sum_1 = [ortype for ortype in (set_ortype) if (trtype =="AC") & haskey(dict_opres_routes,"$(r)_$(rr)_$(t)") ];
        
        rhs_1 = !isempty(val_sum_1) ? sum( [ variables["OPRES_FLOW"][join((ortype,r,rr,h,t),"_")] for ortype in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,rr,h,t,trtype),"_")] = JuMP.@constraint(model,  
            variables["CAPTRAN"][join((r,rr,t,trtype),"_")]
            >=
            variables["FLOW"][join((r,rr,h,t,trtype),"_")]
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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_e,set_rfeas,set_t));

for e in (set_e),  r in (set_rfeas), t in (set_t)
    val_sum_0 = [ (i,c,h) for i in (set_i2), c in (set_c), h in (set_h) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_cofire)]; 
    val_sum_1 = [ (i,c,h) for i in (set_cofire), c in (set_c), h in (set_h) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ]; 

    rhs_1 = !isempty(val_sum_1) ?  sum([ variables["GEN"][join((i,c,r,h,t),"_")]*param_hours["$h"]*get(param_emit_rate,"$(e)_$(i)_$(c)_$(r)_$(t)",0) for (i,c,h) in val_sum_0 ]) : 0 ;
    rhs_2 = !isempty(val_sum_1) ? sum([ (1-bio_cofire_perc)*param_hours["$h"]*get(param_emit_rate,"$(e)_coal-new_$(c)_$(r)_$(t)",0)*variables["GEN"][join((i,c,r,h,t),"_")] for (i,c,h) in val_sum_1 ]) : 0 ;
    constraints["$(cons_name)"][join((e,r,t),"_")] = JuMP.@constraint(model,  
        
        variables["EMIT"][join((e,r,t),"_")]
        ==
        rhs_1 + rhs_2 
    )
end

# -----------------------------------------------------------------------
RGGI_start_yr =2012;
cons_name = "eq_RGGI_cap"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t);

for t in (set_t)
    if (t >= RGGI_start_yr)
        val_sum_0 = [r for r in set_RGGI_r if in(r,set_rfeas)];
        rhs_ = !isempty(val_sum_0) ? sum([ variables["EMIT"][join(("CO2",r,t),"_")]  for r in val_sum_0 ]) : 0 ;
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
           param_RGGICap[t] 
            >=
            rhs_ # CO2 => 1 
        )
    end
end


# -----------------------------------------------------------------------
AB32_start_yr = 2014;
AB32_Import_Emit = 0.334;
cons_name = "eq_AB32_cap"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t);

for t in (set_t)
    if (t >= AB32_start_yr)
        val_sum_1 = [ r for r in (set_AB32_r) if in(r,set_rfeas)];
        val_sum_2 = [ (h,r,rr,trtype) for h in (set_h),r in (set_rfeas), rr in (set_AB32_r), trtype in (set_trtype) 
                        if !in(r,set_AB32_r)  & haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)") ];
        rhs_1 = !isempty(val_sum_1) ? sum([variables["EMIT"][join(("CO2",r,t),"_")] for r in (val_sum_1) ]) : 0 ;   # "CO2" => 1
        rhs_2 = !isempty(val_sum_2) ? sum([ param_hours["$h"]*AB32_Import_Emit* variables["FLOW"][join((r,rr,h,t,trtype),"_")]
                    for (h,r,rr,trtype) in val_sum_2 ]) : 0 ; 
        
        
         constraints["$(cons_name)"][t] = JuMP.@constraint(model,  
            param_AB32Cap[t]
            >=
            rhs_1  + rhs_2 
        );
    end
end


# -----------------------------------------------------------------------

cons_name = "eq_batterymandate"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,["battery"],set_t));

for r in (set_rfeas), i in (["battery"]), t in (set_t)
    if (i=="battery")
        val_sum_1 = [ c for c in (set_c) if in((i,c,r,t),set_valcap)];
        lhs_1 = !isempty(val_sum_1) ? sum([ variables["CAP"][join((i,c,r,t),"_")] for c in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((r,i,t),"_")] = JuMP.@constraint(model,
            lhs_1
            >=
            get(param_batterymandate,"$(r)_$(i)_$(t)",0)
        )
    end
end

# -----------------------------------------------------------------------
CarbPolicyStartyear = 2020;
cons_name = "eq_emit_rate_limit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_e,set_rfeas,set_t));

for e in (set_e), r in (set_rfeas), t in (set_t)
    if (t >= CarbPolicyStartyear)  # missing & param_emit_rate_con["$(e)_$(r)_$(t)"]
        val_sum_1 = [ (i,c,h) for i in (set_i2), c in (set_c), h in (set_h) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_cofire)];

        lhs_1 = !isempty(val_sum_1) ? sum([ param_hours["$h"]*variables["GEN"][join((i,c,r,h,t),"_")]  for (i,c,h) in val_sum_1]) : 0 ; 
        lhs_2 = !isempty(val_sum_1) ? sum([ (1-bio_cofire_perc)*param_hours["$h"]*variables["GEN"][join((i,c,r,h,t),"_")] for (i,c,h) in val_sum_1 ]) : 0 ;
             
        constraints["$(cons_name)"][join((e,r,t),"_")] = JuMP.@constraint(model,
            
            param_emit_rate_limit["$(e)_$(r)_$(t)"]*( lhs_1 + lhs_2 )
            >=
            variables["EMIT"][join((e,r,t),"_")] 
        )
    end
end


# -----------------------------------------------------------------------
# *==========================
# * --- RPS CONSTRAINTS ---
# *==========================

cons_name = "eq_REC_Generation"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_RPSCat,set_i2,["TX"],set_t[2:end]));

for rps in (set_RPSCat), i in (set_i2), st in ["TX"], t in (set_t)[2:end]
    if  (t > 2016)
        val_sum_1 = [(c,r,h) for c in (set_c), r in (set_rfeas), h in (set_h) 
                        if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & haskey(dict_RecTech,"$(rps)_$(st)_$(i)_$(t)") & in((r,st),set_r_st)];
        val_sum_2 = [ ast for ast in (["TX"]) if  haskey(dict_RecMap,"$(i)_$(rps)_$(st)_$(ast)_$(t)") ];
        
        lhs_1 = !isempty(val_sum_1) ? sum([ param_hours["$h"]*variables["GEN"][join((i,c,r,h,t),"_")] for (c,r,h) in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2) ? sum([ variables["RECS"][join((rps,i,st,ast,t),"_")] for ast in val_sum_2  ]) : 0 ;
        constraints["$(cons_name)"][join((rps,i,st,t),"_")] = JuMP.@constraint(model,
            lhs_1 >= rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_RPS_OFSWind"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_st,set_t));

for st in (set_st), t in (set_t)
    if (st=="TX") & haskey(param_offshore_cap_req,"$(st)_$(t)")
        val_sum_1 = [ (i,c,rr,r) for i in set_i2, c in set_c, rr in set_rfeas , r in set_rfeas 
                        if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & in((r,st),set_r_st) & haskey(dict_cap_agg,"$(r)_$(rr)") ];
        
        lhs_1 = !isempty(val_sum_1) ? sum([ variables["CAP"][join((i,c,rr,t),"_")] for (i,c,rr) in val_sum_1 ]) : 0 ;

        constraints["$(cons_name)"][join((st,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
            >=
            get(param_offshore_cap_req,"$(st)_$(t)",0)
        )
    end
end     

# -----------------------------------------------------------------------

cons_name = "eq_national_rps"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t);

for t in set_t
    if haskey(param_national_rps_frac,t) 
        
        val_sum_1 = [(r,h) for r in (set_rfeas), h in (set_h) ];
        val_sum_2 = [ (rr,r,h,trtype) for rr in (set_rfeas), r in (set_rfeas), h in (set_h), trtype in (set_trtype) if haskey(dict_routes,"$(r)_$(rr)_$(trtype)_$(t)")];
        val_sum_3= [ (i,c,r,h) for i in (set_storage), c in (set_c), r in (set_rfeas), h in (set_h) 
                            if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_csp_storage)];
        val_sum_4 = [ (i,c,r,h) for i in (set_storage), c in (set_c),r in (set_rfeas), h in (set_h) 
                            if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & !in(i,set_csp_storage)];
        val_sum_0 =  [ (i,c,r,h) for i in (set_re), c in (set_c), r in (set_rfeas), h in (set_h) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
        
        lhs_1 = !isempty(val_sum_0) ? sum([ variables["GEN"][join((i,c,r,h,t),"_")]* param_hours["$h"] for (i,c,r,h) in val_sum_0 ]) : 0 ;
        rhs_1 = !isempty(val_sum_1) ? sum([ variables["LOAD"][join((r,h,t),"_")]*param_hours["$h"] for (r,h) in val_sum_1 ]) : 0 ;
        rhs_2 = !isempty(val_sum_2) ? sum([ param_tranloss["$(rr)_$(r)"]*variables["FLOW"][join((rr,r,h,t,trtype),"_")]*param_hours["$h"] for (rr,r,h,trtype) in val_sum_2]) : 0 ;
        rhs_3 = !isempty(val_sum_3) ? sum([ variables["STORAGE_IN"][join((i,c,r,h,t),"_")]*param_hours["$h"] for (i,c,r,h) in val_sum_3 ])  : 0 ;
        rhs_4 = !isempty(val_sum_4) ? sum([ variables["STORAGE_OUT"][join((i,c,r,h,t),"_")]*param_hours["$h"] for (i,c,r,h) in val_sum_4 ]) : 0 ;
        constraints["$(cons_name)"][t] = JuMP.@constraint(model,
            
            lhs_1
            + 0 #geothermal
            >=
            param_national_rps_frac[t]*(rhs_1 + rhs_2 + rhs_3 + rhs_4)
        );
    end
end

# -----------------------------------------------------------------------
# *====================================
# * --- FUEL SUPPLY CURVES ---
# *====================================

cons_name = "eq_gasused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_cendiv,set_h,set_t));

for cendiv in (set_cendiv), h in (set_h), t in (set_t)
    if (cendiv == "WSC")
        val_sum_1 = [ (i,c,r) for i in (set_gas), c in (set_c), r in (set_rfeas) 
                        if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  &  in((r,cendiv),set_r_cendiv)];
        lhs_1 = !isempty(set_gb) ? sum([ variables["GasUsed"][join((cendiv,gb,h,t),"_")] for gb in (set_gb) ]) : 0 ;
        rhs_1 = !isempty(val_sum_1) ? sum([ param_heat_rate["$(i)_$(c)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")] 
                    for (i,c,r) in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((cendiv,h,t),"_")] = JuMP.@constraint(model,
            lhs_1 == rhs_1            
        );
    end
end


# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_cendiv,set_gb,set_t));

for cendiv in (set_cendiv), gb in (set_gb), t in (set_t)
    if (cendiv == "WSC")
        val_sum_1 = [ gps for gps in set_gps if (gps=="REF") ];
        
        lhs_1 = !isempty(val_sum_1) ? sum([ param_gaslimit["$(cendiv)_$(gb)_$(t)_$(gps)"] for gps in val_sum_1]) : 0 ;
        rhs_1 = !isempty(set_h) ? sum([ param_hours["$h"]*variables["GasUsed"][join((cendiv,gb,h,t),"_")] for h in (set_h)]) : 0 ;
        constraints["$(cons_name)"][join((cendiv,gb,t),"_")] = JuMP.@constraint(model,
            
            lhs_1
            >=
            rhs_1
        )
    end
end


# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_nat"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_gb,set_t));

for gb in (set_gb), t in (set_t)
    
    val_sum_2 = [ (h,cendiv) for h in (set_h), cendiv in (set_cendiv)  if cendiv == "WSC"]
    rhs_1 = !isempty(val_sum_2) ? sum([ variables["GasUsed"][join((cendiv,gb,h,t),"_")]*param_hours["$h"] for (h,cendiv) in val_sum_2 ]) : 0 ;
    constraints["eq_gasbinlimit_nat"]["$(gb)_$(t)"] = JuMP.@constraint(model,
        param_gaslimit_nat["$(gb)_$(t)_REF"] 
        >=
        rhs_1
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_gasaccounting_regional"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_cendiv,set_t));

for cendiv in (set_cendiv), t in (set_t)
    if (cendiv =="WSC")
        val_sum_1 = [ (i,c,r,h) for i in (set_gas), c in (set_c), r in (set_rfeas), h in (set_h) 
                        if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  & in((r,cendiv),set_r_cendiv) ];
        rhs_1 = !isempty(val_sum_1)  ? sum([ param_hours["$h"]*param_heat_rate["$(i)_$(c)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")]
                    for (i,c,r,h) in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((cendiv,t),"_")] = JuMP.@constraint(model,
            
            sum([ variables["Vgasbinq_regional"][join((fuelbin,cendiv,t),"_")] for fuelbin in (set_fuelbin) ])
            ==
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasaccounting_national"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_t);

for t in (set_t)
    val_sum_1 = [ (i,c,r,h) for i in (set_gas), c in (set_c), r in (set_rfeas), h in (set_h) 
                    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    rhs_1 =!isempty(val_sum_1)  ? sum([ param_hours["$h"]*param_heat_rate["$(i)_$(c)_$(r)_$(t)"]*variables["GEN"][join((i,c,r,h,t),"_")] 
                for (i,c,r,h) in val_sum_1 ]) : 0 ;
    constraints["$(cons_name)"][t] = JuMP.@constraint(model,
        sum([ variables["Vgasbinq_national"][join((fuelbin,t),"_")] for fuelbin in (set_fuelbin)])
        == 
        rhs_1
    )
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_regional"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_fuelbin,set_cendiv,set_t));

for fuelbin in (set_fuelbin), cendiv in (set_cendiv), t in (set_t)
    if (cendiv =="WSC")
        
        constraints["$(cons_name)"][join((fuelbin,cendiv,t),"_")] = JuMP.@constraint(model,
            
            param_gasbinwidth_regional["$(fuelbin)_$(cendiv)_$(t)"]
            >=
            variables["Vgasbinq_regional"][join((fuelbin,cendiv,t),"_")]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_gasbinlimit_national"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_fuelbin,set_t));

for fuelbin in (set_fuelbin), t in (set_t)
    
    constraints["$(cons_name)"][join((fuelbin,t),"_")] = JuMP.@constraint(model,
        
        param_gasbinwidth_national["$(fuelbin)_$(t)"]
        >=
        variables["Vgasbinq_national"][join((fuelbin,t),"_")]
    )
end

# -----------------------------------------------------------------------
# *===========
# * bio curve
# *===========

bio_cofire_perc=0.15;
cons_name = "eq_bioused"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_rfeas,set_t));

for r in (set_rfeas), t in (set_t)
    val_sum_1 = [ (i,c,h) for i in (set_cofire), c in (set_c), h in (set_h) 
                    if  haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
    val_sum_2 = [ (c,h) for c in set_c, h in set_h if in(("biopower",c,r,t),set_valcap)];
    
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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_bioclass,set_rfeas,set_t));

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
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_icrht);

for i in (set_storage), c in (set_c),r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        
        val_sum_2 = [ ortype for ortype in (set_ortype) if !in(i,set_csp_storage)];
        val_sum_1 = !in(i,set_csp_storage) ? variables["STORAGE_IN"][join((i,c,r,h,t),"_")] : 0;
        val_sum_0 = [ rr for rr in (set_rfeas_cap) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  & haskey(dict_cap_agg,"$(r)_$(rr)")];
        
        lhs_1 = !isempty(val_sum_0) ? sum([ variables["CAP"][join((i,c,rr,t),"_")]*param_outage["$(i)_$(h)"] for rr in val_sum_0 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2) ? sum([ variables["OPRES"][join((ortype,i,c,r,h,t),"_")] for ortype in val_sum_2 ]) : 0 ;
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

cons_name = "eq_csp_charge"
set_cspcrht = concat_sets(set_csp_storage,set_c,set_rfeas,set_h,set_t);
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_cspcrht);

for i in (set_csp_storage), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")  
        val_sum_1 = [ rr for rr in (set_rfeas_cap) if haskey(dict_cap_agg,"$(r)_$(rr)" ) & haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") ];
        
        lhs_1 = !isempty(val_sum_1)  ? sum([ variables["CAP"][join((i,c,r,t),"_")]*param_csp_sm["$i"]* param_m_cf["$(i)_$(c)_$(rr)_$(t)"] for rr in val_sum_1 ])  :  0 ;
        
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            lhs_1
            ==
            variables["STORAGE_IN"][join((i,c,r,h,t),"_")]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_csp_gen"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_icrht);

for i in (set_i2), c in (set_c), r in (set_rfeas),  h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            variables["GEN"][join((i,c,r,h,t),"_")]
            ==
            variables["STORAGE_OUT"][join((i,c,r,h,t),"_")]
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_level"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,set_cspcrht);

for i in (set_csp_storage), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)")
        val_sum_1 = [  hh for hh in enumerate(set_h) if in(hh,set_nexth)];
        val_sum_2 = [ szn for szn in set_szn if in((h,szn),set_h_szn)];
        
        lhs_1 = !isempty(val_sum_1)  ? sum([ variables["STORAGE_LEVEL"][join((i,c,r,hh,t),"_")] for hh in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_2)  ?  sum([param_numdays["$szn"] for szn in val_sum_2 ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,i,h,t),"_")] = JuMP.@constraint(model,
            lhs_1
            ==
            variables["STORAGE_LEVEL"][join((i,c,r,h,t),"_")]
            + ((variables["STORAGE_IN"][join((i,c,r,h,t),"_")] - variables["STORAGE_OUT"][join((i,c,r,h,t),"_")])*param_hours["$h"])/
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_balance"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_szn,set_storage,set_c,set_rfeas,set_t));

for szn in (set_szn),i in (set_storage), c in (set_c), r in (set_rfeas),t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        val_sum_1 = [ h for h in (set_h) if in((h,szn),set_h_szn)];
        lhs_1 = !isempty(val_sum_1 )  ?  sum([ param_hours["$h"]*variables["STORAGE_IN"][join((i,c,r,h,t),"_")]  for h in val_sum_1 ]) : 0 ;
        rhs_1 = !isempty(val_sum_1 )  ?  sum([param_hours["$h"]*variables["STORAGE_OUT"][join((i,c,r,h,t),"_")]  for h in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((szn,i,c,r,t),"_")] = JuMP.@constraint(model,
            param_storage_eff["$i"]* lhs_1
            ==
            rhs_1
        )
    end
end

# -----------------------------------------------------------------------

cons_name = "eq_storage_thermalres"
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(["ice"],set_c,set_rfeas,set_h,set_t));

for i in (["ice"]), c in (set_c), r in (set_rfeas), h in (set_h), t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            variables["STORAGE_IN"][join((i,c,r,h,t),"_")]
            >=
            sum([ variables["OPRES"][join((ortype,i,c,r,h,t),"_")] for ortype in (set_ortype)])
        )
    end
end  

# -----------------------------------------------------------------------

cons_name = "eq_storage_duration"
set_batcsp = push!(set_csp_storage,"battery");
constraints["$(cons_name)"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef,concat_sets(set_batcsp,set_c,set_rfeas,set_h,set_t));

for i in (set_batcsp), c in (set_c), r in (set_rfeas), h in (set_h),t in (set_t)
    if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") 
        val_sum_1 = [ rr for rr in (set_rfeas_cap) if haskey(dict_valcap,"$(i)_$(c)_$(r)_$(t)") & haskey(dict_cap_agg,"$(r)_$(rr)") ];
        rhs_1 = !in(i,set_csp_storage) ? variables["STORAGE_IN"][join((i,c,r,h,t),"_")]*param_hours["$h"]/sum([param_numdays["$szn"] for szn in set_szn if in((h,szn),set_h_szn) ]) : 0;
        rhs_2 = in(i,set_csp_storage) ? variables["STORAGE_LEVEL"][join((i,c,r,h,t),"_")] : 0;
        lhs_1 = !isempty(val_sum_1) ? sum([ param_storage_duration["$i"]*variables["CAP"][join((i,c,rr,t),"_")] for rr in val_sum_1 ]) : 0 ;
        constraints["$(cons_name)"][join((i,c,r,h,t),"_")] = JuMP.@constraint(model,
            lhs_1
            >=
            rhs_1
            +  rhs_2
        )
    end
end
