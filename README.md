# <center>"COVID-19 Analyzer"</center>

![](https://i.imgur.com/S7EHnnB.png)

The "COVID-19 Analyzer" application provides a summary view of the SARS-CoV-2 virus epidemic situation using a variety of statistical and data analysis methods on a dataset from [JHU CSSE](https://github.com/CSSEGISandData/COVID-19). The application is available at the following link: https://kpytlak.shinyapps.io/covid-19-analyzer/. The main panel is divided into 5 tools:

 1. **COVID-19 dataset** - allows you to view available COVID-19 disease-related data for the filtered dataset.

 2. **Estimate R(t)** - tool to estimate the instant viral reproduction rate ![equation](https://latex.codecogs.com/gif.latex?R%28t%29), an indicator that tells how many people on average are infected by one person. A parametric SARS-CoV-2 serial interval was assumed with parameters ![equation](https://latex.codecogs.com/gif.latex?%5Cmu_%7BSI%7D%20%3D%204.8) and ![equation](https://latex.codecogs.com/gif.latex?%5Csigma_%7BSI%7D%20%3D%202.3), respectively. [^1] Estimations are made on a 7-day weekly window with 95% confidence interval. However, it is possible to choose your own parameter values. The Bayesian estimation method ![equation](https://latex.codecogs.com/gif.latex?R%28t%29) implemented in the "EpiEstim" package was used. [^2]
 3. **Effectiveness of wearing masks** - tool to estimate the effectiveness of wearing masks (of different types = with different filtration efficiencies) expressed as a decrease in the value of the baseline coefficient ![equation](https://latex.codecogs.com/gif.latex?R_0) to ![equation](https://latex.codecogs.com/gif.latex?R_e). In addition, a heatmap is generated visualizing the effect of mask filtration efficiency and the proportion of mas wearers in the population on the decrease in ![equation](https://latex.codecogs.com/gif.latex?R_0) to ![equation](https://latex.codecogs.com/gif.latex?R_e). [^3]
 4.   **Hypothesis testing** - tool for testing hypotheses on the non-significant differences between averages/medians of selected parameters of countries (e.g. number of new infections, deaths, tests performed, etc.). Depending on the number of selected countries and characteristics of the distributions of values of selected parameters, a test meeting the given assumptions (Student's t/U-Mann-Whitney/ANOVA/Kruskal-Wallis) is automatically selected.
 5. **COVID-19 charts** - visual representation of quantitative data related to time series (number of new infections, deaths, cumulative amounts, etc.).


[^1]: Nishiura, H., Linton, N. M. and Akhmetzhanov, A. R. (2020) 'Serial interval of novel coronavirus (COVID-19) infections', _International Journal of Infectious Diseases_, 93, pp. 284–286. doi: [10.1016/j.ijid.2020.02.060](https://doi.org/10.1016/j.ijid.2020.02.060).
[^2]: Cori, A. _et al._ (2013) 'A New Framework and Software to Estimate Time-Varying Reproduction Numbers During Epidemics', _American Journal of Epidemiology_, 178(9), pp. 1505–1512. doi: [10.1093/aje/kwt133](https://doi.org/10.1093/aje/kwt133).
[^3]: Howard, J. _et al._ (2020) 'Face Masks Against COVID-19: An Evidence Review'. doi: [10.20944/preprints202004.0203.v3](https://doi.org/10.20944/preprints202004.0203.v3).
