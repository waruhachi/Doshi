# Theos Codespace

Kickstart iOS tweak development with a preconfigured Theos environment that works out of the box in GitHub Codespaces or locally via dev containers. It includes common toolchains, formatter integration, and CI workflows for multi-architecture packages.

## Features

The [`devcontainer.json`](.devcontainer/devcontainer.json) file configures a development container to provide a reproducible, ready-to-use environment for Theos-based tweak development.

### **Base Docker Image**
- The container is an Ubuntu-based environment using the official Swift image (`swift:jammy`)

### **Development Tools**
- [Swift](https://swift.org/)
- [Theos](https://theos.dev/)
- [Comet](https://github.com/ginsudev/Comet)
- [libplist](https://github.com/libimobiledevice/libplist)
- [Python 3](https://www.python.org/)
- [logos-format](https://github.com/HearseDev/logos-format)
- [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
- [libgcuniversal](https://github.com/MrGcGamer/LibGcUniversalDocumentation)

### **Editor Extensions**
The codespace includes recommendations for VS Code extensions to improve the development experience:
- [clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)
- [Logos for VS Code](https://marketplace.visualstudio.com/items?itemName=tale.logos-vscode)
- [External formatters](https://marketplace.visualstudio.com/items?itemName=SteefH.external-formatters)

### **Formatting**
The codespace includes VSCode settings to automatically format your code on save using:
- [clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd) for C, C++, Objective-C, and Objective-C++ files using `clang-format` with the included `.clang-format` configuration
- [External formatters](https://marketplace.visualstudio.com/items?itemName=SteefH.external-formatters) for Logos files using `logos-format`

### **Package Types**

This codespace automatically builds three variants of your tweak:

- **Rootful Package** (`*_iphoneos-arm.deb`) - For traditional jailbreaks like checkra1n, unc0ver, Taurine
- **Rootless Package** (`*_iphoneos-arm64.deb`) - For rootless jailbreaks like Dopamine, palera1n rootless
- **RootHide Package** (`*_iphoneos-arm64e.deb`) - For RootHide-based jailbreaks

### **Automated Builds**
The codespace includes GitHub Actions workflows for automated building and releasing:

#### Build Workflow ([`.github/workflows/Build.yml`](.github/workflows/Build.yml))
- Triggers on pushes to the `main` branch
- Builds debug packages (`DEBUG=1`)
- Generates artifacts for each architecture

#### Release Workflow ([`.github/workflows/Release.yml`](.github/workflows/Release.yml))
- Triggers when a new release is published
- Builds optimized packages (`FINALPACKAGE=1`, `STRIP=0`)
- Generates checksums (MD5, SHA1, SHA256) for each package
- Automatically uploads `.deb` files to the GitHub release

## Getting Started

Use the button below to open this Theos Codespace template directly in GitHub Codespaces:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/waruhachi/theos-codespace?quickstart=1)

Or follow these steps to create your own Theos Codespace:

1. **Use this template**

   Click the green `Use this template` button towards the top right of the screen

2. **Open in a codespace**

   Select the `Open in a codespace` option from the dropdown menu

3. **Setup Codespace**

   Wait for the codespace to finish setting up with all Theos dependencies

4. **Create your tweak**

   Use Theos tools to create and develop your iOS tweak:
   ```bash
   $THEOS/bin/nic.pl
   ```

5. **Build your project**

   Build your tweak for testing:
   ```bash
   make clean package DEBUG=1
   ```
> [!IMPORTANT]  
> The linux container can only build rootful (`iphoneos-arm`) packages, use the GitHub Actions workflows to build rootless and RootHide packages.

6. **Release**

   Create a GitHub release to automatically build and distribute packages for all supported architectures

## License

This repository is licensed under the GPL-3.0 License. See [`LICENSE`](LICENSE) for more details.

