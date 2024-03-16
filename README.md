![](res/clock.png)

## Analog clock app for MacOS

This small project builds an analog clock featuring the following concepts:

- creating an application object
- creating a window
- unity build
- drawing with a constant frame rate
- creating a hardware renderer using the Metal framework
- loading images (PNG files)
- GPU shaders (Metal shading language)
- texture mapping
- 2D projection
- 2D rotation
- separation between platform layer and application

## What you need

All you need to follow along or just build this project is:

- Visual Studio Code
- XCode command line tools (not XCode itself)
- [cloc to measure lines of code](https://formulae.brew.sh/formula/cloc)

## VS Code extensions   

The following VS Code extensions are also partly necessary:

- [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack)
- [C/C++ Clang Command Adapter](https://marketplace.visualstudio.com/items?itemName=mitaki28.vscode-clang)
- [Metal Shader Extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=doublebuffer.metal-shader)

# How to build and run

In order to build the project execute <br>
```sh build.sh``` <br>
in the root directory of this project

In order to run execute <br>
```./clock```
