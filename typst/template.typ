// This theme is inspired by https://github.com/matze/mtheme
// The Polylux-port was originally performed by https://github.com/Enivex

#import "@preview/polylux:0.4.0": *

#let bright = rgb("#eb811b")
#let brighter = rgb("#d6c6b7")

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
}

#let outline = toolbox.all-sections((sections, _current) => {
  enum(tight: false, ..sections)
})

#let progress-bar = toolbox.progress-ratio(ratio => {
  set grid.cell(inset: (y: .03em))
  grid(columns: (ratio * 100%, 1fr), grid.cell(fill: bright)[], grid.cell(fill: brighter)[])
})

#let new-section(name) = slide({
  set page(header: none, footer: none)
  show: pad.with(20%)
  set text(size: 1.1em, weight: 600)
  name
  toolbox.register-section(name)
  progress-bar
})

#let focus(body) = context {
  set page(header: none, footer: none, fill: text.fill, margin: 2em)
  set text(fill: page.fill, size: 1.5em)
  set align(center)
  body
}

#let divider = line(length: 100%, stroke: .1em + bright)

#let frame(body) = {
  let bg = rgb(242, 242, 242)
  let title-bg = rgb(220, 220, 220)
  let padding = (top: 0.3em, left: .5em, right: .5em, bottom: .5em)

  show heading.where(level: 3): it => {
    set text(weight: 500)
    box(it, outset: padding, fill: title-bg, width: 100%)
  }

  block(width: 100%, fill: bg, inset: padding, radius: 4pt, [
    #body
  ])
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
  emoji.eye
  h(.25em)
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

  v(2em)

  if explanation != [] {
    uncover("3-", {
      explanation
    })
  }
}

#let small(body) = {
  text(body, size: 0.9em)
}

#let title-slide(title, subtitle) = slide({
  set page(header: none, footer: none)
  text(size: 1.25em, weight: 500, title)

  v(0em)

  subtitle

  divider

  text(size: .6em)[
    B4B36PDV -- Paralelní a distribuované výpočty FEL ČVUT
  ]
})

#let quiz-link-slide(url) = slide({
  show: focus

  link(url)
})

#let slide-items(start: 1, ..items) = slide({
  for (idx, item) in items.pos().enumerate() {
    uncover((beginning: start + idx), item)
    v(1em)
  }
})

#let slide-center(body) = slide({
  align(center, body)
})

#let slogan(body) = align(center, { text(size: 1.5em, body) })
#let important(body) = align(center, { v(2em); text(size: 1.125em, body) })


#let setup(footer: none, text-font: "Fira Sans", math-font: "Fira Math", code-font: "Fira Code", text-size: 18pt, body) = {
  set page(
    paper: "presentation-4-3",
    fill: white.darken(2%),
    margin: (top: 4em, left: 4em, right: 4em, rest: 1em),
    footer: the-footer(footer),
    header: slide-title-header,
  )
  set text(
    font: text-font,
    // weight: "light", // looks nice but does not match Fira Math
    size: text-size,
    fill: rgb("#23373b"), // dark teal
  )
  set strong(delta: 100)
  show math.equation: set text(font: "New Computer Modern Math")
  show raw: set text(font: code-font)
  set align(horizon)
  show emph: it => text(weight: 500, it.body)
  show heading.where(level: 1): _ => none
  set list(tight: true, spacing: 0.8em)
  show "•": text.with(weight: 900)
  show hide: it => {
    set list(marker: none)
    set enum(numbering: n => [])

    it
  }
  set raw(syntaxes: "nasm.sublime-syntax")

  show link: it => {
    set text(font: code-font)
    it
  }

  show image: it => {
    align(center, it)
  }

  body
}

