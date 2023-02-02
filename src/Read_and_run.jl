#function Read_and_run(Base_directory)
#Find all the file names
# list_of_files = filter(x->occursin(".json", x), readdir("C:\\Users\\asm6\\Documents\\Projects\\DAC\\Genreate_adsorption_surfaces\\"))
# list_of_files = filter(x->occursin(".json", x), readdir("/wrk/asm6/CSD_data/CSD_FEASST_Materials/Materials/"))
# list_of_files = filter(x->occursin(".json", x), readdir("/users/asm6/DAC_data/CSD_FEASST_Materials/Materials/"))
#list_of_files = filter(x->occursin.(".json", x), readdir(Base_directory*"CSD_FEASST_Materials/Materials/"))
#list_of_names = replace.(list_of_files, ".json" => "")

#short_list = list_of_names[1:50]

# #@everywhere begin
#     function Intrinisic_refresh_run(Base_directory, name)
#         # directory = "/wrk/asm6/CSD_data/"
#         # directory = "/users/asm6/DAC_data/"
#         # list_of_completed_files = filter(x->occursin(".json", x), readdir(directory*"CSD_FEASST_Materials/Materials/"))
#         list_of_completed_files = filter(x->occursin.(".json", x), readdir(Base_directory*"CSD_FEASST_Materials/Materials/"))
#         list_of_completed_names = replace.(list_of_completed_files, ".json" => "")
    
#         if ~occursin.(list_of_completed_names, name)
#             results = Intrinisic_refresh(directory, name)
#         end
#     end
# #end


#pmap(x -> Intrinisic_refresh_run(Base_directory, x), short_list)

#end

# for name in list_of_names
#     list_of_completed_files = filter(x->occursin(".json", x), readdir("/wrk/asm6/CSD_data/CSD_FEASST_Materials/Materials/"))
#     list_of_completed_names = replace.(list_of_files, ".json" => "")

#     if ~occursin(list_of_completed_names, name)
#         results = Intrinisic_refresh(directory, name)
#     end
# end


