#import "@preview/polylux:0.4.0": *
#import "template.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Konkuretní datové struktury
][
  Cvičení 4
]

#slide-items[
  Minulé cvičení:
  #slogan[
    "Paralelní programování v OpenMP..."
  ]
][
  #only("2")[#image("04/figs/theory.jpg")]
][
  #only("3-")[#image("04/figs/practice.jpg")]
]

#slide[
  Dnešní menu:
  #slogan[
    Konkurentní datové struktury
  ]
]

#slide[
  = Osnova

  - Opakování z minulého cvičení
  - Zámková architektura datových struktur
  - Bezzámková architektura datových struktur
  - Zadání třetí domácí úlohy
]

#new-section[Opakování z minulého cvičení]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Co provádí následující kód? Co bude po skončení v data?

```cpp
  unsigned int num_threads = omp_get_num_threads();
  unsigned int thread_id = omp_get_thread_num();
  std::vector<int> data(100000);
  #pragma omp parallel
  {
    int chunk_size = 1 + data.size() / num_threads;
    int begin = thread_id * chunk_size;
    int end = std::min ( data.size(),
      (thread_id + 1) * chunk_size );
    for (unsigned int i = begin; i < end; i++)
      data[i] ++ ;
  }
  ```

#v(4em)

Napište odpověď
]

#slide[
= Jakým způsobem bude následující kód proveden?

```cpp
  std::vector<int> data(100000);
  int size = data.size();
  #pragma omp parallel
  {
    #pragma omp parallel for
    for (unsigned int i = 0; i < size; i++)
      data[i] ++ ;
  }
  ```

#v(1em)

=== Zvolte co se může stát

1. Kód nelze zkompilovat
2. OpenMP rozdělí práci na for cyklu mezi dostupná fyzická vlákna
3. Vnitřní smyčka bude provedena serielně
4. OpenMP vytvoří více vláken než fyzicky lze a dojde k degradaci výkonu
5. For smyčka bude provedena každým vláknem celá
]

#slide[
= K čemu dojde u následujícího kódu?

```cpp
  int k = 0;
  std::vector<int> data = getRandomVectorOfSize(400);
  #pragma omp parallel num_threads(4)
  {
    int begin = omp_get_thread_num() * 100;
    int end = (1 + omp_get_thread_num()) * 100;
    for (unsigned int i = begin; i < end; i++)
      #pragma omp critical
      k += data[i];
  }
  ```

#v(1em)

=== Zvolte co se může stát

1. Dojde k efektivní paralelizaci výpočtu
2. OpenMP zvládne distribuovat sčítání mezi vlákny aby nedošlo k degradaci výkonu
3. OpenMP bude zbytečně často serializovat vlákna pomocí critical
4. OpenMP bude naprosto zbytečně serializovat vlákna pomocí critical
]

#new-section[Tvorba konkurentních datových struktur]

#slide[
  = Co bychom si přáli?

  Aby jednu strukturu používalo více vláken *současně*.

  #important[
    Co musíme změnit oproti frontě z prvního domácího úkolu?
  ]

  #v(1em)

  - Nesmíme zamykat *celou* datovou strukturu!
  - Se zamykáním zámků musíme šetřit

  #v(5em)

  #h(1fr) #emoji.warning #h(5pt) Jinak se datová struktura stane brzdou výpočtu!
]

#slide-items[
  Možný přístup:

  1. Vezmu kód existující jednovláknové datové struktury
  2. Ve chvíli, kdy strukturu dělám nějaké zásahy, zamknu si část struktury pro sebe

  #important[
    Je to opravddu takto lehké?
  ]
][
  Typický vzor práce s jednovláknovými strukturami:

  #align(center)[
    Příprava $->$ "Poškození" dat $-$ #emoji.lightning$->$ Oprava $->$ Hotovo!
  ]
][
  Musíme zabránit použití "rozbité" části = vyloučit i čtenáře \
  (a zamykat si části struktury, i když to není potřeba -- např. při čtení)
][
  #h(1fr) *To si ale moc nepomůžeme :-(*
]

#slide-items[
  = Jak to tedy udělat lépe?

  1. Strčit hlavu do písku a (téměř) nezamykat
  2. Když nastane problém, tak ho (nějak) vyřešit

  #h(1fr) *To se snáz řekne, než udělá...*
][
  Některé z možných problémů:

  - *Datová struktura se může nacházet v mezistavu:* \
    Buď musí být použitelná, nebo si musíme být jistí, že problém detekujeme, než poškodíme data
  - *Nesmíme uvolnit paměť, pokud s ní pracuje jiné vlákno:* \
    Složitější datové struktury často využívají techniky podobné garbage-collectoru v Javě.
]

#slide[
  = Jak to tedy udělat lépe?

  O takových datových strukturách se těžko přemýšlí...

  #h(1fr) ... a ještě hůř se v nich hledají chyby!

  #v(2em)

  #see-file("http://libcds.sourceforge.net")

  #see-file("C++ Concurrency In Action: Practical Multithreading")
]

#new-section[Cvičení: konkuretní spojový seznam]

#slide-items[
  = Konkurentní spojový seznam

  Reprezentace seznamu prvků

  - My ho budeme chtít mít seřazený vzestupně...
  - Vložení prvku = nalezení správné pozice + vložení nového uzlu

  #v(2em)
  
  #image("04/figs/linkedList.svg", width: 100%)
][
  #frame[
    === Doimplementujte metodu `insert`

    Doimplementujte tělo metody `insert` v souboru `lockBased.h`. Pro synchronizaci vláken použijte `spin_lock` (používá se stejně jako `std::mutex`), který umístíte ke každému uzlu seznamu. Snažte se zámky zamykat pouze na čas modifikace seznamu a pouze tam, kde jsou potřeba!
  ]
]

#slide-items[
  = Data race

  Nesynchronizované přístupy do paměti (s alespoň jedním zápisem) jsou ve standardu C++ vedené jako

  #important[
    #emoji.warning undefined behavior #emoji.warning
  ]

  #v(1em)

  Může se nám stát spousta špatných věcí, například: \
  (ty navíc závisí na kompilátoru a platformě)

  - Můžeme přečíst částečně zapsaná data (dirty read)
  - Vlákno se nedozví o změně provedené jiným vláknem
  - Vlákno se dozví pouze o části provedených změn
][
  #important[
    `std::atomic` \
    Synchronizace přístupů ke stejné proměnné zajištěna
  ]
]

#slide[
  Můžeme se zámků zbavit úplně?
]

#new-section[Bezzámková architektura datových struktur]

#slide-items[
  Navrhnout správně zamykání je náročné

  - Špatné použití může vést k deadlocku
  - Velké množství zámků snižuje potenciál opravdové konkurence
  - Paměťový overhead (`std::mutex` na Linuxu má 40B!)
][
  #important[
    Jak na to?
  ]
][
  #set list(marker: sym.arrow)
  - Pomocí atomických operací s pamětí
]

#slide-items[
  = Porovnej a prohoď

  *Klíčová* operace pro _lock-free_ datové struktury.

  Porovnej a prohoň (neboli *compare-and-swap*) je atomická operace s pamětí na objektu `std::atomic<T> X`, definovaná v C++ jako

  ```cpp
  bool X.compare_exchange_strong( T& expected, T desired)
  ```

  která ma funkcionalitu ekvivalentní

  ```cpp
  if ( X == expected ){ X = desired; return true; }
  else{ expected = X; return false; }
  ```
][
  Kontrolu a změnu datové struktury lze provést *atomicky*!
]

#slide-items[
  === Doimplementujte metodu `insert`

  Doimplementujte tělo metody `insert` v souboru `lockFree.h`. Namísto použití zámků nyní použijte atomickou operaci *compare-and-swap* pro úpravu pointerů ve spojovém seznamu.
][
  #frame[
    === Bonusové úlohy:

    1. Zkuste se zamyslet, zda byste dokázali naimplementovat i dvousměrný spojový seznam
    2. Zkuste naimplementovat spojový seznam, ve kterém může kromě přidávání docházet konkurentně i k mazání prvků
  ]
]

#new-section[Zadání třetí domácí úlohy]

#slide[
  = Konkurentní binární vyhledávací strom

  #grid(columns: 2, gutter: 2em)[
    Struktura, v níž jsou jednotlivé prvky uspořádány tak, aby bylo možné rychle vyhledávat

    - každý uzel tedy má nanejvšš dva potomky;
    - každému uzlu je přiřazen určitý klíč;
    - levý podstrom uzlu obsahuje klíče menší než je klíč uzlu; a
    - pravý podstrom uzlu obsahuje klíče větší než je klíč uzlu.
  ][
    #image("04/figs/bst.svg", width: 80%)
  ]
]

#slide-items[
  = Konkurentní binární vyhledávací strom

  Naimplementujte metody v `bst_tree.cpp` a `bst_tree.h` a zajistěte, že

  1. každý prvek je vložen právě jednou; a
  2. žádný vložený prvek se neztratí.

  Zpracování musí být *konkurentní*, nikoli serielní!

][
  Za spravné výsledky a vysoký stupeň konkurence dostanete až *2b*.
][
  Soubory `bst_tree.cpp` a `bst_tree.h` nahrajte do systému BRUTE.
]