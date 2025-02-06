#import "@preview/polylux:0.4.0": *
#import "template.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Paralelní a distribuované výpočty
][
  Cvičení 2
]

#slide-items[
  Minulé cvičení:
  #slogan[
    "Paralelizace nám může pomoct..."
  ]
][
  #only("2")[#image("02/figs/pdvcrypt.pdf")]
][
  #only("3-")[#image("02/figs/pdvcrypt.pdf")]
]

#slide[
  Dnešní menu:
  #slogan[
    Vlákna a jejich synchronizace
  ]
]

#slide[
  = Osnova

  - Opakování z minulého cvičení
  - Vlákna v C++ 11
  - Přístup ke sdílené paměti a synchronizace
  - Zadání první domácí úlohy
]

#new-section[Opakování z minulého cvičení]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Šifra PDVCrypt

#image("02/figs/pdvcrypt.pdf", width: 100%)

Jeden krok dešifrování:
- $s_i \gets \Big[ s_i + p_1 \times secret(s_{[i-2 .. i+2]}) \Big] \ \mathrm{mod}\ |\Sigma|$
- $i \gets \Big[ i + p_2 \times secret(s_{[i-2 .. i+2]}) \Big] \ \mathrm{mod} \ |s|$
... opakován $N$-krát
]

#slide[
= Šifra PDVCrypt

Jak vypadala paralelizace v OpenMP?

```cpp
pdv::benchmark("Decryption", [&] {
    #pragma omp parallel for num_threads(numThreads)
    for (auto& enc : encrypted) {
        crypt.decrypt(enc.first, enc.second);
    }
});
```
]

#slide[
= Šifra PDVCrypt

```cpp
#pragma omp parallel for num_threads(numThreads)
for(...) {
  ...
}
```

#v(2em)

Co se ve skutečnosti stalo?
]

#new-section[Vlákna v C++ 11]

#slide[
C++11 (přes `#include <thread>`) poskytuje multiplatformní přístup k práci s vlákny:

```cpp
#include <iostream>
#include <thread>

void dummy_thread(int id, int n) {
  std::cout << "Thread " << id << " prints " << n << "\n";
}

int main() {
  std::thread t1(dummy_thread, 1, 2);
  std::thread t2(dummy_thread, 2, 42);
  t1.join();
  t2.join();

  return 0;
}
```
]

#slide[
= Kompaktnější zápis pomocí lambda funkcí

```cpp
#include <iostream>
#include <thread>

void dummy_thread(int id, int n) {
  std::cout << "Thread " << id << " prints " << n << "\n";
}

std::thread t1(dummy_thread, 1, 2);
std::thread t2([&] (int id, int n) {
  std::cout << "Thread " << id << " prints " << n << "\n";
}, 2, 42);
```

Lambda funkce (uvozená pomocí `[&]`) má navíc přístup ke všem lokálním proměnným.
- Nemusíme si je tak předávat například pointery na lokální proměnné jako argumenty, pokud s nimi chceme pracovat
]

#slide[
= Vyřešte úlohu pomocí vláken

Doimplementujte tělo metody `decrypt_threads_1` v souboru `decryption.cpp`.
Spusťte `numThreads` vláken, kdy každé vlákno bude vykonávat funkci `process`.

#v(2em)

Co je na této implementaci špatně?
]

#new-section[Synchronizace vláken při přístupu ke sdílené paměti]

#slide[
= Varianta opravy č.1: Mutex

Mutex nám umožňuje zabránit více vláknum využívat stejný zdroj současně.
- Mutex vlastní vždy pouze jedno vlákno a ostatní vlákna musí čekat (mutex = mutually-exclusive)
- Můžeme tak naimplementovat kritickou sekci, kam může vstoupit jediné vlákno. V této sekci:
  - Zjistíme index, který máme zpracovat
  - Inkrementujeme hodnotu `i`

```cpp
#include <iostream>
#include <thread>
#include <mutex>

std::mutex m;
void dummy_thread() {
  std::cout << "Zde muze byt soucasne vice vlaken." << std::endl;
  {
    std::unique_lock<std::mutex> lock(m);
    std::cout << "Ale zde budu uplne sam..." << std::endl;
  }
  std::cout << "A tady opet nemusim byt sam...";
}
```
]

#slide[
= Varianta opravy č.1: Mutex

Doplňte mutex

Opravte metodu `decrypt_threads_1` za použití mutexu.
Metodu `decrypt_threads_1` neupravujte, opravený kód zapište do metody `decrypt_threads_2`.
]

#slide[
= Varianta opravy č.1: Mutex

#v(2em)

#h(1fr) #emoji.warning #h(5pt) Pozor!

Použití mutexů skrývá hrozbu dead-locků.
Kód musíme navrhovat tak, aby bylo garantované, že vlákno někdy mutex získá (a provede tak kritickou sekci).
Jinak zůstane čekat navěky...
]

#slide[
= Varianta opravy č.2: Atomická proměnná

Pokud nám stačí v rámci kritické sekce provést jednu operaci nad jednou proměnnou, můžeme si vystačit s atomickou operací.

Příklady atomických operací:
- Inkrementování proměnné typu `int`
- Vynásobení proměnné typu `int` konstantou

Jak na to v C++11: `#include <atomic>`
```cpp
int x = 0;
```
$\rightarrow$
```cpp
std::atomic<int> x { 0 };
```
]

#slide[
= Varianta opravy č.2: Atomická proměnná

Nahraďte mutex atomickou proměnnou

Nahraďte mutex v `decrypt_threads_2` atomickou proměnnou.
Nový kód zapište do funkce `decrypt_threads_3`.
]

#slide[
= Varianta opravy č.2: Atomická proměnná

#v(2em)

#h(1fr) Mutex vs. Atomická proměnná

Mutex je založený na systémovém volání jádra operačního systému
- To může být ale drahé!

Atomická proměnná je (většinou) implementovaná na hardwarové úrovni
- Speciální instrukce pro atomické operace nad některými typy
- #emoji.warning Nelze použít vždy! Procesory zpravidla podoporují jenom základní typy.
]

#slide[
= Varianta opravy č.3: Disjunktní rozsahy

I atomická proměnná má ale nějakou režii...

#v(2em)

Nemůžeme se vyhnout použití mutexů a atomických proměnných úplně?

#v(3em)

Doplňte logiku výpočtu rozsahů

Ve funkci `decrypt_threads_4` chybí implementace výpočtu rozsahu `t`-tého vlákna.
Doplňte výpočet hodnot proměnných `begin` a `end`.
]

#new-section[Podmínkové proměnné]

#slide[
= Jaký je problém následujícího kódu?

```cpp
void logger() {
  bool last_value = true;
  while(true) {
    std::unique_lock<std::mutex> lock(m);
    if(last_value != value) {
      std::cout << "Value changed to " << value << std::endl;
      last_value = value;
    }
  }
}
```

#v(2em)

Vlákno které čeká na splnění podmínky vytěžuje procesor (tzv. busy waiting)!
]

#slide[
= Podmínkové proměnné

Podmínkové proměnné (`#include <condition_variable>`) slouží ke komunikaci mezi vlákny
- Umožňují nám čekat na splnění podmínky jiným vláknem (a na signál od něj)

Vytvoření podmínkové proměnné: `std::condition_variable cv;`
Čekání na splnění podmínky: `cv.wait(lock, [&] { return value != last_value; });`
Notifikace o změně stavu: `cv.notify_one();` `cv.notify_all();`
]

#slide[
= Čekání s podmínkovou proměnnou

Nahraďte aktivní čekání podmínkovou proměnnou

V souboru `conditional_variable.cpp` v metodách `logger` a `setter` nahraďte aktivní čekání podmínkovou proměnnou.
]

#new-section[Zadání první domácí úlohy]

#slide[
= Producent -- konzument

Producent vyrábí určitá data a vkládá je do fronty
Konzument je zase z fronty odebírá
Každý pracuje svým tempem

#v(1em)

#image("02/figs/producer-consumer.png", width: 60%)

#v(1em)

#h(1fr) #emoji.warning Konzument nemůže odebírat data, pokud v zásobníku žádná data nejsou.
]

#slide[
= Producent -- konzument

Doimplementujte metody v `ThreadPool.h` a zajistěte, že

1. Výpočet úloh je paralelní a každá úloha (přidaná pomocí metody `process`) je zpracována právě jednou (1 bod)
2. Thread pool nečeká na přidání nových úloh pomocí busy-waitingu (1 bod)
]
