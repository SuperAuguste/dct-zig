const std = @import("std");
const mdct = @import("mdct.zig");

fn bench() !void {
    var timer = try std.time.Timer.start();

    var n: usize = 0;
    while (n < 1) : (n += 1) {
        const data_1 = [_]f32{ 0, 0, 1, 2 };
        const processed_1 = [_]f32{ mdct.mdct(f32, &data_1, 0), mdct.mdct(f32, &data_1, 1) };
        const de_1 = [_]f32{ mdct.imdct(f32, &processed_1, 0), mdct.imdct(f32, &processed_1, 1), mdct.imdct(f32, &processed_1, 2), mdct.imdct(f32, &processed_1, 3) };

        const data_2 = [_]f32{ 1, 2, 3, 4 };
        const processed_2 = [_]f32{ mdct.mdct(f32, &data_2, 0), mdct.mdct(f32, &data_2, 1) };
        const de_2 = [_]f32{ mdct.imdct(f32, &processed_2, 0), mdct.imdct(f32, &processed_2, 1), mdct.imdct(f32, &processed_2, 2), mdct.imdct(f32, &processed_2, 3) };

        // std.log.info("{d}", .{de_1});
        std.log.info("{d} {d}", .{ processed_2, mdct.imdct(f32, &processed_2, 0) });

        std.mem.doNotOptimizeAway(de_1);
        std.mem.doNotOptimizeAway(de_2);
    }

    std.log.err("{d}ms", .{@intToFloat(f32, timer.read()) / @intToFloat(f32, std.time.ns_per_ms)});
}

pub fn main() !void {
    try bench();

    const block_size: usize = 4;

    // NOTE: Pad data with block_size/2 0s at the start and end
    const data = [_]f32{ 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0 };
    var out: [mdct.calcBlockMdctOutputSize(block_size, data.len)]f32 = undefined;
    var outout: [mdct.calcBlockMdctOutputSize(block_size, out.len)]f32 = undefined;

    mdct.naiveBlockMdct(f32, block_size, &data, &out);
    mdct.naiveBlockImdct(f32, block_size, &out, &outout);

    // var i: usize = 0;
    // var block: usize = 0;
    // while (block <= out.len / (block_size / 2) - (block_size / 2)) : (block += 1) {
    //     var s: usize = 0;
    //     while (s < block_size / 2) : (s += 1) {
    //         outout[i] = mdct.imdct(f32, out[(block_size / 2) * block .. (block_size / 2) * (block + 1)], block_size / 2 + s) + mdct.imdct(f32, out[(block_size / 2) * (block + 1) .. (block_size / 2) * (block + 2)], s);
    //         i += 1;
    //     }
    // }

    // std.log.info("{d} {d}", .{ mdct.mdct(f32, data[0..4], 0), mdct.mdct(f32, data[0..4], 1) });
    // std.log.info("{d} {d}", .{ mdct.mdct(f32, data[2..6], 0), mdct.mdct(f32, data[2..6], 1) });

    std.log.info("{d}", .{outout});
    // const z = [_]f32{ out[2], out[3] };
    // std.log.info("{d}", .{mdct.imdct(f32, out[2..4], 2) + mdct.imdct(f32, out[4..6], 0)});

    // std.log.info("{d} {d}", .{ de_1[2] + de_2[0], de_1[3] + de_2[1] });
}
