const std = @import("std");

fn incr(comptime T: type, comptime block_size: u32) std.meta.Vector(block_size, T) {
    comptime var base: [block_size]T = undefined;
    for (base) |*e, i| {
        e.* = @as(T, i);
    }
    return base;
}

fn calculateX(comptime T: type, comptime block_size: u32, N: usize, offset: usize) std.meta.Vector(block_size, T) {
    return @splat(block_size, std.math.pi / @intToFloat(T, N)) * (@as(std.meta.Vector(block_size, T), comptime incr(T, block_size) + @splat(block_size, @intToFloat(T, offset))) + comptime @splat(block_size, @as(T, 0.5)));
}

fn dctSemiScalar(X: anytype, Y: anytype, index: f64) std.meta.Child(@TypeOf(X)) {
    return @reduce(.Add, Y * @cos(X * @splat(@typeInfo(@TypeOf(X)).Vector.len, index)));
}

pub fn main() !void {
    var raw = try std.fs.cwd().openFile("dct.raw", .{});
    defer raw.close();

    const reader = raw.reader();

    const N = 64;

    const X = calculateX(f64, N, N, 0);

    // TODO: Yes this is hacky as all heck
    // But it gets the job done!
    var yarr: [N]f64 = undefined;
    for (yarr) |*e| {
        e.* = @intToFloat(f64, @bitCast(i8, reader.readByte() catch break));
        reader.skipBytes(99, .{}) catch break;
    }

    const Y: std.meta.Vector(N, f64) = yarr;

    var coeffs: [N]f64 = undefined;

    for (coeffs) |*e, i| {
        // TODO: Brainstorm a way to vectorize the whole process!
        // This loop isn't too bad, but it would be so much cooler
        // if even this part was vectorized!
        e.* = dctSemiScalar(X, Y, @intToFloat(f64, i));
    }

    std.log.info("{d}", .{coeffs});
}
