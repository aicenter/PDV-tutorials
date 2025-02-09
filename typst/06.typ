#import "@preview/polylux:0.4.0": *
#import "template.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Řadící algoritmy
][
  B4B36PDV -- Paralelní a distribuované výpočty
]

#slide-items[
  = Osnova

  - Opakování z minulého cvičení
  \
  - Dynamické vytváření úloh s `#pragma omp task`
  - Paralelní merge sort
  - Paralelní counting sort
  \
  - Zadání páté domácí úlohy
]

#new-section[Opakování z minulého cvičení]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Co můžete říct o tomto kódu?

```c
#pragma omp parallel
#pragma omp for
for(int i = 0 ; i < size ; i++) {
  if(is_solution(candidates[i])) {
    std::cout << candidates[i]
              << "is a solution" << std::endl;
    break;
  }
}
```

#v(2em)

- Nepůjde pravděpodobně zkompilovat
- Paralelní blok skončí po nalezení prvního řešení
- Paralelní blok skončí, až všechna vlákna najdou řešení
- Aby blok skončil ihned po nalezení řešení, musíme (vhodně) doplnit `#pragma omp cancel for`
- Aby blok skončil ihned po nalezení řešení, musíme (vhodně) doplnit `#pragma omp cancelation point for`
- Měli bychom nastavit proměnnou prostředí `OMP_CANCELLATION=true`
]

#slide[
= Jak se bude chovat následující kód?

```c
int parallel_worker(int d){
  if (d == 1) return 1;
  int t1 = 0, t2 = 0;
  #pragma omp task
  t1 = parallel_worker(d-1);
  #pragma omp task
  t2 = parallel_worker(d-1);
  #pragma omp taskwait
  return t1+t2;
}
(...)
#pragma omp parallel num_threads(4)
std::cout << parallel_worker(3) ;
```
]

#new-section[`#pragma omp task`]

#slide[
= `#pragma omp task`

Pokud nevíme, jaké úlohy budeme muset v průběhu výpočtu řešit, můžeme je vytvářet dynamicky...

```c
void traverse(node * n) {
  for(node * successor : n->getSuccessors()) {
    #pragma omp task
    traverse(successor);
  }

  do_something();
  
  #pragma omp taskwait
}
```
]

#slide[
= #`pragma omp task`

Co kdybychom chtěli z tasků ale něco vracet?

```c
unsigned long long traverse_and_sum(node * n) {
  std::atomic<unsigned long long> sum = 0;
  for(node * successor : n->getSuccessors()) {
    #pragma omp task shared(sum)
    sum += traverse(successor);
  }

  sum += do_something(n);
  
  #pragma omp taskwait
  return sum.load();
}
```

#v(2em)

#emoji.warning #h(5pt) *Pozor!* Nutno použít `shared` (pro přístup k proměnné) a `taskwait`! 
Nepoužití těchto konstruktů povede k špatnému výsledku programu (data se nezapíší globálně) nebo i k pádu (proměnná `sum` zanikne po `return`)!
]

#slide-items[
= `#pragma omp task`

Něco nám tam ale chybí... Ještě potřebujeme ,,někoho``, kdo `tasky` bude řešit. Potřebujeme si připravit vlákna!

```c
unsigned long long start_traversal() {
  #pragma omp parallel   // Vytvoříme si tým vláken
  traverse_and_sum(root);
}
```
][
#v(2em)

#important[
Rychlá otázka: Stane se skutečně to, co bychom chtěli?
]
]

#slide-items[
= `#pragma omp task`

My ale chceme, aby kořen zpracovávalo pouze _jedno_ vlákno!

#v(2em)

```c
unsigned long long start_traversal() {
  #pragma omp parallel
  #pragma omp single     // pouze jednou!
  traverse_and_sum(root);
}
```

][
#v(1em)

#important[
Rychlá otázka: Stane se skutečně to, co bychom chtěli?
]
]

#slide[
= `#pragma omp task`

#emoji.warning #h(5pt) Režie s vytvářením a správou `tasků` může být drahá.

- Tasky chceme vytvářet tehdy, pokud to povede k lepšímu vytížení procesoru.
- ... ale ne nutně výhradně spravováním tasků ;-)

#v(1em)#v(1em)

```c
double x = 0.0;
if(size <= MIN_PROBLEM_SIZE) {
  return solve_sequential(...);
} else {
  #pragma omp task shared(x)
  x += task1(x);

  #pragma omp task shared(x)
  x += task2(x);

  #pragma omp taskwait
  return x;
}
```
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
}

static float parallel_sum(const float *a, size_t n){
    if (n <= CUTOFF) { return serial_sum(a, n);}
    float x, y;	size_t half = n / 2;
    #pragma omp task shared(x)
    x = parallel_sum(a, half);
    #pragma omp task shared(y)
    y = parallel_sum(a + half, n - half);
    #pragma omp taskwait
    x += y;
    return x;
}
```
]

#new-section[Paralelní merge sort]

#slide[
= Paralelní merge sort

Merge sort je řadící algoritmus, který pracuje následovně:

1. Rozdělí neseřazenou množinu dat na dvě podmnožiny o přibližně stejné velikosti.
2. Seřadí obě podmnožiny.
3. Spojí seřazené podmnožiny do jedné seřazené množiny.

#v(1em)#v(1em)

```c
function mergesort(m)
    if (length(m) <= 1) return m

    middle = length(m) / 2
    left = m[0 ... middle-1]
    right = m[middle ... length(m)-1]

    left = mergesort(left)
    right = mergesort(right)

    return merge(left, right)
```
]

#slide[
= Paralelní merge sort

#image("06/figs/mergesort.png", width: 70%)
]

#slide[
= Paralelní merge sort

#frame[
=== Doimplementujte metodu `mergesort_parallel`

Doimplementujte tělo metody `mergesort_parallel(...)` (a případných dalších metod, které budete potřebovat) v souboru `mergesort_parallel.h`. Pro implementaci můžete využít metodu `merge(...)` a můžete se inspirovat sekvenční implementací, kterou naleznete v souboru `mergesort_sequential.h`.
]

#v(2em)

#emoji.warning #h(5pt) Proměnné v `task` jsou privátní (`lastprivate`) pro daný task, pokud neřeknete jinak (pomocí parametru OpenMP `shared(x)`).
]

#slide[
= Složitost

*Otázka:* Jakou složitost má sekvenční mergesort? A jak je na tom jeho paralelní verze?
]

#new-section[Paralelní counting sort]

#slide[
= Counting sort

Uvažujme, že máme za úkol seřadit pole prvků, které obsahuje hodnoty z malého omezeného rozsahu $a <= x <= b$.

Pak může být použití standardních algoritmů se složitostí $O(n "log" n)$ nevhodné.

#v(2em)

=== Counting sort:

1. Napočítáme si počty jednotlivých prvků $c(x)$ z rozsahu $x in [a,b]$ ("histogram")
2. Počty prvků projdeme ve vzestupném pořadí. Prvek $x$ zapíšeme do výstupního pole $c(x)$-krát.

#v(1em)

#h(1fr) Složitost $O(n + k)$, kde $k = b-a+1$
]

#slide-items[
= Counting sort

1. Napočítáme si počty jednotlivých prvků $c(x)$ z rozsahu $x in [a,b]$ (,,histogram``)
2. Počty prvků projdeme ve vzestupném pořadí. Prvek $x$ zapíšeme do výstupního pole $c(x)$-krát.

#v(1em)#v(1em)

#h(1fr) Jak bychom kroky 1 a 2 mohli paralelizovat?
][
#frame[
=== Doimplementujte metodu `counting_parallel`

Doimplementujte tělo metody `counting_parallel(...)` v souboru `countingsort.h`. Inspirovat se můžete sekvenční implementací tohoto řadícího algoritmu v metodě `counting_sequential(...)`.
]
]

#slide[
  #show: focus

= SPOILER ALERT!

#v(2em)

#emoji.warning #h(5pt) SPOILER ALERT!
]

#new-section[Prefixní suma]

#slide[
= Prefixní suma

1. Napočítáme si počty jednotlivých prvků $c(x)$ z rozsahu $x in [a,b]$ (,,histogram``)
2. Počty prvků projdeme ve vzestupném pořadí. Prvek $x$ zapíšeme do výstupního pole $c(x)$-krát.

#v(1em)#v(1em)

#h(1fr) Bod (2) algoritmu nešel snadno paralelizovat, protože nevíme, kam máme dané číslo umístit bez toho, abychom vyřešili předešlá čísla!

#show "?": text(fill: red, " ? ")
$
  c(x) = [?, ?, 5, ?, ?]
$
]

#slide[
= Prefixní suma

Pro posloupnost čísel $x_0, x_1, x_2, dots$ je prefixní suma posloupnost $y_0, y_1, y_2, dots$ taková, že

$
y_0 &= x_0 \
y_1 &= y_0 + x_1 \
y_2 &= y_1 + x_2 \
dots
$

#v(2em)

=== Příklad:

#table(
  columns: 8,
  [Vstupní sekvence:], [1], [2], [3], [4], [5], [6], [...],
  [Prefixní suma:], [1], [3], [6], [10], [15], [21], [...]
)
]

#slide[
= Prefixní suma

#frame[
=== Doimplementujte metodu `counting_parallel`

Použijte prefixní sumu pro paralelizaci bodu (2) counting sortu.
]
]

#slide[
= Prefixní suma

Jak bychom mohli výypočet prefixní sumy paralelizovat?

#small[
  Hodnota $y_i$ závisí na hodnotě $y_(i-1)$.
]

#frame[
=== Doimplementujte metodu `prefix_sum_parallel`

Doimplementujte tělo metody `prefix_sum_parallel` v souboru `prefixsum.h`.
]
]

#new-section[Zadání páté domácí úlohy]

#slide[
= Paralelní radix sort

Algoritmus pro lexikografické seřazení řetězců stejné délky.

#v(1.5em)

#frame[
=== Naimplementujte metodu `radix_par`

Naimplementujte metodu `radix_par` v `sort.cpp`.
]

#v(1.5em)

#h(1fr) Za správné výsledky a rychlé zpracování dostanete až *2b*.

#v(1.5em)

Soubory `sort.cpp` a `sort.h` nahrajte do systému BRUTE.
]
