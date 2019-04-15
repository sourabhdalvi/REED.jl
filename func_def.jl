function read_set(csv_path)
    set_ = DataFrames.disallowmissing!(CSV.read(csv_path,header=0));
    return collect(Set(set_.Column1))
end

function collect_1D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        pdict[param[row,1]] = param[row,2] ;
    end
    return pdict
end

function collect_2D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];
        pdict["$a"*"_"*"$b"] = param[row,3] ;
    end
    return pdict
end

function collect_3D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];c = param[row,3];
        pdict["$a"*"_"*"$b"*"_"*"$c"] = param[row,4] ;
    end
    return pdict
end

function collect_4D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    if ncol == 5
        for row in 1:nrow
            a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];
            pdict["$a"*"_"*"$b"*"_"*"$c"*"_"*"$d"] = param[row,5] ;
        end
        return pdict
    else
        print("DataFrame doesn't have 5 columns")
    end
end

function collect_5D(file_path)
    param = DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = param[row,5];
        pdict["$a"*"_"*"$b"*"_"*"$c"*"_"*"$d"*"_"*"$e"] = param[row,6] ;
    end
    return pdict
end

function read_set_2D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_3D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_4D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4]);
        push!(slist,i);
    end
    return collect(Set(slist))
end

function read_set_5D(csv_path)
    set = DataFrames.dropmissing(CSV.read(csv_path,header=0), disallowmissing=true);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4],set[row,5]);
        push!(slist,i);
    end
    return collect(Set(slist))
end
    
function collect_set_dict4D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3];d = set_[row,4];
        dict_["$(a)_$(b)_$(c)_$(d)"] = true ;
    end
    return dict_
end

function collect_set_dict3D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];c = set_[row,3]
        dict_["$(a)_$(b)_$(c)"] = true ;
    end
    return dict_
end

function collect_set_dict2D(file_path)
    set_= DataFrames.dropmissing(CSV.read(file_path,header=0), disallowmissing=true);
    dict_ = Dict()
    nrow,ncol = size(set_)
    for row in 1:nrow
        a = set_[row,1];b = set_[row,2];
        dict_["$(a)_$(b)"] = true ;
    end
    return dict_
end