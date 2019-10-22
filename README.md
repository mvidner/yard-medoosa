# YARD Medoosa

Enhance YARD documentation by generating class diagrams.

## Usage

Add `--plugin medoosa` to your `.yardopts`.

During `yard doc`, Medoosa will produce diagrams in the output directory,
linked in the *Files* section:

- `medoosa-nesting.svg` (with classes **hyperlinked** into the rest of the docs)
- `medoosa-nesting.png`

Example output:

![medoosa-nesting small](https://user-images.githubusercontent.com/102056/67187700-14013b80-f3eb-11e9-9e15-17ad58d3b0bb.png)

## Requirements

- The [Graphviz programs](https://graphviz.org/download/)
  (`dot` and `unflatten`)

## Name

If I remember correctly, [Medusa](https://en.wikipedia.org/wiki/Medusa) was
a mythical woman with hair so tangled that a single look of it made people
turn into stone.
Medoosa is the Object Oriented reincarnation, except it produces diagrams that
are much less tangled. yard-medoosa is inspired
by [the original C++ Medoosa](http://medoosa.sourceforge.net/).
