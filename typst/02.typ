#import "template.typ" as metropolis

#setup(
  footer: "\see{PDVCrypt.hpp, 5decrypt.cpp}",
  text-font: "Fira Sans",
  math-font: "Fira Math",
  code-font: "Fira Code",
  text-size: 18pt
) [
  // Title slide
  #slide[
    // Using a frame-style slide for title
    metropolis.frame(
      center[
        text(font: "Fira Sans", size: 2em, "Vlákna a přístup ke sdílené paměti"),
        v(0.5em),
        text("B4B36PDV -- Paralelní a distribuované výpočty")
      ]
    )
  ]
  
  // Intro slide with past exercise and today's menu
  #slide[
    text("Minulé cvičení:", font: "Fira Sans", size: 1.2em),
    v(1em),
    hr(),
    v(1em),
    text("Dnešní menu:", font: "Fira Sans", size: 1.2em),
    hfill(text("Vlákna a jejich synchronizace", size: 2em))
  ]
  
  // Outline slide
  #slide[
    text("Osnova", font: "Fira Sans", size: 1.5em),
    v(1em),
    // Outline content can be filled later or generated via toolbox
    text("• Úvod"),
    text("• Šifra PDVCrypt"),
    text("• Vlákna v C++ 11")
  ]
  
  // Šifra PDVCrypt slides
  #slide[
    // First PDVCrypt slide (fragile frame placeholder)
    text("Šifra PDVCrypt", font: "Fira Sans", size: 1.5em),
    v(1em),
    // Content to be added (e.g., code explanation, pseudocode, etc.)
    text("Detailní pohled na implementaci šifry PDVCrypt.")
  ]
  
  #slide[
    // Second PDVCrypt slide with alternative footer reference
    text("Šifra PDVCrypt", font: "Fira Sans", size: 1.5em),
    v(1em),
    text("Více detailů naleznete v souborech: 5decrypt.cpp a PDVCrypt.hpp")
  ]
  
  #slide[
    // Third PDVCrypt slide
    hfill(text("Co se ve skutečnosti stalo?", font: "Fira Sans", size: 2em))
  ]
  
  // Section: Vlákna v C++ 11
  #new-section("Vlákna v C++ 11")
  
  #slide[
    text("C++11 (přes #include <thread>) poskytuje multiplatformní přístup k práci s vlákny:", font: "Fira Sans", size: 1.2em),
    v(1em),
    // Example code block
    code("c", """
      #include <thread>
      
      void foo() {
        // pracujeme ve vlákně...
      }
      
      int main() {
        std::thread t(foo);
        t.join();
        return 0;
      }
    """)
  ]
  
  #slide[
    text("Kompaktnější zápis pomocí lambda funkcí", font: "Fira Sans", size: 1.5em),
    v(1em),
    code("c++", """
      #include <thread>
      #include <iostream>
      
      int main() {
        std::thread t([]{
          std::cout << "Zpráva z vlákna!\n";
        });
        t.join();
        return 0;
      }
    """)
  ]
]
#slide[
  text("Závěrečné shrnutí", font: "Fira Sans", size: 1.8em),
  v(1em),
  "- V tomto cvičení jsme se podívali na implementaci šifry PDVCrypt a základní možnosti práce s vlákny v C++11.",
  v(0.5em),
  "- Další materiály k tématu naleznete v dokumentaci a příkladech."
]

#slide[
  hfill(text("Děkuji za pozornost!", font: "Fira Sans", size: 2em))
]