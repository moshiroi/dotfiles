import math, sys
W,H=840,990
OX,OY,RAD=64,500,320
QA=0   # query direction, degrees above horizontal
Y,BL,GR,SOFT,INK,DIM,RED,PU="#d8a657","#7daea3","#857f73","#a8a295","#d6d0c2","#444139","#c8776f","#d3869b"
def pt(rel,r=RAD):
    a=math.radians(QA+rel); return OX+r*math.cos(a), OY-r*math.sin(a)
def deg(sim): return math.degrees(math.acos(sim))
floor, nearest, gap = 0.70, 0.92, 0.08
cut = nearest-gap
o=[]; A=o.append
A(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
A('''<style>
text{font-family:Charter,Georgia,serif;fill:#d6d0c2}
.title{font-size:34px}.sub{font-size:18px;fill:#a8a295}
.m{font-size:17px;fill:#bfb9ab}.n{font-size:15px;fill:#a8a295}
.c{font-family:'JetBrainsMono Nerd Font',Menlo,monospace;font-variant-ligatures:none}
</style>''')
for c,col in (("y",Y),("b",BL),("g",GR)):
    A(f'<marker id="{c}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto"><path d="M0,1 L10,5 L0,9 z" fill="{col}"/></marker>')
A(f'<rect width="{W}" height="{H}" fill="#201f1d"/>')
A('<text x="48" y="74" class="title">What the semantic arm keeps</text>')
A('<text x="48" y="106" class="sub">Every save is an arrow. Similarity is how closely it points along the query.</text>')

def wedge(a0,a1,r,fill,op):
    x0,y0=pt(a0,r); x1,y1=pt(a1,r)
    return f'<path d="M{OX},{OY} L{x0:.1f},{y0:.1f} A{r},{r} 0 0 0 {x1:.1f},{y1:.1f} Z" fill="{fill}" fill-opacity="{op}"/>'
fd, gd = deg(floor), deg(cut)
A(wedge(-fd,fd,RAD+20,GR,0.10))
A(wedge(-gd,gd,RAD+20,BL,0.16))
# boundary rays
for s,d,col,dash in ((1,fd,PU,"5 6"),(-1,fd,PU,"5 6"),(1,gd,BL,""),(-1,gd,BL,"")):
    x,y=pt(s*d,RAD+20); A(f'<line x1="{OX}" y1="{OY}" x2="{x:.1f}" y2="{y:.1f}" stroke="{col}" stroke-width="1.2" stroke-dasharray="{dash}"/>')
# arc of unit circle
x0,y0=pt(-72); x1,y1=pt(72)
A(f'<path d="M{x0:.1f},{y0:.1f} A{RAD},{RAD} 0 0 0 {x1:.1f},{y1:.1f}" fill="none" stroke="{DIM}" stroke-width="1"/>')

saves=[(0.92,23,"nearest"),(0.88,-28,""),(0.79,39,"hub"),(0.75,-41,"hub"),(0.52,59,""),(0.40,-66,"")]
for sim,rel,tag in saves:
    keep = sim>=cut; ok = sim>=floor
    col = BL if keep else GR
    m = "b" if keep else "g"
    x,y=pt(rel,RAD-14)
    A(f'<line x1="{OX}" y1="{OY}" x2="{x:.1f}" y2="{y:.1f}" stroke="{col}" stroke-width="{2.4 if keep else 1.6}" marker-end="url(#{m})"/>')
    lx,ly=pt(rel,RAD+34)
    label=f"{sim:.2f}"+(f"  {tag}" if tag else "")
    A(f'<text x="{lx:.1f}" y="{ly+5:.1f}" class="c" style="font-size:15px;fill:{col}" text-anchor="start">{label}</text>')
# query
x,y=pt(0,RAD+8)
A(f'<line x1="{OX}" y1="{OY}" x2="{x:.1f}" y2="{y:.1f}" stroke="{Y}" stroke-width="3.2" marker-end="url(#y)"/>')
lx,ly=pt(0,RAD+34); A(f'<text x="{lx:.1f}" y="{ly+6:.1f}" style="font-size:20px;fill:{Y}">query</text>')
A(f'<circle cx="{OX}" cy="{OY}" r="3.5" fill="{INK}"/>')
# boundary labels inside, along rays
def raylabel(rel,r,txt,col):
    x,y=pt(rel,r); A(f'<text x="{x:.1f}" y="{y:.1f}" class="c" style="font-size:14px;fill:{col}" transform="rotate({-(QA+rel):.1f} {x:.1f} {y:.1f})">{txt}</text>')
for d,txt,col in ((fd,"floor 0.70",PU),(gd,"gap 0.84",BL)):
    x,y=pt(d,RAD+34); A(f'<text x="{x:.1f}" y="{y+5:.1f}" class="c" style="font-size:15px;fill:{col}">{txt}</text>')

# margin notes, colour-linked
NX=572
def note(y,parts,size=17):
    spans="".join(f'<tspan style="fill:{c}">{t}</tspan>' if c else t for t,c in parts)
    A(f'<text x="{NX}" y="{y}" class="m" style="font-size:{size}px">{spans}</text>')
notes=[
 (196,[[("The ",None),("query",Y),(" is embedded",None)],[("too: one more arrow.",None)]]),
 (282,[[("Inside the ",None),("floor",PU),(", 0.70,",None)],[("a save is similar",None)],[("enough to count.",None)]]),
 (392,[[("The ",None),("gap",BL),(" keeps only",None)],[("saves within 0.08 of",None)],[("the ",None),("nearest",BL),(": 0.84 up.",None)]]),
 (502,[[("Between the two sit",None)],[("hubs",GR),(": generic saves",None)],[("near every query.",None)],[("The ",None),("floor",PU),(" alone",None)],[("would keep them.",None)]]),
]
for y,lines in notes:
    for i,l in enumerate(lines): note(y+i*24,l)

# the rule, as an equation with the same colours
EY=914
A(f'<line x1="48" y1="{EY-62}" x2="792" y2="{EY-62}" stroke="#32302d"/>')
A(f'<text x="420" y="{EY}" class="c" text-anchor="middle" style="font-size:22px">'
  f'<tspan style="fill:{BL}">keep</tspan>  ⇔  sim ≥ max(<tspan style="fill:{PU}">floor</tspan>, <tspan style="fill:{BL}">nearest</tspan> − <tspan style="fill:{BL}">gap</tspan>)</text>')
A(f'<text x="420" y="{EY+34}" class="n" text-anchor="middle">text embeddings: floor 0.70, gap 0.08 · image 0.58, 0.10 · passage 0.64, 0.10</text>')
A('</svg>')
open(sys.argv[1],"w").write("\n".join(o))
