#import "@preview/polylux:0.4.0": *
#import "template.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Paralení programování pro vícejádrové stroje s použitím OpenMP
][
  Cvičení 3
]

#slide[
  Minulé cvičení:

  #one-by-one[
    #slogan[
      "Vlákna a jejich synchronizace v C++ 11..."
    ]
  ][
    #v(2em)
    Programování vícevláknových aplikací ručně může být dřina. Proč znovu objevovat kolo, když mužeme použít hotové řešení?
  ][
    #v(2em)
    Dnešní cvičení:
    #slogan[
      OpenMP
    ]
  ]
]

#slide[
  = Osnova

  - Opakování z minulého cvičení
  - Úvod do OpenMP
  - Paralelní bloky se sdílenou pamětí a synchronizace
  - Redukce s OpenMP
  - Rozvrhování výpočtu v OpenMP
  \
  - Zadání druhé domácí úlohy
]

#quiz-link-slide("http://goo.gl/a6BEMb")

#new-section[Co je OpenMP?]

#slide-items[
  = OpenMP: Přehled

  - API pro psání vícevláknových aplikací se sdílenou pamětí
  - Sada directiv, proměnných prostředí a rutin pro kompilátor a programátory
  - Ulehčuje psaní vícevláknových aplikací v C/C++ a Fortran na většině platform s podporou většiny instrukčních sad a operačních systémů
][
  Jako základní referenční příručku můžete použít \ #link("https://msdn.microsoft.com/en-us/library/tt15eb9t.aspx").
]

#slide-items[
  = Otestujte si své prostředí

  #set list(marker: none, spacing: 1.25em)

  - `omp_get_num_procs()`
    - Počet procesorů, které OpenMP využívá v době volání funkce
  - `omp_get_num_threads()`
    - Počet vláken, které OpenMP využívá v době volání funkce
  - `omp_get_max_threads()`
    - Maximální počet vláken, které OpenMP může využít
  - `omp_in_parallel()`
    - Vrací nenulovou hodnotu, pokud jsme uvnitř paralelního bloku
  - `omp_get_nested()`
    - Vrací nenulu, pokud je povoleno vnořování paralelních bloků
][
  Detailní přehled metod s ukázkami na \ #link("https://msdn.microsoft.com/en-us/library/k1h4zbed.aspx").
]

#new-section[Cvičení: Numerická integrace]

#slide-center[
  = Numerická integrace

  #image("03/figs/integral.svg", width: 50%)

  ```cpp
  double integrate(
    std::function<double(double)> integrand,
    double a, double step_size, int step_count);
  ```
]

#slide-items[
  #frame[
    === Doimplementujte sekvenční verzi numerické integrace

    Doimplementujte tělo metody `integrate_sequential` v souboru `integrate.cpp`. Použijte obdélníkovou metodu, kdy jako "výšku" obdélníku použijete hodnotu funkce uprostřed intervalu.

    #set list(marker: none, spacing: 1.25em)

    - `integrand`
      - Funkce, kterou máte za úkol numericky zintegrovat
    - `a`
      - Dolní mez integrálu
    - `step_size`
      - Velikost kroku (šířka obdélníku)
    - `num_steps`
      - Počet kroků (horní mez je `a + step_size * step_count`)
  ]
][
  Jaké problémy budeme mít, pokud budeme chtít tento sekvenční kód paralelizovat?
]

#new-section[Alternativy k mutexům a atomickým proměným v OpenMP]

#slide-items[
  = `#pragma omp parallel`

  ```cpp
  int num_threads = 0;
  #pragma omp parallel
  {
    // Zde jsme vytvorili tym vlaken, ktera vykonavaji nasledujici kod
    num_threads += 1;
  }
  ```
][
  #important[
    Jaký bude výsledek?
  ]
]

#slide-items[
  = `#pragma omp critical` (``mutex'')

  ```cpp
  int num_threads = 0;
  #pragma omp parallel
  {
    // Zde muze byt vice vlaken soucasne...

    #pragma omp critical
    {
      // ..,ale inkrementaci provadi vzdy maximalne jedno vlakno
      num_threads += 1;
    }

    // Zde opet muze byt vice vlaken soucasne
  }
  ```
]

#slide-items[
  #frame[
    === Doimplementujte metodu `integrate_omp_critical`

    Doimplementujte metodu `integrate_omp_critical` v `integrate.cpp`. Využijte k tomu `#pragma omp parallel` a `#pragma omp critical`.

    _Tip:_ Po spuštění vláken v bloku `#pragma omp parallel` si můžete napočítat rozsahy indexů, které jednotlivá vlákna budou zpracovávat. Pro zjištění indexu aktuálního vlákna použijte metodu `omp_get_thread_num()`. Zjistit celkový počet vláken lze pomocí `omp_get_num_threads()`.
  ]
]

#slide[
  = `#pragma omp atomic`

  Na minulém cvičení jsme si ukázali, že mutexy mohou být pomalé. Opravdu pomalé.

  - Jednoduché operace nad jednou proměnnou lze řešit _hardwarovým_ zámkem -- provedením atomické operace

  #v(2em)

  #grid(columns: 2, gutter: 4em)[
    ```cpp
    int num_threads = 0;
    #pragma omp parallel
    {
      #pragma omp atomic
      num_threads += 1;
    }
    ```
  ][
    Ne všechny operace lze provést atomicky!

    Typicky pouze: `x++`, `x--`, `++x`, `--x` a `x OP= expr`, kde \
      #h(1em) `OP` $in$ {`+`, `-`, `*`, `/`, `&`, `^`, `|`, `<<`, `>>`}

    Pokud kompilátor nemá k dispozici danou atomickou operaci, použije záložní plán: mutex.
  ]
]

#slide-items[
  #frame[
    === Doimplementujte metodu `integrate_omp_atomic`

    Doimplementujte metodu `integrate_omp_atomic` v `integrate.cpp`. Místo kritické sekce využijte `#pragma omp atomic`. Jakého zrychlení touto úpravou dosáhneme?
  ]
]

#new-section[Redukce v OpenMP]

#slide-items[
  = Redukce v OpenMP

  To samé lze ale udělat elegantněji a efektivněji:

  ```cpp
  int num_threads = 0;
  #pragma omp parallel reduction(+:num_threads)
  {
    num_threads += 1;
  }
  ```

  OpenMP pak zajistí, že se částečné výsledky _lokálních_ proměnných `num_threads` po konci bloku posčítají

  #v(1em)

  Následující "operátory" jsou podporované (OpenMP verze 3+):

  - Aritmetické: `+`, `*`, `-`, `max`, `min`
  - Logické: `&`, `&&`, `|`, `||`, `^`
]

#slide-items[
  #frame[
    === Doimplementujte metodu `integrate_omp_reduction`

    Doimplementujte tělo metody `integrate_omp_reduction` v souboru `integrate.cpp`. Nahraďte `#pragma omp atomic` redukcí.
  ]
]

#slide[
  = `#pragma omp parallel for`

  Kód s redukcí lze napsat ještě jednodušeji.

  Rozsahy pro vlákna si nemusíme počítat ručně a můžeme práci nechat na OpenMP:

  ```cpp
  double acc = 0.0;

  #pragma omp parallel for reduction(+:acc) //schedule(static)
  for(int i = 0 ; i < step_count ; i++) {
    const double cx = a + (2*i + 1.0)*step_size/2;
    acc += integrand(cx)*step_size;
  }
  return acc;
  ```
]

#slide[
  #important[
    Proč při integraci funkce $"f" paren.l x paren.r = x$ dosahujeme většího zrychlení?
  ]

  Výpočet $"f" paren.l x paren.r = x$ trvá konstantní dobu a práce je tak mezi vlákna rozdělena rovnoměrně.

  To neplatí o funkci $"f" paren.l x paren.r = integral_(0)^(0.001x^2) "sin" paren.l p paren.r dif  p$, kterou aproximujeme numerickou integrací s proměnlivým počtem kroků.
]

#slide-items[
  #frame[
    === Doimplementujte metodu `integrate_omp_for_dynamic`

    Doimplementujte tělo metody `integrate_omp_for_dynamic`. Statické rozvrhování `schedule(static)` nahraďte dynamickým `schedule(dynamic)`. Jaký má tato volba dopad na rychlost numerické integrace $"f" paren.l x paren.r = x$ a $"f" paren.l x paren.r = integral_(0)^(0.001x^2) "sin" paren.l p paren.r dif  p$?
  ]
]

#slide-items[
  = `#pragma omp parallel for schedule`

  Obecná syntaxe (možno použít i další parametry jako např. `reduction`):

  ```cpp
  #pragma omp parallel for schedule(type[,chunk_size])
  ```

  `chunk_size` udává minimální velikost bloku, se kterým se plánuje, např:

  ```cpp
  #pragma omp parallel for schedule(dynamic,16)
  ```

  zajistí, že si vlákno po dokončení práce na aktuálním bloku dat řekne o další blok o 16 prvcích.

][
  #set list(marker: none, spacing: 1.25em)

  - `dynamic`
    - Vlákna si _dynamicky_ alokují bloky, které mají počítat
  - `guided`
    - _Dynamické_ plánování, kde se velikost bloků v průběhu výpočtu zmenšuje
  - `static`
    - Každé vlákno má svůj blok přiřazený napevno (když skončí dříve, musí čekat)
  - `runtime`
    - Rozhodnuto za běhu na základě nastavení prostředí \ (`export OMP_SCHEDULE="dynamic, 100"`)
]

#new-section[Zadání druhé domácí úlohy]

#slide[
  = Paralelní suma vektoru

  V 2. domácí úloze si budete moct vyzkoušet, že úspěšnost různých způsobů paralelizace *závisí* do značné míry na *vstupních datech*.

  #v(1.5em)

  Na vstupu dostanete vektor složený z vektorů náhodně generovaných čísel.

  #v(1.5em)

  Vaším úkolem je čísla v každém vektoru *sečíst* a tento součet vložit do vektoru s řešením na index odpovídající pořadí vektoru, který jste sčítali.
]

#slide[
  = Paralelní suma vektoru

  Doimplementujte metody v `SumsOfVectors.cpp` a zajistěte, že

  - Výpočet sum je paralelní a každá metoda vrací korektní výsledky
  - Metody využívají požadované způsoby paralelizace

  #v(1.5em)

  Za spravné výsledky na každé ze *čtyř* datových sad dostanete 2b.
]