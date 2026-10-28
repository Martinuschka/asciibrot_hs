# asciibrot

A small Haskell command-line program that renders a zooming ASCII Mandelbrot fractal animation in the terminal.

## Features

- Generates a Mandelbrot set in ASCII art
- Animates continuous zoom into the fractal
- Uses terminal control sequences to clear and redraw the screen
- Runs as a simple CLI tool with user-configurable frame rate

## Requirements

- GHC / Cabal
- A terminal that supports ANSI escape codes

## Build

From the project root, run:

```bash
cabal build
```

## Run

```bash
cabal run asciibrot
```

When the program starts, it will prompt for a frame rate in frames per second, such as:

```text
Enter frame rate (frames per second, e.g., 5 or 10) or 'q' to quit:
```

You can also quit by entering:

```text
q
```

or:

```text
quit
```

## Notes

- The animation is intentionally rendered in the terminal using a compact ASCII character set.
- The program uses a fixed canvas size of 80x40 and a default maximum iteration count of 100.
- Press Ctrl+C to interrupt the animation and return to the menu.

## Project Structure

```text
.
├── asciibrot.cabal
├── LICENSE
├── README.md
└── src
    └── Main.hs
```

## License

This project includes a `LICENSE` file; please refer to it for licensing details.
