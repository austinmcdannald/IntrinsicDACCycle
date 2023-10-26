### A Pluto.jl notebook ###
# v0.19.20

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

# ╔═╡ 8fd427db-c1fc-4524-890d-9adde218c773
using DataFrames

# ╔═╡ 0b1dbe45-c4c7-42da-9c96-db5f6229575d
using QHull

# ╔═╡ 0b5dca9e-5773-47c6-bd4e-7c91a64d7332
cd("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 88ff4277-a54c-4c4a-8eeb-04d6deff04b3
begin
	Pkg.resolve()
	Pkg.instantiate()
end

# ╔═╡ 3efa1d09-db11-456f-bf6b-184a2946b86e
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ 42007682-9091-43d2-bbe2-dbe7a1a5b886
begin
	#get all the material files
	list_of_material_files = filter(x -> occursin.(".json",x), readdir(Base_directory*"/CSD_FEASST_Materials/Materials/"))
	#strip off the .json tag
    list_of_materials = replace.(list_of_material_files, ".json" => "")
	#filter for _clean matierals
	# list_of_clean_materials = filter(x -> occursin.("_clean", x), list_of_materials)
end
	
	

# ╔═╡ e470bad6-e3d1-4ccf-a1ef-1a5b043f6955
begin
	#get list of completed intrinsic annalysis
	list_of_intrinsic_mat_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Opt_Intrinsic_cycle/"))
	#strip off the prefix
	list_of_intrinsic_mats = replace.(list_of_intrinsic_mat_files, "Opt_Intrinsic_cyle_" => "")
	#strip off the suffix 
	list_of_intrinsic_mat = replace.(list_of_intrinsic_mats, ".json" => "")
end


# ╔═╡ e93ddc8a-aa46-4e17-ae79-f20fa70b2164
begin
	for name in list_of_materials
		try
			#Try to load the file name
			material_string = Base_directory*"/Opt_Intrinsic_cycle/"*"Opt_Intrinsic_cyle_"*name
			thing = JSON.parsefile(material_string)
			
		catch
			#If the file doesn't exist, make it.
			α = 400/1000000

			try
				Results_Dict = IntrinsicDACCycle.Optimize_Intrinsic_Refresh(Base_directory, name, α)
				results_file = Base_directory*"/Opt_Intrinsic_cycle/Opt_Intrinsic_cyle_"*name*".json"
	    		open(results_file, "w") do f
	        		JSON.print(f, Results_Dict, 4)
	    		end
			catch
				@show name, "Retry later"
			end
		end
	end
end

# ╔═╡ bbeb45af-fb20-45e7-ba22-9ada4c8699df
begin
	α = 400/1000000
	# name = "acs.cgd.5b01554_VAGNUP1452791_clean"
	# name = "ABAYIO_clean"
	name = "ABAVIJ_clean"
	IntrinsicDACCycle.Optimize_Intrinsic_Refresh(Base_directory, name, α)
	
end

# ╔═╡ acc94c2d-067e-4d24-a5c6-5010829cfa59
# begin
# 	for name in list_of_materials
# 		@show name
# 		IntrinsicDACCycle.Optimize_Intrinsic_Refresh(Base_directory, name, α)
# 	end
# end

# ╔═╡ 2f050716-a409-4cde-acbe-9317056bf4e2
begin
	efficiencies = []
	purities = []
	#Get the completed intrinsic files 
	intrinsic_analysis_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Opt_Intrinsic_cycle/"))
	for file in intrinsic_analysis_files
		#read those jsons
	    material_string = Base_directory*"/Opt_Intrinsic_cycle/"*file
		material = JSON.parsefile(material_string)
		material_efficiency = material["Intrinsic_capture_efficiency"]
		material_capture = material["Purity_captured_CO2"]
		append!(efficiencies, material_efficiency)
		append!(purities, material_capture)
	end
end

# ╔═╡ d13dda7e-71c6-4508-9096-6b26cce7162d
begin
	for (i, pure) in enumerate(purities)
		if isnothing(pure)
			purities[i] = NaN
		end
	end

	for (i, eff) in enumerate(efficiencies)
		if isnothing(eff)
			efficiencies[i] = NaN
		end
	end
end

# ╔═╡ d1844117-f4bd-471b-b43d-893407ad8ddd
plot(efficiencies, purities, seriestype =:scatter)

# ╔═╡ c71bcba2-a9af-48df-a028-c56a7bf2e1d2
begin
	plot(efficiencies, purities, seriestype=:scatter,
	ylim = (0,1), xlim = (0,2e-5))
	xlabel!("Intrinsic Capture Efficiency [mol/J]")
	ylabel!("Purity of Captured CO2")
	# ylims!(0,1)
end

# ╔═╡ 628c049a-254c-44a8-9ea2-84190fd66678
begin
	plot(efficiencies, purities, 
		 seriestype=:scatter,
	     xaxis=:log, xlim = (1e-9, 1e-4), ylim = (0,1))
	xlabel!("Intrinsic Capture Efficiency [mol/J]")
	ylabel!("Purity of Captured CO2")

	# xlims!()
end

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
	plot(efficiencies_MJ_ton, purities, 
		 seriestype=:scatter,
	     xaxis=:log, xlim = (1e0, 1e6), ylim = (0,1)
	)
	xlabel!("Intrinsic Capture Cost [MJ/ton]")
	ylabel!("Purity of Captured CO2")
end

# ╔═╡ d3099090-b66e-43d0-b494-59315b45dd4c
efficiencies_MJ_ton

# ╔═╡ a3b3ed71-4ae8-40de-a6d4-cf76efb8623c
begin
	#Find the Pareto Front minimizing the MJ/ton and maximizing purity
	df = DataFrame(x=efficiencies_MJ_ton, y = purities)
	#Sort the data frame on the lowest to highest MJ/ton 
	sort!(df, rev=false)
	#Add that point to the pareto front
	pareto = df[1:1, :]
	#Look at each row of the dataframe (getting worse in MJ/ton)
	## if that point has a higher purity than the latest point in the pareto front
	## add it to the pareto front
	foreach(row -> row.y > pareto.y[end] && push!(pareto,row), eachrow(df))

	#Plot all the data points
	plot(efficiencies_MJ_ton, purities, 
		 seriestype=:scatter,
	     xaxis=:log, xlim = (1e-0, 1e5), ylim = (0,1)
	)
	#Add the pereto front
	plot!(pareto.x,pareto.y, seriestype= :line)
	#Add labels
	xlabel!("Intrinsic Capture Cost [MJ/ton]")
	ylabel!("Purity of Captured CO₂")
end

# ╔═╡ 25e8683c-4f5e-48b4-ac9b-c22985226ca6
begin
	#Find the Pareto Front minimizing the MJ/ton and maximizing purity
	df1 = DataFrame(x=efficiencies_MJ_ton, y = purities)
	#postitive x 
	df2 = df1[df1[:,1] .> 0, :]
	#y less than 1
	df3 = df2[df2[:,2] .< 1, :]
	
	
	#Sort the data frame on the lowest to highest MJ/ton 
	sort!(df3, rev=false)
	#Add that point to the pareto front
	pareto1 = df3[1:1, :]
	#Look at each row of the dataframe (getting worse in MJ/ton)
	## if that point has a higher purity than the latest point in the pareto front
	## add it to the pareto front
	foreach(row -> row.y > pareto1.y[end] && push!(pareto1,row), eachrow(df3))

	#Plot all the data points
	plot(efficiencies_MJ_ton, purities, 
		 seriestype=:scatter,
	     xaxis=:log, xlim = (1e-0, 1e5), ylim = (0,1)
	)
	#Add the pereto front
	plot!(pareto1.x,pareto1.y, seriestype= :line, linewidth = 5 )
	#Add labels
	xlabel!("Intrinsic Capture Cost [MJ/ton]")
	ylabel!("Purity of Captured CO₂")
end

# ╔═╡ 60b30400-efb6-4ee0-9814-47f499feaec9
begin
	#Plot all the data points
	plot(efficiencies_MJ_ton, purities, 
		 seriestype=:scatter,
	     # xaxis=:lin
		 )
	#Add the pereto front
	plot!(pareto1.x,pareto1.y, seriestype= :line, linewidth = 5)
	#Add labels
	xlabel!("Intrinsic Capture Cost [MJ/ton]")
	ylabel!("Purity of Captured CO2")
	xlims!(1.8, 3)
	ylims!(0.9, 1.01)
end

# ╔═╡ a0603bca-93d5-49a9-b287-1ed6bfc60e6f
length(pareto.x)

# ╔═╡ Cell order:
# ╠═0b5dca9e-5773-47c6-bd4e-7c91a64d7332
# ╠═d313100c-e005-4d27-bccf-623098b7c26a
# ╠═53327efa-bde7-499b-8e9c-2fbeb7e5cd9c
# ╠═865f25af-e3e5-49a0-a714-3df691cda719
# ╠═88ff4277-a54c-4c4a-8eeb-04d6deff04b3
# ╠═91d5d45c-b6ea-443d-8da5-b48080249b36
# ╠═343b401d-43f4-4959-8496-552c654a9a6f
# ╠═3efa1d09-db11-456f-bf6b-184a2946b86e
# ╠═42007682-9091-43d2-bbe2-dbe7a1a5b886
# ╠═e470bad6-e3d1-4ccf-a1ef-1a5b043f6955
# ╠═e93ddc8a-aa46-4e17-ae79-f20fa70b2164
# ╠═bbeb45af-fb20-45e7-ba22-9ada4c8699df
# ╠═acc94c2d-067e-4d24-a5c6-5010829cfa59
# ╠═6be91aca-ac94-41b8-a803-16eaf35f46bd
# ╠═32e219a6-60f8-48e5-b238-8a76818700da
# ╠═2f050716-a409-4cde-acbe-9317056bf4e2
# ╠═d13dda7e-71c6-4508-9096-6b26cce7162d
# ╠═d1844117-f4bd-471b-b43d-893407ad8ddd
# ╠═c71bcba2-a9af-48df-a028-c56a7bf2e1d2
# ╠═628c049a-254c-44a8-9ea2-84190fd66678
# ╠═0085b415-394e-4434-a83a-247db4bc7e7a
# ╠═c158ec08-1fdd-42e3-8ee2-2360402b4a35
# ╠═d3099090-b66e-43d0-b494-59315b45dd4c
# ╠═8fd427db-c1fc-4524-890d-9adde218c773
# ╠═a3b3ed71-4ae8-40de-a6d4-cf76efb8623c
# ╠═25e8683c-4f5e-48b4-ac9b-c22985226ca6
# ╠═60b30400-efb6-4ee0-9814-47f499feaec9
# ╠═a0603bca-93d5-49a9-b287-1ed6bfc60e6f
# ╠═0b1dbe45-c4c7-42da-9c96-db5f6229575d
