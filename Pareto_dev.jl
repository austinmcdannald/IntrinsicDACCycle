### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 506d1910-c276-11ed-0daa-2967048541da
using Pkg

# ╔═╡ d9a7da1b-ad1b-40c4-809f-0434d22dfa71
Pkg.activate("/users/asm6/.Julia/dev/IntrinsicDACCycle")

# ╔═╡ a2978e82-d421-43a2-a1a1-30aaa7afb7e4
using Revise

# ╔═╡ 6b01655d-022d-451e-98c7-568cc3f61e54
using IntrinsicDACCycle

# ╔═╡ b02a813c-3686-4a4d-ab44-567cb7f5ee9c
using Metaheuristics

# ╔═╡ b5415c4d-9614-45b9-8455-924bf276267d
using Plots

# ╔═╡ 25cae43e-33a0-4d7d-bda9-be48d9344b63
Base_directory = "C:/Users/asm6/Documents/Projects/DAC/Results"

# ╔═╡ 765111ae-5b7a-447c-9f0d-be12b7ce738e
# Pkg.add("Evolutionary")

# ╔═╡ 7fa47b3d-c53c-477c-b1ed-ff1c7ad2e0f0
# using Evolutionary 

# ╔═╡ 2d9d00f3-3e61-45e4-a7f6-dd7108034e1e
# ╠═╡ disabled = true
#=╠═╡
thing = IntrinsicDACCycle.Intrinisic_refresh(Base_directory, "OKILEA_clean")
  ╠═╡ =#

# ╔═╡ 0ecdf2f3-7b5f-4ea7-9f5f-fa807ca1e58c
begin
	#Define refresh cycle (T, P) path and inlet concentration
	t1 = range(0, 100, 101) #progression of desorption [fake time units]
	t2 = range(0, 100, 101) #progression of desorption [fake time units]
	#Isobarically heat 300 K to 350 K
	T1s = 250.0 .+ (0.5 .* t1) #Temperature [K]  
	P1s = 101325 .+ (0 .* t1) #Pressure [Pa] equal to 1 atmosphere of presure
	#Isothermally pull vaccuum from 1 atm to 0.5 atm.
	T2s = T1s[end] .+ (0.0 .* t2) #Temperature [K] 
	P2s = P1s[end] .+ (-101325/200 .* t2) #Pressure [Pa] equal to 1 atmosphere of presure
	#Concatonate the process steps
	Ts = append!(collect(T1s), collect(T2s))
	Ps = append!(collect(P1s), collect(P2s))
	α = 400/1000000 #400 ppm is the concentration of CO2 in ambient air
end

# ╔═╡ 55d98ee5-68d8-417c-9b5b-e35be1973cc3
Ps[end] - Ps[end-1]

# ╔═╡ 4927c6e9-1bdc-40a9-8ce3-e3072e1ce86a
begin
	#specify the total steps along the path
	steps = 402
	
	T_start = [273.0] .- 0.5 #[K] 
	ΔT = 0.5 .* ones(steps) #[K]

	T_start_lower = [200] #[K]
	T_start_upper = [400] #[K]

	ΔT_lower = zero(ΔT) #[K]
	ΔT_upper = 0.90 .+ zero(ΔT) #[K]

	P_start = [101325.0] .+ 101325.0/steps #[Pa]
	#limit the ΔP to only reach "rough vaccuum" 100 Pa.
	ΔP = (100.0 .- P_start[1])./steps .* ones(steps) #[Pa] the offset of 1 Pa ensures that the path of P never gets to 0 Pa. 

	P_start_lower = [101325.0] #[Pa] 
	P_start_upper = 1.1 .* [101325.0] #[Pa]

	#Lower limit of ΔP is to reach "rough vaccum" 100 Pa
	ΔP_lower = (0.1*P_start .- P_start[1])./steps .+ zero(ΔP) #[Pa]
	# ΔP_lower = (500 .- P_start[1])./steps .+ zero(ΔP) #[Pa]
	ΔP_upper = zero(ΔP) #[Pa]
	
end
	

# ╔═╡ a4527a9f-d2f2-4c39-ad2b-e69192dc5c1b
ΔP

# ╔═╡ 14b33311-45b5-492e-a4cc-2b78038e0177
ΔP_lower

# ╔═╡ 2190372c-5d25-4e0d-8d90-8d71883b0079
P_start .+ cumsum(ΔP_lower)

# ╔═╡ a87eaf2d-d5c8-48bc-bc13-52ab5c6de49d
#Need a Flag for molar faction in bounds and domain of sqrt() see https://github.com/austinmcdannald/IntrinsicDACCycle/issues/20

# ╔═╡ ec49f45a-8050-491c-97c0-b3639da710cd
function ScorePath(parameters)
	T_start = parameters[1]
	ΔT = parameters[2:steps+1]
	P_start = parameters[steps+2]
	ΔP = parameters[steps+3:end]
	
	Ts = T_start .+ cumsum(ΔT)
	Ps = P_start .+ cumsum(ΔP)

	# name = "OKILEA_clean"
	name = "acs.cgd.5b01554_VAGNUP1452791_clean"
	# name = "CUCKIV_charged"
	ξ, α_end =  IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, 													  name,
															Ts, Ps, α)
	
	objectives = [1/ξ, 1-α_end]
	gx = [0.0] # inequality constraints
    hx = [0.0] # equality constraints
	return objectives, gx, hx
end

# ╔═╡ 2886b984-0d0b-43dd-be5c-5a8b82114545
begin
	parameters = cat(T_start, ΔT, P_start, ΔP, dims = 1)
	lower_bound = cat(T_start_lower, ΔT_lower, P_start_lower, ΔP_lower, dims = 1)
	upper_bound = cat(T_start_upper, ΔT_upper, P_start_upper, ΔP_upper, dims = 1)
	bounds = cat(lower_bound, upper_bound, dims = 2)'
end


# ╔═╡ a1e67ca0-fb4c-4eab-8b29-a250f92e62b7
parameters[steps+2] .+ cumsum(parameters[steps+3:end])

# ╔═╡ 246f7b4c-b47f-4e3f-b20d-c0c2e2fa7d16
ScorePath(parameters)

# ╔═╡ e91b9339-2f35-4494-934d-d51a7e76431a
begin
	N= 400
	method = Metaheuristics.NSGA3(N= N)
	optimize!(ScorePath, bounds, method)
end

# ╔═╡ aeec586b-75bb-4103-b039-0b6950e386a7
results = Metaheuristics.get_result(method)

# ╔═╡ cef39395-b3f3-4566-b931-b72e389acbbb
begin
	cost = results.best_sol.f	
	@show cost[1], "J/mol"
	resutlant_ξ = 1/cost[1]
	@show resutlant_ξ, "mol/J"

	inpurity = cost[2]
	@show inpurity, "mol/mol"
	purity = 1-inpurity
	@show purity, "mol/mol"

	path = results.best_sol.x
	path_T_start = path[1]
	path_ΔT = path[2:steps+1]
	path_P_start = path[steps+2]
	path_ΔP = path[steps+3:end]

	path_Ts = path_T_start .+ cumsum(path_ΔT)
	path_Ps = path_P_start .+ cumsum(path_ΔP)
end

# ╔═╡ 5762164c-15b4-470b-a68e-53c05e41bd65
begin
plot(path_Ts, path_Ps./P_start)
xlabel!("Temperature (K)")
ylabel!("Pressure (atm)")
end

# ╔═╡ bf9b207c-3a31-4787-bdc7-295ccff35280
minimum(path_ΔT)

# ╔═╡ f3c9f12d-18a8-4656-a43e-e582b6eb1fe4
minimum(path_Ps ./ P_start)

# ╔═╡ bd02af6e-8875-4aea-8c85-78922df1c069
path_Ts

# ╔═╡ 510696cd-6cc1-4d39-b63c-ae36abd67f0a
begin
	pop_f = zeros(length(results.population), 2)
	for (i, pop) in enumerate(results.population)
		pop_f[i, 1] = pop.f[1]
		pop_f[i, 2] = pop.f[2]
	end
	A = pareto_front(results)

	
	
	scatter(pop_f[:,1], pop_f[:,2], label="Populuation", markersize = 2)
	scatter!([A[:,1]],[A[:,2]], label="Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Cost [J/mol]")
	ylabel!("1-Purity")
end

# ╔═╡ 4393adc0-cba9-4a80-8a06-19965dda414b
begin
	pareto_ξ = [1 ./ A[:,1]]
	pareto_α = [1 .- A[:,2]]

	pop_ξ = 1 ./ pop_f[:,1]
	pop_α = 1 .- pop_f[:,2]

	scatter(pop_ξ, pop_α, label = "Population", markersize=2)
	scatter!(pareto_ξ, pareto_α, label = "Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Efficiency [mol/J]")
	ylabel!("Purity")
end

# ╔═╡ 5d8806f5-4f23-4525-9277-cb80c59a5247
begin
	# pareto_ξ = [1 ./ A[:,1]]
	# pareto_α = [1 .- A[:,2]]

	# pop_ξ = 1 ./ pop_f[:,1]
	# pop_α = 1 .- pop_f[:,2]

	scatter(pop_ξ, pop_α, label = "Population", markersize=2,
			xlim = (7.55e-6,7.62e-6), ylim = (0.99,1.001))
	scatter!(pareto_ξ, pareto_α, label = "Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Efficiency [mol/J]")
	ylabel!("Purity")

end

# ╔═╡ 92d40140-47ce-4849-a334-5a068621fbcd
Metaheuristics.show(results)

# ╔═╡ 6cd92279-4c49-4f0e-bb95-329ef2b8ab11
begin
	all_parameters = zeros(N, length(results.best_sol.x))
	for (i, item) in enumerate(method.status.population)
		all_parameters[i,:] = item.x
	end
	all_T_starts = all_parameters[:,1]
	all_ΔTs = all_parameters[:,2:steps+1]

	all_Ts = all_T_starts .+ cumsum(all_ΔTs, dims = 2)

	all_P_starts = all_parameters[:,steps+2]
	all_ΔPs = all_parameters[:,steps+3:end]

	all_Ps = all_P_starts .+ cumsum(all_ΔPs, dims = 2)
end

# ╔═╡ adb52661-974a-44d0-ae46-9d46726b7116
begin
plot(all_Ts', all_Ps', label=false)
xlabel!("Temperature (K)")
ylabel!("Pressure (atm)")
end

# ╔═╡ c7a93e89-dede-47da-9cbe-fdb6d4abc897
all_Ps[1,:]

# ╔═╡ d18bd1b3-ddaa-4b05-b517-a31772ebbf38


# ╔═╡ 3c515132-de69-4259-892d-e5ff7841b7f6
pareto_ξ

# ╔═╡ 8f6e4f92-2f5f-4295-bf3d-fadc519f74ac
A

# ╔═╡ 1443d6fa-51d3-445c-bc56-10a82e1f36d7
begin
	#try splitting the temperature change and pressure change to sequential
	check_steps = trunc(Int, steps/2)
	check_T_start = path_Ts[1]
	check_ΔT = (path_Ts[end] - path_Ts[1])/check_steps
	check_ΔTs = cat(check_ΔT .+ zeros(check_steps), zeros(check_steps), dims = 1)

	check_P_start = path_Ps[1]
	check_ΔP = (path_Ps[end] - path_Ps[1])/check_steps
	check_ΔPs = cat(zeros(check_steps), check_ΔP .+ zeros(check_steps), dims = 1)

	check_parameters = cat(check_T_start, check_ΔTs, check_P_start, check_ΔPs, dims = 1)
	
	
end

# ╔═╡ 6a64bd4a-c24a-4d8b-a04f-2cef74a954e4
ScorePath(check_parameters)

# ╔═╡ 763ed732-977c-4b01-bb69-5c7b147b55ec
# begin
# 	ideal_scores = [0.0, 0.0]
# 	result = Evolutionary.optimize(ScorePath, 
# 						  ideal_scores,  
# 						  BoxConstraints(lower_bound, upper_bound),
# 						  NSGA2())
# end

# ╔═╡ 109248cd-1914-4a3b-ac5a-3095a0090b43
# typeof(BoxConstraints(lower_bound, upper_bound))


# ╔═╡ 340d3a90-b3eb-4af3-8ec8-c001e30890c4
# typeof(BoxConstraints())

# ╔═╡ 2a293d59-5314-4100-b647-1e3f5e8fca46
function dumb(x)
	 y = 
	try
		sqrt(x)
	catch 
		# none
		"Domain error"
	end
	
	return y
end

# ╔═╡ 48b58b9b-27c0-4502-9c0d-332e4f33a9e7
dumb(-2.0)

# ╔═╡ c74531b1-99d8-4639-a4cf-c8bd08c5c7ac


# ╔═╡ 14997ae6-948f-4861-a73e-cb457452e278


# ╔═╡ ddf5c760-0dd7-4908-a183-1d12385d2191


# ╔═╡ ff227e7b-2d38-470d-8136-1b5876bea5fb


# ╔═╡ 92431f25-3905-46aa-9826-1d9b679c4f1d
# T_start .+ cumsum(ΔT)

# ╔═╡ 7fe6bbb2-f225-4811-88c5-9b6c3de48981
# test = IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, "OKILEA_clean",
															# Ts, Ps, α)

# ╔═╡ e6fa0989-78a7-4c2c-9274-a4543ab56826
# function somefun(α)
# 	objectives = IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, "OKILEA_clean", Ts, Ps, α[1])
# 	return objectives[1]			
# end

# ╔═╡ fe4f23ed-2f94-44fa-a73c-190072f6868c
# Evolutionary.optimize(somefun, [α], CMAES())

# ╔═╡ 69025132-51c5-41f2-980c-77b57852d0ec
# begin
# 	idea_αs = [[0.0]]
# 	Evolutionary.optimize(somefun, [0.0], [α], CMAES())
# end

# ╔═╡ 1c1a94cd-7df3-4c3f-ac56-50f50f4f5806
# Evolutionary.optimize(f = somefun, 
# 	individual = [α], 
# 	method = CMAES())

# ╔═╡ 2b4b8272-d32b-43ab-9b00-eada01ea0c84


# ╔═╡ 70ea3a85-bbb8-46d1-8f7d-7bf3f5c1e67c


# ╔═╡ f39e946c-4829-40a4-a808-39881a4fd7be


# ╔═╡ ee91fa72-1051-4d0f-8c16-63ffe28cbc8d


# ╔═╡ 62122849-d31f-4c91-9401-e8c9865c9b21
# typeof(somefun)

# ╔═╡ 15a51a5f-ab0f-406f-a386-e577c8000cb9
# somefun(0.5)

# ╔═╡ 2a88869b-c526-4bb5-ba33-15dbdcfa17de
# f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2

# ╔═╡ f4d2891b-e8d2-4338-9954-2c017eae2996
# test_x = [20, 25]

# ╔═╡ b4d7d51e-fe45-4453-adf3-39d634d3cd12
# Evolutionary.optimize(f, test_x, CMAES())

# ╔═╡ a367e812-9058-4fbc-94c5-fbb3faf2d79b
# zero(test_x)

# ╔═╡ Cell order:
# ╠═506d1910-c276-11ed-0daa-2967048541da
# ╠═d9a7da1b-ad1b-40c4-809f-0434d22dfa71
# ╠═a2978e82-d421-43a2-a1a1-30aaa7afb7e4
# ╠═6b01655d-022d-451e-98c7-568cc3f61e54
# ╠═25cae43e-33a0-4d7d-bda9-be48d9344b63
# ╠═765111ae-5b7a-447c-9f0d-be12b7ce738e
# ╠═7fa47b3d-c53c-477c-b1ed-ff1c7ad2e0f0
# ╠═b02a813c-3686-4a4d-ab44-567cb7f5ee9c
# ╠═b5415c4d-9614-45b9-8455-924bf276267d
# ╠═2d9d00f3-3e61-45e4-a7f6-dd7108034e1e
# ╠═0ecdf2f3-7b5f-4ea7-9f5f-fa807ca1e58c
# ╠═55d98ee5-68d8-417c-9b5b-e35be1973cc3
# ╠═4927c6e9-1bdc-40a9-8ce3-e3072e1ce86a
# ╠═a4527a9f-d2f2-4c39-ad2b-e69192dc5c1b
# ╠═14b33311-45b5-492e-a4cc-2b78038e0177
# ╠═2190372c-5d25-4e0d-8d90-8d71883b0079
# ╠═a87eaf2d-d5c8-48bc-bc13-52ab5c6de49d
# ╠═ec49f45a-8050-491c-97c0-b3639da710cd
# ╠═2886b984-0d0b-43dd-be5c-5a8b82114545
# ╠═a1e67ca0-fb4c-4eab-8b29-a250f92e62b7
# ╠═246f7b4c-b47f-4e3f-b20d-c0c2e2fa7d16
# ╠═e91b9339-2f35-4494-934d-d51a7e76431a
# ╠═aeec586b-75bb-4103-b039-0b6950e386a7
# ╠═cef39395-b3f3-4566-b931-b72e389acbbb
# ╠═5762164c-15b4-470b-a68e-53c05e41bd65
# ╠═bf9b207c-3a31-4787-bdc7-295ccff35280
# ╠═f3c9f12d-18a8-4656-a43e-e582b6eb1fe4
# ╠═bd02af6e-8875-4aea-8c85-78922df1c069
# ╠═510696cd-6cc1-4d39-b63c-ae36abd67f0a
# ╠═4393adc0-cba9-4a80-8a06-19965dda414b
# ╠═5d8806f5-4f23-4525-9277-cb80c59a5247
# ╠═92d40140-47ce-4849-a334-5a068621fbcd
# ╠═6cd92279-4c49-4f0e-bb95-329ef2b8ab11
# ╠═adb52661-974a-44d0-ae46-9d46726b7116
# ╠═c7a93e89-dede-47da-9cbe-fdb6d4abc897
# ╠═d18bd1b3-ddaa-4b05-b517-a31772ebbf38
# ╠═3c515132-de69-4259-892d-e5ff7841b7f6
# ╠═8f6e4f92-2f5f-4295-bf3d-fadc519f74ac
# ╠═1443d6fa-51d3-445c-bc56-10a82e1f36d7
# ╠═6a64bd4a-c24a-4d8b-a04f-2cef74a954e4
# ╠═763ed732-977c-4b01-bb69-5c7b147b55ec
# ╠═109248cd-1914-4a3b-ac5a-3095a0090b43
# ╠═340d3a90-b3eb-4af3-8ec8-c001e30890c4
# ╠═2a293d59-5314-4100-b647-1e3f5e8fca46
# ╠═48b58b9b-27c0-4502-9c0d-332e4f33a9e7
# ╠═c74531b1-99d8-4639-a4cf-c8bd08c5c7ac
# ╠═14997ae6-948f-4861-a73e-cb457452e278
# ╠═ddf5c760-0dd7-4908-a183-1d12385d2191
# ╠═ff227e7b-2d38-470d-8136-1b5876bea5fb
# ╠═92431f25-3905-46aa-9826-1d9b679c4f1d
# ╠═7fe6bbb2-f225-4811-88c5-9b6c3de48981
# ╠═e6fa0989-78a7-4c2c-9274-a4543ab56826
# ╠═fe4f23ed-2f94-44fa-a73c-190072f6868c
# ╠═69025132-51c5-41f2-980c-77b57852d0ec
# ╠═1c1a94cd-7df3-4c3f-ac56-50f50f4f5806
# ╠═2b4b8272-d32b-43ab-9b00-eada01ea0c84
# ╠═70ea3a85-bbb8-46d1-8f7d-7bf3f5c1e67c
# ╠═f39e946c-4829-40a4-a808-39881a4fd7be
# ╠═ee91fa72-1051-4d0f-8c16-63ffe28cbc8d
# ╠═62122849-d31f-4c91-9401-e8c9865c9b21
# ╠═15a51a5f-ab0f-406f-a386-e577c8000cb9
# ╠═2a88869b-c526-4bb5-ba33-15dbdcfa17de
# ╠═f4d2891b-e8d2-4338-9954-2c017eae2996
# ╠═b4d7d51e-fe45-4453-adf3-39d634d3cd12
# ╠═a367e812-9058-4fbc-94c5-fbb3faf2d79b
