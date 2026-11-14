"""05-text.ans: an annotated trace of one real MCP tool call.

Text earns its place by being literal and dense: the actual messages on the
wire, in order, with what each step costs or decides. Width is checked so it
fits an 84-column pane.
"""
import re, sys

def c(h): return f"\x1b[38;2;{int(h[1:3],16)};{int(h[3:5],16)};{int(h[5:7],16)}m"
R, B, D = "\x1b[0m", "\x1b[1m", "\x1b[2m"
FG, GREY = c("#ebdbb2"), c("#928374")
YOU, LLM, CLI, SRV, EXT = c("#d3869b"), c("#7daea3"), c("#a9b665"), c("#d8a657"), c("#e78a4e")
CODE, WARN = c("#89b482"), c("#ea6962")
WIDTH = 84

you = f"{YOU}{B}you{R}"
llm = f"{LLM}{B}LLM{R}"
cli = f"{CLI}{B}client{R}"
srv = f"{SRV}{B}server{R}"
ext = f"{EXT}{B}GitHub{R}"
def arrow(label=""): return f"{GREY}──{R}{FG}{label}{R}{GREY}──▶{R}" if label else f"{GREY}──▶{R}"
def back(label=""): return f"{GREY}◀──{R}{FG}{label}{R}{GREY}──{R}"
def code(s): return f"{CODE}{s}{R}"
def why(s): return f"{GREY}{s}{R}"
def step(n, title): return f" {CLI}{B}{n}{R}  {B}{FG}{title}{R}"  # circled digits draw 2 cells wide

L = []
L.append(f" {B}{FG}One MCP tool call, as it happens{R}")
L.append(f" {GREY}you type:{R} {YOU}\"open an issue in dotfiles: rex theme should live in nix\"{R}")
L.append("")
L.append(f" {GREY}cast:{R} {you} {GREY}·{R} {llm} {GREY}+{R} {cli} {GREY}(in Claude Code) ·{R} {srv} {GREY}(github-mcp process) ·{R} {ext}")
L.append(f" {GREY}{'─' * (WIDTH - 2)}{R}")

L.append(step("①", "startup") + f"  {GREY}once per session, before you type anything{R}")
VIS = lambda s: re.sub(r"\x1b\[[0-9;]*m", "", s)
def note(left, text, col=42, colour=GREY):
    return left + " " * max(1, col - len(VIS(left))) + f"{colour}{text}{R}"
L.append(note(f"     {cli} {arrow(' initialize ')} {srv}", "agree on protocol version"))
L.append(note(f"     {cli} {back(' capabilities ')} {srv}", "server says: I have tools"))
L.append(note(f"     {cli} {arrow(' tools/list ')} {srv}", ""))
L.append(note(f"     {cli} {back(' 26 tools ')} {srv}", "every schema rides along in every", colour=WARN))
L.append(note("", "LLM request: ~4k tokens of context", colour=WARN))
L.append("")

L.append(step("②", "the model chooses") + f"  {GREY}no MCP traffic yet{R}")
L.append(f"     {llm} reads your message + the 26 tool descriptions, emits:")
L.append(f"       {code('tool_use  create_issue {repo: \"dotfiles\", title: \"rex theme in nix\"}')}")
L.append(f"     {why('a vague tool description here = the wrong tool picked')}")
L.append("")

L.append(step("③", "the host gatekeeps"))
L.append(f"     Claude Code {arrow()} {you}   {YOU}allow github · create_issue?{R}  {why('[y] once / always / no')}")
L.append(f"     {why('servers cannot act on their own; every call goes through this')}")
L.append("")

L.append(step("④", "the call") + f"  {GREY}JSON-RPC 2.0 over stdio (pipes) or HTTP{R}")
L.append(f"     {cli} {arrow(' tools/call ')} {srv} {arrow(' POST /repos/…/issues ')} {ext}")
L.append(f"       {code('{\"method\":\"tools/call\",\"id\":7,\"params\":{\"name\":\"create_issue\",…}}')}")
L.append(f"     {why('the server holds the GitHub token; the LLM never sees it')}")
L.append("")

L.append(step("⑤", "the result comes back"))
L.append(f"     {cli} {back(' result ')} {srv} {back(' 201 Created ')} {ext}")
L.append(f"       {code('{\"id\":7,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"Created #42\"}]}}')}")
L.append(f"     {why('this text is appended to the conversation, then the LLM continues')}")
L.append("")

L.append(step("⑥", "the answer"))
L.append(f"     {llm} {arrow()} {you}   {YOU}\"Opened dotfiles#42.\"{R}")
L.append(f" {GREY}{'─' * (WIDTH - 2)}{R}")

L.append(f" {B}{FG}worth remembering{R}")
L.append(f"  {SRV}•{R} the {llm} never talks to servers; the {cli} does, and only after {you} allow it")
L.append(f"  {SRV}•{R} tool lists cost context on every turn: fewer, sharper servers beat many")
L.append(f"  {SRV}•{R} secrets live in the server process, not in the prompt")

# keep it inside the pane
vis = lambda s: re.sub(r"\x1b\[[0-9;]*m", "", s)
too_wide = [(i, len(vis(l))) for i, l in enumerate(L) if len(vis(l)) > WIDTH]
assert not too_wide, too_wide
open(sys.argv[1], "w").write("\n".join(L) + "\n")
print(f"{len(L)} lines, max width {max(len(vis(l)) for l in L)}")
