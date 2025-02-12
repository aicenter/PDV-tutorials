#import "@preview/polylux:0.4.0": *
#import "/template/main.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

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
    #v(2em)
    B4B36PDV:
    #slogan[
      "Ale ne všechny přístupy vedou\
      ke stejně dobrým výsledkům!"
    ]
  ][
    #v(2em)
    Dnešní cvičení: #slogan[Vlákna a jejich synchronizace]
  ]
]

#slide[
  = Osnova

  - Opakování z minulého cvičení
  \
  - Vlákna v C++ 11
  - Přístup ke sdílené paměti
  \
  - Zadání první domácí úlohy
]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Šifra `PDVCrypt`

Vzpomeňte si na šifru `PDVCrypt` z minulého cvičení:

#image("assets/pdvcrypt.svg", width: 70%)

Jeden krok dešifrování:

$
  s_i <- [ s_i + p_1 times "secret"( overbrace(s_[ i-2..i+2 ], "EQRBF") ) ] mod abs(Sigma)
$
$
  i <- [ i + p_2 times "secret"( s_[ i-2..i+2 ] ) ] mod abs(s)
$

... opakován $N$-krát

]

#slide[
= Jak vypadala paralelizace v OpenMP?

```cpp
  void decrypt_openmp(const PDVCrypt &crypt,
    std::vector<std::pair<std::string, enc_params>> &encrypted,
    unsigned int numThreads) {

    const unsigned long size = encrypted.size();

    #pragma omp parallel for num_threads(numThreads)
    for(unsigned long i = 0; i < encrypted.size(); i++) {
      auto & enc = encrypted[i];
      crypt.decrypt(enc.first, enc.second);
    }
  }
  ```
]

#slide[
= Šifra `PDVCrypt`

```cpp
  #pragma omp parallel for num_threads(numThreads)
  for(...) {
    ...
  }
  ```

#v(2em)
#h(1fr) Co se ve skutečnosti stalo?
]

#section-slide[Vlákna v C++ 11]

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

#v(1em)

Lambda funkce (uvozená pomocí `[&]`) má navíc přístup ke všem lokálním proměnným:
- Nemusíme si je tak předávat například pointery na lokální proměnné jako argumenty
]

#slide-items[

#frame[
=== Vyřešte úlohu pomocí vláken

Doimplementujte tělo metody `decrypt_threads_1` v souboru `decryption.cpp`. Spusťte `numThreads` vláken, kdy každé
vlákno bude vykonávat funkci `process`.
]

#important[
  Co je na této implementaci špatně?
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

#frame[
=== Doplňte mutex

Opravte metodu `decrypt_threads_1` za použití mutexu. Metodu `decrypt_threads_1` neupravujte, opravený kód zapište do
metody `decrypt_threads_2`.
]
]

#slide[
  = Varianta opravy č.1: Mutex

  == #emoji.warning #h(1em) Pozor!

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
Jak na to v C++11:

```cpp #include <atomic>```

```cpp int x = 0;``` #h(2em)$->$#h(2em) ```cpp std::atomic<int> x { 0 };```
]

#slide[
= Varianta opravy č.2: Atomická proměnná

#frame[
=== Nahraďte mutex atomickou proměnnou

Nahraďte mutex v `decrypt_threads_2` atomickou proměnnou. Nový kód zapište do funkce `decrypt_threads_3`.
]
]

#slide-items[
  = Varianta opravy č.2: Atomická proměnná

  #slogan[
    Mutex vs. Atomická proměnná
  ]

  #v(2em)

  Mutex je založený na systémovém volání jádra operačního systému

  - To může být ale *drahé*!
][
  Atomická proměnná je (většinou) implementovaná na hardwarové úrovni

  - Speciální instrukce pro atomické operace nad některými typy
][
  *#emoji.warning #h(1em) Nelze použít vždy!*

  - Procesory zpravidla podoporují jenom základní typy.
]

#slide-items[
  = Varianta opravy č.3: Disjunktní rozsahy

  _I atomická proměnná má ale nějakou režii..._

  #v(2em)

  #important[
    Nemůžeme se vyhnout použití mutexů \ a atomických proměnných úplně?
  ]
][
#frame[
=== Doplňte logiku výpočtu rozsahů

Ve funkci `decrypt_threads_4` chybí implementace výpočtu rozsahu `t`-tého vlákna. Doplňte výpočet hodnot proměnných `begin` a `end`.
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
  === Jaký je problém následujícího programu?

  Vlákno které čeká na splnění podmínky *vytěžuje procesor* (tzv. _busy waiting_)!
]

#slide-items[
= Podmínkové proměnné

Podmínkové proměnné (```cpp #include <condition_variable>```) slouží ke komunikaci mezi vlákny

- Umožňují nám čekat na splnění podmínky jiným vláknem (a na signál od něj)
][
- Vytvoření podmínkové proměnné:\
  ```cpp std::condition_variable cv;```
][
- Čekání na splnění podmínky:\
  ```cpp cv.wait(lock, [&] { return value != last_value; });```
][
- Notifikace o změně stavu:\
  ```cpp cv.notify_one();``` \
  ```cpp cv.notify_all();```
]

#slide[
= Čekání s podmínkovou proměnnou

#frame[
=== Nahraďte aktivní čekání podmínkovou proměnnou

V souboru `conditional_variable.cpp` v metodách `logger` a `setter` nahraďte aktivní čekání podmínkovou proměnnou.
]
]

#section-slide[Zadání domácího úkolu]

#slide-items[
  = Producent -- konzument

  - Producent vyrábí určitá data a vkládá je do fronty
  - Konzument je zase z fronty odebírá
  - Každý pracuje svým tempem

  #v(2em)

  #image("assets/producer-consumer.png", width: 70%)
][
  #important[
    Co je na tomto přístupu zajímavé?
  ]
]

#slide[
= Producent -- konzument

Doimplementujte metody v `ThreadPool.h` a zajistěte, že

1. Výpočet úloh je paralelní a každá úloha (přidaná pomocí metody `process`) je zpracována právě jednou (1 bod)
2. Thread pool nečeká na přidání nových úloh pomocí busy-waitingu (1 bod)
]