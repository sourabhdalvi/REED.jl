
# Create Variable CAP,INV
var_name = "CAP"
variables["CAP"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_t)
variables["INV"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_t)
for i in set_i2, c in set_c, r in set_r, t in set_t 
        variables["CAP"][i, c, r, t] = JuMP.@variable(model, base_name="CAP_{$i,$c, $r, $t}", start = 0.0, binary=false)
        variables["INV"][i, c, r, t] = JuMP.@variable(model, base_name="INV_{$i,$c, $r, $t}", start = 0.0, binary=false)
end

# Create Variable INVREFURB, EXTRA_PRESCRIP

variables["INVREFURB"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef,set_i2,set_r,set_t)
variables["EXTRA_PRESCRIP"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_pcat,set_r,set_t)
for i in set_i2, r in set_r, t in set_t
    variables["INVREFURB"][i, r, t] = JuMP.@variable(model, base_name="INVREFURB_{$i, $r, $(t)}", start = 0.0, binary=false)

    if in(i,set_pcat)
        variables["EXTRA_PRESCRIP"][i, r, t] = JuMP.@variable(model, base_name="EXTRA_PRESCRIP_{$(i), $(r), $(t)}", start = 0.0, binary=false)
    end
    
end

# Create Variable INV_RSC
var_name = "INV_RSC"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_t,set_rscbin)
for i in set_i2, c in set_c, r in set_r, t in set_t
    if in(i,set_rsc_i)
        for rscbin in set_rscbin
            variables["$(var_name)"][i, c, r, t, rscbin] = 
                JuMP.@variable(model, base_name="$(var_name)_{$i, $c, $r, $t, $rscbin}", start = 0.0, binary=false)
        end
    end
end

### Generation and storage variables
#### Note that in constraints where both GEN and STORAGE_OUT exist, CSP-TES is normally represented as STORAGE_OUT

# Create Variable GEN,STORAGE_IN, STORAGE_OUT, STORAGE_LEVEL
var_name = "GEN"
variables["GEN"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_h,set_t)
variables["STORAGE_IN"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_h,set_t)
variables["STORAGE_OUT"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_h,set_t)
variables["STORAGE_LEVEL"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_h,set_t)
for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    variables["GEN"][i, c, r, h, t] = JuMP.@variable(model, base_name="GEN_{$(i), $(c), $(r), $(h), $(t)}", start = 0.0, binary=false)
    variables["STORAGE_IN"][i, c, r, h, t] = JuMP.@variable(model, base_name="STORAGE_IN_{$(i), $(c), $(r), $(h), $(t)}", start = 0.0, binary=false)
    variables["STORAGE_OUT"][i, c, r, h, t] = JuMP.@variable(model, base_name="STORAGE_OUT_{$(i), $(c), $(r), $(h), $(t)}", start = 0.0, binary=false)
    variables["STORAGE_LEVEL"][i, c, r, h, t] = JuMP.@variable(model, base_name="STORAGE_LEVEL_{$(i), $(c), $(r), $(h), $(t)}", start = 0.0, binary=false)
end


# Create Variable CURT
var_name = "CURT"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_h,set_t)
for r in set_r, h in set_h, t in set_t
    variables["$(var_name)"][r, h, t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(h), $(t)}", start = 0.0, binary=false)
end

# Create Variable MINGEN
var_name = "MINGEN"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_szn,set_t)
for r in set_r, szn in set_szn, t in set_t
    variables["$(var_name)"][r, szn, t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(szn), $(t)}", start = 0.0, binary=false)
end

### Trade variables
# Create Variable FLOW
var_name = "FLOW"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_r,set_h,set_t,set_trtype)
for r in set_r, rr in set_r, h in set_h, t in set_t, trtype in set_trtype
    variables["$(var_name)"][r, rr, h, t, trtype] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(rr), $(h), $(t), $(trtype)}", start = 0.0, binary=false)
end

# Create Variable OPRES_FLOW
var_name = "OPRES_FLOW"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_ortype,set_r,set_r,set_h,set_t)
for ortype in set_ortype, r in set_r, rr in set_r, h in set_h, t in set_t
    variables["$(var_name)"][ortype, r, rr, h, t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(ortype), $(r), $(rr), $(h), $(t)}", start = 0.0, binary=false)
end

# Create Variable PRMTRADE
var_name = "PRMTRADE"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_r,set_szn,set_t)
for r in set_r, rr in set_r, szn in set_szn, t in set_t
    variables["$(var_name)"][r, rr, szn, t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(rr), $(szn), $(t)}", start = 0.0, binary=false)
end

### Operating reserve variables

# Create Variable OPRES
var_name = "OPRES"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_i2,set_c,set_r,set_h,set_t)
for i in set_i2, c in set_c, r in set_r, h in set_h, t in set_t
    variables["$(var_name)"][i, c, r, h, t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(i), $(c), $(r), $(h), $(t)}", start = 0.0, binary=false)
end

### Fuel amounts variable 

var_name = "GasUsed"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_cendiv,set_gb,set_h,set_t)
for cendiv in set_cendiv, gb in set_gb, r in set_r, h in set_h, t in set_t
    variables["$(var_name)"][cendiv,gb,h,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(cendiv), $(gb), $(h), $(t)}", start = 0.0, binary=false)
end

var_name = "Vgasbinq_national"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_fuelbin,set_t)
for fuelbin in set_fuelbin,  t in set_t
    variables["$(var_name)"][fuelbin,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(fuelbin), $(t)}", start = 0.0, binary=false)
end

var_name = "Vgasbinq_regional"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_fuelbin,set_cendiv,set_t)
for fuelbin in set_fuelbin, cendiv in set_cendiv,  t in set_t
    variables["$(var_name)"][fuelbin,cendiv,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(fuelbin), $(cendiv), $(t)}", start = 0.0, binary=false)
end

var_name = "BIOUSED"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_bioclass,set_r,set_t)
for bioclass in set_bioclass, r in set_r,  t in set_t
    variables["$(var_name)"][bioclass,r,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(bioclass), $(r), $(t)}", start = 0.0, binary=false)
end

# * RECS variables

var_name = "RECS"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_RPSCat,set_i2,set_st,set_st,set_t)
for RPSCat in set_RPSCat, i in set_i2, st in set_st, ast in set_st, t in set_t
    variables["$(var_name)"][RPSCat,i,st,ast,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(RPSCat),$(i), $(st), $(ast), $(t)}", start = 0.0, binary=false)
end

var_name = "ACP_Purchases"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_RPSCat,set_st,set_t)
for RPSCat in set_RPSCat,  st in set_st,  t in set_t
    variables["$(var_name)"][RPSCat,st,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(RPSCat), $(st), $(t)}", start = 0.0, binary=false)
end

var_name = "EMIT"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_e,set_r,set_t)
for e in set_e,  r in set_r,  t in set_t
    variables["$(var_name)"][e,r,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(e), $(r), $(t)}", start = 0.0, binary=false)
end

# * transmission variables

var_name = "CAPTRAN"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_r,set_trtype,set_t)
for r in set_r,  rr in set_r, trtype in set_trtype, t in set_t
    variables["$(var_name)"][r,rr,trtype,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(rr), $(trtype), $(t)}", start = 0.0, binary=false)
end

var_name = "INVTRAN"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_r,set_t,set_trtype)
for r in set_r,  rr in set_r, t in set_t,  trtype in set_trtype
    variables["$(var_name)"][r,rr,t,trtype] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(rr), $(t), $(trtype)}", start = 0.0, binary=false)
end

var_name = "INVSUBSTATION"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_vc,set_t)
for r in set_r, vc in set_vc, t in set_t
    variables["$(var_name)"][r,vc,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(vc), $(t)}", start = 0.0, binary=false)
end

var_name = "LOAD"
variables["$(var_name)"] =  JuMP.Containers.DenseAxisArray{JuMP.variable_type(model)}(undef, set_r,set_h,set_t)
for r in set_r, h in set_h, t in set_t
    variables["$(var_name)"][r,h,t] = 
        JuMP.@variable(model, base_name="$(var_name)_{$(r), $(h), $(t)}", start = 0.0, binary=false)
end