const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const config_header = b.addConfigHeader(.{
        .style = .{ .cmake = b.path("src/config.h.in") },
    }, .{
        .ufps_VERSION_MAJOR = 0,
        .ufps_VERSION_MINOR = 0,
        .ufps_VERSION_PATCH = 0,
    });

    const exe = b.addExecutable(.{
        .name = "ufps",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.addConfigHeader(config_header);
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("inc"));
    exe.addCSourceFiles(.{
        .files = &.{
            "src/main.cpp",
            "src/utils/system_info.cpp",
            "src/utils/text_utils.cpp",
            "src/utils/wmi.cpp",
            "src/graphics/buffer.cpp",
            "src/graphics/command_buffer.cpp",
            "src/graphics/mesh_manager.cpp",
            "src/graphics/persistent_buffer.cpp",
            "src/graphics/program.cpp",
            "src/graphics/renderer.cpp",
            "src/graphics/shader.cpp",
            "src/graphics/window.cpp",
            "src/events/key_event.cpp",
            "src/events/mouse_event.cpp",
            "src/events/mouse_button_event.cpp",
        },
        .flags = &.{
            "-std=c++23",
            "-fexperimental-library",
            "-DNOMINMAX",
            "-Wall",
            "-Wextra",
            "-pedantic",
            "-Werror",
            "-Wcast-qual",
            "-Wconversion-null",
            "-Wmissing-declarations",
            "-Woverlength-strings",
            "-Wpointer-arith",
            "-Wunused-local-typedefs",
            "-Wunused-result",
            "-Wvarargs",
            "-Wvla",
            "-Wwrite-strings",
        },
    });
    exe.linkLibCpp();

    switch (target.result.os.tag) {
        .windows => {
            // exe.linkSystemLibrary("stdc++exp");
            exe.linkSystemLibrary("wbemuuid");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("ole32");
            exe.linkSystemLibrary("oleaut32");
            exe.linkSystemLibrary("opengl32");
        },
        else => exe.linkSystemLibrary("GL"),
    }

    const run = b.addRunArtifact(exe);
    b.step("run", "").dependOn(&run.step);
}
