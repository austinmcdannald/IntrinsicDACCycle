### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ e1a46be2-4c3c-497a-af33-6a86f0160836
using Pkg

# ╔═╡ 6ce6c5c3-726d-4e7e-982d-697cf5bab7eb
Pkg.activate("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ efa35bc6-1c76-43a8-9f7e-e39df7e2acd3
using JSON

# ╔═╡ e22dd4a8-b4fb-44c8-b8ac-04c8e57b38c7
using IntrinsicDACCycle

# ╔═╡ 1b9888f2-d48f-11ed-3f02-eb7b0ffc209b
cd("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 497c914f-005a-4b07-a3cc-70a630f456db
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ 52128a77-62c3-45c0-9db3-aac879e57d1f
begin
	#get all the material files
	list_of_material_files = filter(x -> occursin.(".json",x), readdir(Base_directory*"/CSD_FEASST_Materials/Materials/"))
	#strip off the .json tag
    list_of_materials = replace.(list_of_material_files, ".json" => "")
	#filter for _clean matierals
	# list_of_clean_materials = filter(x -> occursin.("_clean", x), list_of_materials)
end

# ╔═╡ ecbda318-5c96-472f-b3fa-c083a8073614
begin
	#get list of completed intrinsic annalysis
	list_of_intrinsic_mat_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Opt_Intrinsic_cycle/"))
	#strip off the prefix
	list_of_intrinsic_mats = replace.(list_of_intrinsic_mat_files, "Opt_Intrinsic_cyle_" => "")
	#strip off the suffix 
	list_of_intrinsic_mat = replace.(list_of_intrinsic_mats, ".json" => "")
end

# ╔═╡ 190f588f-31d8-43a1-bd3d-0e96a8ad21d3
begin
	for name in list_of_materials[1:2]
	
		#Try to load the file name
		material_string = Base_directory*"/Opt_Intrinsic_cycle/"*"Opt_Intrinsic_cyle_"*name*".json"
		thing = JSON.parsefile(material_string)

		@show thing["Intrinsic_capture_efficiency"] .> 0.0
		
	end
end

# ╔═╡ 90597263-22f1-4ca9-966f-60775ab3045f
thing

# ╔═╡ Cell order:
# ╠═1b9888f2-d48f-11ed-3f02-eb7b0ffc209b
# ╠═e1a46be2-4c3c-497a-af33-6a86f0160836
# ╠═6ce6c5c3-726d-4e7e-982d-697cf5bab7eb
# ╠═efa35bc6-1c76-43a8-9f7e-e39df7e2acd3
# ╠═e22dd4a8-b4fb-44c8-b8ac-04c8e57b38c7
# ╠═497c914f-005a-4b07-a3cc-70a630f456db
# ╠═52128a77-62c3-45c0-9db3-aac879e57d1f
# ╠═ecbda318-5c96-472f-b3fa-c083a8073614
# ╠═190f588f-31d8-43a1-bd3d-0e96a8ad21d3
# ╠═90597263-22f1-4ca9-966f-60775ab3045f
