const std = @import("std");

const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub fn main() !void {
    if (c.glfwInit() == 0) {
        @panic("GLFW Initialization failed");
    }
    defer c.glfwTerminate();

    // todo error callback

    const win = c.glfwCreateWindow(640, 480, "Hello Zig!", null, null);
    if (win == null) {
        @panic("GLFW window creation failed");
    }
    defer c.glfwDestroyWindow(win);

    while (c.glfwWindowShouldClose(win) == 0) {
        c.glfwPollEvents();
        c.glfwSwapBuffers(win);
    }
}
