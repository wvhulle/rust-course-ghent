// UI components and helpers

#import "colors.typ": accent, colors, node-radius, stroke-width as default-stroke-width
#import "@preview/touying:0.6.1": pause

// Shared implementation for titled boxes (warning, error, etc.)
#let titled-box(
  title: auto,
  default-title: "Notice",
  color: colors.operator,
  stroke-width: default-stroke-width,
  inset: 0.7em,
  radius: node-radius,
  content,
) = context {
  let show-title = if title == auto { true } else if title == false { false } else { true }
  let title-text = if title == auto { default-title } else if title == false { none } else { title }
  v(0.5em)
  if show-title and title-text != none {
    align(center, block(
      breakable: false,
      above: 1em,
      {
        rect(
          fill: color,
          stroke: accent(color) + stroke-width,
          inset: (top: inset + 0.4em, bottom: inset, left: inset, right: inset),
          radius: radius,
          content,
        )
        place(
          top + center,
          dy: -0.6em,
          box(
            rect(
              fill: color,
              stroke: accent(color) + stroke-width,
              inset: (x: 0.5em, y: 0.2em),
              radius: radius,
              text(weight: "bold")[#title-text],
            ),
          ),
        )
      },
    ))
  } else {
    block(
      above: 0.5em,
      rect(
        fill: color,
        stroke: accent(color) + stroke-width,
        inset: inset,
        radius: radius,
        content,
      ),
    )
  }
}

#let qa(question, answer) = {
  let q-box = rect(radius: 0.5em, inset: 0.5em, outset: 0em, fill: yellow.lighten(70%))[#question]
  let a-box = rect(radius: 0.5em, inset: 0.5em, outset: 0em, fill: green.lighten(70%))[#answer]
  let curved-arrow = curve(
    stroke: green,
    curve.move((0em, 0em)),
    curve.quad((0em, 1em), (1em, 1em)),
  )
  // v(0.4em)
  box({
    set par(spacing: 0pt)
    q-box

    v(0.2em)
    pause
    align(right, stack(dir: ltr, curved-arrow, a-box))
  })
}

#let warning(
  title: auto,
  color: colors.error,
  stroke-width: default-stroke-width,
  inset: 0.7em,
  radius: node-radius,
  content,
) = titled-box(
  title: title,
  default-title: "Warning",
  color: color,
  stroke-width: stroke-width,
  inset: inset,
  radius: radius,
  content,
)

#let error(
  title: auto,
  color: colors.error,
  stroke-width: default-stroke-width,
  inset: 0.7em,
  radius: node-radius,
  content,
) = titled-box(
  title: title,
  default-title: "Error",
  color: color,
  stroke-width: stroke-width,
  inset: inset,
  radius: radius,
  content,
)

#let info(
  title: auto,
  color: colors.pin,
  stroke-width: default-stroke-width,
  inset: 0.7em,
  radius: node-radius,
  content,
) = titled-box(
  title: title,
  default-title: "Info",
  color: color,
  stroke-width: stroke-width,
  inset: inset,
  radius: radius,
  content,
)

#let legend(items, vertical: false) = {
  align(center)[
    #grid(
      columns: if vertical { 1 } else { items.len() },
      rows: if vertical { items.len() } else { auto },
      column-gutter: 2em,
      row-gutter: if vertical { 1em } else { 0em },
      ..items
        .map(item => {
          (
            align(if vertical { left } else { center })[
              #box(width: 2em, height: 0.8em, rect(fill: item.color, stroke: accent(item.color)))
              #h(0.5em)
              #text(size: 0.7em)[#item.label]
            ],
          )
        })
        .flatten()
    )]
}


// TODO helper
#let todo(content: text(style: "oblique")[TODO]) = box(stroke: 2pt + red, content)

// Large centered text helper
#let large-center-text(content) = [
  #set text(72pt)
  #set align(center)
  #content
]

