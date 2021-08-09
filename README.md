# Adaptive high-order numerical simulations of hyperbolic PDEs with Trixi.jl: A case study of Julia for scientific computing

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
<!-- [![DOI](https://zenodo.org/badge/DOI/TODO.svg)](https://doi.org/TODO) -->

This repository contains the source files of the paper on
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) to be submitted
to the proceedings of JuliaCon 2021. Additionally, it also contains
material to reproduce the numerical experiments reported therein.

## Abstract

We present Trixi.jl, a Julia library for adaptive high-order numerical simulations
of hyperbolic partial differential equations (PDEs). Utilizing Julia's strengths,
Trixi.jl is extendable, easy to use, and fast. We describe the main design choices
that enable these features and compare Trixi.jl with an established open
source Fortran code for hyperbolic PDEs using the same numerical methods.
We conclude with an assessment of Julia for simulation-focused scientific
computing, an area that is still dominated by traditional high-performance
computing languages such as C, C++, and Fortran.


## Referencing

This repository contains information and code to reproduce the results presented in the article
```bibtex
@online{ranocha2021adaptive,
  title={Adaptive high-order numerical simulations of hyperbolic {PDEs} with
         {T}rixi.jl: {A} case study of {J}ulia for scientific computing},
  author={Ranocha, Hendrik and Schlottke-Lakemper, Michael and Winters, Andrew Ross
          and Faulhaber, Erik and Chan, Jesse and Gassner, Gregor},
  year={2021},
  month={08},
  eprint={TODO},
  eprinttype={arXiv},
  eprintclass={math.NA}
}
```

If you find these results useful, please cite the article mentioned above. If you
use the implementations provided here, please **also** cite this repository as
```bibtex
@misc{ranocha2021adaptiveRepro,
  title={Reproducibility repository for
         Adaptive high-order numerical simulations of hyperbolic {PDEs} with
         {T}rixi.jl: {A} case study of {J}ulia for scientific computing},
  author={Ranocha, Hendrik and Schlottke-Lakemper, Michael and Winters, Andrew Ross
          and Faulhaber, Erik and Chan, Jesse and Gassner, Gregor},
  year={2021},
  month={08},
  howpublished={\url{https://github.com/trixi-framework/paper-2021-juliacon}},
  doi={TODO:Zenodo-DOI}
}
```


## Reproducing the numerical experiments

- All material necessary to reproduce the simulation of a Kelvin-Helmholtz
  shown in the paper is contained in the folder
  [`figure_kelvin_helmholtz`](figure_kelvin_helmholtz/),
  including a [`README.md`](figure_kelvin_helmholtz/README.md) with instructions.
- All material necessary to reproduce the acoustics simulation on a curved
  high-order mesh shown in the paper is contained in the folder
  [`figure_gingerbread_man`](figure_gingerbread_man/),
  including a [`README.md`](figure_gingerbread_man/README.md) with instructions.
- All material necessary to reproduce the performance comparison with the Fortran
  code [FLUXO](https://github.com/project-fluxo/fluxo) is contained in the folder
  [`pid_runs`](pid_runs/),
  including a [`README.md`](pid_runs/README.md) with instructions.


## Building the paper

The source files of the paper are contained in the folder [`paper`](paper/).
Build the paper by running
```bash
make
```
Clean up your mess afterwards with
```bash
make clean
```


## Useful links

* JuliaCon Proceedings: https://proceedings.juliacon.org/
* Author's guide: https://juliacon.github.io/proceedings-guide/author/


## License

The source code included in this repository is licensed under the MIT license
(see [LICENSE.md](LICENSE.md)). The manuscript is subject to the license of
the JuliaCon proceedings.


## Disclaimer

Everything is provided as is and without warranty. Use at your own risk!
