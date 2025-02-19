#import "../template/main.typ" as ctu-lab-slides
#import ctu-lab-slides: *

#show: ctu-lab-slides.setup

#title-slide[
  Organizace předmětu a seznámení se s paralelizací
][
  Cvičení 1
]

#slide[
  = Osnova

  - Čím se budeme zabývat?
  - Hodnocení předmětu
  %%
  - Úvod do paralelního hardwaru a softwaru
]

#section-slide[Organizace předmětu]

#slide[
  = Důležité informace

  == Přednášející

  - Matěj Kafka #small[(paralelní část)]
  - Michal Jakob #small[(distribuovaná část)]

  == Cvičící

  - Petr Macejko
  - Jakub Dupák
  - Max Hollmann
  - Jáchym Herynek
  - David Milec
  - Adéla Kubíková

  == Stránky cvičení:

  https://pdv.pages.fel.cvut.cz/
]

#slide[
  = Čím se budeme zabývat?

  #slogan[
    #highlight("2", "1,3-", [ Paralelní ]) a #highlight("3-", "-2", [ Distribuované ]) výpočty
  ]

  #toolbox.side-by-side[
    #uncover("2-")[
      #frame[
        === Paralelní výpočty

        - *Jeden* výpočet provádí současně *více* vláken
        - Vlákna typicky sdílí pamět a výpočetní prostředky
        %%
        - Cíl:
          - Zrychlit výpočet úlohy

        _7 týdnů_
      ]
    ]
  ][
    #uncover("3-")[
      #frame[
        === Distribuované výpočty

        - Výpočet provádí současně více oddělených výpočetních uzlů #small[(často i geograficky)]
        %%
        - Cíle:
          - Zrychlit výpočet
          - #highlight("4", "-3", [ Robustnost výpočtu ])

        _6 týdnů_

      ]
    ]
  ]
]

#slide[
  = Docházka

  Docházka na cvičení není povinná.

  #comment[ _To ale neznamená, že byste na cvičení neměli chodit..._ ]

  - Budeme probírat látku, která se Vám bude hodit u úkolů a u zkoušky.
  - Dostanete prostor pro práci na semestrálních pracích.
  - Konzultace budou probíhat *primárně* na cvičeních.
  - Ušetříme Vám čas a nervy (nebo v to alespoň doufáme ;-)

  #footnote[
    #emoji.warning Pokud se na cvičení rozhodnete nechodit, budeme předpokládat, že probírané látce dokonale rozumíte.
    Případné konzultace v žádném případě nenahrazují cvičení!
  ]
]

#slide-focus[
  = Samostatná práce

  #slogan[
    Vyžadujeme *samostatnou* práci na všech úlohách.
  ]

  #important[
    #emoji.warning *Plagiáty jsou zakázané.*

    Nepřidělávejte prosím starosti nám, ani sobě.
  ]
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

```bash cmake <src dir> -B <build dir> -DCMAKE_BUILD_TYPE=Release```
]

Zde `<src dir>` je složka se souborem `CMakeLists.txt`.

#frame[
=== Kompilace

```bash cmake --build <build dir> ```
]

Zde `<build dir>` je složka s vygenerovanými soubory pro sestavení programu.

Nebo použijte IDE s dobrou podporou C++, například CLion (multiplatformní).

#v(2em)

#frame[
=== Cvičení
Vyzkoušejte na souboru `0hello.cpp`.
]
]

#slide[
  #frame[
    === Podpora C++20

    Vyzkoušejte, že vám funguje kompilace C++20 na souboru `0cpp20.cpp`. 

    Pokud se vám nepodaří sestavit program, zkuste si nainstalovat novější verzi kompilátoru do *7. cvičení*, kde budeme potřebovat některé nové vlastnosti C++20.

    Dnes smažte `0cpp20.cpp` z `CMakeLists.txt` a pokračujte dále.  
  ]
]

#slide[
  = Bylo, nebylo...

  == Pro připomenutí

  Cílem paralelních výpočtů je dosáhnout zvýšení výkonu

  #toolbox.side-by-side[
    #align(center + horizon, image("assets/single_thread.svg", width: 50%))
  ][
    == _von Neumannova architektura_
    - Jaké má nevýhody?
    - Jak bychom je mohli opravit?
    - A jak bychom dále mohli navýšit výkon procesoru?
  ]
]

#slide-items[
  = Moderní procesor

  #align(center)[
    #image("assets/modern_cpu.svg", width: 80%)
  ]
][
#frame[
=== Memory bandwidth

Otestujte vaši paměť pomocí kódu v `1memory.cpp`.
]
]

#slide(alignment: center)[
  = Moderní procesor

  #v(3em)
  #set text(size: 1.8em)
  #text(fill: rgb("#3f3d3d"))[*Paralelizace:*]
  #set list(marker: none, spacing: 1em)

  #one-by-one[][
    - #block(width: 100%, outset: 0.5em, fill: rgb("#c16a6a"))[Pipelining #small[(procesor)]]
  ][
    - #block(width: 100%, outset: 0.5em, fill: rgb("#5d9bc4"))[Vektorizace #small[(kompilátor)]]
  ][
    - #block(width: 100%, height: 1.2em, outset: 0.5em, fill: rgb("#9970a1"))[Vlákna #small[(Vy #emoji.face)]]
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

  #frame[
    === Cache-miss

    Pozorujete důsledky cache-missu na výkon programů:
    
    - `1memory.cpp`
    - `2matrix.cpp`.
  ]
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

#footnote[
  #link("https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:14,fontUsePx:'0',j:1,lang:c%2B%2B,selection:(endColumn:2,endLineNumber:3,positionColumn:2,positionLineNumber:3,selectionStartColumn:2,selectionStartLineNumber:3,startColumn:2,startLineNumber:3),source:'void+multiply(int+*+number,+int+multiplyBy)+%7B%0A*number+%3D+(*number)+*+multiplyBy%3B%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:gsnapshot,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'1',intel:'0',libraryCode:'0',trim:'1',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:c%2B%2B,libs:!(),options:'-O3',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+gcc+(trunk)+(Editor+%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4", "https://godbolt.org")
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
  #text(size: 1em)[Jaké máme možnosti, abychom dosáhli deterministického výsledku\ (_který pravděpodobně chceme_)?]
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

      Mějme procesor s $P$ jádry a úlohu, která při využití jednoho jádra trvá $t$ milisekund. Využijeme-li všech $P$ jader
      pro vyřešení úlohy, vyřešení úlohy zvládneme za $t/P$ milisekund.
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

  Mějme pole o 1,000,000 prvků. S každým prvkem pole máme za úkol 100× provést "magickou operaci" $x <- e^ln(x)$. Tuto
  úlohu lze dobře paralelizovat.


  ```cpp
    void magic_operation(std::vector<double>& array) {
        for (size_t i = 0; i < array.size(); i++) {
            for (size_t k = 0; k < 500; k++) {
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

```cpp
  void magic_operation(std::vector<double>& array) {
      for (size_t i = 0; i < array.size(); i++) {
          for (size_t k = 0; k < 500; k++) {
              array[i] = exp(log(array[i]));
          }
      }
  }
```
]

Proč jsme ale nedosáhli $P$-násobného zrychlení (kde $P$ je počet jader procesoru?). Vzpomeňte si na Amdahlův zákon.

$
  S = frac(1, s + frac(1-s, P))
$

Dokážete říct, co tvoří neparalelizovatelnou část programu? \
(vyžadující $s%$ času)
]

#slide[
= Exponenciální kluzavý proůměr

#align(center)[
  #image("assets/ema.svg", width: 80%)
]

$
  "EMA"_0 &= "price"_0 \
  "EMA"_i &= "price"_i * "k" + "EMA"_(i-1) * (1 - "k")
$

#footnote[  
  https://en.wikipedia.org/wiki/Exponential_smoothing
]
]

#slide[
= Exponenciální kluzavý průměr

#quiz(
  [
  === Je následující tvrzení pravdivé?

  Proces výpočtu exponenciálního kluzavého průměru je možné snadno paralelizovat.
  ],
  false,
  [
    Co nám dělá s paralelizací problémy?
  ],
  [
    Uvažujte množinu datových sad. Mohli bychom využít více jader v tomto případě?
  ],
)
]

