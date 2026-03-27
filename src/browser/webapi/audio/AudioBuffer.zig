// Copyright (C) 2023-2026  Lightpanda (Selecy SAS)
//
// Francis Bouvier <francis@lightpanda.io>
// Pierre Tachoire <pierre@lightpanda.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const js = @import("../../js/js.zig");
const Session = @import("../../Session.zig");

const Allocator = std.mem.Allocator;

const AudioBuffer = @This();

_arena: Allocator,
_sample_rate: f64 = 44100,
_length: u32 = 44100,
_number_of_channels: u32 = 1,
_channel_data: []const f32, // Points to pre-computed fingerprint data

pub fn getSampleRate(self: *const AudioBuffer) f64 {
    return self._sample_rate;
}

pub fn getLength(self: *const AudioBuffer) u32 {
    return self._length;
}

pub fn getDuration(self: *const AudioBuffer) f64 {
    return @as(f64, @floatFromInt(self._length)) / self._sample_rate;
}

pub fn getNumberOfChannels(self: *const AudioBuffer) u32 {
    return self._number_of_channels;
}

// getChannelData(channel) → Float32Array
// Bridge auto-converts js.TypedArray(f32) to V8 Float32Array
pub fn getChannelData(self: *const AudioBuffer, channel: u32) js.TypedArray(f32) {
    if (channel >= self._number_of_channels) return .{ .values = &.{} };
    return .{ .values = self._channel_data };
}

pub fn deinit(self: *AudioBuffer, _: bool, session: *Session) void {
    session.releaseArena(self._arena);
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(AudioBuffer);
    pub const Meta = struct {
        pub const name = "AudioBuffer";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
        pub const weak = true;
        pub const finalizer = bridge.finalizer(AudioBuffer.deinit);
    };

    pub const sampleRate = bridge.accessor(AudioBuffer.getSampleRate, null, .{});
    pub const length = bridge.accessor(AudioBuffer.getLength, null, .{});
    pub const duration = bridge.accessor(AudioBuffer.getDuration, null, .{});
    pub const numberOfChannels = bridge.accessor(AudioBuffer.getNumberOfChannels, null, .{});
    pub const getChannelData = bridge.function(AudioBuffer.getChannelData, .{});
};
