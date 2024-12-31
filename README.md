# ZIGODD: decimal odd to probability Zig converter

Zigodd is a program written in Zig with the purpose of converting 
decimal odds to the implied probability. The full explanation of the code
it's on this [blogpost](https://vinybrasil.github.io/blog/zigodd).

## Usage

Building the program:

```bash
zig build
```

Running the program with a game with 3 outcomes:
```bash
./zig-out/bin/zigodd 1.27 6.00 10.25
```

Or for a game with 2 outcomes:
```bash
./zig-out/bin/zigodd 1.42 3.10
```