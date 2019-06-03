str_sets_dict = Dict()
open("Sets.json", "r") do f
    global str_sets_dict
    str_sets_dict=JSON.parse(f)  # parse and transform data
end
