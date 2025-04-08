# ZIGODD: decimal odd to probability Zig converter

Zigodd is a program written in Zig with the purpose of converting 
decimal odds to the implied probability. The full explanation of the code
it's on this [blogpost](https://vinybrasil.github.io/blog/zigodd).

## Usage

Building the program:

```bash
zig build
```

To convert from odd to probability from a game with 3 outcomes:
```bash
./zig-out/bin/zigodd 1.27 6.00 10.25 --debug
```

Or for a game with 2 outcomes:
```bash
./zig-out/bin/zigodd 1.42 3.10 --debug
```

To convert from probability to odd, the payout should be given as well as the flag --probtoodd. A game with a payout (vigorish) of 95,09055% and 3 possible outcomes:
```bash
./zig-out/bin/zigodd 0.7487445 0.1584843 0.0927713 -k 0.9509055 --probtoodd --debug
```

Or for a game with 2 outcomes:
```bash
./zig-out/bin/zigodd 0.89 0.11 -k 0.9509055 --probtoodd
```