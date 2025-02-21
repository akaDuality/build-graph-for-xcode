# Build Graph

**Build graph** – the essential tool to analyze the compilation time of a multi-module app.

The app shows the compilation order for modules and links between them, allowing the filter of any step. 

[More info](https://rubanov.dev/build-graph/)

<img width="1844" alt="HeaderLight" src="https://github.com/user-attachments/assets/fdf2d818-0e77-4660-9caa-5a27aa746ec2" />

## How to use
- Open Xcode with your project, clean, and build from scratch
- Launch Build Graph, give access to read files at Derived Data
- Select your project in the left panel

## Modules Structure
- Build Graph Release – target for release, including FireBase.
- Build Graph Debug – target for development purpose

Modules:
- `App` – joins feature modules in the app
- `UI` – main app features
  - `Projects` – left panel with project selection
  - `Details` – center panel that draws a graph
  - `Filters`– right panel that allows to filter graph
- `Domain` – infrastructure module with parsing domain
  - `BuildParser` – reads `.xcactivitylog` files with compilation information
  - `GraphParser` – reads `target-graph` file with dependencies between modules
  - `Snapshot` – samples of different Xcode's builds
- `XCLogParser` – fork that doesn't parse String and stays on Substring as long as possible to speedup the parsing 

## Contribution
Each new version of Xcode can break parsing. You can try to fix and suggest PR.
