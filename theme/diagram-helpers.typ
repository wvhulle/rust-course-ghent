// Diagram helpers using Fletcher and CeTZ

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, hide, node, shapes
#import "@preview/touying:0.6.1": touying-reducer
#import "@preview/cetz:0.4.2": canvas, draw
#import "colors.typ": (
  accent, arrow-width as default-arrow-width, colors, node-outset as default-node-outset,
  node-radius as default-node-radius, stroke-width as default-stroke-width,
)

// Touying bindings for CeTZ and Fletcher
#let cetz-canvas = touying-reducer.with(reduce: canvas, cover: draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: diagram, cover: hide.with(bounds: true))

// Fletcher diagram helpers
#let spaced-diagram(
  stroke-width: default-stroke-width,
  node-radius: default-node-radius,
  arrow-width: default-arrow-width,
  node-outset: default-node-outset,
  ..args,
  body,
) = fletcher-diagram(
  node-stroke: stroke-width,
  node-corner-radius: node-radius,
  edge-stroke: arrow-width,
  node-outset: node-outset,
  ..args,
  body,
)

#let accented-node(
  pos,
  color: none,
  name: none,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  shape: auto,
  content,
) = node(
  pos,
  content,
  fill: if color == none { none } else { color },
  stroke: if color == none { none } else { accent(color) + stroke-width },
  outset: outset,
  shape: shape,
  name: name,
)

#let stream-node(
  pos,
  name,
  color: colors.stream,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  body,
) = accented-node(pos, color: color, name: name, stroke-width: stroke-width, outset: outset, body)

#let emoji-node(
  pos,
  color,
  name,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  inset: -1pt,
  content,
) = node(
  pos,
  text(size: 2.5em, content),
  fill: if color == none { none } else { color },
  stroke: if color == none { none } else { accent(color) + stroke-width },
  outset: outset,
  inset: inset,
  shape: shapes.circle,
  name: name,
)

#let title-node(
  pos,
  fill: none,
  stroke: none,
  outset: default-node-outset,
  content,
) = node(
  pos,
  content,
  outset: outset,
  fill: fill,
  stroke: stroke,
)

#let call-node(
  pos,
  color,
  name,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  content,
) = accented-node(pos, color: color, name: name, stroke-width: stroke-width, outset: outset, content)

#let result-node(
  pos,
  color,
  name,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  content,
) = accented-node(pos, color: color, name: name, stroke-width: stroke-width, outset: outset, content)

#let state-node(
  pos,
  title,
  desc,
  color,
  name,
  stroke-width: default-stroke-width,
  title-size: 0.7em,
  desc-size: 0.6em,
  outset: default-node-outset,
) = node(
  pos,
  stack(
    dir: ttb,
    spacing: 0.5em,
    text(size: title-size, weight: "bold")[#title],
    text(size: desc-size, style: "italic")[#desc],
  ),
  fill: color,
  stroke: accent(color) + stroke-width,
  outset: outset,
  name: name,
)

#let workflow-step(
  pos,
  num,
  title,
  items,
  color,
  name,
  stroke-width: default-stroke-width,
  text-size: 0.6em,
  outset: default-node-outset,
) = node(
  pos,
  align(left, text(size: text-size, [
    *#num. #title*
    #for item in items [
      - #item
    ]
  ])),
  fill: color,
  stroke: accent(color) + stroke-width,
  outset: outset,
  name: name,
)

#let layer(
  pos,
  name,
  label,
  desc,
  examples,
  color: colors.operator,
  stroke-width: default-stroke-width,
  label-size: 1em,
  desc-size: 0.7em,
  examples-size: 0.6em,
  outset: default-node-outset,
) = {
  node(
    pos,
    name: name,
    fill: color,
    stroke: accent(color) + stroke-width,
    outset: outset,
    stack(
      dir: ttb,
      spacing: 0.6em,
      text(weight: "bold", size: label-size, label),
      text(size: desc-size, style: "italic", desc),
      text(size: examples-size, examples.join(" • ")),
    ),
  )
}

#let queue-item(
  pos,
  consumed,
  name,
  color: colors.neutral,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  content,
) = node(
  pos,
  if consumed { [#strike[#content]] } else { content },
  outset: outset,
  fill: if consumed { color.lighten(90%) } else { color },
  stroke: accent(colors.neutral) + stroke-width,
  shape: shapes.rect,
  name: name,
)

#let data-item(
  pos,
  name,
  color: colors.data,
  stroke-width: default-stroke-width,
  outset: default-node-outset,
  content,
) = node(
  pos,
  content,
  outset: outset,
  fill: color,
  stroke: accent(color) + stroke-width,
  shape: shapes.circle,
  name: name,
)

#let accented-edge(
  from,
  to,
  ..args,
  label: none,
  color: none,
  stroke-width: default-stroke-width,
  label-size: 0.6em,
) = {
  let positional-args = args.pos()
  let named-args = args.named()

  let mark = if positional-args.len() > 0 { positional-args.at(0) } else { "->" }

  edge(
    from,
    to,
    if label != none { text(size: label-size)[#label] },
    mark,
    stroke: if color != none { accent(color) + default-arrow-width } else { stroke-width },
    ..named-args,
  )
}

#let queue-link(
  from,
  to,
  label,
  color,
  stroke-width: default-stroke-width,
  ..args,
) = edge(
  from,
  to,
  text(size: 6pt)[#label],
  "--",
  stroke: accent(color) + stroke-width,
  ..args,
)

// CeTZ canvas helpers
#let styled-circle(
  draw,
  center,
  color,
  radius: 0.5,
  stroke-width: default-stroke-width,
  body,
) = {
  draw.circle(
    center,
    radius: radius,
    fill: color,
    stroke: accent(color) + stroke-width,
  )
  if body != none and body != [] {
    draw.content(
      (center.at(0), center.at(1) + radius + 0.15),
      text(weight: "bold", body),
      anchor: "center",
    )
  }
}

#let accented-rect(
  draw,
  from,
  to,
  color,
  stroke-width: default-stroke-width,
  radius: none,
  content,
) = {
  draw.rect(
    from,
    to,
    fill: color,
    stroke: accent(color) + stroke-width,
    radius: radius,
  )
  if content != none {
    let center-x = (from.at(0) + to.at(0)) / 2
    let top-y = calc.max(from.at(1), to.at(1)) + 0.15
    draw.content((center-x, top-y), [#content], anchor: "south")
  }
}

#let accented-triangle(
  draw,
  p1,
  p2,
  p3,
  color,
  stroke-width: default-stroke-width,
  label-size: 0.8em,
  content,
) = {
  draw.merge-path(fill: color, stroke: accent(color) + stroke-width, {
    draw.line(p1, p2)
    draw.line((), p3)
    draw.line((), p1)
  })
  if content != none {
    let center-x = (p1.at(0) + p2.at(0) + p3.at(0)) / 3
    let center-y = (p1.at(1) + p2.at(1) + p3.at(1)) / 3
    draw.content((center-x, center-y), text(size: label-size)[#content], anchor: "center")
  }
}

#let styled-line(
  draw,
  from,
  to,
  color,
  stroke-width: default-stroke-width,
  mark: none,
) = {
  draw.line(
    from,
    to,
    stroke: accent(color) + stroke-width,
    mark: mark,
  )
}

#let styled-content(
  draw,
  pos,
  color,
  anchor: "center",
  background: none,
  padding: 0.2,
  content,
) = {
  if background != none {
    draw.content(
      pos,
      box(
        fill: background,
        inset: padding * 1em,
        radius: 0.2em,
        text(weight: "bold")[#content],
      ),
      anchor: anchor,
    )
  } else {
    draw.content(
      pos,
      [#content],
      anchor: anchor,
    )
  }
}

#let hexagon(
  draw,
  center,
  size,
  color: white,
  stroke-width: default-stroke-width,
  label,
) = {
  let stroke-color = accent(color)
  let radius = size / 2
  let (cx, cy) = center
  let radius = size / 2

  let vertices = ()
  for i in range(6) {
    let angle = i * 60deg
    let x = cx + radius * calc.cos(angle)
    let y = cy + radius * calc.sin(angle)
    vertices.push((x, y))
  }

  if color != none {
    draw.merge-path(fill: color, stroke: none, {
      for i in range(6) {
        let vertex = vertices.at(i)
        if i == 0 {
          draw.line(vertex, vertex)
        } else {
          draw.line((), vertex)
        }
      }
      draw.line((), vertices.at(0))
    })
  }

  for i in range(6) {
    let start = vertices.at(i)
    let end = vertices.at(calc.rem(i + 1, 6))
    draw.circle(start, radius: 0.08, fill: stroke-color, stroke: none)
    draw.line(start, end, stroke: stroke-color + stroke-width)
  }
  if label != none {
    draw.content((center.at(0), center.at(1) + radius + 0.05), text[#label], anchor: "center")
  }
}

// Timeline entry drawing helper for history slides
#let draw-timeline-entry(y, year, event, description, reference, ref-url, color) = {
  import draw: *
  rect(
    (1, y - 0.3),
    (3, y + 0.3),
    fill: color,
    stroke: accent(color) + default-stroke-width,
    radius: default-node-radius,
  )
  content((2, y), text(size: 0.7em, weight: "bold", year), anchor: "center")

  content((3.5, y + 0.2), text(size: 0.8em, weight: "bold", event), anchor: "west")
  content((3.5, y - 0.03), text(size: 0.6em, description), anchor: "west")
  content(
    (3.5, y - 0.24),
    link(ref-url, text(size: 0.6em, style: "italic", fill: accent(colors.stream), reference)),
    anchor: "west",
  )

  line((0.8, y), (1, y), stroke: accent(colors.neutral) + default-stroke-width)
}

// Arrow drawing helper for fused/unfused stream visualization
#let fuse-arrow(multiple: false, fused: false, color) = {
  cetz-canvas(length: 1.8cm, {
    import draw: *
    let arrow-width = 2 * default-arrow-width
    if multiple {
      if fused {
        line((-0.8, 0), (0.6, 0), stroke: accent(color) + arrow-width)
        line((0.8, -0.3), (0.8, 0.3), stroke: accent(color) + (arrow-width))
      } else {
        line((-0.8, 0), (0.8, 0), stroke: accent(color) + arrow-width, mark: (end: "barbed"))
      }
      for i in range(if fused { 4 } else { 3 }) {
        let dash-x = -0.6 + i * 0.4
        line((dash-x, -0.15), (dash-x, 0.15), stroke: accent(color) + (arrow-width))
      }
    } else {
      line((-0.8, 0), (0.3, 0), stroke: accent(color) + arrow-width)
      line((0, -0.2), (0, 0.2), stroke: accent(color) + (arrow-width * 1.5))
      if fused {
        line((0.3, 0), (0.6, 0), stroke: accent(color) + arrow-width)
        line((0.8, -0.3), (0.8, 0.3), stroke: accent(color) + (arrow-width))
      } else {
        line((0.3, 0), (0.8, 0), stroke: accent(color) + arrow-width, mark: (end: "barbed"))
      }
    }
  })
}
