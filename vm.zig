const std = @import("std");
const math = std.math;

pub const Value = union(enum) {
    Int:  i32,
    Str:  []const u8,
    Bool: bool,
};

pub const Instruction = enum {
    Push,
    Add, Sub, Mul, Div, Mod,
    BitwiseAnd, BitwiseOr, BitwiseXor,
    LogicalAnd, LogicalOr,
    GreaterThan, LessThan,
    LogBaseTwo, LogBaseTen, Log,
    Sqrt, Sin, Cos, Tan,
    Load,
    Store,
    Jump,
    JumpIfFalse,
    JumpIfTrue,
    Print,
};

pub const Inst = struct {
    op:      Instruction,
    operand: ?Value = null,
};

pub const VM = struct {
    allocator: std.mem.Allocator,
    stack:     std.ArrayList(Value),
    mem:       []i32,                // simple flat memory

    pub fn init(allocator: std.mem.Allocator, mem: []i32) VM {
        return VM{
            .allocator = allocator,
            .stack     = std.ArrayList(Value).init(allocator),
            .mem       = mem,
        };
    }

    pub fn deinit(self: *VM) void {
        self.stack.deinit();
    }

    pub fn run(self: *VM, program: []const Inst) !void {
        var pc: usize = 0;
        while (pc < program.len) {
            const inst = program[pc];
            pc += 1;

            switch (inst.op) {
                .Push => {
                    const v = inst.operand.?;
                    try self.stack.append(v);
                },
                .Add => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Int = a + b });
                },
                .Sub => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Int = a - b });
                },
                .Mul => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Int = a * b });
                },
                .Div => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Int = @divTrunc(a, b) });
                },
                .Mod => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Int = @mod(a, b) });
                },
                .BitwiseAnd => {
                    const b = self.stack.pop().?.Bool;
                    const a = self.stack.pop().?.Bool;
                    try self.stack.append(Value{ .Bool = a and b });
                },
                .BitwiseOr => {
                    const b = self.stack.pop().?.Bool;
                    const a = self.stack.pop().?.Bool;
                    try self.stack.append(Value{ .Bool = a or b });
                },
                .BitwiseXor => {
                    const b = self.stack.pop().?.Bool;
                    const a = self.stack.pop().?.Bool;
                    try self.stack.append(Value{ .Bool = a != b });
                },
                .LogicalAnd => {
                    const b = self.stack.pop().?.Bool;
                    const a = self.stack.pop().?.Bool;
                    try self.stack.append(Value{ .Bool = a and b });
                },
                .LogicalOr => {
                    const b = self.stack.pop().?.Bool;
                    const a = self.stack.pop().?.Bool;
                    try self.stack.append(Value{ .Bool = a or b });
                },
                .GreaterThan => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Bool = a > b });
                },
                .LessThan => {
                    const b = self.stack.pop().?.Int;
                    const a = self.stack.pop().?.Int;
                    try self.stack.append(Value{ .Bool = a < b });
                },
                .LogBaseTwo => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.log2(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .LogBaseTen => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.log10(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .Log => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.log(f64, std.math.e, v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .Sqrt => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.sqrt(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .Sin => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.sin(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .Cos => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.cos(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },
                .Tan => {
                    const v_int: i32 = self.stack.pop().?.Int;
                    const v_f: f64   = @floatFromInt(v_int);
                    const r_f: f64   = std.math.tan(v_f);
                    const r_int: i32 = @intFromFloat(r_f);
                    try self.stack.append(Value{ .Int = r_int });
                },

                .Load => |operand| {
                    const idx: usize = @as(usize, operand.Int);
                    try self.stack.append(Value{ .Int = self.mem[idx] });
                },
                .Store => |operand| {
                    const idx: usize = @as(usize, operand.Int);
                    const v   = self.stack.pop().?;
                    self.mem[idx]    = v.Int;
                },

                .Jump => |operand| {
                    pc = @as(usize, operand.Int);
                },
                .JumpIfFalse => |operand| {
                    const cond = self.stack.pop().?.Bool;
                    if (!cond) pc = @as(usize, operand.Int);
                },
                .JumpIfTrue => |operand| {
                    const cond = self.stack.pop().?.Bool;
                    if (cond) pc = @as(usize, operand.Int);
                },

                .Print => {
                    const v = self.stack.pop().?;
                    switch (v) {
                        .Bool => |b| std.debug.print("{}\n", .{b}),
                        .Int  => |i| std.debug.print("{d}\n", .{i}),
                        .Str  => |s| std.debug.print("{s}\n", .{s}),
                    }
                },
            }
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var mem_buffer: [256]i32 = undefined;
    const mem_slice = mem_buffer[0..];

    var vm = VM.init(arena.allocator(), mem_slice);
    defer vm.deinit();
    
    // raw1: Compute 3 + 4
    // const raw1 = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{ .Int = 3 } },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 4 } },
    //     Inst{ .op = .Add, .operand = null },
    //     Inst{ .op = .Print, .operand = null },
    // };
    // std.debug.print("raw1: 3 + 4\n", .{});
    // try vm.run(raw1[0..]);

    // raw2: Compute (5 * 6) - (2 + 3)
    // const raw2 = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{ .Int = 5 } },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 6 } },
    //     Inst{ .op = .Mul, .operand = null },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 2 } },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 3 } },
    //     Inst{ .op = .Add, .operand = null },
    //     Inst{ .op = .Sub, .operand = null },
    //     Inst{ .op = .Print, .operand = null },
    // };
    // std.debug.print("raw2: (5 * 6) - (2 + 3)\n", .{});
    // try vm.run(raw2[0..]);

    // raw3: Compute 300 - 200
    // const raw3: [4]Inst = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{.Int = 300} },
    //     Inst{ .op = .Push, .operand = Value{.Int = 200} },
    //     Inst{ .op = .Sub, .operand = null },
    //     Inst{ .op = .Print, .operand = null},
    // };
    // std.debug.print("raw3: 300 - 200\n", .{});
    // try vm.run(raw3[0..]);

    // Print a string
    // const raw4 = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{ .Str = "Hello, Zig VM!" } },
    //     Inst{ .op = .Print, .operand = null },
    // };
    // std.debug.print("raw4: Print String\n", .{});
    // try vm.run(raw4[0..]);


    // const raw5: [2]Inst = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{.Str = "Jacob Morgan"} },
    //     Inst{ .op = .Print, .operand = null},
    // };
    // try vm.run(raw5[0..]);

    // const rawOne: [3]Inst = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{ .Int = 2 } },
    //     Inst{ .op = .Sqrt, .operand = null},
    //     Inst{ .op = .Print, .operand = null}
    // };
    // try vm.run(rawOne[0..]);

    // const boolTest: [4]Inst = [_]Inst{
    //     Inst{ .op = .Push, .operand = Value{ .Bool = true } },
    //     Inst{ .op = .Push, .operand = Value{ .Bool = false } },
    //     Inst{ .op = .LogicalAnd, .operand = null},
    //     Inst{ .op = .Print, .operand = null}
    // };
    // try vm.run(boolTest[0..]);

    // Compute cos(4 - 2) + sin(4 - 1) and print the result
    // const prog: [10]Inst = [_]Inst{
    //     // cos(4 - 2)
    //     Inst{ .op = .Push, .operand = Value{ .Int = 4 } },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 2 } },
    //     Inst{ .op = .Sub,  .operand = null },
    //     Inst{ .op = .Cos,  .operand = null },
    // 
    //     // sin(4 - 1)
    //     Inst{ .op = .Push, .operand = Value{ .Int = 4 } },
    //     Inst{ .op = .Push, .operand = Value{ .Int = 1 } },
    //     Inst{ .op = .Sub,  .operand = null },
    //     Inst{ .op = .Sin,  .operand = null },
    // 
    //     // add the two results
    //     Inst{ .op = .Add,  .operand = null },
    // 
    //     // print it
    //     Inst{ .op = .Print, .operand = null },
    // };
    // try vm.run(prog[0..]);
    // rounds to nearest whole
    // output: 0
}
