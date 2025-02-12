#import "@preview/polylux:0.4.0": *
#import "../template/main.typ" as metropolis
#import metropolis: *

#show: metropolis.setup

#title-slide[
  Vektorové instrukce
][
  B4B36PDV -- Paralelní a distribuované výpočty
]

#slide-items[
  = Osnova

  - Opakování z minulého cvičení
  \
  - Autovektorizace
  - Ruční vektorizace pomocí intrinsics
]

#section-slide[Opakování z minulého cvičení]

#quiz-link-slide("http://goo.gl/a6BEMb")

#slide[
= Který způsob je efektivnější?

```c
bool mat[M][N];

// A:
#pragma omp parallel
#pragma omp for
for(int i = 0; i < M; i++) {
 for(int j = 0; j < N; j++){
    if (mat[i][j]){ /* report solution and terminate all; */ }
}}

// B:
for(int i = 0; i < M; i++) {
  #pragma omp parallel
  #pragma omp for
  for(int j = 0; i < N; j++){
    if (mat[i][j]){ /* report solution and terminate all; */ }
}}
```
]

#slide[
= Jakým způsobem bude následující kód proveden?

```c
bool mat[M][N];
for(int i = 0; i < M; i++) {
    #pragma omp parallel
    #pragma omp for
    for(int j = 0; j < N; j++){
        #pragma omp cancellation point for
        if (mat[i][j]){
            #pragma omp cancel for
        }
    }
}
std::cout << "Finished!" << std::endl;
```

#v(2em)

- Výpočet končí okamžitě po nalezení prvního řešení.
- Po nalezení prvního řešení výpočet skončí, až všechna vlákna narazí na 'cancellation point'.
- Ani jedna z předchozích odpovědí není správná.
]

#slide[
  = Moderní procesor

  #align(center)[
    #set text(size: 1.8em)
    #text(fill: rgb("#3f3d3d"))[*Paralelizace:*]
    #set list(marker: none)

    - #block(width: 100%, outset: 0.5em, fill: rgb("#c16a6a"))[Pipelining #small[(procesor)]]
    - #block(width: 100%, outset: 0.5em, fill: rgb("#5d9bc4"))[
        Vektorizace #small[
          #only("1")[(kompilátor)]
          #only("2-")[#strike[(kompilátor)]\ #text(weight: 600, fill: red)[(Vy #emoji.face)]]
        ]
      ]
    - #block(width: 100%, height: 2em, outset: 0.5em, fill: rgb("#9970a1"))[Vlákna #small[(Vy #emoji.face)]]
  ]
]

#slide[
  = Skalární zpracování dat

  #image("assets/scalar.svg", width: 40%)
]

#slide-items[
  = Vektorové zpracování dat

  #image("assets/vectorized.svg", width: 95%)
][
  #important[Není to až taková magie, jak to vypadá :-)]
]

#slide-items[

= Vektorové zpracování dat (pomocí AVX / AVX2)

hfill `#include <immintrin.h>`
vspace[1em]

- `__m256` - datový typ ,,vektor délky 256 bitů``
  (`float` má 32 bitů, a proto se do takového vektoru vejde 8x)
][
- `_mm256_add_ps(x,y)`
  - Nad dvěma 256-bitovými vektory `x` a `y`... (`_mm256_`)
  - ...provádím operaci sčítání... (`add`)
  - ...při čemž vektory obsahují elementy typu _packed-single_ (`_ps`).
][
- _packed_ -- vektor ,,zabaluje`` více prvků stejného typu
- _single_ -- _single-precision number_ aka `float`
]

#section-slide[
  Level 1: Autovektorizace #h(1em) #emoji.ghost
]

#slide[
= Autovektorizace

Moderní kompilátor se snaží zdetekovat `for` smyčky, které lze vektorizovat...

Například:

```c
float a[1024], b[1024], c[1024];
for(int i = 0 ; i < 1024 ; i++) {
  a[i] = b[i] + c[i];
}
```

lze převést na

```c
for(int i = 0 ; i < 1024 ; i += 8) {
  _mm256_storeu_ps(&a[i],
    _mm256_add_ps(
      _mm256_loadu_ps(&b[i]),
      _mm256_loadu_ps(&c[i])
  ));
}
```
]

#slide[
= Autovektorizace GCC

Vektorizaci kontrolujeme s pomocí parametrů kompilátoru:

- `-march=native`: zapne kompilaci přímo na konrétní hw, včetně zpřístupnění vektorových instrukcí.
- `-ftree-vectorize`: zapne autovektorizaci.
- `-fopt-info-vec-all`: informace o autovektorizaci.
- `-O2` musíme snížit level optimalizace, abychom mohli kontrolovat autovektorizaci.
]

#slide[
= Autovektorizace MSVC

Vektorizaci kontrolujeme s pomocí parametrů kompilátoru *a přímo ve zdrojovém kódu*. Vektorizace je na úrovni `/O2` defaultně
zapnutá.

- `/Qvec-report:2`: informace o autovektorizaci.
- `/fp:fast` zpřístupní pokročilou autovektorizaci floatů, která ale může mít vliv na výsledek (float operace na
  počítačích nejsou komutativní...).
- `#pragma loop(no_vector)`: Deaktivuje autovektorizaci pro konkrétní cyklus.
]

#slide[
= Autovektorizace

#frame[
=== Vyzkoušejte si autovektorizaci
Spusťte `autovec(.exe)` s autovektorizací a následně zkuste autovektorizaci vypnout:

*GCC*: zakomentujte v souboru `CMakeLists.txt` řádek `add_compile_options("-ftree-vectorize")`

Jak se program zpomalí, pokud vypnete autovektorizaci?
]

Také se podívejte do logu ze sestavování programu na zprávy o proběhlé autovektorizaci.

]

#slide-items[
= Výhody a nevýhody autovektorizace

#set list(marker: none)

- #text(fill: rgb("#556B2F"))[+] Je to ,,zadarmo`` (kompilátor se pokusí vektorizaci provést za Vás)
][
  #set list(marker: none)

  - #text(fill: rgb("#B22222"))[-] Ne vždy se to kompilátoru musí povést...
][
#set list(marker: none)

-
  -
    - Kompilátor vám nemusí ,,rozumět`` (často dokáže vektorizovat jenom smyčky v určitém tvaru)
    - Kompilátor musí zajistit, že výsledek programu bude identický, jako kdyby nevektorizoval *i za těch nejhorších možných
      podmínek*
    - Musí uvažovat, že může dojít k datovým závislostem
    - Musí zajistit, že dojde ke _stejnému_ zaokrouhlení při floating-point operacích
][
```cpp
  float x;
  float y1 = x * x * x * x * x * x * x * x;
  float y2 = x * x;
  y2 = y2 * y2;
  y2 = y2 * y2;
  assert(y1 == y2);
  ```
]

#section-slide[
  Level 2: Intel SPMD Compiler #h(1em) #emoji.ghost #emoji.ghost
]

#slide[
  = Intel SPMD Compiler (ISPC)

  #slogan[Tušíte co znamená zkratka SPMD?]

  *SPMD = _single-program multiple-data_*

  Napíšete jeden program, který ale pomocí vektorizace poběží na více daty současně. Kompilátor za vás rozhodne, jak má
  vektorizace proběhnout.
]

#slide-items[
  = Intel SPMD Compiler (ISPC)

  *Intel SPMD Compiler (ISPC)*

  - Nadstavba jazyka C
  - Od základu uvažuje o programu jako o _paralelním_!

][
  #v(5em)
  #slogan[Bohužel nemáme čas se ISPC na PDV věnovat :-(]
]

#section-slide[
  Level 3: Intrinsics #h(1em) #emoji.ghost #emoji.ghost #emoji.ghost
]

#slide-items[
  = Intrinsics

  #set list(marker: none)

  - *Intrinsics*
    - Funkce a datové typy, které zpřístupňují nativní instrukce procesoru *bez nutnosti programovat v assembleru*

  #important[#h(1fr)Instrukční sada: AVX / AVX2]
][
  #set list(marker: none)

  - #link("https://intel.ly/2GOHp7r") (Intel Intrinsics Guide)
  - Výborná reference! Využívejte, když si nebudete jistí!
]

#slide[
= `#include <immintrin.h>`

#important[`#include <immintrin.h>`]

#slogan[
#emoji.warning V GCC je třeba všechny kódy kompilovat s \
`-march=native` !
]
]

#slide-items[
= AVX / AVX2 intrinsics

Datový typ vektor: `__m256...`
- `__m256` -- vektor obsahující 8 x 32bit `float`
- `__m256d` -- vektor obsahující 4 x 64bit `double`
- `__m256i` -- vektor obsahující celočíselné typy

Načtení a zápis 256 bitů (8 x 32bit `float`) z/do adresy `float * x`:
```c
__m256 data = _mm256_loadu_ps(x);
_mm256_storeu_ps(x, data);
```

#v(1.5em)

#frame[
=== Doimplementujte načtení a zápis dat do metody `normaldist_vec(...)`

Do těla `for` smyčky v metodě `normaldist_vec(...)` v souboru `normdist.cpp` doimplementujte načtení a zpětný zápis `__m256` vektoru
z adresy `&data[i]`.
]
]

#slide[
= Výpočet hustoty normálního rozdělení

Načítat a ukládat stejná data je nuda...

#frame[
  === Doimplementujte výpočet hustoty normálního rozdělení
  
  Pro každý prvek načteného vektoru spočtěte hodnotu funkce
  $ f(x)=frac(1, sqrt(2 pi sigma^2)) "exp"( - frac((x- mu)^2, 2 sigma^2) ) $
]

`__m256 _mm256_set1_ps(x)`

#h(2em)Nastaví všechny prvky vektoru na `x`

`__m256 _mm256_add_ps(x, y)`, `__m256 _mm256_sub_ps(x, y)`
`__m256 _mm256_mul_ps(x, y)`, `__m256 _mm256_div_ps(x, y)`

#h(2em)Vypočte součet, rozdíl, součin a podíl vektorů `x` a `y`

#v(2em)

#h(2em)Pro aproximaci $"exp"(x)$ (vektorově) použijte `__m256 exp_vec(x)`

#align(center)[$
"exp"(x)$ approx $frac((x+3)^2 + 3, (x-3)^2 + 3)
(2,2)"-Padé aproximátor"
$]
]

#slide[
  = Podmíněné zpracování

  Paralelní řazení bitonic sort

  #image("assets/bitonic.png", width: 100%)

  Součástí řazení je i podmíněné prohazování prvků v poli: zjednodušená verze na dalších slidech.
]

#slide-items[
= Podmíněné zpracování

Občas chceme zpracovat různé prvky různým způsobem...
```c
size_t half = N / 2;
for(unsigned int i = 0 ; i < half ; i++) {
    if(data[i] > data[i+half])
      std::swap(data[i], data[i+half]);
}
```
][
#v(2em)
`__m256 _mm256_blendv_ps(x, y, mask)`:
#image("assets/blendv.svg", width: 95%)
]

#slide[
= Podmíněné zpracování

#frame[
=== Doimplementujte tělo metody `condswap_vec(...)`
Doimplementujte tělo metody `condswap_vec(...)` v souboru `cond.cpp`, která bude vektorově vykonávat následující kód
```c
  size_t half = N / 2;
  for(unsigned int i = 0 ; i < half ; i++) {
      if(data[i] > data[i+half])
        std::swap(data[i], data[i+half]);
  }
  ```
Pro implementaci podmínky využijte `_mm256_blendv_ps(x,y,mask)`.
]

Vektorová instrukce pro porovnání vektorů $x < y$ typu _packed-single_:
`__m256 _mm256_cmp_ps(x, y, _CMP_LT_OQ)`
]

#slide-items[
= Bitové operace

S primitivními vektorovými instrukcemi jste se setkali už dříve!

#important[například `x & y` nebo `x ^ y`]

][
#v(3em)

#h(1fr)My se podíváme na něco zajímavějšího...
]

#slide-items[
= Bitové operace

`_lzcnt_u64(uint64_t x)`

`_tzcnt_u64(uint64_t x)`

#h(2em) Počet _leading_, resp. _trailing zeros_ v čísle `x`

#v(1em)

*Například:*

#h(2em) `_lzcnt_u64(0b00001000 ... 00011100) = 4`

#h(2em) `_tzcnt_u64(0b00001000 ... 00011100) = 2`

][

#frame[
=== Doimplementujte tělo metody `log2_lzcnt(...)`
Doimplementujte tělo metody `log2_lzcnt(...)` v souboru `lzcnt.cpp`. Pro `x > 0` má tato metoda provést výpočet
ekvivalentní `(int)log2(x)`.

Tip: Jaký vztah má pozice nejvyššího jedničkového bitu k hodnotě logaritmu o základu 2?
]
]

#slide[
= Bitové operace

`_mm_popcnt_u64(uint64_t x)`

#h(2em) Počet jedničkových bitů v čísle `x`

#frame[
=== Doimplementujte tělo metody `popcnt_intrinsic(...)`
Doimplementujte tělo metody `popcnt_intrinsic(...)` v souboru `popcnt.cpp`.
]
]

#section-slide[Semestrální úloha]

#slide[
  = Semestrální úloha

  #important[Prohledávání stavového prostoru]

  #image("assets/pacman2.svg", width: 50%)
]
