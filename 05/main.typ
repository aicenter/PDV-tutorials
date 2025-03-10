#import "@preview/polylux:0.4.0": *
#import "../template/main.typ" as ctu-lab-slides
#import ctu-lab-slides: *

#show: ctu-lab-slides.setup

#title-slide[
  Dekompoziční techniky
][
  Cvičení 5
]

#slide-items[
  = Osnova

  - Opakování z minulého cvičení
  \
  - Datová dekompozice se zařezáváním
  - Explorativní dekompozice
  - Rekurzivní dekompozice
  \
  - Zadání čtvrté domácí úlohy
]

#section-slide[Opakování z minulého cvičení]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Jakým způsobem bude následující kód proveden?

```c
int a = getCurrentValue();
int b = compute(); // casove narocna funkce
int c = getCurrentValue();
if (a < b){
  a.compare_exchange_strong(c, b);
}
```

== Možné odpovědi:
- Kód nelze zkompilovat
- Do A se vždy uloží B
- Do A se uloží C, pokud B není rovno C
- Do C se uloží A, pokud A není rovno B
- Do A se uloží B, pokud A není rovno C
- Kód vrací chybu, pokud A není rovno C
]

#slide[
= V čem může být rozdíl po ukončení výpočtu následujících dvou funkcí?

```c
void compute_1(){
  node * null_ptr = nullptr;
  node * a = getMainNode();
  if(a == null_ptr){
    if(getMainNode().compare_exchange_strong
      (null_ptr, getNewNode())){
        return;
    }
  }
  std::cout << a->value << std::endl;
}

void compute_2(){
  node * null_ptr = nullptr;
  node * a = getMainNode();
  if(a == null_ptr){
    if(getMainNode().compare_exchange_strong
      (a, getNewNode())){
        return;
    }
  }
  std::cout << a->value << std::endl;
}
```
]

#section-slide[Cvičení: Problém $3n+1$]

#slide-items[
  = Problém $3n+1$ (Collatzův problém)
  Collatzova posloupnost je definovaná následovně (pro $n in bb(N)$):

  $
    f(n) = cases(frac(n, 2) & "pro n sudé", 3n + 1 & "pro n liché"
    )
  $

  Má se za to, že tato sekvence vždy dosáhne *1* (_Collatz conjecture_). \
  Po kolika krocích se tak ale stane?
][
  #h(1fr) Collatzova funkce $C(n)$ \
  #h(1fr) např. $C(5)=5$, $C(16)=4$
]

#slide-items[
  = Problém $3n+1$ (Collatzův problém)
  Úkol 1: Máme zadanou konečnou podmnožinu přirozených čísel $X in bb(N)$. \ Jaké je minimum funkce $C(n)$ na množině $X$?

  $
    min_(n in X) C(n)
  $
][
  #important[
    Jak výpočet optima paralelizovat?
  ]
][
  #important[
    Jak paralelní výpočet zrychlit? #small[Musíme vždy generovat celé sekvence?]
  ]
][
#frame[
=== Doimplementujte metodu `findmin_parallel`

Doimplementujte metodu `findmin_parallel` v souboru `1early_exit.cpp` pro paralelní nalezení minima funkce $C(n)$ na
množině $X$ (reprezentované ve vektorem data).

Udržujte si dosud nalezené optimim pro zařezávání nepotřebných výpočtů $C(n)$ (tj. ve chvíli, kdy daný výpočet
prokazatelně vede k suboptimálnímu řešení).
]
]

#slide-items[
  = Problém $3n+1$ (Collatzův problém)

  Úkol 2: Nalezněte číslo $n in bb(N)$ takové, že $C(n) >= k$.
][

Sekvenčně je to jednoduché:
```cpp
  unsigned long i = 1;
  while(collatz(i) >= k) i++;
  ```

Jak tento výpočet zparalelizujeme?][
  == Čím se tento problém liší od předchozího?
][
  Každé vlákno dokáže rozhodout o nalezení výsledku. Jak upravíme kód pro ukončení výpočtu?
]

#slide-items[
= OpenMP cancellation

OpenMP nabízí možnost zastavení všech vláken v paralelním bloku pomocí direktivy:

```cpp #pragma omp cancel```
][
Pro použití této funkce je nutné nastavit prostředí `OMP_CANCELLATION = true`.

#comment[
  K zamyšlení: proč není tato funkce automaticky zapnuta?
]
]
#slide-items[
= Jak na to?

```c
#pragma omp parallel
#pragma omp for
for (...){
    if (condition){
      #pragma omp cancel for
    }
}
```
][
```c
#pragma omp parallel
{
  while(true){
   #pragma omp cancellation point parallel
    if (condition){
    #pragma omp cancel parallel
    }
  }
}
```

#footnote[
#emoji.warning Nutné nastavit v prostředí `OMP_CANCELLATION = true` !
]
]

#slide[
= Problém $3n+1$ (Collatzův problém)

#frame[
=== Doimplementujte metodu `findn_parallel`

Doimplementujte metodu `findn_parallel` v souboru `2cancellations.cpp` pro paralelní nalezení čísla $n$, pro které platí $C(n) >= k$.

Použijte OpenMP cancellation.
]
]

#section-slide[Explorativní dekompozice]

#slide[
  = Explorativní dekompozice: Řešení problému SAT

  Chceme splnit booleovskou funkci $phi$ nad booleovskými proměnnými $x$, $y$, $z$, ...
  #image("assets/sat1.svg", width: 80%)

  Máme 4 vlákna -- jak byste úlohu paralelizovali?
]

#slide[
  = Explorativní dekompozice: Řešení problému SAT

  Chceme splnit booleovskou funkci $phi$ nad booleovskými proměnnými $x$, $y$, $z$, ...
  #image("assets/sat2.svg", width: 80%)
]

#slide-items[
  = Rekurzivní dekompozice

  #important[
    Z algoritmizace víte, že pro některé úlohy je vhodná rekurze.
  ]
  #comment[Vzpomeňte si na řazení! (např. quick-sort z přednášky)]
  #image("assets/quicksort.png", width: 60%)

][
  == Jak takovýto rekurzivní výpočet zparalelizovat?

  U rekurzivních úloh často ani nevíme, jaké podúkoly budeme muset řešit...
]

#slide-items[
= Rekurzivní dekompozice

== Řešení
#important[
  Budeme paralelní úlohy spouštět dynamicky!
]
Ve chvíli, kdy potřebujeme zavolat jinou rekurzivní metodu spustíme nový `#pragma omp task`. Ten se zpracuje ve chvíli,
kdy nějaké vlákno nemá, co dělat. Vzpomeňte si na thread-pool!
][
== Otázka

Jak se tento přístup liší od `#pragma omp parallel for schedule(dynamic)`?
]

#slide[
= Příklad `#pragma omp task`: Paralelní suma

```c
float sum(const float *a, size_t n){
    float r;
    #pragma omp parallel
    #pragma omp single
    r = parallel_sum(a, n);
    return r;


static float parallel_sum(const float *a, size_t n){
    if (n <= CUTOFF) { return serial_sum(a, n);`
    float x, y;  size_t half = n / 2;
    #pragma omp task shared(x)
    x = parallel_sum(a, half);
    #pragma omp task shared(y)
    y = parallel_sum(a + half, n - half);
    #pragma omp taskwait
    x += y;
    return x;

```
]

#slide-items[
  = Fibonacciho posloupnost

  #important[
    1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, ...
  ]
  Fibonacciho posloupnost (pro $n in bb(N)$) je definovaná:

  $
    F(n) = cases(1 & "pokud" n = 1 "nebo" n=2, F(n-1) + F(n-2) & "jinak"
    )
  $

][

#frame[
=== Doimplementujte metodu `fibonacci_par`

Doimplementujte metodu `fibonacci_par` v souboru `3tasks.cpp`. Rekurzivní volání spouštějte pomocí direktivy `#pragma omp task`.
]

#footnote[
#emoji.warning Proměnné v `task` jsou privátní (`lastprivate`) pro daný task, \
pokud neřeknete jinak (pomocí parametru OpenMP `shared(x)`).
]
]

