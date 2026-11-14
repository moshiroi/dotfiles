---
name: explain
description: Make explainer diagrams, traces, comparisons and reports and show them in a Rex pane beside the conversation, saved to ~/explainers so they can be browsed later in yazi. Use when the user asks to explain, visualise, diagram, compare, or write up how something works, or asks for a report or an explainer, especially "show me", "draw", "walk me through", "explain X visually".
---

# explain

Turn an explanation into one or more **explainers**: files in the house
style, saved to a topic folder, shown in a Rex pane next to the
conversation. The user reads them in the terminal; nothing opens a browser
or Preview.app.

## 1. Pick the variants: each must earn its place

Choose only the variants that carry something the others can't. Never make
a variant that restates another in a different format (a text copy of the
concept diagram is low signal and the user has called that out).

| Variant | File | Its job | Pick it for |
|---|---|---|---|
| Concept diagram | `NN-concept.png` | **shape**: the parts and how they connect | "how does X work", architecture, the big picture |
| Sequence diagram | `NN-sequence.png` | **order**: who talks to whom, when | protocols, request flows, auth handshakes, debugging a path |
| Comparison chart | `NN-comparison.png` | **choosing**: options side by side + a verdict | "X vs Y", "should I…", trade-offs |
| Report | `NN-report.md` | **depth**: reasoning read top to bottom, tables, code | deep dives, write-ups, decisions with context |
| Text trace | `NN-trace.ans` | **literal detail**: real payloads, commands, costs, gotchas, copyable, works over ssh | "what actually happens", wire formats, step-by-step with real values |

Usually 1–3 variants. A quick "explain X" is often a single concept diagram
or a single trace. Number files in reading order (`01-`, `02-`, …).

## 2. Where things go

```
~/explainers/<topic-slug>/
  01-concept.png        what the user views
  02-trace.ans
  03-report.md
  .src/                 sources, hidden in yazi
    01-concept.svg
    02-trace.py
```

Use a short kebab-case topic slug. If the folder exists, add to it with the
next number rather than overwriting; overwrite only when revising the same
explainer.

## 3. House style (all variants)

Gruvbox-material, matching helix (custom-cat), Rex, and the starship prompt.

```
bg   #1d2021   panel #292929   panel2 #404040   border #504945
fg   #ebdbb2   soft  #d4be98   muted  #928374 / #a89984
red #ea6962  orange #e78a4e  yellow #d8a657  green #a9b665
aqua #89b482  blue #7daea3  purple #d3869b      cream-on-dark #fbf1c7
```

- Font: `'JetBrainsMono Nerd Font', Menlo, monospace`.
- Give each actor or role **one colour and keep it** across all variants of a
  topic (e.g. client green, server yellow, host blue, user purple).
- Every diagram has a title and a one-line subtitle saying what it shows.
- Prefer real names and real values (`tools/call`, `POST /repos/…/issues`,
  `~4k tokens`) over placeholders.

### Diagrams (concept, sequence, comparison): SVG → PNG

Write the SVG to `.src/`, render with
`rsvg-convert -o NN-name.png .src/NN-name.svg`, then **look at the PNG** (Read
it) before showing it, and fix overlaps, clipped labels, or arrows that miss
their boxes. Start from `templates/concept.svg` in this skill folder (a worked MCP
example) for the palette, arrow markers and text classes. Width 1180px; height to fit. Keep text
≥16px.

### Text trace: `.ans`

Start from `templates/trace.py` (a worked MCP example): it builds the file from coloured segments,
aligns annotation columns by visible width, and **asserts every line fits
84 columns**. Keep that assert. Conventions:

- grey = why it matters, green = literal/copyable payload, red = a cost or
  a gotcha, actor colours as above.
- Circled digits (①②…) draw two cells wide: follow them with two spaces.
- Run it: `python3 .src/NN-trace.py NN-trace.ans`.

### Report: `.md`

Plain markdown. `explain-view` renders it with glow in the gruvbox style,
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
