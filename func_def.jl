function read_set(csv_path)
    set_ = CSV.read(csv_path,header=0).Column1;
    set_ = Set(set_)
    return set_
end

function collect_1D(file_path)
    param = CSV.read(file_path,header=0);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        pdict[param[row,1]] = param[row,2] ;
    end
    return pdict
end

function collect_2D(file_path)
    param = CSV.read(file_path,header=0);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];
        pdict["$a"*"_"*"$b"] = param[row,3] ;
    end
    return pdict
end

function collect_3D(file_path)
    param = CSV.read(file_path,header=0);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a =param[row,1];b = param[row,2];c = param[row,3];
        pdict["$a"*"_"*"$b"*"_"*"$c"] = param[row,4] ;
    end
    return pdict
end

function collect_4D(file_path)
    param = CSV.read(file_path,header=0);
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
    param = CSV.read(file_path,header=0);
    pdict = Dict()
    nrow,ncol = size(param)
    for row in 1:nrow
        a = param[row,1];b = param[row,2];c = param[row,3];d = param[row,4];e = param[row,5];
        pdict["$a"*"_"*"$b"*"_"*"$c"*"_"*"$d"*"_"*"$e"] = param[row,6] ;
    end
    return pdict
end

function read_set_2D(csv_path)
    set = CSV.read(csv_path,header=0);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2]);
        push!(slist,i);
    end
    return Set(slist)
end

function read_set_3D(csv_path)
    set = CSV.read(csv_path,header=0);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3]);
        push!(slist,i);
    end
    return Set(slist)
end

function read_set_4D(csv_path)
    set = CSV.read(csv_path,header=0);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4]);
        push!(slist,i);
    end
    return Set(slist)
end

function read_set_5D(csv_path)
    set = CSV.read(csv_path,header=0);
    slist = []
    nrow,ncol = size(set)
    for row in 1:nrow
        i = (set[row,1],set[row,2],set[row,3],set[row,4],set[row,5]);
        push!(slist,i);
    end
    return Set(slist)
end