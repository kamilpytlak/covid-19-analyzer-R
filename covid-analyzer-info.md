#### Narzędzie *COVID-19 Analyzer* zapewnia sumaryczny podgląd na sytuację epidemiologiczną związaną z chorobą COVID-19 w wybranym bądź wybranych krajach świata. Panel podzielony został na 5 narzędzi:

1.  **Zbiór danych COVID-19** - umożliwia podgląd dostępnych danych związanych z chorobą COVID-19 dla przefiltrowanego zbioru danych,

2.  **Kalkulator R** - narzędzie do estymacji współczynnika reprodukcji wirusa $R$, czyli wskaźnika informującego, ile średnio osób zakaża jedna osoba. Założono parametryczny interwał seryjny SARS-CoV-2 z parametrami odpowiednio $\mu_{SI} = 4.8$ i $\sigma_{SI} = 2.3$.[^1] Szacowania dokonywane są na 7-dniowym oknie tygodniowym z 95% przedziałem ufności. Istnieje jednak możliwość doboru własnych wartości parametrów. Wyniki generowane są z użyciem funkcji z biblioteki "EpiEstim"[^2].

3.  **Efektywność noszenia masek** - narzędzie do oszacowania efektywności noszenia masek (różnego rodzaju = o różnym współczynniku skuteczności filtracji) wyrażonej jako spadek wartości bazowego współczynnika $R_0$ do $R_{e}$. Ponadto generowana zostaje mapa cieplna (ang. *heatmap*) wizualizująca wpływ współczynnika skuteczności filtracji maski i proporcji osób noszących maski w populacji na spadek wartości współczynnika $R_0$ do $R_e$.[^3]

4.  **Testowanie hipotez** - narzędzie to testowania hipotez dotyczących braku istotnych różnic pomiędzy średnimi/medianami wybranych parametrów danych krajów (np. liczby nowych zakażeń, zgonów, wykonanych testów, itp.). W zależności od liczby wybranych krajów i charakterystyki rozkładów wartości wybranych parametrów automatycznie dopasowywany jest test (t-Studenta/U-Manna-Whitneya/ANOVA/Kruskala-Wallisa).

5.  **Wykresy COVID-19** - wizualna reprezentacja danych ilościowych związanych z szeregami czasowymi (liczba nowych zakażeń, zgonów, ilości skumulowane, itp.).

[^1]: Nishiura, H., Linton, N. M. and Akhmetzhanov, A. R. (2020) 'Serial interval of novel coronavirus (COVID-19) infections', *International Journal of Infectious Diseases*, 93, pp. 284--286. doi: [10.1016/j.ijid.2020.02.060](https://doi.org/10.1016/j.ijid.2020.02.060).

[^2]: Cori, A. *et al.* (2013) 'A New Framework and Software to Estimate Time-Varying Reproduction Numbers During Epidemics', *American Journal of Epidemiology*, 178(9), pp. 1505--1512. doi: [10.1093/aje/kwt133](https://doi.org/10.1093/aje/kwt133).

[^3]: Howard, J. *et al.* (2020) 'Face Masks Against COVID-19: An Evidence Review'. doi: [10.20944/preprints202004.0203.v3](https://doi.org/10.20944/preprints202004.0203.v3).

------------------------------------------------------------------------

<div align="right"><h4>Autor narzędzia: Kamil Pytlak <br />
Kontakt: 115151@student.upwr.edu.pl</h4></div>

