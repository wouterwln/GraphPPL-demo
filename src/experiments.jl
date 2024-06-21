println("Loading dependencies...")
using RxInfer
using Distributions
using StableRNGs
using Random
using Plots
pgfplotsx()
println("Dependencies loaded successfully!")


@model function ssm_step(x_prev, x_next, y, drift, precision)
    x_next_mean := x_prev + drift
    x_next ~ Normal(mean=x_next_mean, variance=10)
    y ~ Normal(mean=x_next, precision=precision)
end

@model function ssm(drift, y)
    observation_precision ~ Gamma(2, 1)
    x[1] ~ Normal(mean=1.0, variance=10.0)
    for i in eachindex(drift)
        y[i] ~ ssm_step(x_prev=x[i], x_next=new(x[i+1]), drift=drift[i], precision=observation_precision)
    end
end

@model function hierarchical_ssm(y)
    local upper_drift
    for i in eachindex(y)
        upper_drift[i] ~ Normal(mean=0, variance=1)
    end
    hidden_state_drift ~ ssm(drift=upper_drift)
    y ~ ssm(drift=hidden_state_drift)
end


RxInfer.default_init(::typeof(ssm)) = @initialization begin
    q(observation_precision) = Gamma(2, 100)
end


function run_experiments(tikz=false)

    println("Starting experiments...")

    if !isdir("plots")
        mkdir("plots")
    end

    if tikz
        pgfplotsx()
    else
        gr()
    end



    rng = StableRNG(42)

    println("Generating data...")

    n = 100
    top_priors = [rand(rng, Normal(0, 1)) for _ in 1:n]
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
        q(upper_drift) = NormalMeanVariance(0, 100)
        μ(upper_drift) = NormalMeanVariance(0, 100)
        q(hidden_state_drift) = NormalMeanVariance(0, 100)
        μ(hidden_state_drift) = NormalMeanVariance(0, 100)
    end

    constraints = @constraints begin
        for q in ssm
            for q in ssm_step
                q(x_next, y, precision) = q(x_next, y)q(precision)
            end
        end
    end



    println("Running inference...")

    result = infer(model=hierarchical_ssm(), iterations=10, data=(y=y,), initialization=init, constraints=constraints)

    println("Inference completed successfully!")
    println("Generating plots...")

    posterior = last(result.posteriors[:hidden_state_drift])

    p1 = plot(hidden_top, label="Drift Hidden State", size=(500, 400), extra_kwargs=:subplot, legend=:bottomright)
    plot!(p1, mean.(posterior), ribbon=std.(posterior), label="Estimated Drift")
    scatter!(p1, obs_top, label="Actual Drift", markersize=3)
    if !tikz
        savefig(p1, "plots/hierarchical_ssm.png")
    else
        savefig(p1, "plots/hierarchical_ssm.tikz")
    end

    p2 = scatter(y, size=(500, 400), label="Observations", extra_kwargs=:subplot, legend=:topright, markersize=3)
    if !tikz
        savefig(p2, "plots/observations.png")
    else
        savefig(p2, "plots/observations.tikz")
    end
end
