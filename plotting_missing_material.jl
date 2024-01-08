### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 1f1f7e7c-a98c-11ee-06cc-d35617ad856e
using Pkg

# ╔═╡ 1a4b857d-a15f-4680-a6c5-bb6bcf52a386
Pkg.activate("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 1bd8aabe-760f-4d4e-b51d-5ec30adc37e2
using Revise

# ╔═╡ dce4dbbe-2182-416b-bdf4-3cc9273d96b4
begin
	using Plots
	using Distributed
	using JSON
	using DataFrames
	using QHull
	
	
end

# ╔═╡ 922be9ce-ab6e-4364-b4be-20e5396ff345
using IntrinsicDACCycle

# ╔═╡ f80a999a-f124-41c6-b958-101d6783346b
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ ee9b2780-869a-4313-87f4-f453a0f51019
begin
	#get all the material files
	list_of_material_files = filter(x -> occursin.(".json",x), readdir(Base_directory*"/CSD_FEASST_Materials/Materials/"))
	#strip off the .json tag
    list_of_materials = replace.(list_of_material_files, ".json" => "")
	#filter for _clean matierals
	# list_of_clean_materials = filter(x -> occursin.("_clean", x), list_of_materials)
end

# ╔═╡ 40493104-9387-4e6c-8749-edbc2717372e
begin
	#get list of completed intrinsic annalysis
	list_of_intrinsic_mat_files = filter(x -> occursin.("json", x), readdir(Base_directory*"/Opt_Intrinsic_cycle_w_err/"))
	#strip off the prefix
	list_of_intrinsic_mats = replace.(list_of_intrinsic_mat_files, "Opt_Intrinsic_cyle_" => "")
	#strip off the suffix 
	list_of_intrinsic_mat = replace.(list_of_intrinsic_mats, ".json" => "")
end

# ╔═╡ 25deb9f4-3270-43dd-85a2-d4539c9c35b9
remaining_materials = setdiff(list_of_materials, list_of_intrinsic_mat)

# ╔═╡ 62024e00-6f21-435e-9f7c-0c72d4f5502f
α = 400/1000000

# ╔═╡ bd9b1af5-b58c-468e-bd54-898bfb025975
name = remaining_materials[1]

# ╔═╡ 2bbdaacf-4d9e-425e-bb6c-7a4b34ce1a7a
begin
	Results_Dict = IntrinsicDACCycle.Optimize_Intrinsic_Refresh_w_err(Base_directory, name, α)
	results_file = Base_directory*"/Opt_Intrinsic_cycle_w_err/Opt_Intrinsic_cyle_"*name*".json"
	open(results_file, "w") do f
		JSON.print(f, Results_Dict, 4)
	end
end

# ╔═╡ 23bbd4ac-5674-44c8-8ade-fb2d9644c1aa
begin
	dT_max = 0.25
	dP_max = -125.0
	
	# T_start = 317.046
	T_start = 400
    ΔT = 200
    P_start = 101325.0
    ΔP = 100.0 - P_start

	T_steps = length(T_start:dT_max:T_start+ΔT)
	P_steps = length(P_start:dP_max:P_start+ΔP)

	#Choose the larger number of steps
	steps = maximum([T_steps, P_steps])
	#Create the T and P path with those steps
	Ts = collect(LinRange(T_start, T_start+ΔT, steps))
	Ps = collect(LinRange(P_start, P_start+ΔP, steps))

	#Perform the Intrinsic Refresh Analysis with those steps
	# ξ, α_end =  IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, name,
	# 														Ts, Ps, α)
end

# ╔═╡ 711267c0-835d-4bdb-a711-cc83b3bba263
begin
	material, Kh_N₂, Kh_CO₂, One_atm_N₂ = IntrinsicDACCycle.read_jsons(Base_directory, name)

	βs = IntrinsicDACCycle.T_to_β.(Ts) #[mol/kJ]

	#Extrapolate Henry constants along the path
    #Extrapolate the CO2 isotherm to the βs
    Henry_CO2, Henry_CO2_err = IntrinsicDACCycle.Kh_extrapolate(βs, Kh_CO₂, material) #[mmol/(kg Pa)]

    #Extrapolate the N2 isotherm to the βs
    Henry_N2, Henry_N2_err = IntrinsicDACCycle.Kh_extrapolate(βs, Kh_N₂, material)  #[mmol/(kg Pa)]
	
end

# ╔═╡ 85ac026e-0e77-45db-8b62-f1cf97e9d0bd
begin
	Henry_CO2_upper = Henry_CO2 + 1.95 .* Henry_CO2_err
	Henry_CO2_lower = Henry_CO2 - 1.95 .* Henry_CO2_err

	Henry_N2_upper = Henry_N2 + 1.95 .* Henry_N2_err
	Henry_N2_lower = Henry_N2 - 1.95 .* Henry_N2_err
	
	plot(Ts, Henry_CO2, label = "CO2")
	plot!(Ts, Henry_CO2_lower, fillrange = Henry_CO2_upper, fillalpha = 0.35, color = 1, label = "CO2 Confidence Bound")
	
	plot!(Ts, Henry_N2, label = "N2", color = 2)
	plot!(Ts, Henry_N2_lower, fillrange = Henry_N2_upper, fillalpha = 0.35, color = 2, label = "N2 Confidence Bound")
	
	plot!(xlabel = "Temperature (K)", ylabel = "KH (mmol/(kg Pa))")
	plot!(yaxis = :log)
	


end

# ╔═╡ 06dc1355-6760-46f0-81b8-3d924eb8ac7a
let
	βs = IntrinsicDACCycle.T_to_β.(Ts)
	plot(βs, Henry_CO2, label = "CO2")
	plot!(βs, Henry_CO2_lower, fillrange = Henry_CO2_upper, fillalpha = 0.35, color = 1, label = "CO2 Confidence Bound")
	
	plot!(βs, Henry_N2, label = "N2", color = 2)
	plot!(βs, Henry_N2_lower, fillrange = Henry_N2_upper, fillalpha = 0.35, color = 2, label = "N2 Confidence Bound")
	
	plot!(xlabel = "β (mol/kJ)", ylabel = "KH (mmol/(kg Pa))")
	plot!(yaxis = :log)
	


end

# ╔═╡ 6db754f3-3dbd-4371-8473-63497e6aa363
let 
	Ts = collect(100:0.25:600)
	βs = IntrinsicDACCycle.T_to_β.(Ts)
	material, Kh_N₂, Kh_CO₂, One_atm_N₂ = IntrinsicDACCycle.read_jsons(Base_directory, name)
	
	Henry_CO2, Henry_CO2_err = IntrinsicDACCycle.Kh_extrapolate(βs, Kh_CO₂, material)

	Henry_CO2_upper = Henry_CO2 + 1.95 .* Henry_CO2_err
	Henry_CO2_lower = Henry_CO2 - 1.95 .* Henry_CO2_err

	plot(βs, Henry_CO2, label = "CO2")
	plot!(βs, Henry_CO2_lower, fillrange = Henry_CO2_upper, fillalpha = 0.35, color = 1, label = "CO2 Confidence Bound")
	
	plot!(xlabel = "β (mol/kJ)", ylabel = "KH (mmol/(kg Pa))")
	plot!(yaxis = :log)
end

# ╔═╡ b1b6894b-19cb-4d67-87ff-24485bafc274


# ╔═╡ ee052937-90a5-45b2-92a9-6bc1c9cee77e


# ╔═╡ 0a7aeef9-e6f2-49fb-8ae3-cee0747c289d


# ╔═╡ bf00888f-8579-4f47-bd0d-7eec050f2b4a
begin
	N2_GCMC_temp = IntrinsicDACCycle.β_to_T(Kh_N₂["beta"])
	CO2_GCMC_temp = IntrinsicDACCycle.β_to_T(Kh_CO₂["beta"])

	@show T_start
	@show T_start + ΔT
	@show N2_GCMC_temp
	@show CO2_GCMC_temp


	@show IntrinsicDACCycle.T_to_β(T_start)
	@show IntrinsicDACCycle.T_to_β(T_start + ΔT)
	@show IntrinsicDACCycle.T_to_β(N2_GCMC_temp)
	@show IntrinsicDACCycle.T_to_β(CO2_GCMC_temp)
	
end

# ╔═╡ Cell order:
# ╠═1f1f7e7c-a98c-11ee-06cc-d35617ad856e
# ╠═1a4b857d-a15f-4680-a6c5-bb6bcf52a386
# ╠═dce4dbbe-2182-416b-bdf4-3cc9273d96b4
# ╠═1bd8aabe-760f-4d4e-b51d-5ec30adc37e2
# ╠═922be9ce-ab6e-4364-b4be-20e5396ff345
# ╠═f80a999a-f124-41c6-b958-101d6783346b
# ╠═ee9b2780-869a-4313-87f4-f453a0f51019
# ╠═40493104-9387-4e6c-8749-edbc2717372e
# ╠═25deb9f4-3270-43dd-85a2-d4539c9c35b9
# ╠═62024e00-6f21-435e-9f7c-0c72d4f5502f
# ╠═bd9b1af5-b58c-468e-bd54-898bfb025975
# ╠═2bbdaacf-4d9e-425e-bb6c-7a4b34ce1a7a
# ╠═23bbd4ac-5674-44c8-8ade-fb2d9644c1aa
# ╠═711267c0-835d-4bdb-a711-cc83b3bba263
# ╠═85ac026e-0e77-45db-8b62-f1cf97e9d0bd
# ╠═06dc1355-6760-46f0-81b8-3d924eb8ac7a
# ╠═6db754f3-3dbd-4371-8473-63497e6aa363
# ╠═b1b6894b-19cb-4d67-87ff-24485bafc274
# ╠═ee052937-90a5-45b2-92a9-6bc1c9cee77e
# ╠═0a7aeef9-e6f2-49fb-8ae3-cee0747c289d
# ╠═bf00888f-8579-4f47-bd0d-7eec050f2b4a
