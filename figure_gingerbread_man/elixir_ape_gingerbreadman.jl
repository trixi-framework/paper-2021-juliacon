
###############################################################################
# generate the gingerbread man mesh file using HOHQMesh
using HOHQMesh

control_file = joinpath(@__DIR__, "mesh_gingerbread_man.control")
output = generate_mesh(control_file)

###############################################################################
# setup the Trixi simulation
using OrdinaryDiffEq
using Trixi

###############################################################################
# semidiscretization of the acoustic perturbation equations

equations = AcousticPerturbationEquations2D(v_mean_global=(0.0, -0.5), c_mean_global=1.0,
                                            rho_mean_global=1.0)

# Create DG solver with polynomial degree = 6 and (local) Lax-Friedrichs/Rusanov flux
solver = DGSEM(polydeg=6, surface_flux=flux_lax_friedrichs)

# Create unstructured quadrilateral mesh from a file
mesh_file = joinpath(@__DIR__, "out", "mesh_gingerbread_man.mesh")
mesh = UnstructuredMesh2D(mesh_file)

# Setup the initial and boundary conditions
function initial_condition_ginger_pulse(x, t, equations::AcousticPerturbationEquations2D)
    v1_prime = 0.0
    v2_prime = 0.0
    nose          = exp(-log(2) * ((x[1] - 0.0)^2 + (x[2] - 43.5)^2) / 2.0)
    button_top    = exp(-log(2) * ((x[1] - 0.0)^2 + (x[2] - 30.25)^2) )
    button_bottom = exp(-log(2) * ((x[1] - 0.0)^2 + (x[2] - 22.5)^2) )

    return SVector(v1_prime, v2_prime, nose + button_top + button_bottom,
                   Trixi.global_mean_vars(equations)...)
  end

initial_condition = initial_condition_ginger_pulse

boundary_condition_slip_wall = BoundaryConditionWall(boundary_state_slip_wall)
boundary_conditions = Dict( :Body    => boundary_condition_slip_wall,
                            :Button1 => boundary_condition_slip_wall,
                            :Button2 => boundary_condition_slip_wall,
                            :Eye1    => boundary_condition_slip_wall,
                            :Eye2    => boundary_condition_slip_wall,
                            :Smile   => boundary_condition_slip_wall,
                            :Bowtie  => boundary_condition_slip_wall )

# A semidiscretization collects data structures and functions for the spatial discretization
semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                    boundary_conditions=boundary_conditions)


###############################################################################
# ODE solvers, callbacks etc.

# Create ODE problem with time span from 0.0 to 16.0
tspan = (0.0, 16.0)
ode = semidiscretize(semi, tspan)

# At the beginning of the main loop, the SummaryCallback prints a summary of the simulation setup
# and resets the timers
summary_callback = SummaryCallback()

# The AnalysisCallback allows to analyse the solution in regular intervals and prints the results
analysis_callback = AnalysisCallback(semi, interval=100)

# The SaveSolutionCallback allows to save the solution to a file in regular intervals
save_solution = SaveSolutionCallback(interval=1500,
                                     save_initial_solution=true,
                                     save_final_solution=true,
                                     solution_variables=cons2state)

# Create a CallbackSet to collect all callbacks such that they can be passed to the ODE solver
callbacks = CallbackSet(summary_callback, analysis_callback, save_solution)

###############################################################################
# run the simulation

# use a Runge-Kutta method with automatic (error based) time step size control
sol = solve(ode, RDPK3SpFSAL49(), abstol=1.0e-6, reltol=1.0e-6,
            save_everystep=false, callback=callbacks);
# Print the timer summary
summary_callback()

###############################################################################
# convert the output files using Trixi2Vtk for plotting with ParaView / VisIt
using Trixi2Vtk

trixi2vtk("out/solution_??????.h5", output_directory="out", nvisnodes=14)
