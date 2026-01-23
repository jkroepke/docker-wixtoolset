[![CI](https://github.com/jkroepke/docker-wixtoolset/workflows/CI/badge.svg)](https://github.com/jkroepke/docker-wixtoolset/actions?query=workflow%3ACI)
[![GitHub license](https://img.shields.io/github/license/jkroepke/docker-wixtoolset.svg?logo=github)](https://github.com/jkroepke/docker-wixtoolset/blob/master/LICENSE.txt)
[![Docker Pulls](https://img.shields.io/docker/pulls/jkroepke/wixtoolset?logo=docker)](https://hub.docker.com/r/jkroepke/wixtoolset)

# docker-wixtoolset

⭐ Don't forget to star this repository! ⭐

## About

Docker image for building **Windows MSI installers** using the **WiX Toolset 5** on **Linux**.  
It runs the official WiX CLI (`wix build`, `wix extension add`, etc.) under **Wine** with a preinstalled **.NET SDK 10.0.102 so you can build MSI packages without needing Windows or Wine setup.

## Features
- Run `wix build` directly on Linux
- Includes **WiX Toolset 5.0.2** (pinned for license compatibility)
- Preinstalled WiX extensions:
  - `WixToolset.Util.wixext`
  - `WixToolset.Firewall.wixext`
  - `WixToolset.UI.wixext`
- Based on Debian with Wine and .NET SDK preinstalled
- Fully isolated environment for CI/CD builds
- No need for a Windows VM or manual configuration

## Example usage
Build an MSI directly from Linux:
```bash
docker run --rm -v $(pwd):/src -w /src jkroepke/wixtoolset wix build Product.wxs
```

### List installed extensions:

```
docker run --rm jkroepke/wixtoolset wix extension list
```

## Version information

WiX Toolset is pinned to version 5.0.2. This is the latest available version with public binary artifacts.

WiX Toolset 6 and newer versions require a commercial license agreement and paid maintenance fee to access official binaries.

See WiX Toolset OSMF License and the [introduction post](https://github.com/wixtoolset/issues/issues/8974) for details.

## Use cases

- Build .msi installers from Linux-based CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins)
- Cross-compile Windows installers for Go, .NET, Python, or C++ applications
- Reproducible builds without any Windows dependencies

## Tags

- latest

## About

Docker Container for creating MSI with wixtoolset under linux

## License

This project is licensed under the [MIT License](LICENSE.txt).
