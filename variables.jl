
print("CAP"); @time variables["CAP"] = add_variable_constraints(model,str_sets_dict["CAP"],"CAP");
print("INV"); @time variables["INV"] = add_variable_constraints(model,str_sets_dict["INV"],"INV");
print("INVREFURB"); @time variables["INVREFURB"] = add_variable_constraints(model,str_sets_dict["INVREFURB"],"INVREFURB");
print("EXTRA_PRESCRIP"); @time variables["EXTRA_PRESCRIP"] = add_variable_constraints(model,str_sets_dict["EXTRA_PRESCRIP"],"EXTRA_PRESCRIP");
print("INV_RSC"); @time variables["INV_RSC"] = add_variable_constraints(model,str_sets_dict["INV_RSC"],"INV_RSC");

print("GEN"); @time variables["GEN"] = add_variable_constraints(model,str_sets_dict["GEN"],"GEN");
print("STORAGE_IN"); @time variables["STORAGE_IN"] = add_variable_constraints(model,str_sets_dict["STORAGE_IN"],"STORAGE_IN");
print("STORAGE_OUT"); @time variables["STORAGE_OUT"] = add_variable_constraints(model,str_sets_dict["STORAGE_OUT"],"STORAGE_OUT");
print("STORAGE_LEVEL"); @time variables["STORAGE_LEVEL"] = add_variable_constraints(model,str_sets_dict["STORAGE_LEVEL"],"STORAGE_LEVEL");
print("CURT"); @time variables["CURT"] = add_variable_constraints(model,str_sets_dict["CURT"],"CURT");
print("MINGEN"); @time variables["MINGEN"] = add_variable_constraints(model,str_sets_dict["MINGEN"],"MINGEN");

print("FLOW"); @time variables["FLOW"] = add_variable_constraints(model,str_sets_dict["FLOW"],"FLOW");
print("OPRES_FLOW"); @time variables["OPRES_FLOW"] = add_variable_constraints(model,str_sets_dict["OPRES_FLOW"],"OPRES_FLOW");
print("PRMTRADE"); @time variables["PRMTRADE"] = add_variable_constraints(model,str_sets_dict["PRMTRADE"],"PRMTRADE");

print("OPRES"); @time variables["OPRES"] = add_variable_constraints(model,str_sets_dict["OPRES"],"OPRES");
print("GasUsed"); @time variables["GasUsed"] = add_variable_constraints(model,str_sets_dict["GasUsed"],"GasUsed");
print("Vgasbinq_national"); @time variables["Vgasbinq_national"] = add_variable_constraints(model,str_sets_dict["Vgasbinq_national"],"Vgasbinq_national");
print("Vgasbinq_regional"); @time variables["Vgasbinq_regional"] = add_variable_constraints(model,str_sets_dict["Vgasbinq_regional"],"Vgasbinq_regional");
print("BIOUSED"); @time variables["BIOUSED"] = add_variable_constraints(model,str_sets_dict["BIOUSED"],"BIOUSED");

print("RECS"); @time variables["RECS"] = add_variable_constraints(model,str_sets_dict["RECS"],"RECS");
print("ACP_Purchases"); @time variables["ACP_Purchases"] =  add_variable_constraints(model,str_sets_dict["ACP_Purchases"],"ACP_Purchases");
print("EMIT"); @time variables["EMIT"] = add_variable_constraints(model,str_sets_dict["EMIT"],"EMIT");


print("CAPTRAN"); @time variables["CAPTRAN"] = add_variable_constraints(model,str_sets_dict["CAPTRAN"],"CAPTRAN");
print("INVTRAN"); @time variables["INVTRAN"] = add_variable_constraints(model,str_sets_dict["INVTRAN"],"INVTRAN");
print("INVSUBSTATION"); @time variables["INVSUBSTATION"] = add_variable_constraints(model,str_sets_dict["INVSUBSTATION"],"INVSUBSTATION");

print("LOAD"); @time variables["LOAD"] = add_variable_constraints(model,str_sets_dict["LOAD"],"LOAD");










