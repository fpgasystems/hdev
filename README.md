<!-- <div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text"> -->
<p align="right">
<a href="https://github.com/fpgasystems">fpgasystems</a> <a href="https://github.com/fpgasystems/hacc">ETHZ-HACC</a>
</p>

<p align="center">
<img src="./docs/images/hdev-removebg.png" align="center" width="350">
</p>

<h1 align="center">
  HACC Development
  <p align="center">
  <a href="https://github.com/fpgasystems/hdev/releases">
    <img src="https://img.shields.io/github/v/release/fpgasystems/hdev" alt="Latest release" />
  </a>
  <a href="https://github.com/fpgasystems/hdev/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/fpgasystems/hdev" alt="License" />
  </a>
  <a href="https://github.com/fpgasystems/hdev/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/fpgasystems/hdev?color=blue" alt="Contributors" />
  </a>
  <a href="https://github.com/fpgasystems/hdev/stargazers">
    <img src="https://img.shields.io/github/stars/fpgasystems/hdev?style=flat" alt="GitHub stars" />
  </a>
  </p>
</h1> 

Initially developed for the [ETH Zurich Heterogeneous Accelerated Compute Cluster (ETHZ-HACC),](https://github.com/fpgasystems/hacc) **HACC Development (hdev)** is a versatile development platform designed for use on any AMD-compatible heterogeneous cluster. 

The tool is built around a simple yet powerful command-line interpreter (CLI) and a set of optimized deployment templates. While the CLI simplifies infrastructure setup, validation, and device configuration through an intuitive device index, the deployment templates integrate a variety of open-source frameworks, providing pre-configured projects that enable developers to quickly address a broader range of acceleration problems and challenges efficiently.

Overall, **hdev** helps create better acceleration solutions for research institutions with high-performance computing needs.

## Sections
* [Citation](#citation)
* [Disclaimer](#disclaimer)
* [Features](./docs/features.md)
* [Installation](./docs/installation.md)
* [Known limitations](./docs/known-limitations.md)

![HACC Development (hdev) stack.](./docs/images/stack.png "HACC Development (hdev) stack.")
*HACC Development (hdev) stack.*

# Disclaimer

* **HACC Development (hdev)** software is provided "as is" and without warranty of any kind, express or implied. The authors and maintainers of this repository make no claims regarding the fitness of this software for specific purposes or its compatibility with any particular hardware or software environment.
* **hdev** users are responsible for assessing its suitability for their intended use, including compatibility with their high-performance computing clusters and heterogeneous environments. The authors and maintainers of **hdev** assume no liability for any issues, damages, or losses arising from the use of this software.
* It is recommended to thoroughly test **hdev** in a controlled environment before deploying it in a production setting. Any issues or feedback should be reported to the repository's issue tracker.
* By using **hdev**, you acknowledge and accept the terms and conditions outlined in this disclaimer.

# Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14202998.svg)](https://doi.org/10.5281/zenodo.14202998)

If you use **hdev** in your work, we kindly request that you cite it as follows:

```
@misc{moya2024hdev,
  author       = {Javier Moya, Mario Ruiz, Gustavo Alonso},
  title        = {fpgasystems/hdev: HACC Development},
  howpublished = {Zenodo},
  year         = {2024},
  month        = nov,
  note         = {\url{https://doi.org/10.5281/zenodo.14202998}},
  doi          = {10.5281/zenodo.14202998}
}
