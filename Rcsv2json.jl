function collect_2D(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,Float64]), disallowmissing=true);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a =param[row,1];b = parse(Int64,param[row,2]);
            pdict[(a,b)] = param[row,3] ;
        end
        return pdict
    catch
        return Dict()
    end
end

function collect_3D(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,Float64]), disallowmissing=true);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a =param[row,1];b = param[row,2];c = parse(Int64,param[row,3]);
            pdict[(a,b,c)] = param[row,4] ;
        end
        return pdict
    catch
        return Dict()
    end
end

function collect_4D(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,String,Float64]), disallowmissing=true,);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = param[row,3];d = parse(Int64,param[row,4]);
            pdict[(a,b,c,d)] = param[row,5] ;
        end
        return pdict
    catch
        return Dict()
    end
end

function collect_4Df(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,String,Float64]), disallowmissing=true,);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = parse(Int64,param[row,3]);d = param[row,4];
            pdict[(a,b,c,d)] = param[row,5] ;
        end
        return pdict
    catch
        return Dict()
    end
end    
    
    
function collect_5D(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,String,String,Float64]), disallowmissing=true);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = parse(Int64,param[row,5]);
            pdict[(a,b,c,d,e)] = param[row,6] ;
        end
        return pdict
    catch
        return Dict()
    end
end
    
function collect_5DF(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,String,String,Float64]), disallowmissing=true);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = param[row,3];d = parse(Int64,param[row,4]);e = param[row,5];
            pdict[(a,b,c,e,d)] = param[row,6] ;
        end
        return pdict
    catch
        return Dict()
    end
end
    
function collect_6D(file_path)
    try
        param = DataFrames.dropmissing(CSV.read(file_path,header=0,types=[String,String,String,String,String,String,Float64]), disallowmissing=true);
        pdict = Dict()
        nrow,ncol = size(param)
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = param[row,5];f =parse(Int64,param[row,6])
            pdict[(a,b,c,d,e,f)] = param[row,7] ;
        end
        return pdict
    catch
        return Dict()
end


valid_dict = Dict()

valid_dict["CAP"] = collect_4D("../GDX_data/Var_CAP.csv");
valid_dict["INV"] = collect_4D("../GDX_data/Var_INV.csv");
valid_dict["INVREFURB"] = collect_4D("../GDX_data/Var_INVREFURB.csv");
valid_dict["EXTRA_PRESCRIP"] = collect_3D("../GDX_data/Var_EXTRA_PRESCRIP.csv");
valid_dict["INV_RSC"] = collect_5D("../GDX_data/Var_INV_RSC.csv");

valid_dict["GEN"] = collect_5D("../GDX_data/Var_GEN.csv");
valid_dict["STORAGE_IN"] = collect_5D("../GDX_data/Var_STORAGE_IN.csv");
valid_dict["STORAGE_OUT"] = collect_5D("../GDX_data/Var_STORAGE_OUT.csv");
valid_dict["STORAGE_LEVEL"] = collect_5D("../GDX_data/Var_STORAGE_LEVEL.csv");
valid_dict["CURT"] = collect_3D("../GDX_data/Var_CURT.csv");
valid_dict["MINGEN"] = collect_3D("../GDX_data/Var_MINGEN.csv");

valid_dict["FLOW"] = collect_5DF("../GDX_data/Var_FLOW.csv");
valid_dict["OPRES_FLOW"] = collect_5D("../GDX_data/Var_OPRES_FLOW.csv");
valid_dict["PRMTRADE"] = collect_4D("../GDX_data/Var_PRMTRADE.csv");

valid_dict["OPRES"] = collect_6D("../GDX_data/Var_OPRES.csv");
valid_dict["GasUsed"] = collect_4D("../GDX_data/Var_GasUsed.csv");
# valid_dict["Vgasbinq_national"] = collect_2D("../GDX_data/Var_Vgasbinq_national.csv");
# valid_dict["Vgasbinq_regional"] = collect_3D("../GDX_data/Var_Vgasbinq_regional.csv");
valid_dict["BIOUSED"] = collect_3D("../GDX_data/Var_BIOUSED.csv");

valid_dict["RECS"] = collect_5D("../GDX_data/Var_RECS.csv");
valid_dict["ACP_Purchases"] = collect_3D("../GDX_data/Var_ACP_Purchases.csv");
valid_dict["EMIT"] = collect_3D("../GDX_data/Var_EMIT.csv");

valid_dict["CAPTRAN"] = collect_4D("../GDX_data/Var_CAPTRAN.csv");
valid_dict["INVTRAN"] = collect_4Df("../GDX_data/Var_INVTRAN.csv");
valid_dict["INVSUBSTATION"] = collect_3D("../GDX_data/Var_INVSUBSTATION.csv");
valid_dict["LOAD"] = collect_3D("../GDX_data/Var_LOAD.csv");


