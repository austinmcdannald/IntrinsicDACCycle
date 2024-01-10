### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 04d821e2-ae64-11ee-1714-81a3d48995f0
using Pkg

# ╔═╡ 035386c2-dfa4-458f-9ac3-c058e5ac8ae8
Pkg.activate("C:/Users/asm6/.jula/dev/IntrinsicDACCycle")

# ╔═╡ b9e88116-2c95-4b70-9dd1-48451dcc5fdf
using Revise

# ╔═╡ 62094f7b-e991-407e-b183-54bbf3faddef
using IntrinsicDACCycle

# ╔═╡ b70516f5-449a-4cf4-b3c2-7133fdf9ef63
using Distributions

# ╔═╡ 033fb358-7bcd-4a12-b95f-610964e7346f
using Plots

# ╔═╡ 77c703ec-85c6-47b7-bd51-37e405016aad
begin
	Ts = collect(LinRange(200, 400, 200))

	βs = IntrinsicDACCycle.T_to_β.(Ts)

	Base_directory = "C:/Users/asm6/Documents/Projects/DAC/Results"
	name = "ABETIN_clean"

	material, Kh_N₂, Kh_CO₂, One_atm_N₂ = IntrinsicDACCycle.read_jsons(Base_directory, name)

	Henry_CO2_mean, Henry_CO2_err = IntrinsicDACCycle.Kh_extrapolate(βs, Kh_CO₂, material)

	samples = 100
	old_Henry_CO2_dist = rand(MvNormal(vec(Henry_CO2_mean), vec(Henry_CO2_err)), samples)

	factor = reshape(rand(Normal(0,1), 100), 1, :)
	Henry_CO2_dist = reshape(Henry_CO2_mean, :, 1) .+ reshape(Henry_CO2_err, :, 1) * factor
	# Henry_CO2_dist = Henry_CO2_mean .+ factor .* Henry_CO2_err
	
	
end

# ╔═╡ d2d94092-2c46-46b0-8366-c49ce346175a


# ╔═╡ 91969a35-c2a1-4db1-bbb2-2304b0173dac
old_Henry_CO2_dist

# ╔═╡ 50899242-476b-447a-95ca-421bdfa38696
Henry_CO2_dist

# ╔═╡ 6b28ca3e-ecfc-42f5-aa18-0d09e8695b7c
plot(Ts, log10.(Henry_CO2_dist))

# ╔═╡ bd988b64-729c-4229-b69a-e6fe79a4c3fa
plot(Ts, log10.(old_Henry_CO2_dist))

# ╔═╡ afd44c8e-013c-4756-a73b-23f943428120


# ╔═╡ 219f32f1-f196-4375-af32-fc754726e29a
begin
	test_factor = reshape(factor, 1, :)
	test_err = reshape(Henry_CO2_err, :, 1)
	test_mean = reshape(Henry_CO2_mean, :, 1)

	test_mean .+ test_err * test_factor
end

# ╔═╡ d7ec4bdc-3f32-436f-82b9-ff58baef6e0e
begin
	Ps = collect(LinRange(101325.0, 100, 200))
	α = 400/1000000

	objectives_dist = IntrinsicDACCycle.Intrinisic_refresh_objectives_posterior_dist(Base_directory, name, Ts, Ps, α)

end

# ╔═╡ c29e001d-7d5b-496a-93f3-44cc30d99e4a


# ╔═╡ ac76a0e2-b695-4367-b80e-b30f0c708ee5


# ╔═╡ dc011f47-6e93-4f08-91d5-4985e9a78931


# ╔═╡ 85301608-9599-4694-a1c3-291b7be1587f


# ╔═╡ c30eb827-302d-4396-bf4e-3e0a97ac2806


# ╔═╡ 7d4e02b7-19f9-47bc-9b82-a9110ad8280e


# ╔═╡ eca5eb18-4dfe-45bc-ba91-c0375f4746c3


# ╔═╡ Cell order:
# ╠═04d821e2-ae64-11ee-1714-81a3d48995f0
# ╠═035386c2-dfa4-458f-9ac3-c058e5ac8ae8
# ╠═b9e88116-2c95-4b70-9dd1-48451dcc5fdf
# ╠═62094f7b-e991-407e-b183-54bbf3faddef
# ╠═b70516f5-449a-4cf4-b3c2-7133fdf9ef63
# ╠═77c703ec-85c6-47b7-bd51-37e405016aad
# ╠═d2d94092-2c46-46b0-8366-c49ce346175a
# ╠═91969a35-c2a1-4db1-bbb2-2304b0173dac
# ╠═50899242-476b-447a-95ca-421bdfa38696
# ╠═033fb358-7bcd-4a12-b95f-610964e7346f
# ╠═6b28ca3e-ecfc-42f5-aa18-0d09e8695b7c
# ╠═bd988b64-729c-4229-b69a-e6fe79a4c3fa
# ╠═afd44c8e-013c-4756-a73b-23f943428120
# ╠═219f32f1-f196-4375-af32-fc754726e29a
# ╠═d7ec4bdc-3f32-436f-82b9-ff58baef6e0e
# ╠═c29e001d-7d5b-496a-93f3-44cc30d99e4a
# ╠═ac76a0e2-b695-4367-b80e-b30f0c708ee5
# ╠═dc011f47-6e93-4f08-91d5-4985e9a78931
# ╠═85301608-9599-4694-a1c3-291b7be1587f
# ╠═c30eb827-302d-4396-bf4e-3e0a97ac2806
# ╠═7d4e02b7-19f9-47bc-9b82-a9110ad8280e
# ╠═eca5eb18-4dfe-45bc-ba91-c0375f4746c3
