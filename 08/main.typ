#import "@preview/polylux:0.4.0": *
#import "../template/main.typ" as ctu-lab-slides
#import ctu-lab-slides: *

#show: ctu-lab-slides.setup

#title-slide[
  Paralelní maticové operace
][
  Cvičení 8
]

#slide[
  = Osnova

  - Paralelní maticové operace
  - Semestrální úloha
]

#section-slide[Paralelní maticové operace]

#slide-items[
  = Násobení vektorů

  Skalární součin vektorů $u$ a $v$ délky $n$ lze spočítat jako
  $ u times v = sum_(i=0)^(n-1) u[i] dot v[i] $

  Co když je mnoho prvků v obou vektorech nulových?
][
  #comment[
    #emoji.warning Potom je neefektivní jak samotné násobení, tak i vektorová reprezentace.
  ]
]

#slide-items[
  = Řídké vektory

  Vektory s *málo nenulovými hodnotami* lze reprezentovat kompaktněji!

  Místo toho, abychom si pamatovali všechny (i nulové) prvky, tak si pamatujeme pouze:

  - na jakých indexech jsou nenulové prvky
  - jaké hodnoty jsou na těchto indexech
][
  #v(1em)
  Např. vektor $v = (0,0,0,0,3,0,1,0,0,0,2)$ reprezentujeme pomocí \
  $v = { (4,3), (6,1), (10,2) }$
][
  #v(1em)
  Jak spočteme skalární součin vektorů $u$ a $v$?

  #table(
    stroke: none,
    columns: 5,
    align: center,
    [ #only(3, text(fill: red, sym.circle.filled)) ],
    [ #only(4, text(fill: red, sym.circle.filled)) ],
    [ #only("5-6", text(fill: red, sym.circle.filled)) ],
    [ #only("7-8", text(fill: red, sym.circle.filled)) ],
    [],
    [$(1,1)$],
    [$(2,5)$],
    [$(6,2)$],
    [$(8,2)$],
    [],
    [$(2,3)$],
    [$(4,3)$],
    [$(6,1)$],
    [$(7,2)$],
    [],
    [ #only("3-4", text(fill: green, sym.circle.filled)) ],
    [ #only(5, text(fill: green, sym.circle.filled)) ],
    [ #only(6, text(fill: green, sym.circle.filled)) ],
    [ #only(7, text(fill: green, sym.circle.filled)) ],
    [ #only(8, text(fill: green, sym.circle.filled)) ],
  )
]

#slide-items[
  = Násobení matice vektorem

  Součin matice A o rozměrech $m times n$ a vektoru $u$ délky $n$ lze spočítat jako
  $ A_u = (A_1 times u, A_2 times u, dots, A_m times u) $
  kde $A_i, i in [m]$ jsou jednotlivé řádky matice $A$.
][
  == Jak tento výpočet zparalelizovat?
][
  #image("assets/mmult.svg", width: 50%)

  Je nutné slévat částečné výsledky jednotlivých vláken. Jak na to?

]

#slide-items[
  = Vlastní redukce

  Standardní redukce jsou definované na jednoduchých proměnných.
  #important[
    Co když chceme agregovat výsledky ve složitější datové struktuře?
  ]
][
  #comment[ Deklarujeme si vlastní redukci! ]
][

```cpp
  #pragma omp declare reduction(name:type:expression) \
          initializer(expression)
```
][
#v(1em)
/ `name`: název vlastní redukce
/ `type`: typ, nad kterým je redukce definována (např. std::vector<int>)
/ `expression`: funkce, která se má vykonávat nad dvěma částečnými výsledky
][
#set list(marker: sym.arrow)

- Částečné výsledky jsou uložené v proměnných `omp_in` a `omp_out`
- Výsledek redukce uložíme zpět do proměnné `omp_out`
][
/ `initializer`: jaká má být počáteční hodnota lokální kopie redukované proměnné v každém vlákně (lokální proměnná = `omp_priv`)
]

#slide-items[
= Příklad vlastní redukce

```cpp
  void merge_elements(element_t& dest, element_t& in) {
    dest = gcd(dest, in);
  }

  #pragma omp declare reduction(merge : element_t : merge_elements) initializer(omp_priv = 0)

  element_t result;

  #pragma omp parallel for reduction(merge : result)
  for(int i = 0; i < size; i++) {
    // do something with result
  }
  ```
][
#frame[
=== Doimplementujte násobení matice s vektorem

Doimplementujte násobení matice s vektorem Doimplementujte tělo metody `multiply_parallel` v souboru `multiply.cpp`.
Vlastní redukci jsme vám již deklarovali. Redukce využívá funkci `merge`. Doimplementujte i tělo redukce (funkce `merge`).
Všechny vektory se kterými pracujete jsou řídké!
]
]

#section-slide[Semestrální úloha]

#slide[
  = Stavové prostory

  Diskrétní dynamické systémy mají různé *konfigurace* Mezi konfiguracemi lze přecházet pomocí akcí

  Jak takové systémy vypadají?

  #image("assets/pacman2.svg", width: 50%)
]

#slide[
  = Hanojské věže

  Přesouváme věže z disků z *počátečních* kolíků na *koncové*.

  - Jen jeden disk v jednom kroku
  - Větší disk nemůže být na menším
  \

  #image("assets/hanoi.svg", width: 50%)

  #footnote[#emoji.warning Doména je korektní, pokud $"DISCS" * "TOWERS" * ceil(log_2("RODS")) <= 64$]
]

#slide[
  = Loydův hlavolam ("sliding puzzle")

  Přesouváme X po poli abychom se dostali z počáteční konfigurace na setříděnou.

  - Jen jedno prohození v jednom kroku.
  - Prohodíme X s poličkem o jedno nahoře, dole, vlevo nebo vpravo.
  #v(1em)
  #image("assets/sp.svg", width: 50%)
  #v(1em)

  #footnote[#emoji.warning Doména je korektní pro rozměry pole $3 times 3$ a $4 times 4$]
]

#slide[
  = Splňování booleovských formulí ("SAT")

  Pro danou formuli v *konjunktivním normálním tvaru* hledáme ohodnocení, ve kterém bude *splněná*.
  $ (not x or not y) and y $

  - Přiřazení ohodnocení jen jedné proměnné v jednom kroku.
  - Přiřadíme hodnotu jakékoli proměnné s indexem větším než proměnná ohodnocená v minulém kroku.

  #v(2em)
  #image("assets/sat.svg", width: 50%)
  #v(2em)

  #footnote[
    #emoji.warning Doména je korektní, pokud $"NUM_VARS" <= 40$
  ]
]

#slide[
  = Bludiště

  Hledáme cestu z počáteční pozice na koncovou.

  - Pohybujeme se o jedno políčko v každém kroku.
  - Změníme pozici, pokud nám v cestě nebrání zeď.

  #v(2em)
  #image("assets/maze.svg", width: 90%)
  #v(2em)

  #footnote[#emoji.warning Doména je korektní, pokud $log_2("WIDTH" * "HEIGHT") >= 64$]
]

#slide[
  = Prohledávání do šířky (BFS)

    #for i in range(1, 16) {
      only(str(i))[
        #image("assets/bfs" + str(16 - i) + ".svg", width: 100%)
      ]
    }
    #only("16-")[#image("assets/bfs0.svg", width: 100%)]
    #v(8em)
    #only("16-")[
      #important[Optimální, ale (potenciálně) s exponenciální pamětí!]
    ]
]

#slide-items[
  = Prohledávání do hloubky (DFS)
  #for i in range(1, 8) {
    only(str(i))[#image("assets/dfs" + str(7 - i) + ".svg", width: 100%)]
  }
    #v(8em)
    #only("7")[
      #important[
        Malá paměťová náročnost, ale bez garancí!
      ]
    ]
]

#slide[
  = ID-DFS

  #important[
    Co když chceme jak garance,\
    tak malou paměťovou náročnost?
  ]

  #comment[Budeme prohledávat do *omezené* hloubky]
]

#slide-items[
  = ID-DFS

  #for i in range(1, 26) {
    only(i)[#image("assets/iddfs" + str(26 - i + 1) + ".svg", width: 100%)]
  }

  #only(26)[#image("assets/iddfs0.svg", width: 100%)]
  #v(8em)
  #only(26)[
    #important[
      V paměti máme pouze aktuální cestu :-)
    ]
  ]
]

#slide-items[
  = Co byste ještě měli vylepšit?

  Nechceme vás příliš ovlivňovat...

][
  - Některé uzly jsme navštěvovali mnohokrát (i na stejné cestě!) (Zkuste zabránit vstupování do stejných stavů -- v
    paralelní verzi možná budete muset dělat kompromisy...)
][

  - Nemusíte implementovat přesné verze těchto algoritmů (Například, v ID-DFS si můžete pamatovat o něco víc než jen
    aktuální cestu. Také můžete malé části stromu procházet pomocí BFS...)
][
  ... ale především po vás budeme chtít tyto algoritmy paralelizovat :-)
]

#slide-items[
  = Shared pointers

  Zejména v ID-DFS algoritmu je správná správa paměti nutností! \
  (Váš algoritmus musí být schopný běžet v prostředí s omezenou pamětí)
][
Dosud jste se pravděpodobně setkali zejména s *raw pointery* ; \
napříkad `state* s;`
][
  Veškerá zodpovědnost za správnou správu paměti by byla na vás :-(
]

#slide-items[
  = Shared pointers

  Naším cílem ale není zkoušet vás z toho, kdo je lepší programátor v C/C++...

  Proto správu paměti (částečně) přebíráme za vás!

  #h(1fr) Jak to děláme?

  #slogan[ C++11 shared pointers ]
]

#slide-items[
= Shared pointers

S RAII návrhovým vzorem jsme se už setkali u `std::unique_lock`.

```cpp
  template <typename lock_t>
  class unique_lock {
  private:
    lock_t& mutex;

  public:
    unique_lock(lock_t& mutex) : mutex(mutex) {
      mutex.lock();
    }

    ~unique_lock() {
      mutex.unlock();
    }
  };
  ```
][
  #important[
    Vlastnictví zámku je unikátní.
  ]
]

#slide-items[
= Shared pointers

Obdobně funguje i `std::unique_ptr` pro správu pointeru.

Paměť se uvolní okamžitě po zániku instance `std::unique_ptr`!

== Co když to ale nechceme?
][
- Instanci `std::unique_ptr` uložíme například do vektoru. Dále používáme raw pointer (získaný přes `ptr.get()`).\
  Paměť se ale uvolní po zániku vektoru, raw pointer přestane být validní!
][
- Důsledně budeme spravovat, kdo aktuálně pointer vlastní. Paměť zanikne, když ho nějaká funkce nikomu nepředá (pomocí `std::move`).

#comment[To je celkem dost pracné!]
][
- Použijeme `std::shared_ptr` a pointery předáváme jako kdyby to byly raw pointery.
]

#slide[
= Shared pointers

*Shared pointers* = jednoduchá automatická správa paměti (jednoduchý ,,garbage collector``)

- Každý shared pointer si drží počítadlo, kolik instancí `std::shared_ptr` na dané místo v paměti ukazuje
  - Při kopírování shared pointeru se počítadlo zvýší
  - Při rušení instance se počítadlo sníží
- Když počítadlo dospěje na nulu, paměť se dealokuje
]

#slide-items[
  = Shared pointers

  Při rozumné práci fungují výborně, ale...

  #slogan[
    #emoji.warning Pozor na cykly!!!
  ]

  #only("1")[#image("assets/sharedptr1.svg", width: 100%)]
][
  #only("2")[#image("assets/sharedptr2.svg", width: 100%)]
]

#slide[
= Shared pointer

Se shared pointery dokonce můžete provádět atomické operace:
```cpp
  // 'atomicka promenna'
  std::shared_ptr<const state>& concurrent_ptr = ...;

  // ocekavana hodnota:
  std::shared_ptr<const state> local_copy
                       = atomic_load(&concurrent_ptr);

  // hodnota k zapsani
  std::shared_ptr<const state> new_ptr = ...;

  while(...) {
    if(atomic_compare_exchange_strong(
            &concurrent_ptr, &local_copy, new_ptr)) {
      break;
    }
  }
  ```
]