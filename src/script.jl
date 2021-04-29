# make sure that your pwd is set to the folder containing script and HANKEstim
# otherwise adjust the load path
# cd("HANK_BusinessCycleAndInequality/src")
#
# Need 5G to compute steady state and linearize
using Pkg, JLD2, Random
Pkg.activate("../")
Pkg.pin(name = "JLD2", version = "0.1.11")
push!(LOAD_PATH, pwd())
using HANKEstim, ForwardDiff

#initialize model parameters
m_par = ModelParameters()
Random.seed!(1793)
@time begin
    sr = compute_steadystate(m_par)
end
include("save_sr.jl")
@time begin
    lr = linearize_full_model(sr, m_par)
end
JLD2.jldopen("linearize_full_model_output_seed1793.jld2", true, true, true, IOStream) do file
    write(file, "gx", lr.State2Control)
    write(file, "hx", lr.LOMstate)
    write(file, "A", lr.A)
    write(file, "B", lr.B)
end

#=@time begin # 230s, incl compile time
    Random.seed!(1793)
    lr    = linearize_full_model(sr, m_par)
end
@assert false
HANKEstim.@save "7_Saves/linearresults.jld2" lr=#
# HANKEstim.@load "7_Saves/linearresults.jld2"

# plot some irfs to tfp (z) shock
# using LinearAlgebra, Plots
# x0                  = zeros(size(lr.LOMstate,1), 1)
#  x0[sr.indexes.Z] = 100 * m_par.σ_Z
# #x0[sr.indexes.σ]    = 100 * m_par.σ_Sshock

# MX                  = [I; lr.State2Control]
# irf_horizon         = 40
# x                   = x0 * ones(1, irf_horizon + 1)
# IRF_state_sparse    = zeros(sr.n_par.ntotal, irf_horizon)

# for t = 1:irf_horizon
#         IRF_state_sparse[:, t] = (MX * x[:, t])'
#         x[:, t+1]              = lr.LOMstate * x[:, t]
# end

# plt1 = plot(IRF_state_sparse[sr.indexes.Z,:],  label = "TFP (percent)", reuse = false)
# plt1 = plot!(IRF_state_sparse[sr.indexes.I,:], label = "Investment (percent)")
# plt1 = plot!(IRF_state_sparse[sr.indexes.Y,:], label = "Output (percent)")
# plt1 = plot!(IRF_state_sparse[sr.indexes.C,:], label = "Consumption (percent)")
#=
if HANKEstim.e_set.estimate_model == true
    # warning: estimation might take a long time!
    er = find_mode(sr, lr, m_par)
    # loading the mode only works with a full mode save file not our provided file
    er = load_mode(sr; file = HANKEstim.e_set.save_mode_file)
    # montecarlo(sr, lr, er, m_par)
end
=#
