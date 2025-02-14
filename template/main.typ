
// This theme is inspired by https://github.com/matze/mtheme
// The Polylux-port was originally performed by https://github.com/Enivex

#import "@preview/polylux:0.4.0"
#import polylux: *

#let bright = rgb("#eb811b")
#let brighter = rgb("#d6c6b7")

/// Helper functions

#let slide-title-header = toolbox.next-heading(h => {
  show: toolbox.full-width-block.with(fill: text.fill, inset: 1.1em)
  set text(fill: page.fill)
  strong(h)
})

#let the-footer(content) = {
  set text(size: 0.8em)
  show: pad.with(.5em)
  set align(bottom)
  context text(fill: text.fill.lighten(40%), content)
  h(1fr)
  toolbox.slide-number
  h(-60pt)
}

#let outline = toolbox.all-sections((sections, _current) => {
  enum(tight: false, ..sections)
})

#let progress-bar = toolbox.progress-ratio(ratio => {
  set grid.cell(inset: (y: .03em))
  grid(columns: (ratio * 100%, 1fr), grid.cell(fill: bright)[], grid.cell(fill: brighter)[])
})

#let divider = line(length: 100%, stroke: .1em + bright)

#let focus(body) = context {
  set page(header: none, footer: none, fill: text.fill, margin: 2em)
  set text(fill: page.fill, size: 1.5em)
  set align(center + horizon)
  body
}

/// Slide functions

#let title-slide(title, subtitle) = polylux.slide({
  set page(header: none, footer: none)
  set align(horizon)

  text(size: 1.25em, weight: 500, title)

  v(0em)

  subtitle

  divider

  text(size: .6em)[
    B4B36PDV -- Paralelní a distribuované výpočty \
    FEL ČVUT
  ]
})

#let section-slide(name) = polylux.slide({
  set page(header: none, footer: none)
  set align(horizon)
  show: pad.with(left: 20%, right: 20%, top: 0%, bottom: 20%)
  set text(size: 1.1em, weight: 600)
  name
  toolbox.register-section(name)
  progress-bar
})

#let slide(alignment: left, body) = polylux.slide({
  v(0.5em)
  align(alignment, body)
})

#let slide-center(body) = slide(alignment: center, body)

#let slide-focus(body) = polylux.slide({
  v(1fr)
  body
  v(2fr)
})

#let slide-items(start: 1, ..items) = slide({
  for (idx, item) in items.pos().enumerate() {
    uncover((beginning: start + idx), item)
    v(1em, weak: true)
  }
})

#let quiz-link-slide(url) = polylux.slide({
  show: focus

  link(url)
})

/// Element functions

#let slogan(body) = align(center, {
  v(1em)
  text(size: 1.3em, weight: 500, body)
  v(2em, weak: true)
})

#let important(body) = align(center, {
  v(1em)
  text(size: 1.125em, body)
  v(2em, weak: true)
})

#let small(body) = {
  text(body, size: 0.9em)
}

#let rule = {
  v(1em, weak: true)
  line(length: 100%, stroke: 1pt + rgb("#434343"))
}

#let frame(body) = {
  let bg = rgb(242, 242, 242)
  let title-bg = rgb(220, 220, 220)

  v(1.5em, weak: true)

  show heading.where(level: 3): it => {
    set text(weight: 500)
    box(it, outset: (top: 0.3em, left: 0.75em, right: .75em, bottom: .6em), fill: title-bg, width: 100%)
    v(1.125em, weak: true)
  }

  block(
    width: 100%,
    fill: bg,
    inset: (top: 0em, left: 0.75em, right: .75em, bottom: .5em),
    radius: 4pt,
    { body; v(0.5em) },
  )
}

#let highlight(highlited, normal, body) = {
  only(highlited, {
    set text(fill: bright)
    body
  })
  only(normal, {
    body
  })
}

#let see-file(file) = {
  $=>$
  h(.5em)
  text(font: "Fira Code", size: 0.8em, file)
}

#let quiz(assignement, correct, answer, explanation) = {
  frame(assignement)

  uncover("2-", {
    if correct {
      text(fill: green, weight: 500, "Tvrzení je pravdivé.")
      answer
    } else {
      text(fill: rgb("#ba3b35"), weight: 500, "Tvrzení není pravdivé.")
      answer
    }
  })

  v(1em)

  if explanation != [] {
    uncover("3-", {
      explanation
    })
  }
}

#let comment(body) = {
  v(1em, weak: true)
  set text(style: "italic")
  align(right, small(body))
  v(1.5em, weak: true)
}

#let footnote(body) = {
  v(1fr)
  rule
  v(-0.5em)
  small(body)
  v(2em)
}

#let setup(body) = {
  set page(
    paper: "presentation-4-3",
    fill: white.darken(2%),
    margin: (top: 4em, left: 4em, right: 4em, rest: 1em),
    footer: the-footer(""),
    header: slide-title-header,
  )
  set text(
    font: "Fira Sans",
    weight: 400,
    size: 18pt,
    fill: rgb("#23373b"),
    tracking: 0.2pt,
    spacing: 0.3em,
    top-edge: "ascender",
    bottom-edge: "baseline",
    alternates: true,
  )
  set par(leading: 0.5em, spacing: 1.125em, linebreaks: "optimized")
  show math.equation: set text(font: "New Computer Modern Math")
  show raw: it => text(font: "Fira Code", ligatures: false, size: 1.125em, it)
  show raw.where(block: true): it => {
    v(2em, weak: true)
    it
    v(1em, weak: true)
  }

  set raw(syntaxes: "nasm.sublime-syntax")

  show strong: set text(weight: 300)
  set list(spacing: 0.5em, indent: 0.5em)

  // Special syntax for separating adjacent lists
  show "%%": v(0pt)

  show heading.where(level: 1): _ => none
  show heading.where(level: 2): it => {
    set text(size: 0.75em, weight: 600)
    v(1em)
    it
    v(0.5em)
  }
  show "•": text.with(weight: 900)
  show hide: it => {
    set list(marker: none)
    set enum(numbering: n => [])

    it
  }

  show link: it => {
    set text(font: "Fira Code")
    it
  }

  show image: it => {
    pad(top: 1em, bottom: 1em, align(center, it))
  }

  show terms: it => {
    set list(marker: none)
    it
  }

  body
}

