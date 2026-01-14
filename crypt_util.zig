const std = @import("std");

pub fn xorCipher(data: []u8, key: []const u8) void {
    for (data, 0..) |*byte, i| {
        byte.* ^= key[i % key.len];
    }
}

pub fn rotateLeft(byte: u8, count: u3) u8 {
    return (byte << count) | (byte >> (8 - count));
}

pub fn main() void {
    var buffer = [_]u8{ 0xDE, 0xAD, 0xBE, 0xEF };
    const key = "zig_secret";
    xorCipher(&buffer, key);
}
