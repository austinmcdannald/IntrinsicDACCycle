### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 91940f5e-aa7c-11ee-3924-b90d825c91e6
using Pkg

# ╔═╡ bad9a968-13fe-4fa6-ad4d-f4a2b0ed5e3b
Pkg.activate("/users/asm6/Julia_scripts/IntrinsicDACCycle")

# ╔═╡ febedf6a-1d0b-4673-8a7b-ee7935fb7d6c
using Revise

# ╔═╡ 89b13632-f2bd-49d1-a8a8-e97d918797d8
begin
	using Plots
	using Distributed
	using JSON
	using DataFrames
	using QHull
	
	
end

# ╔═╡ 7701affb-bddf-42ee-9cee-cdec1b6e5730
using IntrinsicDACCycle

# ╔═╡ 9a88bcd5-83fd-4da2-96a8-320d0c62978d
using Distributions

# ╔═╡ abcca850-2e65-4c14-936d-08b210fd836b
using NaNStatistics

# ╔═╡ 9a732c62-b2b8-479d-9e59-9f168805469f
Base_directory = "/users/asm6/DAC_data"

# ╔═╡ 717751b7-5de4-4e85-ba20-99d47895f1ee
begin
	name = "GUPBOJ03_clean"
end

# ╔═╡ 9693dee0-21e4-4a24-b9ec-eef60eb6cbe7
begin
	full_file = Base_directory*"/Opt_Intrinsic_cycle_w_err/Opt_Intrinsic_cyle_"*name*".json"
	
	
	results_dict = JSON.parsefile(full_file)
end

# ╔═╡ 9382a88f-a30b-4fd9-afea-3bb1375f503c
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

# ╔═╡ 37bfdb54-96db-4ff8-8702-097dc56fe679
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

# ╔═╡ 138b71da-9e96-4a86-ad26-8ac583a5c77e
begin 
	n_CO2 = results_dict["Refresh_Path"]["Moles_CO2"][1]
	n_N2 = results_dict["Refresh_Path"]["Moles_N2"][1]

	plot(Ts, log.(n_CO2 .+ 1e-12), label = "CO2")
	plot!(Ts, log.(n_N2 .+ 1e-12), label = "N2")
	scatter!(Ts, log.(n_N2 .+ 1e-12), label = "N2")
end

# ╔═╡ 90d319c0-85ec-4ef7-a66c-c2be81e9301e
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

# ╔═╡ 7dbda39c-c6d5-426b-ac15-403e8d3910dc
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

# ╔═╡ 1c5c8f5c-2359-4dff-8db8-b86f46054b03
begin
	Ps = results_dict["Refresh_Path"]["Pressures"][1]

	plot(Ts, Ps)
end

# ╔═╡ f194efc8-3c31-4e85-b170-bd614e53a0cb
begin
	A = (KH_N2_path .* Ps) .- (KH_CO2_path .* Ps)

	plot(Ts, log10.(-1 .* A))
end


# ╔═╡ 6b56b3f7-f473-42a1-9438-0f576ec4220c
begin
	B = n_CO2 .+ n_N2 .+ (KH_CO2_path .* Ps) .- (KH_N2_path .* Ps) 

	plot(Ts, B)
end

# ╔═╡ 6f361213-cb70-48dd-aa44-90e9fb4d6835
begin
	C = -1 .* n_CO2 
	plot(Ts, C)
end

# ╔═╡ 36c128ad-cfb9-476d-b1e2-3179e287a431
begin
	plot(Ts, log10.(-1 .* A))
	plot!(Ts, log10.(B))
end

# ╔═╡ b385ba30-185d-42f1-b2cd-cbf038715ee5
begin
	x1 = (-1 .* B .+ sqrt.(B.^2 .- 4 .* A .* C))./(2 .* A)
	x2 = (-1 .* B .- sqrt.(B.^2 .- 4 .* A .* C))./(2 .* A)

	plot(Ts, x1)
	#plot(Ts, x2)
end

# ╔═╡ 0a4417f2-dc76-4fa8-89eb-df75f94d42bf
begin
	plot(Ts, B.^2 .- 4 .* A .* C)
end

# ╔═╡ 3d9bc07b-3390-45df-a59b-a7982fd748c6
maximum(x1)

# ╔═╡ 58db2979-2c6f-430c-a361-cdf3dfae18bd
begin
	plot(Ts, KH_CO2_path .* Ps .* x1)
end

# ╔═╡ aafcb5c7-2e3e-4a9e-ae1c-b9e586b48e57
begin
	α = 400/1000000
	ξ, α_end =  IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, name,
                                                                Ts, Ps, α)
end

# ╔═╡ c86b78a4-254f-4ca3-8c4f-d16fc3311fa7
thing =  IntrinsicDACCycle.Optimize_Intrinsic_Refresh_path_distributions(Base_directory, name, α)


# ╔═╡ eb2039c4-7d8a-460c-a84f-7264740e89ce


# ╔═╡ adf4a134-e8f1-4b4d-bf84-9a5987ec4f99
begin
	T_starts = []
	T_ends = []
	P_starts = []
	P_ends = []
	ξs = []
	αs = []
	for q in thing
		T_start = q.x[1]
		append!(T_starts, T_start)

		T_end = q.x[1] + q.x[2]
		append!(T_ends, T_end)

		P_start = q.x[3]
		append!(P_starts, P_start)

		P_end = q.x[3] + q.x[4]
		append!(P_ends, P_end)

		ξ = 1/q.f[1]
		append!(ξs, ξ)

		α = 1 - q.f[2]
		append!(αs, α)
		
	end
	
end

# ╔═╡ 788fa820-273a-4ace-90dc-d12b669eae37
begin
	path_distributions = hcat(T_starts, T_ends, P_starts, P_ends, ξs, αs)
	normalized_path_distributions = mapslices(path_distributions -> (path_distributions .- minimum(path_distributions))/(maximum(path_distributions) - minimum(path_distributions)), path_distributions, dims = 1)
end

# ╔═╡ 4f011181-cacf-47e6-b475-1e43f70e3ff6
scatter(path_distributions[:,5], path_distributions[:,6])

# ╔═╡ f55aa753-4ba9-489e-9e92-d6afca14e8e9
begin
	@show minimum(path_distributions[:,5])
	@show maximum(path_distributions[:,5])
	
	@show minimum(path_distributions[:,6])
	@show maximum(path_distributions[:,6])
end

# ╔═╡ 95282e1d-0654-4ee0-8ee3-9a4dbd175d61
begin
	arg = argmax(path_distributions[:,5])
	path_distributions[arg,:]
end

# ╔═╡ 15a6252d-ac7f-4368-8c02-3792f13ae058
begin
	arg2 = argmax(path_distributions[:,6])
	path_distributions[arg2,:]
end

# ╔═╡ 4fa8b971-7841-4537-ba6d-0f64f706fd40
begin
	λ = 1
	path_distributions[arg2 + λ,:]
end

# ╔═╡ 631e9b73-b245-43be-9015-0b22a6c82a10
begin
	T_start, T_end, P_start, P_end = path_distributions[arg, 1:4]

	ΔT = 0.25
	ΔP = -125.0

	path_T_steps = length(T_start:ΔT:T_end)
	path_P_steps = length(P_start:ΔP:P_end)	

	path_steps = maximum([path_T_steps, path_P_steps])

	trial_Ts = collect(LinRange(T_start, T_end, path_steps))
	trial_Ps = collect(LinRange(P_start, P_end, path_steps))

	objectives_dist = IntrinsicDACCycle.Intrinisic_refresh_objectives_posterior_dist(Base_directory, name, trial_Ts, trial_Ps, α, 10)
	
end

# ╔═╡ 376fbf9e-8085-4075-9370-20262f5771d5
begin
	trial_βs = IntrinsicDACCycle.T_to_β.(trial_Ts)

	material, Kh_N₂, Kh_CO₂, One_atm_N₂ = IntrinsicDACCycle.read_jsons(Base_directory, name)

	Henry_CO2_mean, Henry_CO2_err = IntrinsicDACCycle.Kh_extrapolate(trial_βs, Kh_CO₂, material)
	Henry_N2_mean, Henry_N2_err = IntrinsicDACCycle.Kh_extrapolate(trial_βs, Kh_N₂, material)

	Upper_Henry_CO2 = Henry_CO2_mean .+ 1.95 .* Henry_CO2_err
	Lower_Henry_CO2 = Henry_CO2_mean .- 1.95 .* Henry_CO2_err

	Upper_Henry_N2 = Henry_N2_mean .+ 1.95 .* Henry_N2_err
	Lower_Henry_N2 = Henry_N2_mean .- 1.95 .* Henry_N2_err
end

# ╔═╡ b75ce4e5-6d9c-4fef-8bf0-bc569e1625fc


# ╔═╡ 43bd21d8-11d4-4930-9b59-c5f5066e6318
begin
	plot(trial_Ts, Henry_CO2_mean, label = "CO2", c=1)
	plot!(trial_Ts, Lower_Henry_CO2, fillrange=Upper_Henry_CO2, label = "CI CO2", c =1, alpha = 0.35)
	plot!(trial_Ts, Henry_N2_mean, label = "N2", c=2)
	plot!(trial_Ts, Lower_Henry_N2, fillrange=Upper_Henry_N2, label = "CI N2", c =2, alpha = 0.35)

end

# ╔═╡ 11ef2251-00cd-45c4-bafb-4ea3d8db2909
begin
	#Generate heat of adsorption along the path
    trial_q_CO2_mean, trial_q_CO2_err = IntrinsicDACCycle.qₐ∞(trial_βs, Kh_CO₂) #kJ/mol of gas
    trial_q_CO2_mean  *= 10^3 #[J/mol]
    trial_q_CO2_err  *= 10^3 #[J/mol]
    trial_q_N2_mean, trial_q_N2_err = IntrinsicDACCycle.qₐ∞(trial_βs, Kh_N₂) #kJ/mol of gas
    trial_q_N2_mean  *= 10^3 #[J/mol]
    trial_q_N2_err  *= 10^3 #[J/mol]
    
    #Generate specific heat of sorbent along the path
    trial_cv_s_mean, trial_cv_s_err =  IntrinsicDACCycle.Extrapolate_Cv(Base_directory, name, trial_Ts) #[J/(kg K)]
end

# ╔═╡ d48f7019-7e73-4711-be4c-31dba92b856a


# ╔═╡ 1b670cce-7501-4985-9ba1-335b56eff171
begin
	samples = 100
	Henry_CO2_dist = rand(MvNormal(vec(Henry_CO2_mean), vec(Henry_CO2_err)), samples)
    Henry_N2_dist = rand(MvNormal(vec(Henry_N2_mean), vec(Henry_N2_err)), samples)

    q_CO2_dist = rand(MvNormal(vec(trial_q_CO2_mean), vec(trial_q_CO2_err)), samples)
    q_N2_dist = rand(MvNormal(vec(trial_q_N2_mean), vec(trial_q_N2_err)), samples)

    cv_s_dist = rand(MvNormal(vec(trial_cv_s_mean), vec(trial_cv_s_err)), samples)
end

# ╔═╡ 28cc48b9-3eb2-4461-b97d-55df46101699


# ╔═╡ 0f091bc7-8c1e-4b7d-acc8-d102188eafc6
begin
	capture_e_dist = []
    purity_dist = []
    Δn_CO2_dist = []
    Δn_N2_dist = []
	for i in 1:samples
		Henry_CO2 = Henry_CO2_dist[:,i]
        Henry_N2 = Henry_N2_dist[:,i]

        q_CO2 = q_CO2_dist[:,i]
        q_N2 = q_N2_dist[:,i]

        cv_s = cv_s_dist[:,1]



        #Generate Equilibrium loadings along the path
        """Occasionally after sampling the material prameters, the path step size will be too coarse 
        and the Analytical_Henry_Generate_sorption_path will try to take the square root of a negative number.
            When that happens, we will return NaNs. This will be a flag to re-evalutate at finer step sizes. 
        """
        n_CO2, n_N2, d_CO2, d_N2, αs = try
            IntrinsicDACCycle.Analytical_Henry_Generate_sorption_path(trial_βs, trial_Ps, α, Henry_CO2, Henry_N2) #[mmol/kg]
        catch error_message
            if isa(error_message, DomainError)
                print("DomainError: sqrt of negative number. Try finer step size in Ts and Ps")
                trial_βs .* NaN, trial_βs .* NaN, trial_βs .* NaN, trial_βs .* NaN, trial_βs .* NaN
            end
        end 
        n_CO2 *= 10^-3 #convert to [mol/kg]
        n_N2 *= 10^-3 #convert to [mol/kg]
        d_CO2 *= 10^-3 #convert to [mol/kg]
        d_N2 *= 10^-3 #convert to [mol/kg]
    


        #Energy balance for step 1
        (Q_adsorb_CO2, Q_adsorb_N2, 
        W_adsorb_CO2, W_adsorb_N2) = IntrinsicDACCycle.intrinsic_refresh_step_1(trial_Ts, 
                                                        n_CO2, n_N2,
                                                        q_CO2, q_N2)
        # [J/kg_sorb]

        E1 = Q_adsorb_CO2 +Q_adsorb_N2 + W_adsorb_CO2 + W_adsorb_N2 # [J/kg_sorb]

        #Energy balance for step 2
        (Q_CO2, Q_N2, 
        W_desorb_CO2, W_desorb_N2, 
        E_heat_ads_CO2, E_heat_ads_N2, 
        E_heat_sorb, E_P) = IntrinsicDACCycle.intrinsic_refresh_step_2(trial_Ts, trial_Ps, 
                                                    n_CO2, n_N2, d_CO2, d_N2,
                                                    q_CO2, q_N2,
                                                    cv_s)
        # [J/kg_sorb]
    
        E2 = nansum(Q_CO2 .+ Q_N2 
                    .+ W_desorb_CO2 .+ W_desorb_N2 
                    .+ E_heat_ads_CO2 .+ E_heat_ads_N2 
                    .+ E_heat_sorb .+ E_P)   # [J/kg_sorb]

        #Energy balance for step 3
        E3 = 0 # [J/kg_sorb]

        #Total Energy of refresh cycle
        E = E1 + E2 + E3# [J/kg_sorb]

        #Total captureed CO2 and N2
        Δn_CO2 = n_CO2[1] - n_CO2[end] # [mol/kg_sorb]
        Δn_N2 = n_N2[1] - n_N2[end] # [mol/kg_sorb]

        #Calculate performance metrics 
        Intrinsic_capture_efficiency = Δn_CO2/E #[mol/J]
        Purity_captured_CO2 = Δn_CO2/(Δn_CO2 + Δn_N2) #[]

        append!(capture_e_dist, Intrinsic_capture_efficiency)
        append!(purity_dist, Purity_captured_CO2)
        append!(Δn_CO2_dist, Δn_CO2)
        append!(Δn_N2_dist, Δn_N2)

    end
end

# ╔═╡ 5db5d525-1171-4f9c-a36d-c1fe3af35d26
capture_e_dist

# ╔═╡ d6d3c0aa-e914-4d0b-82bf-3546e5b0ff13
begin
	plot(trial_Ts, Henry_CO2_dist[:,4])
	plot!(trial_Ts, Henry_N2_dist[:,4])

end

# ╔═╡ ed64bb1e-b04c-45a7-be1a-5390d6a356f5
begin
	test_mean = [10.0, 15.0, 20.0]
	test_var = [10.0, 10.0, 10.0]

	matrix = [[1.0, 1.0, 1.0],
	[1.0, 1.0, 1.0],
	[1.0, 1.0, 1.0]]

	var_matrix = matrix * reshape(test_var, 1,3)
	@show var_matrix

	test_samples = rand(MvNormal(vec(test_mean), vec(var_matrix)), samples)
end

# ╔═╡ e62bf371-5131-4c43-886e-611962b1beb9


# ╔═╡ 8b666fe9-2c76-4519-bb45-5403e2c061c0


# ╔═╡ 3543d275-7d19-4bdd-b4ab-b6b1b5a5669c


# ╔═╡ 9ecbce4a-d1ab-4d77-be78-ab5753233282


# ╔═╡ 1492e644-86a9-489d-b0af-8b0902132ee9


# ╔═╡ bd53fe70-7113-4105-8356-8f882ef72dca


# ╔═╡ e34e9c63-3bdd-4e3d-b1da-e42651a76d44


# ╔═╡ 358d984d-f09b-4463-acdb-0eea818c3202


# ╔═╡ 5fa7d72d-43ee-45e7-b349-0b943653e134


# ╔═╡ 7a107eb8-4efd-421c-99cf-8b84397b1d5d


# ╔═╡ bfb34be1-33fb-40a2-8b02-912164a70ac7
Henry_CO2_dist

# ╔═╡ f32c2359-cc54-47f5-8311-cd3087826bce


# ╔═╡ 8948da0c-6084-4418-8afc-fffda5133a0e


# ╔═╡ efc8ae81-0190-4946-ae4b-5e4c1fbf35fa


# ╔═╡ 1b98cb44-e5be-4ebc-ab62-bbe854f31d84


# ╔═╡ 3cace9c2-508b-4a87-a893-6bfc13e9e02c
path_distributions[arg, 1:4]

# ╔═╡ 1675bbc6-51ec-41ee-b927-255747173596
minimum(path_distributions[:,6])

# ╔═╡ 341ed373-b108-43c5-927c-696a0ca606de


# ╔═╡ Cell order:
# ╠═91940f5e-aa7c-11ee-3924-b90d825c91e6
# ╠═bad9a968-13fe-4fa6-ad4d-f4a2b0ed5e3b
# ╠═89b13632-f2bd-49d1-a8a8-e97d918797d8
# ╠═febedf6a-1d0b-4673-8a7b-ee7935fb7d6c
# ╠═7701affb-bddf-42ee-9cee-cdec1b6e5730
# ╠═9a732c62-b2b8-479d-9e59-9f168805469f
# ╠═717751b7-5de4-4e85-ba20-99d47895f1ee
# ╠═9693dee0-21e4-4a24-b9ec-eef60eb6cbe7
# ╠═9382a88f-a30b-4fd9-afea-3bb1375f503c
# ╠═37bfdb54-96db-4ff8-8702-097dc56fe679
# ╠═138b71da-9e96-4a86-ad26-8ac583a5c77e
# ╠═90d319c0-85ec-4ef7-a66c-c2be81e9301e
# ╠═7dbda39c-c6d5-426b-ac15-403e8d3910dc
# ╠═1c5c8f5c-2359-4dff-8db8-b86f46054b03
# ╠═f194efc8-3c31-4e85-b170-bd614e53a0cb
# ╠═6b56b3f7-f473-42a1-9438-0f576ec4220c
# ╠═6f361213-cb70-48dd-aa44-90e9fb4d6835
# ╠═36c128ad-cfb9-476d-b1e2-3179e287a431
# ╠═b385ba30-185d-42f1-b2cd-cbf038715ee5
# ╠═0a4417f2-dc76-4fa8-89eb-df75f94d42bf
# ╠═3d9bc07b-3390-45df-a59b-a7982fd748c6
# ╠═58db2979-2c6f-430c-a361-cdf3dfae18bd
# ╠═aafcb5c7-2e3e-4a9e-ae1c-b9e586b48e57
# ╠═c86b78a4-254f-4ca3-8c4f-d16fc3311fa7
# ╠═eb2039c4-7d8a-460c-a84f-7264740e89ce
# ╠═adf4a134-e8f1-4b4d-bf84-9a5987ec4f99
# ╠═788fa820-273a-4ace-90dc-d12b669eae37
# ╠═4f011181-cacf-47e6-b475-1e43f70e3ff6
# ╠═f55aa753-4ba9-489e-9e92-d6afca14e8e9
# ╠═95282e1d-0654-4ee0-8ee3-9a4dbd175d61
# ╠═15a6252d-ac7f-4368-8c02-3792f13ae058
# ╠═4fa8b971-7841-4537-ba6d-0f64f706fd40
# ╠═631e9b73-b245-43be-9015-0b22a6c82a10
# ╠═376fbf9e-8085-4075-9370-20262f5771d5
# ╠═b75ce4e5-6d9c-4fef-8bf0-bc569e1625fc
# ╠═43bd21d8-11d4-4930-9b59-c5f5066e6318
# ╠═11ef2251-00cd-45c4-bafb-4ea3d8db2909
# ╠═9a88bcd5-83fd-4da2-96a8-320d0c62978d
# ╠═d48f7019-7e73-4711-be4c-31dba92b856a
# ╠═1b670cce-7501-4985-9ba1-335b56eff171
# ╠═abcca850-2e65-4c14-936d-08b210fd836b
# ╠═28cc48b9-3eb2-4461-b97d-55df46101699
# ╠═0f091bc7-8c1e-4b7d-acc8-d102188eafc6
# ╠═5db5d525-1171-4f9c-a36d-c1fe3af35d26
# ╠═d6d3c0aa-e914-4d0b-82bf-3546e5b0ff13
# ╠═ed64bb1e-b04c-45a7-be1a-5390d6a356f5
# ╠═e62bf371-5131-4c43-886e-611962b1beb9
# ╠═8b666fe9-2c76-4519-bb45-5403e2c061c0
# ╠═3543d275-7d19-4bdd-b4ab-b6b1b5a5669c
# ╠═9ecbce4a-d1ab-4d77-be78-ab5753233282
# ╠═1492e644-86a9-489d-b0af-8b0902132ee9
# ╠═bd53fe70-7113-4105-8356-8f882ef72dca
# ╠═e34e9c63-3bdd-4e3d-b1da-e42651a76d44
# ╠═358d984d-f09b-4463-acdb-0eea818c3202
# ╠═5fa7d72d-43ee-45e7-b349-0b943653e134
# ╠═7a107eb8-4efd-421c-99cf-8b84397b1d5d
# ╠═bfb34be1-33fb-40a2-8b02-912164a70ac7
# ╠═f32c2359-cc54-47f5-8311-cd3087826bce
# ╠═8948da0c-6084-4418-8afc-fffda5133a0e
# ╠═efc8ae81-0190-4946-ae4b-5e4c1fbf35fa
# ╠═1b98cb44-e5be-4ebc-ab62-bbe854f31d84
# ╠═3cace9c2-508b-4a87-a893-6bfc13e9e02c
# ╠═1675bbc6-51ec-41ee-b927-255747173596
# ╠═341ed373-b108-43c5-927c-696a0ca606de
