### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ d313100c-e005-4d27-bccf-623098b7c26a
using Pkg

# ╔═╡ 53327efa-bde7-499b-8e9c-2fbeb7e5cd9c
Pkg.activate("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 865f25af-e3e5-49a0-a714-3df691cda719
using Revise

# ╔═╡ 91d5d45c-b6ea-443d-8da5-b48080249b36
using IntrinsicDACCycle

# ╔═╡ 343b401d-43f4-4959-8496-552c654a9a6f
using Distributed

# ╔═╡ 6be91aca-ac94-41b8-a803-16eaf35f46bd
using Plots

# ╔═╡ 32e219a6-60f8-48e5-b238-8a76818700da
using JSON

# ╔═╡ 0b5dca9e-5773-47c6-bd4e-7c91a64d7332
cd("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 3efa1d09-db11-456f-bf6b-184a2946b86e
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ 42007682-9091-43d2-bbe2-dbe7a1a5b886
begin
	#get all the material files
	list_of_material_files = filter(x -> occursin.(".json",x), readdir(Base_directory*"/CSD_FEASST_Materials/Materials/"))
	#strip off the .json tag
    list_of_materials = replace.(list_of_material_files, ".json" => "")
	#filter for _clean matierals
	list_of_clean_materials = filter(x -> occursin.("_clean", x), list_of_materials)
end
	
	

# ╔═╡ 2efeee35-b918-4b7f-aba1-f80a6b49db00
short_list = rand(list_of_clean_materials, 100)

# ╔═╡ e470bad6-e3d1-4ccf-a1ef-1a5b043f6955
begin
	#get list of completed intrinsic annalysis
	list_of_intrinsic_mat_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Intrinsic_cycle/"))
	#strip off the prefix
	list_of_intrinsic_mats = replace.(list_of_intrinsic_mat_files, "Intrinsic_cyle_" => "")
	#strip off the suffix 
	list_of_intrinsic_mat = replace.(list_of_intrinsic_mats, ".json" => "")
end


# ╔═╡ 38710c90-7dd1-4a2b-a77c-c45c9fc2e87f
test = findall(x->x in short_list, list_of_intrinsic_mat)

# ╔═╡ 72c3aac7-8b92-478e-b5f3-8e65ff67753a
test_run = IntrinsicDACCycle.Intrinisic_refresh(Base_directory, short_list[2])

# ╔═╡ 742db65a-b46d-41ab-99fd-0e7531327322
results = pmap(x -> IntrinsicDACCycle.Intrinisic_refresh(Base_directory, x), short_list)

# ╔═╡ e93ddc8a-aa46-4e17-ae79-f20fa70b2164
begin
	for name in short_list
		thing = IntrinsicDACCycle.Intrinisic_refresh(Base_directory, name)
	end
end

# ╔═╡ 2f050716-a409-4cde-acbe-9317056bf4e2
begin
	efficiencies = []
	purities = []
	#Get the completed intrinsic files 
	intrinsic_analysis_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Intrinsic_cycle/"))
	for file in intrinsic_analysis_files
		#read those jsons
	    material_string = Base_directory*"/Intrinsic_cycle/"*file
		material = JSON.parsefile(material_string)
		material_efficiency = material["Intrinsic_capture_efficiency"]
		material_capture = material["Purity_captured_CO2"]
		append!(efficiencies, material_efficiency)
		append!(purities, material_capture)
	end
end

# ╔═╡ c71bcba2-a9af-48df-a028-c56a7bf2e1d2
begin
	plot(efficiencies, purities, seriestype=:scatter)
	xlabel!("Intrinsic Capture Efficiency [mol/J]")
	ylabel!("Purity of Captured CO2")
end

# ╔═╡ 206797be-2d39-4e20-8cbb-fd25bae7c53b
efficiencies[efficiencies .> 3.1*10^-8]

# ╔═╡ b88310f1-1cad-4dbb-95be-d22eda8b2526
intrinsic_analysis_files[efficiencies .> 3.1*10^-8]

# ╔═╡ 0085b415-394e-4434-a83a-247db4bc7e7a
begin
	efficiencies_kg_MJ = efficiencies .* 44.01 .* 0.001 .* 10^9 #g/mol #kg/g #J/MJ
	efficiencies_ton_MJ = efficiencies_kg_MJ .* 0.001 #ton/kg
	efficiencies_MJ_ton = efficiencies_ton_MJ.^(-1)
	@show maximum(efficiencies_ton_MJ)
	@show minimum(efficiencies_MJ_ton)
end
								  

# ╔═╡ c158ec08-1fdd-42e3-8ee2-2360402b4a35
begin
	plot(efficiencies_MJ_ton, 1 .- purities, seriestype=:scatter)
	xlabel!("Intrinsic Capture Efficiency [MJ/ton]")
	ylabel!("1 - Purity of Captured CO2")
end

# ╔═╡ b865b800-2fed-4e7b-b5dc-7147e3e61746
size(efficiencies_MJ_ton)

# ╔═╡ f0e0a2b0-12d7-4adf-9ac3-22013482cc40
begin
	name_file = "Intrinsic_cyle_LORMOW_clean.json"
	material_string = Base_directory*"/Intrinsic_cycle/"*name_file
	material = JSON.parsefile(material_string)
end

# ╔═╡ f5a9a833-6948-4ceb-bf62-1f32f468516e
material["Refresh_Path"]["Temperatures"]

# ╔═╡ e4a5d1ac-a9f2-429d-af24-fbba116f66cc


# ╔═╡ Cell order:
# ╠═0b5dca9e-5773-47c6-bd4e-7c91a64d7332
# ╠═d313100c-e005-4d27-bccf-623098b7c26a
# ╠═53327efa-bde7-499b-8e9c-2fbeb7e5cd9c
# ╠═865f25af-e3e5-49a0-a714-3df691cda719
# ╠═91d5d45c-b6ea-443d-8da5-b48080249b36
# ╠═343b401d-43f4-4959-8496-552c654a9a6f
# ╠═3efa1d09-db11-456f-bf6b-184a2946b86e
# ╠═42007682-9091-43d2-bbe2-dbe7a1a5b886
# ╠═2efeee35-b918-4b7f-aba1-f80a6b49db00
# ╠═e470bad6-e3d1-4ccf-a1ef-1a5b043f6955
# ╠═38710c90-7dd1-4a2b-a77c-c45c9fc2e87f
# ╠═72c3aac7-8b92-478e-b5f3-8e65ff67753a
# ╠═742db65a-b46d-41ab-99fd-0e7531327322
# ╠═e93ddc8a-aa46-4e17-ae79-f20fa70b2164
# ╠═6be91aca-ac94-41b8-a803-16eaf35f46bd
# ╠═32e219a6-60f8-48e5-b238-8a76818700da
# ╠═2f050716-a409-4cde-acbe-9317056bf4e2
# ╠═c71bcba2-a9af-48df-a028-c56a7bf2e1d2
# ╠═206797be-2d39-4e20-8cbb-fd25bae7c53b
# ╠═b88310f1-1cad-4dbb-95be-d22eda8b2526
# ╠═0085b415-394e-4434-a83a-247db4bc7e7a
# ╠═c158ec08-1fdd-42e3-8ee2-2360402b4a35
# ╠═b865b800-2fed-4e7b-b5dc-7147e3e61746
# ╠═f0e0a2b0-12d7-4adf-9ac3-22013482cc40
# ╠═f5a9a833-6948-4ceb-bf62-1f32f468516e
# ╠═e4a5d1ac-a9f2-429d-af24-fbba116f66cc
