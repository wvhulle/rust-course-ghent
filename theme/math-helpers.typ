// Mathematical notation helpers and proof-tree support

#import "@preview/showybox:2.0.4" as mod-showybox
#import "@preview/curryst:0.5.1" as curryst: rule
#import "colors.typ": accent, colors, primary-color, secondary-color, stroke-width, text-color

// Small caps helper
#let smc(content) = text(font: "Linux Libertine", smallcaps[#content])

// Type theory notation
#let stlc = smallcaps[stlc]
#let cx = "cx"
#let Cx = "Cx"
#let Sb(d, g) = $op(sans("Sb"))(#d, #g)$
#let Tm(g, a) = $op(sans("Tm"))(#g, #a)$
#let Ty(g) = $op(sans("Ty"))(#g)$
#let _type = type
#let type = "type"
#let suc(n) = $op("suc")(#n)$
#let snd(n) = $op("snd")(#n)$
#let fst(n) = $op("fst")(#n)$
#let fat(v) = $bold(upright(#v))$

// Showybox configuration
#let showybox-frame-style = (
  title-color: secondary-color.lighten(25%),
  body-color: secondary-color.transparentize(80%),
  border-color: color.luma(100%, 0%),
)

#let showybox = mod-showybox.showybox.with(
  frame: showybox-frame-style,
  body-style: (
    color: text-color,
  ),
)

#let definition(of-thing, content) = {
  showybox(
    frame: showybox-frame-style + (border-color: primary-color),
    title-style: (
      boxed-style: (
        anchor: (y: horizon, x: center),
      ),
    ),
    title: of-thing.replace(regex("^\w"), m => upper(m.text)),
    {
      show of-thing: v => underline[*#v*]
      content
    },
  )
}

// Inference rule styling
#let inf-style(body) = {
  show "zero": $mono("zero")$
  show "suc": $bold("suc")$
  show "type": $sans("type")$
  show "fst": $bold("fst")$
  show "snd": $bold("snd")$
  show "cx": $sans("cx")$
  show "Cx": $sans("Cx")$
  show "[p]": $[fat(p)]$

  body
}

#let proof-tree = curryst.prooftree.with(min-premise-spacing: 2em, stroke: 0.8pt)

#let inf-rules(
  inset: 10%,
  ..formulas,
) = box(inset: (left: inset, right: inset), width: 1fr, par(justify: true, leading: 1.25em, linebreaks: "simple", {
  set text(overhang: false)
  set align(center)

  let lb = linebreak(justify: true)

  formulas.pos().map(f => if f == () { lb } else { box(inf-style(proof-tree(f))) }).join(" ")
  lb
}))

