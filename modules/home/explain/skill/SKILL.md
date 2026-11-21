---
name: explain
description: Make explainers (3Blue1Brown-style intuition pages, concept diagrams, text traces and, when asked, reports) and show them in a Rex pane beside the conversation, saved to ~/explainers so they can be browsed later in yazi. Use when the user asks to explain, visualise, diagram, compare, or write up how something works, or asks for a report or an explainer, especially "show me", "draw", "walk me through", "explain X visually".
---

# explain

Turn an explanation into one or more **explainers**: files in the house
style, saved to a topic folder, shown in a Rex pane next to the
conversation. The user reads them in the terminal; nothing opens a browser
or Preview.app.

## 1. Pick the variants: each must earn its place

Four variants, each with a job the others can't do. Never make one that
restates another in a different format.

| Variant | File | Its job | Pick it for |
|---|---|---|---|
| Intuition | `NN-intuition.png` | **why**: one idea as a picture, 3Blue1Brown style | an idea with a shape: similarity, ranking, a threshold, a trade-off curve, a data structure |
| Concept diagram | `NN-concept.png` | **shape**: the parts and how they connect | a system: architecture, a pipeline, "how does X work" |
| Text trace | `NN-trace.ans` | **literal detail**: real payloads, commands, costs, gotchas, in order, copyable | "what actually happens", a request or protocol step by step, wire formats |
| Report | `NN-report.md` | **reasoning**: an argument read top to bottom | only when asked for a write-up, a decision or a deep dive |

The default for "explain X":

1. a **concept diagram** if X is a system with parts,
2. an **intuition page** for its key idea (the owner rates these above
   everything else; reach for one whenever the idea can be drawn as
   geometry, a number line, a curve or a structure),
3. a **trace** when the literal values matter.

Two or three files, in that reading order. A small question may need only
one. There is no sequence diagram (the trace carries order, with real
values) and no comparison chart: a trade-off with a shape is an intuition
page, a feature-by-feature comparison is a table in the trace or a report.

Number files in reading order (`01-`, `02-`, …).

## 2. Where things go

```
~/explainers/<topic-slug>/
  01-concept.png        what the user views
  02-intuition.png
  03-trace.ans
  .src/                 sources, hidden in yazi
    01-concept.svg
    02-intuition.py
    03-trace.py
```

Use a short kebab-case topic slug. If the folder exists, add to it with the
next number rather than overwriting; overwrite only when revising the same
explainer.

## 3. House style (all variants)

Lichen, the desktop palette (`modules/theme/palette.nix` in the dotfiles):
warm charcoal, bone text, muted hues.

```
bg   #201f1d   raised #282724   card #32302d   border #444139
text #d6d0c2   soft  #bfb9ab   note #a8a295   label #857f73   faint #78746a
red  #c8776f   (Lichen's error: the one accent in diagrams and traces)
identity hues, intuition pages only (Lichen's terminal hues):
yellow #d8a657  blue #7daea3  purple #d3869b  green #a9b665
aqua #89b482    orange #e78a4e  sage #98a585
```

`soft` sits halfway between text and note, for code in diagrams and prose
in traces. Rules are `card`, leaders `faint`.

- Fonts: traces and reports are monospace (the terminal's). Diagrams use
  `Charter` for words and `'JetBrainsMono Nerd Font'` only for code, table
  names, routes and paths. rsvg only sees installed fonts: SF Pro, New York,
  Iowan and Hoefler silently fall back; Charter, Georgia and Avenir Next work.
- **Colour is never decoration.** In concept diagrams and traces it is
  one ink, with red for a cost, failure or gotcha. In an intuition page a
  colour *names* an object, and the words that mention it wear the same
  colour (see below). No colour per actor or per kind of thing.
- Every diagram has a title and a one-line subtitle saying what it shows.
- Prefer real names and real values (`tools/call`, `POST /repos/…/issues`,
  `~4k tokens`) over placeholders.

### Concept diagrams: SVG → PNG

Write the SVG to `.src/`, render with
`rsvg-convert -z 2 -o NN-name.png .src/NN-name.svg` (2× for a sharp pane),
then **look at the PNG** (Read it) before showing it, and fix overlaps,
clipped labels, wires that close a shape by accident, or leaders that run
along a wire. Start from `templates/concept.svg` and `concept-2.svg` (a
worked flingd-search example over two pages) and copy their classes,
marker and layout.

**Size for the pane.** The viewer shrinks the whole image to fit a pane
half the window wide, so a wide canvas turns 15px notes into 9px. Draw at
**840px wide**, 48px margins, and no page taller than ~950px. When a figure
runs longer, split it into pages (`01-concept`, `02-concept`) the reader
flips with ←/→, end each page with a small `→ 02 · FUSE` pointer, and give
each page its own title. Prefer vertical flows: a pipeline reads down the
page, with side effects (a store, an external API) branching right.
Type: title 34, subtitle 18, stage label 14, heading 22, step 19, notes and
code 16, nothing below 15.

Draw it like a page from Leonardo's notebooks: the figure explains the
mechanism, notes stand in the margin beside what they describe, and ink
does the work colour usually does.

- **Monochrome ink.** Words in bone (#d6d0c2), notes in #a8a295, wires in
  1.2px #a8a295 with open chevron arrowheads. No panels, no boxes, no
  fills. Grouping comes from whitespace and alignment.
- **Colour is rare and means one thing.** At most one accent per diagram,
  for what the reader must not miss: a failure path, a cost, a danger. Red
  (#c8776f) by default. If you reach for a second colour, say it in a
  margin note instead. No colour keys.
- **Two columns.** The figure on the left (x 48–540), a hairline rule at
  x 568, margin notes on the right (x 592–792, Charter 16, wrapped by hand
  at ~27 characters). Put each note at the height of what it describes; add
  a dotted leader (1px, `1 4` dash) only when it points at one specific
  line, and run it through empty space, never along a wire.
- **Numbered stages.** Split the figure into stages read top to bottom,
  each headed by a small tracked label: `I · INDEX`, `II · RETRIEVE`.
- **Draw things as what they are.** A store is a small vessel (the
  cylinder glyph), a step is its name, the idea at the heart of it (a
  formula, a rule) is set large in the middle with one quiet line beneath.
  Hierarchy is size and position, not weight or colour.
- **Wires are orthogonal** with 8px rounded elbows; fan-out and fan-in
  share one bus. Check that buses don't enclose a column of text.
- **Every note earns its line.** A margin note adds the why, the cost or
  the consequence; it never restates the figure.

### Intuition page (3Blue1Brown): SVG → PNG

One idea, drawn so it can be seen rather than read. Start from
`templates/intuition.py` (the semantic arm's floor and gap as a cone of
cosine angles): it generates the SVG from real numbers, so the geometry
is true. Same canvas as the diagrams: 840px wide, rendered with `-z 2`.

- **Draw the idea, not the system.** Pick the geometry the maths already
  has: similarity is an angle, rank is a position on a line, a threshold
  is a boundary, a budget is an area. Compute positions from the real
  values (`math.acos(sim)`), never place them by eye.
- **One concrete example.** Real values from the code or a real query,
  each labelled at its mark: `0.92 nearest`, `0.79 hub`.
- **Colour is identity.** Three or four colours, each naming one object
  (query yellow, kept blue, floor purple, dropped grey). The same word in
  the notes and in the equation wears the same colour, so the eye links
  sentence to shape with no legend. Never use a colour for two things.
- **Symmetry and one focal object.** Put the subject (the query) on an
  axis, heaviest stroke, and let everything else arrange around it.
  Regions are faint fills (10–16% opacity) bounded by thin lines.
- **Notes build the idea in order**, one short paragraph each, top to
  bottom in the margin column: what you see, the first rule, the second
  rule, the consequence. Each introduces at most one coloured word.
- **End with the rule** as one equation in mono, its terms in their
  colours, with the real constants in a quiet line beneath.
- Labels sit at the tips of their marks, outside the figure; check none
  collides with a boundary label or the margin column.

### Text trace: `.ans`

Same rules as the diagrams, set in a terminal: the figure on the left, notes
in a margin column on the right, one ink. Start from `templates/trace.py`
(the flingd-search trace) and keep its layout kit as is: `title`, `step`,
`row`, `sub`, `code`, `table`, `bullets`, `rule`. Don't hand-pad lines.

- **76 columns.** The pane gives 78; the script asserts every line fits.
- **Fixed grid.** Steps at column 1 (`1  Title`, its file or function
  right-aligned at the edge), the figure at column 5, every note at column
  40. A note wraps inside the margin; if it wraps, shorten it first. A
  figure line too long for its side pushes its note to the next line.
- **One ink, three weights.** Code and literal values bright (mark them
  with backticks in `row`), prose soft, notes and table heads grey, rules
  dim. Bold only for the title and step titles.
- **Red is for a cost or a gotcha** (`row(..., red=True)`): a slow path, a
  failure mode, something that surprises. Nothing else is coloured: no
  colour per actor, no green code.
- **Literal blocks** (SQL, JSON, a command) go in `code()`, behind a dim
  `│` gutter, broken by hand at a meaningful point.
- **Tables** left-align words and right-align numbers (`right=`), with a
  grey head row. Notes about a table go beneath it as rows, not as a
  trailing column.
- **No blank lines inside a step**, except around a table or block; one
  blank line between steps. End with `Worth remembering`: three bullets,
  one conclusion each.
- Plain digits for steps; circled digits are two cells wide and break the
  grid.
- Run it: `python3 .src/NN-trace.py NN-trace.ans`, then read the output
  with colours stripped (`sed 's/\x1b\[[0-9;]*m//g'`) and fix any note
  that wraps or any column that drifts.

### Report: `.md`

Plain markdown. `explain-view` renders it with glow in the Lichen style,
wrapped to the pane, so don't hard-wrap for a width. Lead with a TL;DR
blockquote, use tables for comparisons and fenced code with a language.
Images don't render inside markdown; point to the diagram files instead
("see 01-concept").

## 4. Show it

```
explain-show ~/explainers/<topic>/01-concept.png
```

`explain-show` opens the file in `explain-view` in a Rex pane to the right
of the conversation (`--below` for underneath), closes any previous explain
pane first so there is only one, and leaves focus with the user. In the
viewer the user moves through the topic folder with ←/→, scrolls with the
wheel / space / d·u, and closes with q.

Then tell the user in a sentence what's there and how many files, e.g.
"3 explainers in ~/explainers/oauth-pkce: concept, trace, report. ←/→ to
move between them."

Outside Rex (`$REX_SESSION` unset), `explain-show` runs the viewer in the
current terminal, which would take over Claude's own terminal. Don't call
it there; give the user the command to run instead.

## 5. Rules for touching Rex panes

- Prefer `explain-show` / `rex split -- COMMAND`: it runs the command in a
  new pane, so nothing is typed into the user's shells.
- Never type (`rex send`, `send-key`, `write`) into a pane you didn't
  create. If you must drive the explain pane, first confirm what is on
  screen with `rex capture` (the viewer's first line starts with
  ` explain · `). Checking the process name is not enough: the viewer
  shows up as `yazi` or `python3`.
- Never send keys to yazi blindly: `d` trashes files there.

## 6. Browsing later

`yazi ~/explainers` shows every topic with previews (images, rendered
markdown, coloured traces). Enter opens the viewer; `o` offers the editor
or Preview.app.
