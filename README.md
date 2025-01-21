 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/calvin-wirawan/INF4000">Visualisation of birth trends in England and Wales: Relation with age group, deprivation and country of birth</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/calvin-wirawan">Calvin Wirawan</a> is licensed under <a href="https://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""></a></p>  

# Visualisation of birth trends in England and Wales: <br>Relation with age group, deprivation and country of birth

This project aimed to generate a composite visualisation to examine birth trends in relation to various socio-demographic characteristics. The specific research questions 
were listed as follows:
1.	What has been the trend of live births in England and Wales over the past decade?
2.	What patterns are observed in the differences between the number of live births in England and Wales among mothers aged under 30 and those aged older?
3.	What relationships are inferred between levels of deprivation and the incidence of stillbirths in England and Wales?
4.	How does the live birth proportion in England and Wales vary between mothers born in the UK and those born outside the UK?
<br/>

The primary dataset used in the study was obtained from the birth registrations data (2023) provided by the Office for National Statistics:
> https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthsinenglandandwalesbirthregistrations/2023/2023birthregistrations.xlsx

To visualise the combination of jitter plot, box plot and violin plot, a secondary dataset from the ONS was employed:
> https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/childmortalitystatisticschildhoodinfantandperinatalchildhoodinfantandperinatalmortalityinenglandandwales/2022/cim2022deathcohortworkbook.xlsx

To visualise the butterfly chart, this dataset from the ONS was used:
> https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/parentscountryofbirth/2023/2023birthsbyparentscountryofbirth.xlsx

The experiment was carried out using R programming language version 4.4.1 (2024-06-14) and software RStudio Desktop 
for macOS version 2024.12.0+467. Besides the R base packages, the following packages were also used: 
- `tidyverse`
- `readxl`
- `reshape2`
- `ggstatsplot`
- `patchwork`
- `MetBrewer`
- `ggtext`

> [!TIP]
> Instructions on how to run the code were provided in file: [INSTRUCTION.md](INSTRUCTION.md)
<br/>

### Composite Visualisation
<br/>

![Composite](https://github.com/user-attachments/assets/7c5eafce-dd79-4baf-a0a6-57dafca3cd2c)
