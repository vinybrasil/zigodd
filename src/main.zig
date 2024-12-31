const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Odds: type = struct {
    k: f32 = 0.0,
    odds: []f32 = undefined,
    probabilities: []f32 = undefined,

    pub fn calculate_k(self: *Odds) anyerror!void {
        var sum: f32 = 0;

        for (self.odds) |item| {
            sum += (1 / item);
        }

        self.k = 1 / sum;
    }

    pub fn calculate_probabilities(self: *Odds) anyerror!void {
        const allocator = std.heap.page_allocator;
        var probs_processed = std.ArrayList(f32).init(allocator);

        for (self.odds) |item| {
            const prob_processed = self.k * (1 / item);
            try probs_processed.append(prob_processed);
        }

        self.probabilities = probs_processed.items;
    }
};

pub fn main() anyerror!void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);

    defer std.process.argsFree(std.heap.page_allocator, args);

    var myodds = Odds{};

    const len_probabilities: u32 = @intCast(args.len);

    const odds_raw = args[1..len_probabilities];

    const allocator = std.heap.page_allocator;
    var odds_processed = std.ArrayList(f32).init(allocator);

    defer odds_processed.deinit();

    for (odds_raw) |item| {
        const odd_processed = try std.fmt.parseFloat(f32, item);
        try odds_processed.append(odd_processed);
    }

    myodds.odds = odds_processed.items;

    try myodds.calculate_k();

    try myodds.calculate_probabilities();

    try stdout.print("-------ZIGODD: ODDS TO PROBABILITY CONVERSOR-------\n", .{});

    try stdout.print("---decimal odds to convert: \n", .{});

    for (myodds.odds, 0..) |item, index| {
        try stdout.print("o{d}: {d:0.2}\n", .{ index + 1, item });
    }
    try stdout.print("---calculated payout (k): \n", .{});
    try stdout.print("k: {d:0.7}\n", .{myodds.k});

    try stdout.print("---calculated probabilities: \n", .{});
    for (myodds.probabilities, 0..) |item, index| {
        try stdout.print("p{d}: {d:0.7}\n", .{ index + 1, item });
    }

    try stdout.print("-----------------------------------------------------\n", .{});
}
