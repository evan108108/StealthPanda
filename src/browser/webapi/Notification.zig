// Minimal Notification stub for stealth mode.
// Exposes Notification.permission = "default" to pass intoli bot detection.

const js = @import("../js/js.zig");
const Page = @import("../Page.zig");

const Notification = @This();
_pad: bool = false,

pub const JsApi = struct {
    pub const bridge = js.Bridge(Notification);
    pub const Meta = struct {
        pub const name = "Notification";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
        pub const empty_with_no_proto = true;
    };

    pub const permission = bridge.property("default", .{ .template = false });
};
