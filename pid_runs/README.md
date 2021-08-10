# Performance index (PID) computations of Trixi.jl and FLUXO

The files in this folder can be used to reproduce the numerical experiments
for the performance comparison between the Fortran code
[FLUXO](https://gitlab.com/project-fluxo/fluxo) and the Julia code
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl).
All results reported in the paper were obtained with the Intel compiler suite v18.0.03
and Julia v1.6.1. The runs were performed with a single Intel Xeon Gold 6130 processor
on [Tetralith](https://www.nsc.liu.se/systems/tetralith/), an HPC cluster provided by the
[Swedish National Infrastructure for Computing (SNIC)](https://snic.se/).

## Trixi.jl run instructions

To reproduce the Trixi.jl numerical PID experiments, proceed as follows.
- Start Julia in this folder and activate the project environment therein
  ```shell
  > julia --project=@. --threads=1 --check-bounds=no
  ```
- Execute one of the included elixir files; either `elixir_euler_pid.jl` for the
  3D compressible Euler equations on a heavily warped periodic box mesh or `elixir_mhd_pid.jl`
  for the 3D ideal GLM-MHD equations on a heavily warped periodic box mesh. One can vary the polynomial
  degree (`polydeg`) directly from the REPL. For example, one can run a compressible Euler test with fifth
  order polynomials using
  ```julia
  julia> using Trixi

  julia> trixi_include("elixir_euler_pid.jl", polydeg=5)
  ```
- The PID is a quantity reported during the Trixi.jl simulation and is easily extracted.
  Below is an example check-in terminal output from the simulation setup run with
  the commands in the previous step:
  ```
  ────────────────────────────────────────────────────────────────────────────────────────────────────
   Simulation running 'CompressibleEulerEquations3D' with DGSEM(polydeg=5)
  ────────────────────────────────────────────────────────────────────────────────────────────────────
   #timesteps:                200                run time:       3.93717669e+00 s
   Δt:             4.94155838e-03                time/DOF/rhs!:  5.86020104e-08 s
   sim. time:      9.53523721e-01
   #DOF:                    13824
   #elements:                  64

   Variable:       rho              rho_v1           rho_v2           rho_v3           rho_e
   L2 error:       3.89745194e-03   3.08224319e-03   3.73575208e-03   3.82055431e-03   5.96909051e-03
   Linf error:     9.32386945e-02   6.21319993e-02   9.94372780e-02   9.33482995e-02   1.49278473e-01
   ∑∂S/∂U ⋅ Uₜ :   9.90536480e-06
  ────────────────────────────────────────────────────────────────────────────────────────────────────
  ```
  The PID information is found on the top right with the label `time/DOF/rhs!:  5.86020104e-08 s`.
- In order to change the type of DG solver used during the comparison one must make some simple edits
  to either of the included elixir files. As committed in this repo, the weak form DG solver with the
  HLL surface flux is used by default. To change to the flux differencing entropy conservative DG
  solver comment the weak form solver instructions and uncomment the flux differencing commands, e.g.,
  in `elixir_euler_pid.jl` edit lines 17-24 to become
  ```julia
  # For ECKEP flux split form
  volume_flux = flux_ranocha
  solver = DGSEM(polydeg=3, surface_flux=flux_ranocha,
                 volume_integral=VolumeIntegralFluxDifferencing(volume_flux))

  # For standard DG weak form + HLL
  #solver = DGSEM(polydeg=3, surface_flux=flux_hll,
  #               volume_integral=VolumeIntegralWeakForm())
  ```
  In the ideal GLM-MHD elixir file a similar comment/uncomment can be done on lines 13-21 as follows
  ```julia
  # For ECKEP flux split form
   volume_flux = (flux_hindenlang_gassner, flux_nonconservative_powell)
   solver = DGSEM(polydeg=3, surface_flux=(flux_hindenlang_gassner, flux_nonconservative_powell),
                 volume_integral=VolumeIntegralFluxDifferencing(volume_flux))

  # For standard DG weak form + HLL
  #volume_flux = (flux_central, flux_nonconservative_powell)
  #solver = DGSEM(polydeg=3, surface_flux=(flux_hll, flux_nonconservative_powell),
  #               volume_integral=VolumeIntegralFluxDifferencing(volume_flux))
  ```

## FLUXO configuration, compilation, and run instructions

The files necessary to reproduce the FLUXO simulations for the PID comparison are also included.
These simulation were run on the same heavily warped periodic box mesh.
For the FLUXO simulations this mesh is read into the code from the file `ConformBoxHeavilyWarped_04_mesh.h5` at runtime.
This mesh file was generated with the [High Order Preprocessor (HOPR)](https://www.hopr-project.org/index.php/Home) tool.
We also include the `hopr_parameter_ConformBoxHeavilyWarped.ini` file used with HOPR to generate this mesh.

To reproduce the FLUXO numerical PID experiments, proceed as follows. Note, for this discussion it is assumed that
one has access to some version of the Intel compiler suite.
- Clone the [FLUXO](https://gitlab.com/project-fluxo/fluxo) source code. The results reported in this work used the
  `master` branch with the commit hash `f16435a779ca342b44b12d0475506ec2d25e7db9`.
- Follow the provided [installation instructions](https://gitlab.com/project-fluxo/fluxo/-/blob/master/INSTALL.md).
- Compilation of the FLUXO code for these PID comparisons used a few combinations of the available options that
  are selected/configured via [CMake](https://cmake.org/).
  We note that many default options are used, e.g., that parabolic (i.e. second order derivative) terms are *deactivated*.
  Also, the default option for the DG solver used by FLUXO is the flux differencing version.
- To compile FLUXO first open a terminal, navigate to the FLUXO directory, and create a new subdirectory for the
  `build`.
  ```
  > mkdir build; cd build
  ```
- The `makefile` for FLUXO is generated using CMake.
  Here we give the instructions for three versions of the `makefile` as they differ slightly
  for compressible Euler versus ideal GLM-MHD and weak form versus flux differencing form.
  All versions will build FLUXO in `Release` mode, which activates compiler and other optimizations.
  - For the weak form DG solver with the compressible Euler equations execute
    ```
    > cmake -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_Fortran_COMPILER=ifort -D CMAKE_BUILD_TYPE=Release -D FLUXO_EQNSYSNAME=navierstokes -D FLUXO_DISCTYPE=1 ../
    ```
    where the option `FLUXO_DISCTYPE=1` activates the weak form.
  - For the flux differencing DG solver with the compressible Euler equations execute
    ```
    > cmake -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_Fortran_COMPILER=ifort -D CMAKE_BUILD_TYPE=Release -D FLUXO_EQNSYSNAME=navierstokes ../
    ```
  - For the flux differencing DG solver with the ideal GLM-MHD equations execute
    ```
    > cmake -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_Fortran_COMPILER=ifort -D CMAKE_BUILD_TYPE=Release -D FLUXO_EQNSYSNAME=mhd -D FLUXO_EQN_NONCONS_GLM=ON ../
    ```
- Once the `makefile` is generated simply type in the terminal
  ```
  > make
  ```
  to build the particular FLUXO configuration. Note, if CMake does not detect a precompiled version of the HDF5 library
  then it will automatically download and build a local copy of HDF5 as a first step of the FLUXO compilation.
  The executable `fluxo` is contained in your FLUXO directory in `build/bin/` upon a successful compilation.
- To configure the different physical models use one of the included `.ini` files; either `fluxo_parameter_euler_pid.ini`
  for the compressible Euler equations or `fluxo_parameter_mhd_pid.ini` for the ideal GLM-MHD equations. Depending
  upon the build configuration above the corresponding `.ini` file may need to be altered.
  - For the weak form DG solver, compressible Euler equations PID setup change lines 38 and 39 of
    `fluxo_parameter_euler_pid.ini` to be
    ```
    Riemann    = 22  ! 1: LF, 22:HLL, 32: ECKEP-Ranocha, 33: ESKEP-Ranocha
    !VolumeFlux = 32  ! 0: standard DG, 1: standard DG metric dealiased, 32:ECKEP-Ranocha
    ```
    This sets the numerical surface flux to use the HLL Riemann solver and disables the numerical volume flux (as it
    is not present in the weak form DG solver).
  - For the flux differencing form DG solver, compressible Euler equations PID setup change lines 38 and 39 of
    `fluxo_parameter_euler_pid.ini` to be
    ```
    Riemann    = 32  ! 1: LF, 22:HLL, 32: ECKEP-Ranocha, 33: ESKEP-Ranocha
    VolumeFlux = 32  ! 0: standard DG, 1: standard DG metric dealiased, 32:ECKEP-Ranocha
    ```
    This sets the numerical surface and volume flux functions to be the entropy conservative and kinetic
    energy preserving flux of Ranocha.
  - For the weak form DG solver, ideal GLM-MHD equations PID setup change lines 38 and 39 of
    `fluxo_parameter_mhd_pid.ini` to be
    ```
    Riemann       = 4  !Riemann solver (surface flux): 1: LLF 4: HLL, 11: EC-Derigs, 12: EC-FloGor
    VolumeFlux    = 0  !two-point split-form flux:  0: standard DG, 1: standard DG metric dealiased, 10: EC-Derigs, 12: EC-FloGor
    ```
    This sets the numerical surface flux to be the HLL Riemann solver and the numerical volume flux to be the central flux.
    The flux differencing DG solver with a central volume flux is algebraically equivalent to the weak form DG solver.
  - For the flux differencing form DG solver, ideal GLM-MHD equations PID setup change lines 38 and 39 of
    `fluxo_parameter_mhd_pid.ini` to be
    ```
    Riemann       = 12  !Riemann solver (surface flux): 1: LLF 4: HLL, 11: EC-Derigs, 12: EC-FloGor
    VolumeFlux    = 12  !two-point split-form flux:  0: standard DG, 1: standard DG metric dealiased, 10: EC-Derigs, 12: EC-FloGor
    ```
    This sets the numerical surface and volume flux functions to be the entropy conservative and kinetic/magnetic
    energy preserving flux due to Hindenlang and Gassner.
- To execute the particular physical setup with its accompanying surface and volume flux combination execute
  ```
  mpirun -np 1 $(fluxopath)/build/bin/fluxo fluxo_parameter_euler_pid.ini
  ```
  for the compressible Euler setup or
  ```
  mpirun -np 1 $(fluxopath)/build/bin/fluxo fluxo_parameter_mhd_pid.ini
  ```
  for the ideal GLM-MHD setup.
  Note, for either run command the mesh file `ConformBoxHeavilyWarped_04_mesh.h5` must be in the same folder as the `.ini` file.
  Also, by default, CMake will configure FLUXO to compile with MPI capabilities such that one must specify a single rank
  for the serial PID comparison runs.
- During a FLUXO simulation information about the current run is output to the screen according to the ini parameter
  `Analyze_dt`. It is within this output information that one finds the PID value. Below we show a portion of such
  FLUXO terminal output for a run using the `fluxo_parameter_euler_pid.ini` file.
  ```
  ------------------------------------------------------------------------------------------------------------------------------------
   Sys date   :    04.08.2021 11:53:51
   CALCULATION TIME PER TSTEP/DOF: [ 9.69513E-07 sec ], nRKstages:   5
   Timestep   :    4.6502353E-03
  #Timesteps   :    8.7000000E+01
   Sim time   :    4.0000000E-01
   L_2        :    5.047056300516E-04   4.187939598071E-04   4.734560283398E-04   4.995685323228E-04   7.434139394407E-04
   L_2_colloc :    5.285411275588E-04   4.370326021381E-04   5.034501138426E-04   5.236081583404E-04   7.982683614151E-04
   L_inf      :    1.696711371902E-02   1.270523391131E-02   1.680713994982E-02   1.696274374697E-02   2.649233188224E-02
        Entropy      :    7.568197287005E+01
        dEntropy/dt  :    5.148426964752E-06
     dSdU*Ut         :    4.964204203360E-06
  ....................................................................................................................................
   FLUXO RUNNING MAN_SOL... [    1.96 sec ]
  ------------------------------------------------------------------------------------------------------------------------------------
  ```
  The PID value is found near the top with the label `CALCULATION TIME PER TSTEP/DOF: [ 9.69513E-07 sec ], nRKstages:   5`.
- It is important to note that this PID value is for one complete explicit time step.
  Therefore, in order to compare the FLUXO PID value to the Trixi.jl PID value **one must divide** the FLUXO PID value
  by the number of explicit Runge-Kutta stages. For all the PID runs this value will be *five*.
