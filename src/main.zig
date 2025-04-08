const std = @import("std");
const stdout = std.io.getStdOut().writer();
const mini_parser = @import("mini_parser");
const mem = std.mem;

const usage =
    \\Usage: example <opts>
    \\
    \\Options:
    \\  --help  -h      Display help list
    \\  --text  -t      Print text
    \\  --bool  -b      Print boolean
    \\
;

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

    pub fn calculate_odds(self: *Odds) anyerror!void {
        const allocator = std.heap.page_allocator;
        var odds_processed = std.ArrayList(f32).init(allocator);

        for (self.probabilities) |item| {
            const odd_processed = self.k / item;
            try odds_processed.append(odd_processed);
        }

        self.odds = odds_processed.items;
    }
};
const type_conversion = enum {
    probtoodd,
    oddtoprob,
};

pub fn main() anyerror!void {
    var myodds = Odds{};

    const allocator = std.heap.page_allocator;

    const argv = std.os.argv[0..];

    var parameters = std.ArrayList(f32).init(allocator);
    var verbose: bool = undefined;
    var mode = type_conversion.oddtoprob;
    var vig: f32 = undefined;
    var i: usize = 0;

    // following the tutorial of mini_parser
    while (argv.len > i) : (i += 1) {
        const parser = try mini_parser.init(argv[i], &.{
            .{ .name = "param1", .short_name = '1', .type = .argument }, // 4
            .{ .name = "param2", .short_name = '2', .type = .argument }, // 5
            .{ .name = "param3", .short_name = '3', .type = .argument }, // 6
            .{ .name = "help", .short_name = 'h', .type = .boolean }, // 1
            .{ .name = "probtoodd", .short_name = 'p', .type = .boolean }, // 2
            .{ .name = "debug", .short_name = 'd', .type = .boolean }, // 3
            .{ .name = "vig", .short_name = 'k', .type = .argument }, // 2
        });

        switch (parser.argument) {
            0 => std.debug.print("no argument was given.\n", .{}),
            1 => {
                const parameter_processed = try std.fmt.parseFloat(f32, parser.value);
                try parameters.append(parameter_processed);
            },
            2 => {
                const parameter_processed = try std.fmt.parseFloat(f32, parser.value);
                try parameters.append(parameter_processed);
            },
            3 => {
                const parameter_processed = try std.fmt.parseFloat(f32, parser.value);
                try parameters.append(parameter_processed);
            },
            4 => std.debug.print("Usage: {s}\n", .{usage}),
            5 => {
                mode = type_conversion.probtoodd;

                std.debug.print("INFO: mode changed to: {any}\n", .{mode});
            },
            6 => {
                std.debug.print("INFO: enabled verbose\n", .{});
                verbose = true;
            },

            7 => {
                vig = try std.fmt.parseFloat(f32, parser.value);
            },

            8 => std.debug.print("argument '{s}' does not exist.\n", .{argv[i]}),
            else => {
                // a manouver to be able to dont have to write -1, -2 or -3 for the first argument
                if (i == 1) {
                    const parameter_processed = try std.fmt.parseFloat(f32, mem.sliceTo(argv[i], 0));
                    try parameters.append(parameter_processed);
                }
                if (i == 2) {
                    const parameter_processed = try std.fmt.parseFloat(f32, mem.sliceTo(argv[i], 0));
                    try parameters.append(parameter_processed);
                }
                if (i == 3) {
                    const parameter_processed = try std.fmt.parseFloat(f32, mem.sliceTo(argv[i], 0));
                    try parameters.append(parameter_processed);
                }
            },
        }
    }

    if (mode == type_conversion.probtoodd) {
        myodds.probabilities = parameters.items;
        myodds.k = vig;

        try myodds.calculate_odds();

        if (verbose) {
            try stdout.print("-------ZIGODD: ODDS TO PROBABILITY CONVERTER-------\n", .{});

            try stdout.print("---probabilities to convert: \n", .{});

            for (myodds.probabilities, 0..) |item, index| {
                try stdout.print("p{d}: {d:0.2}\n", .{ index + 1, item });
            }
            try stdout.print("---used payout (k): \n", .{});
            try stdout.print("k: {d:0.7}\n", .{myodds.k});

            try stdout.print("---calculated odds: \n", .{});
            for (myodds.odds, 0..) |item, index| {
                try stdout.print("o{d}: {d:0.7}\n", .{ index + 1, item });
            }

            try stdout.print("-----------------------------------------------------\n", .{});
        }
    }

    if (mode == type_conversion.oddtoprob) {
        myodds.odds = parameters.items;

        try myodds.calculate_k();

        try myodds.calculate_probabilities();

        if (verbose) {
            try stdout.print("-------ZIGODD: ODDS TO PROBABILITY CONVERTER-------\n", .{});

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
    }
}
