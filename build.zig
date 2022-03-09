const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const dct_encoder_exe = b.addExecutable("dct-encoder", "src/encoder.zig");
    dct_encoder_exe.setTarget(target);
    dct_encoder_exe.setBuildMode(mode);
    dct_encoder_exe.install();

    const dct_encoder_run = dct_encoder_exe.run();
    dct_encoder_run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        dct_encoder_run.addArgs(args);
    }

    const run_step1 = b.step("run-encoder", "Run the encoder");
    run_step1.dependOn(&dct_encoder_run.step);

    const dct_decoder_exe = b.addExecutable("dct-decoder", "src/decoder.zig");
    dct_decoder_exe.setTarget(target);
    dct_decoder_exe.setBuildMode(mode);
    dct_decoder_exe.install();

    const dct_decoder_run = dct_decoder_exe.run();
    dct_decoder_run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        dct_decoder_run.addArgs(args);
    }

    const run_step2 = b.step("run-decoder", "Run the decoder");
    run_step2.dependOn(&dct_decoder_run.step);
}
