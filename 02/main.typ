#import "@preview/polylux:0.4.0": *
#import "/template/main.typ" as ctu-lab-slides
#import ctu-lab-slides: *

#show: ctu-lab-slides.setup

#title-slide[
  Vlákna a přístup ke sdílené paměti
][
  Cvičení 2
]

#slide[
  Minulé cvičení:

  #one-by-one[
    #slogan[
      "Paralelizace nám může pomoct..."
    ]
  ][
    B4B36PDV:
    #slogan[
      "Ale ne všechny přístupy vedou\
      ke stejně dobrým výsledkům!"
    ]
  ][
    Dnešní cvičení:
    #slogan[Vlákna a jejich synchronizace]
  ]
]

#slide[
  = Osnova

  - Opakování z minulého cvičení
  %%
  - Vlákna v C++ 11
  - Přístup ke sdílené paměti
  %%
  - Zadání první domácí úlohy
]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Exponenciální klouzavý průměr


#align(center)[
  #image("assets/ema.svg", width: 80%)
]

$
  "EMA"_0 &= "price"_0 \
  "EMA"_i &= "price"_i * "k" + "EMA"_(i-1) * (1 - "k")
$

]

#slide-focus[
= Jak vypadala paralelizace v OpenMP?

```cpp
  #pragma omp parallel for
  for (size_t i = 0; i < stock_prices.size(); i++) {
      ema[i] = exponential_moving_average(stock_prices[i], 0.1);
  }
```
]

#slide-focus[
= Parallel for

```cpp
  #pragma omp parallel for
  for(...) {
    ...
  }
  ```

#comment[Co se ve skutečnosti stalo?]
]

#section-slide[Vlákna v C++ 11]

#slide-focus[
= Vlákna v C++ 11

C++11 (přes `#include <thread>`) poskytuje multiplatformní přístup k práci s vlákny.

#v(1em)

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

  int main() {
    std::thread t1(dummy_thread, 1, 2);
    std::thread t2([&](int id, int n) {
      std::cout << "Thread " << id << " prints " << n << "\n";
    }, 2, 42);
  }
  ```

#footnote[
Lambda funkce (uvozená pomocí `[&]`) má navíc přístup ke všem lokálním proměnným.

Nemusíme si je tak předávat například pointery na lokální proměnné jako argumenty.
]
]

#slide-focus[
= Operace `map`

`Map` aplikuje funkci na každý prvek v poli.

#v(1em)

```cpp
    void map_sequential(std::vector<float>& data, MapFn map_fn) {
        for (float& f : data) {
            f = map_fn(f);
        }

        // C ekvivalent:
        for (size_t i = 0; i < data.size(); i++) {
            data[i] = map_fn(data[i]);
        }
    }
    ```

#important[
Operace `map` je ideální pro paralelizaci!
]
]

#slide-items[
= Soubor `1threads.cpp`

```cpp
    void map_openmp(std::vector<float>& data, MapFn map_fn);

    void map_manual(std::vector<float>& data, MapFn map_fn);
```

][
  #important[
    Co je na naší manuální implementaci paralelizace špatně?
  ]
]

#section-slide[Synchronizace vláken při přístupu ke sdílené paměti]

#slide-items[
  = Varianta opravy č.1: Mutex

  Mutex nám umožňuje zabránit více vláknům využívat stejný zdroj současně.

  - Mutex vlastní vždy pouze jedno vlákno a ostatní vlákna musí čekat (mutex = _mutually-exclusive_)
][
- Můžeme tak naimplementovat kritickou sekci, kam může vstoupit jediné vlákno. V této sekci:
  - Zjistíme index, který máme zpracovat
  - Inkrementujeme hodnotu `i`
][
#v(1em)

```cpp
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

#slide-items[
= Varianta opravy č.1: Mutex

#frame[
=== Doplňte mutex

Doimplementujte metodu `map_manual_locking` za použití mutexu.
]
][
  == #emoji.warning Pozor!

  Použití mutexů skrývá hrozbu _dead-locků_. Kód musíme navrhovat tak, aby bylo garantované, že vlákno někdy mutex získá
  (a provede tak kritickou sekci). Jinak zůstane čekat navěky...
]

#slide-items[
= Varianta opravy č.2: Atomická proměnná

Pokud nám stačí v rámci kritické sekce provést _jednu_ operaci nad _jednou_ proměnnou, můžeme si vystačit s atomickou
operací.

Příklady atomických operací:
- Inkrementování proměnné typu `int`
- Vynásobení proměnné typu `int` konstantou
][
== Jak na to v C++11:

```cpp
  #include <atomic>
```

```cpp   int x = 0;``` #h(2em)$->$#h(2em) ```cpp std::atomic<int> x { 0 };```

#v(1em)
][
#frame[
=== Nahraďte mutex atomickou proměnnou

Doimplementujte metodu `map_manual_atomic` za použití atomické proměnné.
]
]

#slide-items[
  = Varianta opravy č.2: Atomická proměnná

  #slogan[
    Mutex vs. Atomická proměnná
  ]

  == Mutex je založený na systémovém volání jádra operačního systému

  To může být ale *drahé*!
][
  == Atomická proměnná je (většinou) implementovaná na hardwarové úrovni

  Speciální instrukce pro atomické operace nad některými typy
][
  == #emoji.warning Nelze použít vždy!

  Procesory zpravidla podoporují jenom základní typy.
]

#slide-items[
  = Varianta opravy č.3: Disjunktní rozsahy

  _I atomická proměnná má ale nějakou režii..._

  #important[
    Nemůžeme se vyhnout použití mutexů \ a atomických proměnných úplně?
  ]
][
#frame[
=== Doplňte logiku výpočtu rozsahů

Doimplementujte metodu `map_manual_ranges` za použití disjunktních rozsahů.
]
]

#section-slide[Podmínkové proměnné]

#slide-items[
= Jaký je problém následujícího programu?

#frame[
=== Jaký je problém následujícího programu?

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
]
][
  Vlákno které čeká na splnění podmínky *vytěžuje procesor* (tzv. _busy waiting_)!
]

#slide-items[
= Podmínkové proměnné

Podmínkové proměnné (```cpp #include <condition_variable>```) slouží ke komunikaci mezi vlákny.

Umožňují nám čekat na splnění podmínky jiným vláknem (a na signál od něj).
][
== Vytvoření podmínkové proměnné
```cpp std::condition_variable cv;```
][
== Čekání na splnění podmínky
```cpp cv.wait(lock, [&] { return value != last_value; });```
][
== Notifikace o změně stavu
```cpp cv.notify_one();```

```cpp cv.notify_all();```
]

#slide[
= Čekání s podmínkovou proměnnou

#frame[
=== Nahraďte aktivní čekání podmínkovou proměnnou

V souboru `2conditional_variable.cpp` v metodách `logger` a `setter` nahraďte aktivní čekání podmínkovou proměnnou.
]
]

#section-slide[Zadání domácího úkolu]

#slide-items[
  = Producent -- konzument

  + Producent vyrábí určitá data a vkládá je do fronty
  + Konzument je zase z fronty odebírá
  + Každý pracuje svým tempem

  #v(2em)

  #image("assets/producer-consumer.png", width: 70%)
][
  #important[
    Co je na tomto přístupu zajímavé?
  ]
]

#slide[
= Producent -- konzument

#frame[
=== Zadání domácí úlohy

Doimplementujte metody v `ThreadPool.h` a zajistěte, že

+ Výpočet úloh je paralelní a každá úloha (přidaná pomocí metody `process`) je zpracována právě jednou (1 bod)
+ Thread pool nečeká na přidání nových úloh pomocí busy-waitingu (1 bod)
]
]