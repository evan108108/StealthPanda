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
const AudioDestinationNode = @import("AudioDestinationNode.zig");
const OscillatorNode = @import("OscillatorNode.zig");
const DynamicsCompressorNode = @import("DynamicsCompressorNode.zig");
const GainNode = @import("GainNode.zig");
const AnalyserNode = @import("AnalyserNode.zig");
const AudioBufferSourceNode = @import("AudioBufferSourceNode.zig");

const AudioContext = @This();

_sample_rate: f64 = 44100,
_state: []const u8 = "running",
_destination: AudioDestinationNode = .{},

// Constructor: new AudioContext()
pub fn init(page: *Page) !*AudioContext {
    return page._factory.create(AudioContext{});
}

pub fn getSampleRate(self: *const AudioContext) f64 {
    return self._sample_rate;
}

pub fn getState(self: *const AudioContext) []const u8 {
    return self._state;
}

pub fn getCurrentTime(_: *const AudioContext) f64 {
    return 0;
}

pub fn getDestination(self: *AudioContext) *AudioDestinationNode {
    return &self._destination;
}

// Factory methods
pub fn createOscillator(_: *AudioContext, page: *Page) !*OscillatorNode {
    return page._factory.create(OscillatorNode{});
}

pub fn createDynamicsCompressor(_: *AudioContext, page: *Page) !*DynamicsCompressorNode {
    return page._factory.create(DynamicsCompressorNode{});
}

pub fn createGain(_: *AudioContext, page: *Page) !*GainNode {
    return page._factory.create(GainNode{});
}

pub fn createAnalyser(_: *AudioContext, page: *Page) !*AnalyserNode {
    return page._factory.create(AnalyserNode{});
}

pub fn createBufferSource(_: *AudioContext, page: *Page) !*AudioBufferSourceNode {
    return page._factory.create(AudioBufferSourceNode{});
}

// resume() → Promise<void> (resolve immediately)
pub fn @"resume"(self: *AudioContext, page: *Page) !js.Promise {
    self._state = "running";
    return page.js.local.?.resolvePromise({});
}

// close() → Promise<void> (set state to "closed")
pub fn close(self: *AudioContext, page: *Page) !js.Promise {
    self._state = "closed";
    return page.js.local.?.resolvePromise({});
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(AudioContext);
    pub const Meta = struct {
        pub const name = "AudioContext";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const constructor = bridge.constructor(AudioContext.init, .{});
    pub const sampleRate = bridge.accessor(AudioContext.getSampleRate, null, .{});
    pub const state = bridge.accessor(AudioContext.getState, null, .{});
    pub const currentTime = bridge.accessor(AudioContext.getCurrentTime, null, .{});
    pub const destination = bridge.accessor(AudioContext.getDestination, null, .{});
    pub const createOscillator = bridge.function(AudioContext.createOscillator, .{});
    pub const createDynamicsCompressor = bridge.function(AudioContext.createDynamicsCompressor, .{});
    pub const createGain = bridge.function(AudioContext.createGain, .{});
    pub const createAnalyser = bridge.function(AudioContext.createAnalyser, .{});
    pub const createBufferSource = bridge.function(AudioContext.createBufferSource, .{});
    pub const @"resume" = bridge.function(AudioContext.@"resume", .{ .dom_exception = true });
    pub const close = bridge.function(AudioContext.close, .{ .dom_exception = true });
};
