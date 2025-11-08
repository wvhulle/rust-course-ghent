// Based on a template by https://github.com/zeroeightysix/tt-lectures

#import "@preview/touying:0.6.1": (
  config-colors, config-common, config-info, config-methods, config-page, config-store, meanwhile, only, pause,
  touying-slides, uncover, utils,
)
#import "@preview/codly:1.3.0": codly-init

// Import all theme components
#import "theme/colors.typ": primary-color, secondary-color, tertiary-color, text-color
#import "theme/slides.typ": new-section-slide, slide
#import "theme/components.typ": qa
#import "theme/code-fragments.typ": embed-qr-code, embed-url-code, init-code-fragments
#import "@preview/tiaoma:0.3.0": *
#import "@preview/codly:1.3.0": *
#import "theme/math-helpers.typ": *
#import "@preview/curryst:0.5.1": *
#let rust-course(
  aspect-ratio: "16-9",
  progress-bar: true,
  header: utils.display-current-heading(level: 2),
  header-right: self => utils.display-current-heading(level: 1),
  footer-columns: (25%, 1fr, 25%),
  footer-a: self => self.info.author,
  footer-b: self => [#{
      if self.info.short-title == auto { self.info.title } else { self.info.short-title }
    }  #place(right + horizon)[#text(fill: gray, style: "italic")[#link(
        "https://play.rust-lang.org/?version=stable&mode=debug&edition=2024",
      )[play.rust-lang.org]]#h(0.5em)]],
  footer-c: self => {
    h(1fr)
    utils.display-info-date(self)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
    h(1fr)
  },
  enable-qr-codes: false, // Set to true to enable QR code generation
  enable-diagrams: true, // Set to false to disable diagram rendering for faster compilation
  ..args,
  body,
) = {
  // Default heading numbering for presentations
  set heading(numbering: "1.")
  set text(size: 1.6em)

  show: codly-init.with()
  init-code-fragments()


  show raw.where(block: true): it => {
    if enable-qr-codes {
      embed-qr-code(it)
    } else {
      embed-url-code(it)
    }
  }


  show grid.where(columns: 2): set grid(column-gutter: 2em)
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        //
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: primary-color,
      secondary: secondary-color,
      tertiary: tertiary-color,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: text-color,
    ),
    // save the variables for later use
    config-store(
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )

  body
}

// Re-export commonly used functions for convenience
#import "theme/slides.typ": focus-slide, matrix-slide, new-section-slide, slide, title-slide
#import "theme/components.typ": error, info, large-center-text, legend, todo, warning
#import "theme/diagram-helpers.typ": *
#import "theme/colors.typ": accent, arrow-width, colors, node-outset, node-radius, stroke-width

