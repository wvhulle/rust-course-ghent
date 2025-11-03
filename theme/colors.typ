// Color definitions and utilities

#let primary-color = green.darken(60%)
#let secondary-color = green.darken(40%)
#let tertiary-color = green.darken(30%)
#let text-color = black.transparentize(20%)

#let stroke-width = 0.5pt
#let arrow-width = 1pt
#let node-radius = 5pt
#let node-outset = 2pt

#let accent(color, sat: 90%, dark: 25%) = {
  let rgb_color = rgb(color)
  let comps = rgb_color.components()
  let r = comps.at(0)
  let g = comps.at(1)
  let b = comps.at(2)

  if calc.abs(r - g) < 5% and calc.abs(g - b) < 5% {
    rgb_color.darken(dark)
  } else {
    rgb_color.saturate(sat).darken(dark)
  }
}

#let colors = (
  title: color.rgb("#bfeddc"),
  code: color.rgb("#fcfcf5"),
  neutral: color.hsl(0deg, 0%, 90.98%),
  stream: color.hsl(200deg, 65%, 92%),
  operator: color.hsl(45.16deg, 100%, 88.76%),
  data: color.hsl(330.91deg, 57.89%, 95%),
  state: color.hsl(140deg, 34.88%, 84.71%),
  action: color.hsl(21.25deg, 68.57%, 86.27%),
  pin: color.hsl(240deg, 100%, 93.92%),
  error: color.hsl(0deg, 100%, 90.39%),
)
