#import "../template/main.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#slide[
  #text(size: 1.3em)[
    *Úvod do B4B36PDV*
  ]

  Organizace předmětu a seznámení se s paralelizací

  #metropolis.divider

  #set text(size: .8em)
  B4B36PDV -- Paralelní a distribuované výpočty \
  FEL ČVUT
]

#slide[
  = Osnova

  - Čím se budeme zabývat?
  - Hodnocení předmětu
  \
  - Úvod do paralelního hardwaru a softwaru
]

#section-slide[Organizace předmětu]

#slide[
  = Důležité informace

  *Přednášející:* Matěj Kafka, Michal Jakob

  *Cvičící:* Petr Macejko, Jakub Dupák, Max Hollmann, Jáchym Herynek, David Milec

  *Stránky cvičení:* #link("https://pdv.pages.fel.cvut.cz/")
]

#slide[
  = Čím se budeme zabývat?

  #align(center)[
    #text(size: 1.2em)[
      #highlight("2", "1,3-", [ Paralelní ]) a #highlight("3-", "-2", [ Distribuované ]) výpočty
    ]
    #v(1em)
  ]

  #grid(columns: (1fr, 1fr), gutter: 1em, align: top, [
    #uncover("2-")[
      #frame[
        === Paralelní výpočty

        - *Jeden* výpočet provádí současně *více* vláken
        - Vlákna typicky sdílí pamět a výpočetní prostředky
        \
        - Cíl: Zrychlit výpočet úlohy
        \
        - (7 týdnů)
      ]
    ]
  ], [
    #uncover("3-")[
      #frame[
        === Distribuované výpočty

        - Výpočet provádí současně více oddělených výpočetních uzlů #small[(často i geograficky)]
        \
        - Cíle:
          - Zrychlit výpočet
          - #highlight("4", "-3", [ Robustnost výpočtu ])
        \
        - (6 týdnů)
      ]
    ]
  ])
  #v(1fr)
]

#slide[
  = Hodnocení předmětu

  // #block(title: "Paralelní výpočty", [
  //   - 5 malých programovacích úloh #h(1fr) 10 bodů
  //   - Semestrální práce #h(1fr) 12 bodů
  // ])

  // #block(title: "Distribuované výpočty", [
  //   - 2 malé úlohy #h(1fr) 4 body
  //   - Semestrální práce #h(1fr) 14 bodů
  // ])

  // #block(title: "Praktická zkouška", [
  //   - Praktická část zkoušky (min. 10b) #h(1fr) 20 bodů\
  //     (Vyřešení zadaného problému za použití paralelizace.)
  //   - Teoretická část zkoušky (min. 20b) #h(1fr) 40 bodů
  // ])

  #frame[
    === Paralelní výpočty

    - 5 malých programovacích úloh #h(1fr) 10 bodů
    - Semestrální práce #h(1fr) 12 bodů
    #v(0.2em)
    - Praktická zkouška #h(1fr) 20 bodů
  ]

  #frame[
    === Distribuované výpočty

    - 2 malé úlohy #h(1fr) 4 body
    - Semestrální práce #h(1fr) 14 bodů
    #v(0.2em)
    - Praktická zkouška #h(1fr) 20 bodů
  ]

  #frame[
    === Praktická

    - Praktická část zkoušky (min. 10b) #h(1fr) 20 bodů\
      #small[(Vyřešení zadaného problému za použití paralelizace.)]
    - Teoretická část zkoušky (min. 20b) #h(1fr) 40 bodů
  ]

  V semestru musíte získat *alespoň 20 bodů* #h(1fr) Celkem: 100 bodů
]

#slide[
  = Hodnocení předmětu

  #align(center)[
    #text(size: 1.2em)[
      Vyžadujeme *samostatnou* práci na všech úlohách.
    ]
  ]

  #v(2em)

  #emoji.warning *Plagiáty jsou zakázané.* Nepřidělávejte prosím starosti nám, ani sobě.
]

#slide[
  = Hodnocení předmětu

  #text(size: 1.2em)[
    Docházka na cvičení není povinná.
  ]

  #align(right)[
    To ale neznamená, že byste na cvičení neměli chodit...
  ]

  #v(2em)

  - Budeme probírat látku, která se Vám bude hodit u úkolů a u zkoušky.
  - Dostanete prostor pro práci na semestrálních pracích.
  - Konzultace budou probíhat *primárně* na cvičeních.
  - Ušetříme Vám čas a nervy (nebo v to alespoň doufáme ;-)

  #v(5em)
  #line(length: 100%)
  #set text(size: .8em)
  #emoji.warning Pokud se na cvičení rozhodnete nechodit, budeme předpokládat, že probírané látce dokonale rozumíte.
  Případné konzultace v žádném případě nenahrazují cvičení!
]

#slide[
  = Na čem budeme stavět?

  #item-by-item[
    - Programování v jazyce C/C++ (B0B36PRP)
      - Základy programování v jazyce C/C++
      - Kompilace programů v jazyce C/C++
      - Základy objektového programování (znalost C++11 výhodou)
    - Technologické předpoklady paralelizace (B4B36OSY)
      - Vlákna a jejich princip
      - Metody synchronizace a komunikace vláken
    - Základní znalost fungování počítače a procesoru (B4B35APO)
    - Znalost základních algoritmů (B4B33ALG)
  ]
]

#section-slide[Opakování]

#slide[
= Kompilace programů v C/C++ s pomocí Cmake

#frame[
=== Vygenerování build scriptů

```bash
    cmake <src dir>
    ```
]

Zde `<src dir>` je složka se souborem `CMakeLists.txt`.

#frame[
=== Kompilace

```bash
    cmake --build <build dir>
    ```
]

Zde `<build dir>` je složka s vygenerovanými soubory pro sestavení programu.

Nebo použijte IDE s dobrou podporou C++, například CLion (multiplatformní) nebo Visual Studio (Windows).
]

#slide[
  = Bylo, nebylo...

  Pro připomenutí: Cílem paralelních výpočtů je dosáhnout zvýšení výkonu

  #v(3em)

  #toolbox.side-by-side[
    #align(center, image("assets/single_thread.svg", width: 50%))
  ][
    *_von Neumannova architektura_*
    - Jaké má nevýhody?
    - Jak bychom je mohli opravit?
    - A jak bychom dále mohli navýšit výkon procesoru?

    #v(1em)
    #see-file("1memory.cpp")
  ]
]

#slide[
  = Moderní procesor

  #align(center)[
    #image("assets/modern_cpu.svg", width: 80%)
  ]
]

#slide[
  = Moderní procesor

  #align(center)[
    #set text(size: 1.8em)
    #text(fill: rgb("#3f3d3d"))[*Paralelizace:*]
    #set list(marker: none)

    #one-by-one[][
      - #block(width: 100%, outset: 0.5em, fill: rgb("#c16a6a"))[Pipelining #small[(procesor)]]
    ][
      - #block(width: 100%, outset: 0.5em, fill: rgb("#5d9bc4"))[Vektorizace #small[(kompilátor)]]
    ][
      - #block(width: 100%, height: 1.2em, outset: 0.5em, fill: rgb("#9970a1"))[Vlákna #small[(Vy #emoji.face)]]
    ]
  ]
]

#slide[
  = Moderní procesor

  Možné "nástrahy" použití moderního procesoru s více jádry a cache:

  - Komunikace s pamětí je stále pomalá (problém *cache-miss*)
  - Přístup ke sdíleným datům více vlákny (*true sharing*)
  - Udržování koherence cache může být drahé (*false sharing*)
  - ... a jiné
]

#slide[
  = Cache-miss

  #see-file("1memory.cpp")

  #v(2em)

  #see-file("2matrix.cpp")
]

#slide[
= True sharing

```c
  void multiply(int* number, int multiplyBy) {
    *number = (*number) * multiplyBy;
  }
  ```

#v(1.5em)
Předpokládejme `int number = 1;` a mějme dvě vlákna:

- Vlákno 1: `multiply(&number,2)`
- Vlákno 2: `multiply(&number,3)`

Co bude v proměnné `number` po skončení obou vláken?
]

#slide[
= True sharing

#block(width: 100%)[
#set text(size: 1.2em)
#set align(center)

```c
  void multiply(int * number, int multiplyBy) {
    *number = (*number) * multiplyBy;
  }
  ```

#v(1em)↓#v(1em)

```x86
  imul esi, DWORD PTR [rdi]
  mov DWORD PTR [rdi], esi
  ret
  ```
]

#v(1.5em)
#align(right)[
  #emoji.eye #link("http://godbolt.org")
]
]

#slide[

= True sharing

#v(1em)

#grid(align: top, columns: (1fr, 1fr))[
=== Vlákno 1

```x86 mov esi, 2```

#only("4-5")[#v(4em)]

```x86 imul esi, DWORD PTR [rdi]```

#only("6-7")[#v(2em)]

#only("8-")[#v(4.5em)]

```x86 mov DWORD PTR [rdi], esi```

```x86 ret```
][
=== Vlákno 2

```x86 mov esi, 3```

#only("2-3")[#v(4em)]

#only("6-")[#v(1.5em)]

```x86 imul esi, DWORD PTR [rdi]```

```x86 mov DWORD PTR [rdi], esi```

```x86 ret```
]

#align(center)[
#v(1fr)
#text(size: 1.2em)[
#only("3,5")[Výsledek:\ `number = 6`]
#only("7")[Výsledek:\ `number = 3`]
#only("9")[Výsledek:\ `number = 2`]
]
]
#only(
  "10",
)[
  #text(size: 1em)[Jaké máme možnosti, abychom dosáhli deterministického výsledku\ (který pravděpodobně chceme)?]
]
#v(1fr)
]

#slide[
  = False-sharing

  Moderní procesor pracuje s pamětí *po blocích*, které se mapují do cache.
  - I když vlákna nepracují se stejnými proměnnými, mohou chtít pracovat se stejným *blokem*.
  - Jeden blok se pak nutně musí nacházet v cachích různých jader -- a ve více kopiích

  #align(center)[
    #only("1")[
      #image("assets/false_sharing_1.svg", width: 80%)
    ]
    #only("2")[
      #image("assets/false_sharing_2.svg", width: 80%)
    ]
    #only("3")[
      #image("assets/false_sharing_3.svg", width: 80%)
    ]
    #only("4")[
      #image("assets/false_sharing_4.svg", width: 80%)
    ]
    #only("5")[
      #image("assets/false_sharing_5.svg", width: 80%)
    ]
  ]

  #uncover("5")[
    - Ale právě té komunikaci s pamětí jsme se chtěli použitím cache vyhnout!
  ]
]

#slide[
  = False-sharing

  #align(center)[
    #see-file("3false_sharing.cpp")
  ]
]

#section-slide[Paralelizace v praxi]

#slide[
  = Paralelizace v praxi

  #quiz(
    [
      === Je následující tvrzení pravdivé?

      Mějme procesor s $p$ jádry a úlohu, která při využití jednoho jádra trvá $T$ milisekund. Využijeme-li všech $p$ jader
      pro vyřešení úlohy, vyřešení úlohy zvládneme za $T/p$ milisekund.
    ],
    false,
    [
      Proč? Zkuste vymyslet co možná nejvíce důvodů, proč tomu tak není.
    ],
    [
      O úlohách, kde toto tvrzení platí říkáme, že jsou tzv. _lineární_ nebo také _embarassingly parallel_. Takových úloh ale
      v praxi potkáme velmi málo.
    ],
  )
]

#slide[
= Paralelizace v praxi

#quiz(
  [
  === Je následující tvrzení pravdivé?

  Mějme pole o 1,000,000 prvků. S každým prvkem pole máme za úkol 100x provést "magickou operaci" $x <- e^ln(x)$. Tuto
  úlohu lze dobře paralelizovat.

  ```c
                  void magic_operation(double * array) {
                    for(unsigned int i = 0 ; i < 1000000 ; i++) {
                      for(unsigned int k = 0 ; k < 500 ; k++) {
                        array[i] = exp(log(array[i]));
                      }
                    }
                  }
                ```
  ],
  true,
  [
  Jednotlivé výpočty hodnot `array[i]` na sobě nezávisí a můžeme je rozložit mezi různá vlákna a dosáhnout téměř
  lineárního nárůstu výkonu.
  ],
  [
    A nebo bychom si mohli vzpomenout, že $ln x$ a $e^x$ jsou inverzní funkce. Ale to bychom neměli co paralelizovat ;-)
  ],
)
]

#slide[
= Paralelizace v praxi

#frame[
=== Je následující tvrzení pravdivé?

Mějme pole o 1,000,000 prvků. S každým prvkem pole máme za úkol 100× provést "magickou operaci" $x <- e^ln(x)$. Tuto
úlohu lze dobře paralelizovat.

```c
      void magic_operation(std::vector<double>& array) {
          for (ptrdiff_t i = 0; i < (ptrdiff_t)array.size(); i++) {
              for (size_t k = 0; k < 500; k++) {
                  array[i] = exp(log(array[i]));
              }
          }
      }
    ```
]

Proč jsme ale nedosáhli $s$-násobného zrychlení (kde $s$ je počet jader procesoru?). Vzpomeňte si na Amdahlův zákon.

$
  S = frac(1, (1-p) + frac(p, s))
$

Dokážete říct, co tvoří neparalelizovatelnou část programu? \
(vyžadující $(1-p)%$ času)
]

#slide[
= Šifra `PDVCrypt`

#align(center)[
  #image("assets/pdvcrypt.svg", width: 70%)
]

Jeden krok dešifrování:

$
  s_i <- [ s_i + p_1 times "secret"( overbrace(s_[ i-2..i+2 ], "EQRBF") ) ] mod abs(Sigma)
$
$
  i <- [ i + p_2 times "secret"( s_[ i-2..i+2 ] ) ] mod abs(s)
$

... opakován $N$-krát

#v(3em)

*Úkol:* Doimplementujte dešifrovací pravidlo do metody `decrypt` v souboru `PDVCrypt.cpp`.
]

#slide[
= Šifra `PDVCrypt`

#quiz(
  [
  === Je následující tvrzení pravdivé?

  Proces dešifrování řetězce zašifrovaného pomocí `PDVCrypt` lze snadno paralelizovat.
  ],
  false,
  [
    Proč paralelní verze dešifrovacího algoritmu vůbec nefunguje?
  ],
  [
    Uvažujte množinu zašifrovaných řetězců, které máte za úkol dešifrovat. Mohli bychom využít více jader v tomto případě?
  ],
)
]

