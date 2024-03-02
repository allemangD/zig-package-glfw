Fetch GLFW via experimental zig package manager `build.zig.zon`

Invoke CMake commands to build and install GLFW to zig-cache

Add Zig executable which includes and links to GLFW.


Drawing inspiration from CMake ExternalProject.

----

Ideally there would be some mechanism like `b.addCMakeProject` with options to:

- provide CMake CLI or CACHE_ARGS
- infer source/config/install dirs
- infer installed libraries and linkage (pkgconfig?)
- inf
- set CMAKE_CXX_COMPILER to `zig c++`
- set CMAKE_C_COMPILER to `zig c`
- Infer modules/artifacts from installed targets.
  - inspect/evaluate `glfw3Targets.cmake` and produce a module/artifact for each cmake target

---

I imagine usage like:

```zig
const glfw = b.dependency("glfw", .{
    // automatically use zig for CMAKE_C_COMPILER, CMAKE_CXX_COMPILER
    .target = target,  // pass on as compiler flags
    .optimize = optimize, // convert to CMAKE_BUILD_TYPE
    .cache_args = .{
        "GLFW_BUILD_SHARED_LIBS:BOOL=OFF",
        "GLFW_BUILD_WAYLAND:BOOL=OFF",
        "GLFW_BUILD_X11:BOOL=ON",
        "GLFW_BUILD_TESTS:BOOL=OFF",
    },
});

exe.addModule(
    "glfw",  // the name of the @import which defers to @cImport.
    glfw.module("glfw"), // the name of the cmake target
);
exe.linkLibrary(
    glfw.artifact("glfw"), // the name of the cmake target
);
```
