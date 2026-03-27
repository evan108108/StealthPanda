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

const js = @import("../js/js.zig");

pub fn registerTypes() []const type {
    return &.{ Chrome, ChromeRuntime, ChromeApp };
}

const Chrome = @This();

_runtime: ChromeRuntime = .{},
_app: ChromeApp = .{},

pub fn getRuntime(self: *Chrome) *ChromeRuntime {
    return &self._runtime;
}

pub fn getApp(self: *Chrome) *ChromeApp {
    return &self._app;
}

// csi() returns timing data — detection scripts check it exists more than its values
pub fn csi(_: *const Chrome) void {}

// loadTimes() — same, existence check is what matters
pub fn loadTimes(_: *const Chrome) void {}

pub const JsApi = struct {
    pub const bridge = js.Bridge(Chrome);
    pub const Meta = struct {
        pub const name = "Chrome";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
        pub const empty_with_no_proto = true;
    };

    pub const runtime = bridge.accessor(Chrome.getRuntime, null, .{});
    pub const app = bridge.accessor(Chrome.getApp, null, .{});
    pub const csi = bridge.function(Chrome.csi, .{ .noop = true });
    pub const loadTimes = bridge.function(Chrome.loadTimes, .{ .noop = true });
};

const ChromeRuntime = struct {
    _pad: bool = false,

    pub fn connect(_: *const ChromeRuntime) void {}
    pub fn sendMessage(_: *const ChromeRuntime) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(ChromeRuntime);
        pub const Meta = struct {
            pub const name = "ChromeRuntime";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
            pub const empty_with_no_proto = true;
        };

        pub const connect = bridge.function(ChromeRuntime.connect, .{ .noop = true });
        pub const sendMessage = bridge.function(ChromeRuntime.sendMessage, .{ .noop = true });
        pub const id = bridge.property(null, .{ .template = false });
    };
};

const ChromeApp = struct {
    _pad: bool = false,

    pub fn getDetails(_: *const ChromeApp) ?bool {
        return null;
    }
    pub fn getIsInstalled(_: *const ChromeApp) bool {
        return false;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(ChromeApp);
        pub const Meta = struct {
            pub const name = "ChromeApp";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
            pub const empty_with_no_proto = true;
        };

        pub const isInstalled = bridge.property(false, .{ .template = false });
        pub const getDetails = bridge.function(ChromeApp.getDetails, .{});
        pub const getIsInstalled = bridge.function(ChromeApp.getIsInstalled, .{});
    };
};
