"""03-trace.ans: one search, then one Ask, with the real knobs.

Layout, the diagram's rules in a terminal: the figure on the left, notes in
a margin column on the right, one ink, red only for a cost or a gotcha.
Everything fits WIDTH columns, which the pane gives with room to spare.
"""
import re, sys, textwrap

# ── layout kit (copy as is) ────────────────────────────────────────────────
WIDTH, BODY, NOTE = 76, 5, 40          # total, figure indent, margin column

def rgb(h): return f"\x1b[38;2;{int(h[1:3],16)};{int(h[3:5],16)};{int(h[5:7],16)}m"
R, B = "\x1b[0m", "\x1b[1m"
INK, SOFT, NOTE_C, DIM, RED = rgb("#d6d0c2"), rgb("#bfb9ab"), rgb("#a8a295"), rgb("#78746a"), rgb("#c8776f")
VIS = lambda s: re.sub(r"\x1b\[[0-9;]*m", "", s)

def ink(s, base):
    """`code` and literal values in bright ink; the rest in `base`."""
    return base + re.sub(r"`([^`]+)`", lambda m: f"{INK}{m[1]}{base}", s) + R

def plain(s): return s.replace("`", "")

L = []
def blank(): L.append("")
def rule(): L.append(f" {DIM}{'─' * (WIDTH - 2)}{R}")

def title(t, *lines):
    L.append(f" {B}{INK}{t}{R}")
    for l in lines: L.append(" " + ink(l, NOTE_C))

def step(n, t, ref=""):
    left = f" {NOTE_C}{n}{R}  {B}{INK}{t}{R}"
    pad = WIDTH - len(VIS(left)) - len(ref)
    L.append(left + (" " * max(2, pad) + f"{NOTE_C}{ref}{R}" if ref else ""))

def row(left="", note="", red=False, indent=BODY):
    """A figure line with its note in the margin column. A note wraps inside
    the margin; a figure line too long for its side pushes the note below."""
    lines = textwrap.wrap(plain(note), WIDTH - NOTE) if note else []
    # re-apply `code` marks after wrapping on the plain text
    marks = re.findall(r"`([^`]+)`", note)
    def mark(s):
        for m in marks: s = s.replace(m, f"`{m}`", 1)
        return s
    colour = RED if red else NOTE_C
    head = " " * indent + ink(left, SOFT) if left else ""
    if lines and len(VIS(head)) > NOTE - 2:
        L.append(head); head = ""
    for i, n in enumerate(lines or [""]):
        h = head if i == 0 else ""
        L.append(h + " " * (NOTE - len(VIS(h))) + ink(mark(n), colour) if n else h)

def sub(label):
    L.append(" " * BODY + f"{INK}{label}{R}")

def code(*lines, indent=BODY):
    for l in lines: L.append(" " * indent + f"{DIM}│{R} {INK}{l}{R}")

def table(head, rows, widths, indent=BODY, right=()):
    """Columns left-aligned, except those in `right` (numbers)."""
    fmt = lambda cells, c: "".join(
        f"{c}{x:>{w}}{R}" if i in right else f"{c}{x:<{w}}{R}" for i, (x, w) in enumerate(zip(cells, widths)))
    L.append(" " * indent + fmt(head, NOTE_C))
    for r in rows: L.append(" " * indent + fmt(r, INK))

def bullets(*items):
    for it in items:
        w = textwrap.wrap(it, WIDTH - 4)
        L.append(f"  {NOTE_C}·{R} {SOFT}{w[0]}{R}")
        for x in w[1:]: L.append(f"    {SOFT}{x}{R}")

# ── the trace ──────────────────────────────────────────────────────────────
title("One search, then one Ask, as they happen",
      'the query  `"paul graham on doing great work"`',
      "routes/search/mod.rs · retrieve(), retrieve_for_ask()")
rule(); blank()

step("1", "Indexed at save time", "embeddings/")
row("`link` → trigger → job queue", "every save or edit")
row("  → worker → `gemini-embedding-2`")
blank()
row("`links.search_tsv`", "local, always")
row("`link_contents.tsv`", "local, always")
row("`link_embeddings`", "hosted; text and image")
row("`link_passage_embeddings`", "hosted; halfvec, one per page")
row("eligibility", "gates only what Gemini may read")
blank()

step("2", "Two arms at once", "tokio::join!")
sub("lexical")
code("to_tsquery('english',", "  'paul & graham & great & work')")
row("`ts_rank` + `url ILIKE` via pg_trgm", "never skipped")
sub("semantic")
row("embed the query", "per-user cache first")
row("deadline `1 s` as you type", "embedding takes 0.1–0.5 s")
row("skip if q is under `3` chars", "a prefix means nothing")
blank()

step("3", "Exact scans, kept only as evidence")
code("WITH qv AS MATERIALIZED", "  (SELECT $3::vector AS v)", "… embedding <=> qv.v AS distance", "… LIMIT 50")
row("without the CTE", "340 ms over 8,854 passages, not 2", red=True)
blank()
table(("target", "floor", "gap", "weight"),
      [("text", "0.70", "0.08", "1.00"), ("image", "0.58", "0.10", "0.75"), ("passage", "0.64", "0.10", "1.25")],
      (10, 6, 7, 9), right=(1, 2, 3))
blank()
row("floor", "least similarity that counts")
row("gap", "drops “hubs” far behind the nearest")
row("passages", "8 kept per link")
row("`embedding_targets`", "holds these; retune with an UPDATE")
blank()

step("4", "Fuse ranks, k = 60", "fusion.rs")
table(("save", "ranked", "score"),
      [("B", "text 1, passage 1", "1/61 + 1.25/61 = .0369"),
       ("A", "lexical 1, text 3", "1/61 + 1/63 = .0323"),
       ("C", "lexical 2", "1/62 = .0161")],
      (6, 20, 22), right=(2,))
blank()
row("B wins with no keyword", "meaning beat words")
row("top 3 lexical pinned", "a cut never drops an exact match")
row("semantic fails or finds 0", "lexical alone, never a 500", red=True)
blank()

step("5", "Ask: the same retriever, then a model", "ask/")
row("keywords: AND first", "then each alone, if AND finds < 3")
row("semantic: the whole question", "2 s deadline")
row("", 'so "paul graham" → paulgraham.com')
row("sources per save, budgeted", "summary, opening, nearest passages")
row("the model", "answers with [n] citations")
row("shown: cited, plus related", "confident and sharing a word")
row("related: similarity ≥ `0.76`", "stricter than the 0.70 floor")
row("a keyword-only match", "is read, never shown as related", red=True)
blank()

step("6", "Opening a file from a hit", "settle.rs")
row("a passage holds every word", "keep its page, no call")
row("otherwise `POST /links/{id}/match`", "the model replies one integer")
row("why not always ask", "it broke 52 good pages, fixed 21")
blank()

rule()
L.append(f" {B}{INK}Worth remembering{R}")
bullets("RAG from first principles: no vector DB, no framework, just Postgres.",
        "Exact scans work because each library is small: no ANN recall loss.",
        "Fusion uses ranks, so ts_rank and cosine never need a common scale.")

too_wide = [(i, len(VIS(l))) for i, l in enumerate(L) if len(VIS(l)) > WIDTH]
assert not too_wide, too_wide
open(sys.argv[1], "w").write("\n".join(L) + "\n")
print(f"{len(L)} lines, max width {max(len(VIS(l)) for l in L)}")
