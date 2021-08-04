
using OrdinaryDiffEq
using Trixi

###############################################################################
# semidiscretization of the compressible Euler equations

gamma = 1.001 # almost isothermal when gamma reaches 1
equations = CompressibleEulerEquations2D(gamma)

# This is a hand made colliding flow setup without reference. Features Mach=70 inflow from both
# sides, with relative low temperature, such that pressure keeps relatively small
# Computed with gamma close to 1, to simulate isothermal gas
function initial_condition(x, t, equations::CompressibleEulerEquations2D)
  # change discontinuity to tanh
  # resolution 128^2 elements (refined close to the interface) and N=3 (total of 512^2 DOF)
  # domain size is [-64,+64]^2
  @unpack gamma = equations
  rho = 0.0247
  c = 0.2
  p = c^2 / gamma * rho
  vel = 13.907432274789372
  slope = 1.0
  v1 = -vel * tanh(slope * x[1])
  # add small initial disturbance to the field, but only close to the interface
  if abs(x[1]) < 10
    v1 = v1 * (1 + 0.01 * sin(pi * x[2]))
  end
  v2 = 0.0
  return prim2cons(SVector(rho, v1, v2, p), equations)
end


boundary_conditions = (x_neg=BoundaryConditionDirichlet(initial_condition),
                       x_pos=BoundaryConditionDirichlet(initial_condition),
                       y_neg=boundary_condition_periodic,
                       y_pos=boundary_condition_periodic)



surface_flux = flux_lax_friedrichs
volume_flux  = flux_ranocha
polydeg = 3
basis = LobattoLegendreBasis(polydeg)

# shock capturing necessary for this tough example, however alpha_max = 0.5 is fine
indicator_sc = IndicatorHennemannGassner(equations, basis,
                                         alpha_max=0.5,
                                         alpha_min=0.0001,
                                         alpha_smooth=true,
                                         variable=density_pressure)
volume_integral = VolumeIntegralShockCapturingHG(indicator_sc;
                                                 volume_flux_dg=volume_flux,
                                                 volume_flux_fv=surface_flux)
solver = DGSEM(basis, surface_flux, volume_integral)

coordinates_min = (-64.0, -64.0)
coordinates_max = ( 64.0,  64.0)

mesh = TreeMesh(coordinates_min, coordinates_max,
                initial_refinement_level=4,
                periodicity=(false,true),
                n_cells_max=100_000)
semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                    boundary_conditions=boundary_conditions)

###############################################################################
# ODE solvers, callbacks etc.

tspan = (0.0, 25.0)
ode = semidiscretize(semi, tspan)

summary_callback = SummaryCallback()

analysis_interval = 1000
analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

alive_callback = AliveCallback(analysis_interval=analysis_interval)

amr_indicator = IndicatorHennemannGassner(semi,
                                          alpha_max=1.0,
                                          alpha_min=0.0001,
                                          alpha_smooth=false,
                                          variable=Trixi.density)

amr_controller = ControllerThreeLevelCombined(semi, amr_indicator, indicator_sc,
                                              base_level=2,
                                              med_level =0, med_threshold=0.0003, # med_level = current level
                                              max_level =8, max_threshold=0.003,
                                              max_threshold_secondary=indicator_sc.alpha_max)

amr_callback = AMRCallback(semi, amr_controller,
                           interval=1,
                           adapt_initial_condition=true,
                           adapt_initial_condition_only_refine=true)

callbacks = CallbackSet(summary_callback,
                        analysis_callback, alive_callback,
                        amr_callback)

stage_limiter! = PositivityPreservingLimiterZhangShu(thresholds=(5.0e-6, 5.0e-6),
                                                     variables=(Trixi.density, pressure))


###############################################################################
# run the simulation
sol = solve(ode, SSPRK43(stage_limiter!),
            save_everystep=false, callback=callbacks);
summary_callback() # print the timer summary


###############################################################################
# plot the numerical result at the final time
using Plots

figdir = joinpath(dirname(@__DIR__), "figures")
fontsizes = (xtickfontsize=18, ytickfontsize=18, xguidefontsize=20, yguidefontsize=20, legendfontsize=18)

pd = PlotData2D(sol)
plot(pd["rho"], title="", colorbar_title="", size=(650, 500), seriescolor=:plasma, clim=(0.0, 45.0); fontsizes...)
savefig(joinpath(figdir, "colliding_flows_density_t" * string(round(Int, last(tspan))) * ".pdf"))

plot(getmesh(pd), xlabel="\$x\$", ylabel="\$y\$", size=(580, 500), linewidth=1.2, grid=false; fontsizes...)
savefig(joinpath(figdir, "colliding_flows_mesh_t" * string(round(Int, last(tspan))) * ".pdf"))