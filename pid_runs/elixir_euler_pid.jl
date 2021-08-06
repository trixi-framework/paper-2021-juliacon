
using OrdinaryDiffEq
using Trixi

###############################################################################
# semidiscretization of the compressible Euler equations

equations = CompressibleEulerEquations3D(1.4)

initial_condition = initial_condition_convergence_test
source_term=source_terms_convergence_test


###############################################################################
# Get the DG approximation space

# For ECKEP flux split form
#volume_flux = flux_ranocha
#solver = DGSEM(polydeg=3, surface_flux=flux_ranocha,
#               volume_integral=VolumeIntegralFluxDifferencing(volume_flux))

# For standard DG weak form + HLL
solver = DGSEM(polydeg=3, surface_flux=flux_hll,
               volume_integral=VolumeIntegralWeakForm())

###############################################################################
# Get the curved quad mesh from a file

# Mapping as described in https://arxiv.org/abs/2012.12040
function mapping(xi, eta, zeta)
  y = eta + 0.15 * (cos(1.5 * pi * xi) * cos(0.5 * pi * eta) * cos(0.5 * pi * zeta))

  x = xi + 0.15 * (cos(0.5 * pi * xi) * cos(2 * pi * y) * cos(0.5 * pi * zeta))

  z = zeta + 0.15 * (cos(0.5 * pi * x) * cos(pi * y) * cos(0.5 * pi * zeta))

  return SVector(x, y, z)
end

cells_per_dimension = (4, 4, 4)
mesh = StructuredMesh(cells_per_dimension, mapping)

###############################################################################
# create the semi discretization object

semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                    source_terms=source_term)

###############################################################################
# ODE solvers, callbacks etc.

tspan = (0.0, 1.0)
ode = semidiscretize(semi, tspan)

summary_callback = SummaryCallback()

analysis_interval = 100
analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

alive_callback = AliveCallback(analysis_interval=analysis_interval)

save_solution = SaveSolutionCallback(interval=50,
                                     save_initial_solution=true,
                                     save_final_solution=true)

stepsize_callback = StepsizeCallback(cfl=0.5)

callbacks = CallbackSet(summary_callback,
                        analysis_callback,
#                        alive_callback,
#                        save_solution,
                        stepsize_callback)

###############################################################################
# run the simulation

sol = solve(ode, CarpenterKennedy2N54(williamson_condition=false),
            dt=1.0, # solve needs some value here but it will be overwritten by the stepsize_callback
            save_everystep=false, callback=callbacks);
summary_callback() # print the timer summary