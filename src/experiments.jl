println("Starting experiments...")
println("Loading dependencies...")

using RxInfer
using Distributions
using StableRNGs
using Random
using Plots

println("Dependencies loaded successfully!")

rng = StableRNG(42)

@model function ssm_step(x_prev, x_next, y, p)
    x_next ~ NormalMeanVariance(x_prev + p, 10)
    o_var ~ InverseGamma(2, 0.001)
    y ~ NormalMeanVariance(x_next, o_var)
end


@model function ssm(p, y)
    x[1] ~ NormalMeanVariance(1.0, 10.0)
    for i in eachindex(p)
        y[i] ~ ssm_step(x_prev=x[i], x_next=new(x[i+1]), p=p[i])
    end
end

@model function hierarchical_ssm(y)
    local h1
    for i in eachindex(y)
        h1[i] ~ NormalMeanVariance(0, 1)
    end
    h2 ~ ssm(p=h1)
    y ~ ssm(p=h2)
end

println("Generating data...")

n = 100
top_priors = [rand(Normal(0, 1)) for _ in 1:n]
hidden_top = [rand(rng, Normal(0, 1))]
obs_top = []
hidden_bottom = [rand(rng, Normal(0, 1))]
y = []
for i in 1:n
    push!(hidden_top, rand(rng, Normal(hidden_top[end] + top_priors[length(hidden_top)], 2)))
    push!(obs_top, rand(rng, Normal(hidden_top[end], 2)))
    push!(hidden_bottom, rand(rng, Normal(hidden_bottom[end] + obs_top[end], 2)))
    push!(y, rand(rng, Normal(hidden_bottom[end], 5)))
end

println("Data generated successfully!")

init = @initialization begin
    q(h1) = NormalMeanVariance(0, 100)
    μ(h1) = NormalMeanVariance(0, 100)
    q(h2) = NormalMeanVariance(0, 100)
    μ(h2) = NormalMeanVariance(0, 100)
end

constraints = @constraints begin
    for q in ssm
        for q in ssm_step
            q(x_next, y, o_var) = q(x_next, y)q(o_var)
        end
    end
end

RxInfer.default_init(::typeof(ssm_step)) = @initialization begin
    q(o_var) = InverseGamma(2, 0.01)
end

println("Running inference...")

result = infer(model=hierarchical_ssm(), iterations=10, data=(y=y,), initialization=init, constraints=constraints)

println("Inference completed successfully!")
println("Generating plots...")

posterior = last(result.posteriors[:h2])

plot(hidden_top, label="Hidden state", size=(750, 400))
plot!(mean.(posterior), ribbon=std.(posterior), label="Estimated hidden state")
scatter!(obs_top, label="Hidden state used in observations")
savefig("plots/hierarchical_ssm.png")

scatter(y, size=(750, 400), label="Observations")
savefig("plots/observations.png")