const std = @import("std");

const CMake = struct {};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfw = b.dependency("glfw", .{});

    const source_dir = glfw.builder.build_root.path orelse unreachable;

    const basename = std.fs.path.basename(glfw.builder.install_prefix);
    const build_dir = b.cache_root.join(b.allocator, &.{ "cmake", basename }) catch unreachable;
    const install_dir = b.cache_root.join(b.allocator, &.{ "cmake-i", basename }) catch unreachable;

    const config_glfw = glfw.builder.addSystemCommand(&.{
        "cmake",
        "-S",
        source_dir,
        "-B",
        build_dir,
        std.fmt.allocPrint(b.allocator, "-DCMAKE_INSTALL_PREFIX:PATH={s}", .{install_dir}) catch unreachable,
        "-DCMAKE_INSTALL_MESSAGE=LAZY",
        "-DCMAKE_MESSAGE_LOG_LEVEL=WARNING",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DGLFW_BUILD_WAYLAND=OFF",
        "-DGLFW_BUILD_X11=ON",
        "-DBUILD_SHARED_LIBS=OFF",
        "-DGLFW_BUILD_TESTS=OFF",
        "-DGLFW_BUILD_DOCS=OFF",
        "-DGLFW_INSTALL=ON",
    });

    const build_glfw = glfw.builder.addSystemCommand(&.{
        "cmake", "--build", build_dir, "-j", "--", "--quiet",
    });
    build_glfw.step.dependOn(&config_glfw.step);

    const install_glfw = glfw.builder.addSystemCommand(&.{ "cmake", "--install", build_dir });
    install_glfw.step.dependOn(&build_glfw.step);

    const exe = b.addExecutable(.{
        .name = "learnzig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    exe.step.dependOn(&install_glfw.step);
    exe.addLibraryPath(.{ .path = b.fmt("{s}/lib", .{install_dir}) });
    exe.addIncludePath(.{ .path = b.fmt("{s}/include", .{install_dir}) });
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("rt");
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("dl");

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
