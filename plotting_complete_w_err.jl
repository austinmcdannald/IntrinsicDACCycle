### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 44f73d62-a9ad-11ee-29ae-7b67672da09b
using Pkg

# ╔═╡ 8f1d16e3-dedb-4282-b371-4330751e0fac
Pkg.activate("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ 485e5cff-f748-4cbe-8f28-65dfc37c1031
using Revise

# ╔═╡ b2064ce6-c3f4-4b7f-8d14-6ec8ebadbb02
begin
	using Plots
	using Distributed
	using JSON
	using DataFrames
	using QHull
	
	
end

# ╔═╡ 526c2367-d88c-4769-b1e0-b10f435e73a8
using IntrinsicDACCycle

# ╔═╡ c36221a9-c7b4-4d0d-9a60-83acad656003
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ 1b6265e2-5db1-4c7a-82a6-bd534bcb4979
begin
	# name = "ABEXIQ_clean"
	name = "EVUMUE_clean"
	# name = "HABRAF_manual"
end

# ╔═╡ 721a7285-6ee4-4027-9ec7-b1f0c9736af4
begin
	full_file = Base_directory*"/Opt_Intrinsic_cycle_w_err/Opt_Intrinsic_cyle_"*name*".json"
	
	
	results_dict = JSON.parsefile(full_file)
end

# ╔═╡ 033672d1-3858-4797-8896-883d4b9f9741
begin
	Ts = results_dict["Refresh_Path"]["Temperatures"][1]
	
	KH_CO2_path = results_dict["Refresh_Path"]["Henry_CO2"][1][1]
	KH_CO2_path_err = results_dict["Refresh_Path"]["Henry_CO2_err"][1][1]

	Kh_CO2_path_upper = KH_CO2_path + 1.95 .* KH_CO2_path_err
	Kh_CO2_path_lower = KH_CO2_path - 1.95 .* KH_CO2_path_err

	KH_N2_path = results_dict["Refresh_Path"]["Henry_N2"][1][1]
	KH_N2_path_err = results_dict["Refresh_Path"]["Henry_N2_err"][1][1]

	Kh_N2_path_upper = KH_N2_path + 1.95 .* KH_N2_path_err
	Kh_N2_path_lower = KH_N2_path - 1.95 .* KH_N2_path_err


	plot(Ts, KH_CO2_path, label = "CO2")
	plot!(Ts, Kh_CO2_path_lower, fillrange = Kh_CO2_path_upper, fillalpha = 0.35, color =1, label = "CO2 CI")

	plot!(Ts, KH_N2_path, label = "N2", color = 2)
	plot!(Ts, Kh_N2_path_lower, fillrange = Kh_N2_path_upper, fillalpha = 0.35, color =2, label = "N2 CI")

	plot!(xlabel = "Temperature (K)", ylabel = "KH (mmol/(kg Pa))")
	plot!(yaxis = :log)
	
end

# ╔═╡ dad90498-b423-40e1-8e2c-a4ce0821028e
begin
	E_to_heat_sorbent = results_dict["E_Balance"]["Step_2"]["E_to_heat_sorbent"][1][1]
	
	Heat_to_desorb_N2 = results_dict["E_Balance"]["Step_2"]["Heat_to_desorb_N2"][1][1]
	Work_to_desorb_N2 = results_dict["E_Balance"]["Step_2"]["Work_to_desorb_N2"][1]
	E_to_heat_adsorbed_N2 = results_dict["E_Balance"]["Step_2"]["E_to_heat_adsorbed_N2"][1]

	Heat_to_desorb_CO2 = results_dict["E_Balance"]["Step_2"]["Heat_to_desorb_CO2"][1][1]
	Work_to_desorb_CO2 = results_dict["E_Balance"]["Step_2"]["Work_to_desorb_CO2"][1]
	E_to_heat_adsorbed_CO2 = results_dict["E_Balance"]["Step_2"]["E_to_heat_adsorbed_CO2"][1]


	E_to_change_pressure = results_dict["E_Balance"]["Step_2"]["E_to_change_pressure"][1]

	plot(Ts[2:end], log.( E_to_heat_sorbent[2:end] .+ 1e-9), label = "E heat sorbent")
	plot!(Ts[2:end], log.(Heat_to_desorb_CO2[2:end] .+ 1e-9), label = "Q CO2")
	plot!(Ts[2:end], log.(Work_to_desorb_CO2[2:end] .+ 1e-9), label = "W CO2")
	plot!(Ts[2:end], log.(E_to_heat_adsorbed_CO2[2:end] .+ 1e-9), label = "E CO2")
	
	plot!(Ts[2:end], log.(Heat_to_desorb_N2[2:end] .+ 1e-9), label = "Q N2")
	plot!(Ts[2:end], log.(Work_to_desorb_N2[2:end] .+ 1e-9), label = "W N2")
	plot!(Ts[2:end], log.(E_to_heat_adsorbed_N2[2:end] .+ 1e-9), label = "E N2")

	plot!(Ts[2:end], log.(E_to_change_pressure[2:end] .+ 1e-9), label = "E ΔP")
	# plot!(xlabel = "Temperature (K)", ylabel = "Energy (J/kg)")
	# plot!(yscale = :log)
end

# ╔═╡ 30adb657-7fe3-459e-9913-a80ddf5318aa
begin 
	n_CO2 = results_dict["Refresh_Path"]["Moles_CO2"][1]
	n_N2 = results_dict["Refresh_Path"]["Moles_N2"][1]

	plot(Ts, log.(n_CO2 .+ 1e-12), label = "CO2")
	plot!(Ts, log.(n_N2 .+ 1e-12), label = "N2")
	scatter!(Ts, log.(n_N2 .+ 1e-12), label = "N2")
end

# ╔═╡ 1e2d14e0-e494-4c05-8546-4bd95a20ad1e
begin
	@show n_N2[1]
	@show n_N2[end]
end

# ╔═╡ 9a1d9648-4213-40ac-8c81-28c3ba288469
begin 
	q_CO2 = results_dict["Refresh_Path"]["Heat_of_adsorb_CO2"][1][1]
	q_N2 = results_dict["Refresh_Path"]["Heat_of_adsorb_N2"][1][1]

	q_CO2_err = results_dict["Refresh_Path"]["Heat_of_adsorb_CO2_err"][1][1]
	q_N2_err = results_dict["Refresh_Path"]["Heat_of_adsorb_N2_err"][1][1]

	q_CO2_upper = q_CO2 + 1.95 .* q_CO2_err
	q_CO2_lower = q_CO2 - 1.95 .* q_CO2_err
	q_N2_upper = q_N2 + 1.95 .* q_N2_err
	q_N2_lower = q_N2 - 1.95 .* q_N2_err

	plot(Ts, log.(q_CO2 .+ 1e-12), label = "CO2")
	plot!(Ts, log.(q_CO2_lower .+ 1e-12), fillrange = log.(q_CO2_upper .+ 1e-12), alpha = 0.35, c = 1, label = "CO2 CI")
	plot!(Ts, log.(q_N2 .+ 1e-12), label = "N2", c = 2)
	plot!(Ts, log.(q_N2_lower .+ 1e-12), fillrange = log.(q_N2_upper .+ 1e-12), alpha = 0.35, c = 2, label = "N2 CI")
end

# ╔═╡ f71147d8-6a92-440a-abca-e8460823884e
begin 
	cv = results_dict["Refresh_Path"]["Specific_heat_sorbent"][1][1]

	cv_err = results_dict["Refresh_Path"]["Specific_heat_sorbent_err"][1][1]
	
	cv_upper = cv + 1.95 .* cv_err
	cv_lower = cv - 1.95 .* cv_err

	# plot(Ts, log.(cv .+ 1e-12), label = "Cv")
	# plot!(Ts, log.(cv_lower .+ 1e-12), fillrange = log.(cv_upper .+ 1e-12), alpha = 0.35, c = 1, label = "Cv CI")

	plot(Ts, cv, label = "Cv")
	plot!(Ts, cv_lower, fillrange = cv_upper, alpha = 0.35, c = 1, label = "Cv CI")
end

# ╔═╡ 94641585-10f3-465e-a190-9ba7c803b2d6
begin
	Ps = results_dict["Refresh_Path"]["Pressures"][1]

	plot(Ts, Ps)
end

# ╔═╡ 1ed630fb-fc29-4f38-9dac-3fe262b6a916
length(Ts)

# ╔═╡ a690e22e-78ac-4c1a-80af-6bb88fc501bc
Ts[2] - Ts[1]

# ╔═╡ 9ed6ae44-1f5e-48fa-bc62-28c68db37f5a
begin
	A = (KH_N2_path .* Ps) .- (KH_CO2_path .* Ps)

	plot(Ts, log10.(-1 .* A))
end


# ╔═╡ 31b04a0b-ac85-4848-908a-75c04a3671ac
begin
	B = n_CO2 .+ n_N2 .+ (KH_CO2_path .* Ps) .- (KH_N2_path .* Ps) 

	plot(Ts, B)
end

# ╔═╡ f8903d9b-972b-4eee-8b19-c2115050f3b2
begin
	C = -1 .* n_CO2 
	plot(Ts, C)
end

# ╔═╡ cb3465ad-45e8-4fd5-b930-3e3d8d2dc60c
begin
	plot(Ts, log10.(-1 .* A))
	plot!(Ts, log10.(B))
end

# ╔═╡ 0c6fd311-7ae6-40f8-81f8-03146cd12a1c
begin
	x1 = (-1 .* B .+ sqrt.(B.^2 .- 4 .* A .* C))./(2 .* A)
	x2 = (-1 .* B .- sqrt.(B.^2 .- 4 .* A .* C))./(2 .* A)

	plot(Ts, x1)
	# plot(Ts, x2)
end

# ╔═╡ 4a6c74d4-df70-4a47-acba-90d4f0f037df
begin
	plot(Ts, B.^2 .- 4 .* A .* C)
end

# ╔═╡ 29296024-89bc-416c-bd6a-42510b979f62
maximum(x1)

# ╔═╡ da1434eb-292a-470a-9888-2a16f74c27b3
begin
	plot(Ts, KH_CO2_path .* Ps .* x1)
end

# ╔═╡ Cell order:
# ╠═44f73d62-a9ad-11ee-29ae-7b67672da09b
# ╠═8f1d16e3-dedb-4282-b371-4330751e0fac
# ╠═b2064ce6-c3f4-4b7f-8d14-6ec8ebadbb02
# ╠═485e5cff-f748-4cbe-8f28-65dfc37c1031
# ╠═526c2367-d88c-4769-b1e0-b10f435e73a8
# ╠═c36221a9-c7b4-4d0d-9a60-83acad656003
# ╠═1b6265e2-5db1-4c7a-82a6-bd534bcb4979
# ╠═721a7285-6ee4-4027-9ec7-b1f0c9736af4
# ╠═033672d1-3858-4797-8896-883d4b9f9741
# ╠═dad90498-b423-40e1-8e2c-a4ce0821028e
# ╠═30adb657-7fe3-459e-9913-a80ddf5318aa
# ╠═1e2d14e0-e494-4c05-8546-4bd95a20ad1e
# ╠═9a1d9648-4213-40ac-8c81-28c3ba288469
# ╠═f71147d8-6a92-440a-abca-e8460823884e
# ╠═94641585-10f3-465e-a190-9ba7c803b2d6
# ╠═1ed630fb-fc29-4f38-9dac-3fe262b6a916
# ╠═a690e22e-78ac-4c1a-80af-6bb88fc501bc
# ╠═9ed6ae44-1f5e-48fa-bc62-28c68db37f5a
# ╠═31b04a0b-ac85-4848-908a-75c04a3671ac
# ╠═f8903d9b-972b-4eee-8b19-c2115050f3b2
# ╠═cb3465ad-45e8-4fd5-b930-3e3d8d2dc60c
# ╠═0c6fd311-7ae6-40f8-81f8-03146cd12a1c
# ╠═4a6c74d4-df70-4a47-acba-90d4f0f037df
# ╠═29296024-89bc-416c-bd6a-42510b979f62
# ╠═da1434eb-292a-470a-9888-2a16f74c27b3
