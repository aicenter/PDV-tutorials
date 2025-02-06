#import "@preview/polylux:0.4.0": *
#import "template.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Paralelní maticové operace
][
  B4B36PDV – Paralelní a distribuované výpočty
]

#slide[
  = Osnova

  - Paralelní maticové operace
  - Semestrální úloha
]

#new-section[Paralelní maticové operace]

#slide-items[
  = Násobení vektorů

  Skalární součin vektorů $u$ a $v$ délky $n$ lze spočítat jako
  $ u times v = sum_(i=0)^(n-1) u[i] dot v[i] $
][
  #important[
    Co když je mnoho prvků v obou vektorech nulových?
  ]
][
  #emoji.warning Potom je neefektivní jak samotné násobení, tak i vektorová reprezentace.
]

#slide-items[
  = Řídké vektory

  Vektory s *málo nenulovými hodnotami* lze reprezentovat kompaktněji! Místo toho, abychom si pamatovali všechny (i
  nulové) prvky, tak si pamatujeme pouze:
  - na jakých indexech jsou nenulové prvky
  - jaké hodnoty jsou na těchto indexech
][
  Např. vektor $v = (0,0,0,0,3,0,1,0,0,0,2)$ reprezentujeme pomocí
  $v = { (4,3), (6,1), (10,2) }$
][
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
  #important[
    Jak tento výpočet zparalelizovat?
  ]
][
  #image("08/figs/mmult.svg", width: 50%)

  Je nutné slévat částečné výsledky jednotlivých vláken. Jak na to?

]

#slide-items[
  = Vlastní redukce

  Standardní redukce jsou definované na jednoduchých proměnných.
  #important[
    Co když chceme agregovat výsledky ve složitější datové struktuře?
  ]
][
  #h(1fr)Deklarujeme si vlastní redukci!
][

```cpp
  #pragma omp declare reduction(name:type:expression) \
          initializer(expression)
```
][
  - name = název vlastní redukce
  - type = typ, nad kterým je redukce definována (např. std::vector<int>)
  - expression = funkce, která se má vykonávat nad dvěma částečnými výsledky
][
#set list(marker: sym.arrow)

- Částečné výsledky jsou uložené v proměnných `omp_in` a `omp_out`
- Výsledek redukce uložíme zpět do proměnné `omp_out`
][
- initializer = jaká má být počáteční hodnota lokální kopie redukované proměnné v každém vlákně (lokální proměnná = `omp_priv`)
]

#slide-items[
= Příklad vlastní redukce

```cpp
  void merge_elements(element_t& dest, element_t& in) {
    dest = gcd(dest, in);
  }
  ...
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

#new-section[Semestrální úloha]

#slide[
  = Stavové prostory

  Diskrétní dynamické systémy mají různé *konfigurace* Mezi konfiguracemi lze přecházet pomocí akcí

  Jak takové systémy vypadají?

  #image("08/figs/pacman2.svg", width: 50%)
]

#slide[
  = Hanojské věže

  Přesouváme věže z disků z *počátečních* kolíků na *koncové*.

  - Jen jeden disk v jednom kroku
  - Větší disk nemůže být na menším
  \

  #image("08/figs/hanoi.svg", width: 50%)

  #emoji.warning Doména je korektní, pokud $"DISCS" * "TOWERS" * ceil(log_2("RODS")) <= 64$
]

#slide[
  = Loydův hlavolam ("sliding puzzle")

  Přesouváme X po poli abychom se dostali z počáteční konfigurace na setříděnou.

  - Jen jedno prohození v jednom kroku.
  - Prohodíme X s poličkem o jedno nahoře, dole, vlevo nebo vpravo.
  #v(1em)
  #image("08/figs/sp.svg", width: 50%)
  #v(1em)

  #emoji.warning Doména je korektní pro rozměry pole $3 times 3$ a $4 times 4$
]

#slide[
  = Splňování booleovských formulí ("SAT")

  Pro danou formuli v *konjunktivním normálním tvaru* hledáme ohodnovení, ve kterém bude *splněná*.
  $ (not x or not y) and y $

  - Přiřazení ohodnocení jen jedné proměnné v jednom kroku.
  - Přiřadíme hodnotu jakékoli proměnné s indexem větším než proměnná ohodnocená v minulém kroku.

  #v(2em)
  #image("08/figs/sat.svg", width: 50%)
  #v(2em)

  #emoji.warning Doména je korektní, pokud $"NUM_VARS" <= 40$
]

#slide[
  = Bludiště

  Hledáme cestu z počáteční pozice na koncovou.

  - Pohybujeme se o jedno políčko v každém kroku.
  - Změníme pozici, pokud nám v cestě nebrání zeď.

  #v(2em)
  #image("08/figs/maze.svg", width: 90%)
  #v(2em)

  #emoji.warning Doména je korektní, pokud $log_2("WIDTH" * "HEIGHT") >= 64$
]

#slide-items[
  = Prohledávání do šířky (BFS)

  #only("1")[#image("08/figs/bfs15.svg", width: 100%)]
][
  #only("2")[#image("08/figs/bfs14.svg", width: 100%)]
][
  #only("3")[#image("08/figs/bfs13.svg", width: 100%)]
][
  #only("4")[#image("08/figs/bfs12.svg", width: 100%)]
][
  #only("5")[#image("08/figs/bfs11.svg", width: 100%)]
][
  #only("6")[#image("08/figs/bfs10.svg", width: 100%)]
][
  #only("7")[#image("08/figs/bfs9.svg", width: 100%)]
][
  #only("8")[#image("08/figs/bfs8.svg", width: 100%)]
][
  #only("9")[#image("08/figs/bfs7.svg", width: 100%)]
][
  #only("10")[#image("08/figs/bfs6.svg", width: 100%)]
][
  #only("11")[#image("08/figs/bfs5.svg", width: 100%)]
][
  #only("12")[#image("08/figs/bfs4.svg", width: 100%)]
][
  #only("13")[#image("08/figs/bfs3.svg", width: 100%)]
][
  #only("14")[#image("08/figs/bfs2.svg", width: 100%)]
][
  #only("15")[#image("08/figs/bfs1.svg", width: 100%)]
][
  #only("16-")[#image("08/figs/bfs0.svg", width: 100%)]

  Optimální, ale (potenciálně) s exponenciální pamětí!
]

#slide-items[
  = Prohledávání do hloubky (DFS)

  #only("1")[#image("08/figs/dfs6.svg", width: 100%)]
][
  #only("2")[#image("08/figs/dfs5.svg", width: 100%)]
][
  #only("3")[#image("08/figs/dfs4.svg", width: 100%)]
][
  #only("4")[#image("08/figs/dfs3.svg", width: 100%)]
][
  #only("5")[#image("08/figs/dfs2.svg", width: 100%)]
][
  #only("6")[#image("08/figs/dfs3.svg", width: 100%)]
][
  #only("7")[#image("08/figs/dfs1.svg", width: 100%)]
][
  #only("8")[#image("08/figs/dfs0.svg", width: 100%)]
  Malá paměťová náročnost, ale bez garancí!
]

#slide[
  = ID-DFS

  #important[
    Co když chceme jak garance,\
    tak malou paměťovou náročnost?
  ]

  #v(2em)

  #h(1fr) Budeme prohledávat do *omezené* hloubky
]

#slide-items[
  = ID-DFS

  #only("1")[#image("08/figs/iddfs26.svg", width: 100%)]
][
  #only("2")[#image("08/figs/iddfs25.svg", width: 100%)]
][
  #only("3")[#image("08/figs/iddfs24.svg", width: 100%)]
][
  #only("4")[#image("08/figs/iddfs25.svg", width: 100%)]
][
  #only("5")[#image("08/figs/iddfs23.svg", width: 100%)]
][
  #only("6")[#image("08/figs/iddfs25.svg", width: 100%)]
][
  #only("7")[#image("08/figs/iddfs22.svg", width: 100%)]
][
  #only("8")[#image("08/figs/iddfs21.svg", width: 100%)]
][
  #only("9")[#image("08/figs/iddfs20.svg", width: 100%)]
][
  #only("10")[#image("08/figs/iddfs21.svg", width: 100%)]
][
  #only("11")[#image("08/figs/iddfs19.svg", width: 100%)]
][
  #only("12")[#image("08/figs/iddfs21.svg", width: 100%)]
][
  #only("13")[#image("08/figs/iddfs22.svg", width: 100%)]
][
  #only("14")[#image("08/figs/iddfs18.svg", width: 100%)]
][
  #only("15")[#image("08/figs/iddfs17.svg", width: 100%)]
][
  #only("16")[#image("08/figs/iddfs18.svg", width: 100%)]
][
  #only("17")[#image("08/figs/iddfs16.svg", width: 100%)]
][
  #only("18")[#image("08/figs/iddfs18.svg", width: 100%)]
][
  #only("19")[#image("08/figs/iddfs22.svg", width: 100%)]
][
  #only("20")[#image("08/figs/iddfs15.svg", width: 100%)]
][
  #only("21")[#image("08/figs/iddfs14.svg", width: 100%)]
][
  #only("22")[#image("08/figs/iddfs13.svg", width: 100%)]
][
  #only("23")[#image("08/figs/iddfs12.svg", width: 100%)]
][
  #only("24")[#image("08/figs/iddfs13.svg", width: 100%)]
][
  #only("25")[#image("08/figs/iddfs11.svg", width: 100%)]
][
  #only("26")[#image("08/figs/iddfs13.svg", width: 100%)]
][
  #only("27")[#image("08/figs/iddfs14.svg", width: 100%)]
][
  #only("28")[#image("08/figs/iddfs10.svg", width: 100%)]
][
  #only("29")[#image("08/figs/iddfs9.svg", width: 100%)]
][
  #only("30")[#image("08/figs/iddfs10.svg", width: 100%)]
][
  #only("31")[#image("08/figs/iddfs8.svg", width: 100%)]
][
  #only("32")[#image("08/figs/iddfs10.svg", width: 100%)]
][
  #only("33")[#image("08/figs/iddfs14.svg", width: 100%)]
][
  #only("34")[#image("08/figs/iddfs15.svg", width: 100%)]
][
  #only("35")[#image("08/figs/iddfs7.svg", width: 100%)]
][
  #only("36")[#image("08/figs/iddfs6.svg", width: 100%)]
][
  #only("37")[#image("08/figs/iddfs5.svg", width: 100%)]
][
  #only("38")[#image("08/figs/iddfs6.svg", width: 100%)]
][
  #only("39")[#image("08/figs/iddfs4.svg", width: 100%)]
][
  #only("40")[#image("08/figs/iddfs6.svg", width: 100%)]
][
  #only("41")[#image("08/figs/iddfs7.svg", width: 100%)]
][
  #only("42")[#image("08/figs/iddfs3.svg", width: 100%)]
][
  #only("43")[#image("08/figs/iddfs2.svg", width: 100%)]
][
  #only("44")[#image("08/figs/iddfs3.svg", width: 100%)]
][
  #only("45")[#image("08/figs/iddfs0.svg", width: 100%)]

  V paměti máme pouze aktuální cestu :-)
]

#slide[
  = Co byste ještě měli vylepšit?

  Nechceme vás příliš ovlivňovat...

  Některé uzly jsme navštěvovali mnohokrát (i na stejné cestě!) (Zkuste zabránit vstupování do stejných stavů -- v
  paralelní verzi možná budete muset dělat kompromisy...)

  Nemusíte implementovat přesné verze těchto algoritmů (Například, v ID-DFS si můžete pamatovat o něco víc než jen
  aktuální cestu. Také můžete malé části stromu procházet pomocí BFS...)

  ... ale především po vás budeme chtít tyto algoritmy paralelizovat :-)
]

#slide[
= Shared pointers

Zejména v ID-DFS algoritmu je správná správa paměti nutností! (Váš algoritmus musí být schopný běžet v prostředí s
omezenou pamětí)

Dosud jste se pravděpodobně setkali zejména s *raw pointery* ; napříkad `state* s;`

Veškerá zodpovědnost za správnou správu paměti by byla na vás :-(
]

#slide-items[
  = Shared pointers

  Naším cílem ale není zkoušet vás z toho, kdo je lepší programátor v C/C++...

  Proto správu paměti (částečně) přebíráme za vás!

  #h(1fr) Jak to děláme?

#slogan[  C++11 shared pointers]
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
]]

#slide-items[
= Shared pointers

Obdobně funguje i `std::unique_ptr` pro správu pointeru.

Paměť se uvolní okamžitě po zániku instance `std::unique_ptr`!

#important[
  Co když to ale nechceme?
]
#v(2em)
][
- Instanci `std::unique_ptr` uložíme například do vektoru. Dále používáme raw pointer (získaný přes `ptr.get()`). Paměť se
  ale uvolní po zániku vektoru, raw pointer přestane být validní!
][
- Důsledně budeme spravovat, kdo aktuálně pointer vlastní. Paměť zanikne, když ho nějaká funkce nikomu nepředá (pomocí `std::move`).

#h(1fr) To je celkem dost pracné!
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

  #only("1")[#image("08/figs/sharedptr1.svg", width: 100%)]
][
  #only("2")[#image("08/figs/sharedptr2.svg", width: 100%)]
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

#slide[
= Sekvenční IDDFS

#frame[
=== Doimplementujte metodu `iddfs`

Doimplementujte metodu `iddfs`
Doimplementujte tělo metody `iddfs`, která bude vykonávat sekvenční prohledávání do hloubky s definovanou maximální
hloubkou (kterou budete iterativně zvyšovat, dokud nenarazíte na cíl). Vyzkoušejte si práci se sdílenými ukazateli a s
doménovými metodami `is_goal()` a `next_states()`.
]
]