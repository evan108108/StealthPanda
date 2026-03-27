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

const js = @import("../../js/js.zig");
const Page = @import("../../Page.zig");
const fingerprint = @import("fingerprint.zig");
const AudioBuffer = @import("AudioBuffer.zig");
const AudioDestinationNode = @import("AudioDestinationNode.zig");
const OscillatorNode = @import("OscillatorNode.zig");
const DynamicsCompressorNode = @import("DynamicsCompressorNode.zig");
const GainNode = @import("GainNode.zig");
const AnalyserNode = @import("AnalyserNode.zig");
const AudioBufferSourceNode = @import("AudioBufferSourceNode.zig");

const OfflineAudioContext = @This();

_sample_rate: f64 = 44100,
_length: u32 = 44100,
_number_of_channels: u32 = 1,
_state: []const u8 = "suspended",
_destination: AudioDestinationNode = .{},

// Constructor: new OfflineAudioContext(channels, length, sampleRate)
pub fn init(channels: u32, length: u32, sample_rate: f64, page: *Page) !*OfflineAudioContext {
    return page._factory.create(OfflineAudioContext{
        ._number_of_channels = channels,
        ._length = length,
        ._sample_rate = sample_rate,
    });
}

pub fn getSampleRate(self: *const OfflineAudioContext) f64 {
    return self._sample_rate;
}

pub fn getLength(self: *const OfflineAudioContext) u32 {
    return self._length;
}

pub fn getNumberOfChannels(self: *const OfflineAudioContext) u32 {
    return self._number_of_channels;
}

pub fn getState(self: *const OfflineAudioContext) []const u8 {
    return self._state;
}

pub fn getCurrentTime(_: *const OfflineAudioContext) f64 {
    return 0;
}

pub fn getDestination(self: *OfflineAudioContext) *AudioDestinationNode {
    return &self._destination;
}

// Factory methods — allocate nodes via page factory
pub fn createOscillator(_: *OfflineAudioContext, page: *Page) !*OscillatorNode {
    return page._factory.create(OscillatorNode{});
}

pub fn createDynamicsCompressor(_: *OfflineAudioContext, page: *Page) !*DynamicsCompressorNode {
    return page._factory.create(DynamicsCompressorNode{});
}

pub fn createGain(_: *OfflineAudioContext, page: *Page) !*GainNode {
    return page._factory.create(GainNode{});
}

pub fn createAnalyser(_: *OfflineAudioContext, page: *Page) !*AnalyserNode {
    return page._factory.create(AnalyserNode{});
}

pub fn createBufferSource(_: *OfflineAudioContext, page: *Page) !*AudioBufferSourceNode {
    return page._factory.create(AudioBufferSourceNode{});
}

// startRendering() → Promise<AudioBuffer>
// Returns pre-computed Chrome 131 fingerprint in stealth mode
pub fn startRendering(self: *OfflineAudioContext, page: *Page) !js.Promise {
    self._state = "running";

    // Create AudioBuffer with pre-computed fingerprint data
    const arena = try page.getArena(.{ .debug = "AudioBuffer" });
    errdefer page.releaseArena(arena);

    const buffer = try arena.create(AudioBuffer);
    buffer.* = .{
        ._arena = arena,
        ._sample_rate = self._sample_rate,
        ._length = self._length,
        ._number_of_channels = self._number_of_channels,
        ._channel_data = fingerprint.CHROME_AUDIO_SAMPLES[0..@min(self._length, fingerprint.SAMPLE_COUNT)],
    };

    self._state = "closed";
    return page.js.local.?.resolvePromise(buffer);
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(OfflineAudioContext);
    pub const Meta = struct {
        pub const name = "OfflineAudioContext";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const constructor = bridge.constructor(OfflineAudioContext.init, .{});
    pub const sampleRate = bridge.accessor(OfflineAudioContext.getSampleRate, null, .{});
    pub const length = bridge.accessor(OfflineAudioContext.getLength, null, .{});
    pub const numberOfChannels = bridge.accessor(OfflineAudioContext.getNumberOfChannels, null, .{});
    pub const state = bridge.accessor(OfflineAudioContext.getState, null, .{});
    pub const currentTime = bridge.accessor(OfflineAudioContext.getCurrentTime, null, .{});
    pub const destination = bridge.accessor(OfflineAudioContext.getDestination, null, .{});
    pub const createOscillator = bridge.function(OfflineAudioContext.createOscillator, .{});
    pub const createDynamicsCompressor = bridge.function(OfflineAudioContext.createDynamicsCompressor, .{});
    pub const createGain = bridge.function(OfflineAudioContext.createGain, .{});
    pub const createAnalyser = bridge.function(OfflineAudioContext.createAnalyser, .{});
    pub const createBufferSource = bridge.function(OfflineAudioContext.createBufferSource, .{});
    pub const startRendering = bridge.function(OfflineAudioContext.startRendering, .{ .dom_exception = true });
};
