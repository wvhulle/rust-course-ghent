#import "dependencies.typ": (
  codly, codly-disable, codly-init, codly-reset, no-codly, qrcode,
)
#let url(it) = {
  let url = if ("rust", "rs").contains(it.lang) {
    (
      "https://play.rust-lang.org/?version=stable&mode=debug&edition=2024&code="
        + it.text.replace("&", "%26").replace(" ", "%20").replace("\n", "%0A")
    )
  } else {
    "google.com"
  }
  url
}

#let embed-url-code(it) = {
  let url = url(it)

  box(
    inset: 0pt,
    clip: true,
  )[
    #{
      it
      place(bottom + right, dx: -0.5em, dy: -0.5em)[
        #text(fill: gray)[#link(url)[_(playground link)_]]
      ]
    }
  ]
}


#let embed-qr-code(it) = {
  let url = url(it)

  box(
    inset: 0pt,
    clip: true,
  )[
    #{
      it
      place(bottom + right, dx: -0.5em, dy: -0.5em)[
        #link(url)[#qrcode(url, options: (
          scale: 0.8,
          fg-color: green.darken(40%),
        ))]
      ]
    }
  ]
}

#let init-code-fragments(
  qr-size: 1.2cm,
) = {
  // Default codly setup with custom lang-format for Rust to add QR codes
  codly(
    languages: (
      rust: (name: "rs", icon: "🦀", color: rgb("#CE412B")),
      python: (name: "Python", icon: "🐍", color: rgb("#3572A5")),
      javascript: (name: "JavaScript", icon: "JS", color: rgb("#F7DF1E")),
      bash: (name: "Bash", icon: "$", color: rgb("#4EAA25")),
    ),
    zebra-fill: rgb("#f5f5f5"),
    radius: 0.5em,
    lang-format: none,
  )
}
