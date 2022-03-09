const std = @import("std");

// TODO: Revectorize, brainstorm new method
fn dct(comptime T: type, samples: []const T, index: T) T {
    var n: usize = 0;
    var sum: T = 0;
    while (n < samples.len) : (n += 1) {
        sum += samples[n] * @cos((std.math.pi / @intToFloat(T, samples.len)) * (@intToFloat(T, n) + 0.5) * index);
    }
    return sum;
}

pub fn main() !void {
    const T = f32;
    const allocator = std.heap.page_allocator;

    var raw = try std.fs.cwd().openFile("dct.raw", .{});
    defer raw.close();

    var out = try std.fs.cwd().createFile("myaudio.zsa", .{});
    defer out.close();

    const reader = raw.reader();

    var SAMPLE: usize = 10;

    var samples = try std.ArrayList(T).initCapacity(allocator, @divTrunc((try raw.stat()).size, SAMPLE) + 1);

    // var z: usize = 0;
    while (true) {
        try samples.append(@intToFloat(T, @bitCast(i8, reader.readByte() catch break)));
        reader.skipBytes(SAMPLE, .{}) catch break;
    }

    const block_size = 64;
    const N = samples.items.len;

    while (samples.items.len % block_size != 0) try samples.append(0);

    // var coeffs_final = try std.ArrayList(T).initCapacity(allocator, N);

    try out.writer().writeIntLittle(u32, @intCast(u32, N));

    var coeff_index: usize = 0;
    var zeroes: u8 = 0;

    while (coeff_index < N) : (coeff_index += 1) {
        var d = dct(T, samples.items, @intToFloat(T, coeff_index));
        if (@fabs(d) <= 1) d = 0;
        const final = @floatToInt(i24, @round(d));

        if (final == 0) {
            zeroes += 1;
        } else {
            if (zeroes != 0) {
                try out.writer().writeByte(0);
                try out.writer().writeByte(zeroes);
                zeroes = 0;
            }

            try out.writer().writeByte(1);
            try out.writer().writeIntLittle(i24, final);
        }
        // try std.io.getStdOut().writer().print("{d}, ", .{final});
        // try coeffs_final.append(@round(d));
    }

    if (zeroes != 0) {
        try out.writer().writeByte(0);
        try out.writer().writeByte(zeroes);
        zeroes = 0;
    }

    // try std.io.getStdOut().writer().print("{d}\n", .{coeffs_final.items[0..N]});
}
