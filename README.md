# YARD Medoosa

Enhance YARD documentation by generating class diagrams.

## Usage

Add `--plugin medoosa` to your `.yardopts`.

During `yard doc`, Medoosa will produce diagrams in the output directory:

- `medoosa-nesting.png`
- `medoosa-nesting.svg` (with hyperlinks)

## Requirements

- The [Graphviz programs](https://graphviz.org/download/)
  (`dot` and `unflatten`)

### Name

This is a reincarnation
of [the original Medoosa](http://medoosa.sourceforge.net/).
