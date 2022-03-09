const std = @import("std");

fn idct(comptime T: type, samples: []const T, index: T) T {
    const N = @intToFloat(T, samples.len);

    var sum: T = 0;
    var n: usize = 1;
    while (n < samples.len) : (n += 1) {
        sum += (2.0 / N) * samples[n] * @cos((index) * @intToFloat(T, n));
    }
    return (1.0 / N) * samples[0] + sum;
}

pub fn main() !void {
    const T = f32;
    const allocator = std.heap.page_allocator;

    var compressed_file = try std.fs.cwd().openFile("myaudio.zsa", .{});
    defer compressed_file.close();

    var pcm_file = try std.fs.cwd().createFile("decomp.raw", .{});
    defer pcm_file.close();

    const N = try compressed_file.reader().readIntLittle(u32);

    var coeffs = try std.ArrayList(T).initCapacity(allocator, N);

    while (coeffs.items.len < N) {
        const kind = try compressed_file.reader().readByte();
        switch (kind) {
            0 => try coeffs.appendNTimes(@as(T, 0), try compressed_file.reader().readByte()),
            1 => try coeffs.append(@intToFloat(T, try compressed_file.reader().readIntLittle(i24))),
            else => @panic("wtf"),
        }
    }

    const increments = std.math.pi / @intToFloat(T, N);
    var x: T = 0;
    while (x < increments * (@intToFloat(T, N) - 1.0 + 0.5)) : (x += increments / 10) {
        // std.debug.print("{d}", .{idct(T, coeffs.items, x)});
        const value = idct(T, coeffs.items, x);
        // std.debug.print("{d}\n", .{value});
        // if (@fabs(value) > 128.0) @panic("AHH");
        const final = @floatToInt(i8, @round(value));
        try pcm_file.writer().writeByte(@bitCast(u8, final));
    }

    // std.debug.print("{d}", .{coeffs.items});
}
