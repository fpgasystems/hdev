<!-- <div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text"> -->
<p align="right">
<a href="https://github.com/fpgasystems">fpgasystems</a> <a href="https://github.com/fpgasystems/hacc">HACC</a>
</p>

<p align="center">
<img src="https://github.com/fpgasystems/hdev/blob/main/hdev-removebg.png" align="center" width="350">
</p>

<h1 align="center">
  HACC Development
</h1> 

Initially developed for the [ETH Zurich Heterogeneous Accelerated Compute Cluster (ETHZ-HACC),](https://github.com/fpgasystems/hacc) **HACC Development (hdev)** is a versatile development platform designed for use on any AMD-compatible heterogeneous cluster. 

The tool is built around a simple yet powerful command-line interpreter (CLI) and a set of optimized deployment templates. While the CLI simplifies infrastructure setup, validation, and device configuration through an intuitive device index, the deployment templates integrate a variety of open-source projects, enabling developers to easily tackle a broader range of acceleration workflows and problems. 

Overall, **hdev** helps create better acceleration solutions for research institutions with high-performance computing needs.

## Sections
* [Citation](#citation)
* [Disclaimer](#disclaimer)
* [Features](./features.md#features)
* [Installation](https://github.com/fpgasystems/hdev_install/?tab=readme-ov-file#installation)
* [License](#license)
* [Known limitations](./known-limitations.md#known-limitations)
* [Programming model](./programming-model.md#programming-model)

# Disclaimer

* **HACC Development (hdev)** software is provided "as is" and without warranty of any kind, express or implied. The authors and maintainers of this repository make no claims regarding the fitness of this software for specific purposes or its compatibility with any particular hardware or software environment.
* **hdev** users are responsible for assessing its suitability for their intended use, including compatibility with their high-performance computing clusters and heterogeneous environments. The authors and maintainers of **hdev** assume no liability for any issues, damages, or losses arising from the use of this software.
* It is recommended to thoroughly test **hdev** in a controlled environment before deploying it in a production setting. Any issues or feedback should be reported to the repository's issue tracker.
* By using **hdev**, you acknowledge and accept the terms and conditions outlined in this disclaimer.

# Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14202998.svg)](https://doi.org/10.5281/zenodo.14202998)

If you use **hdev** in your work, we kindly request that you cite it as follows:

```
@misc{moya2024-hdev,
  author       = {Javier Moya and Gustavo Alonso},
  title        = {fpgasystems/hdev: HACC Development},
  howpublished = {Zenodo},
  year         = {2024},
  month        = nov,
  note         = {\url{https://doi.org/10.5281/zenodo.14202998}},
  doi          = {10.5281/zenodo.14202998}
}
```

# License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Copyright (c) 2024 FPGA @ Systems Group, ETH Zurich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.