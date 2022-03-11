const std = @import("std");

/// Modulated lapped transform window function
pub fn window(comptime T: type, index: T, len: T) T {
    return @sin((std.math.pi / len) * (index + 0.5));
}

// TODO: Naive; factor, vectorize
/// Modified discrete cosine transform
/// Returns useful data from 0 <= index < data.len/2
pub fn mdct(comptime T: type, data: []const T, index: usize) T {
    const len_cast = std.math.lossyCast(T, data.len);

    var n: usize = 0;
    var sum: T = 0;
    while (n < data.len) : (n += 1) {
        const n_cast = std.math.lossyCast(T, n);
        sum += window(T, n_cast, len_cast) * data[n] * @cos(((2.0 * std.math.pi) / len_cast) * (n_cast + 0.5 + len_cast / 4.0) * (std.math.lossyCast(T, index) + 0.5));
    }

    return sum;
}

// TODO: Naive; factor, vectorize
/// Inverse modified discrete cosine transform
/// Returns useful data from 0 <= index < 2*data.len
pub fn imdct(comptime T: type, data: []const T, index: usize) T {
    const index_cast = std.math.lossyCast(T, index);
    const len_cast = std.math.lossyCast(T, data.len);

    var k: usize = 0;
    var sum: T = 0;
    while (k < data.len) : (k += 1) {
        const k_cast = std.math.lossyCast(T, k);
        sum += data[k] * @cos((std.math.pi / len_cast) * (index_cast + 0.5 + len_cast / 2.0) * (k_cast + 0.5));
    }

    return window(T, index_cast, 2 * len_cast) * (2.0 / len_cast) * sum;
}

/// Works for both mdct and its inverse
pub fn calcBlockMdctOutputSize(block_size: usize, len: usize) usize {
    return len - block_size / 2;
}

pub fn naiveBlockMdct(comptime T: type, comptime block_size: usize, data: []const T, out: []T) void {
    std.debug.assert(data.len % block_size == 0);
    std.debug.assert(out.len == calcBlockMdctOutputSize(block_size, data.len));

    var block: usize = 0;
    while (block < out.len / 2) : (block += 1) {
        var outdex: usize = 0;
        while (outdex < block_size / 2) : (outdex += 1) {
            out[block * (block_size / 2) + outdex] = mdct(T, data[block * block_size / 2 ..][0..block_size], outdex);
        }
    }
}

pub fn naiveBlockImdct(comptime T: type, comptime block_size: usize, data: []const T, out: []T) void {
    std.debug.assert(data.len % (block_size / 2) == 0);
    std.debug.assert(out.len == calcBlockMdctOutputSize(block_size, data.len));

    var i: usize = 0;
    var block: usize = 0;
    while (block <= out.len / (block_size / 2) - (block_size / 2)) : (block += 1) {
        var s: usize = 0;
        while (s < block_size / 2) : (s += 1) {
            out[i] = imdct(f32, data[(block_size / 2) * block .. (block_size / 2) * (block + 1)], block_size / 2 + s) + imdct(f32, data[(block_size / 2) * (block + 1) .. (block_size / 2) * (block + 2)], s);
            i += 1;
        }
    }
}
