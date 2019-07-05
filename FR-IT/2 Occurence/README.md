
## SELECTION OF PRESENCES

**As 99% of attacks happen on sheep, our presence occurence data set contains only attacks on sheep by brown bear. (n=).**
Moreover, attacks information (such as GPS location, municipality, species, pastoral units...) will be extracted to explore the data set.

```
> datashp@data %>% group_by(libelle__1) %>% summarize(count=n())
# A tibble: 4 x 2
  libelle__1 count
  <fct>      <int>
1 Bovins         2
2 Caprins        1
3 Equins         1
4 Ovins        762
```


## SELECTION OF ABSENCES (script 17)

1. To select for absences, we chose to randomly take points inside a specific annual area.
This specific area is the annual area of presence of brown bear combined with the presence area of sheep

**First step** select for pastoral units inside brown bear annual presence area (every year) (script create pastoral data)
```
> nbestive
 [1]    0    0    0    0    0    0    0   NA   NA   NA   NA   NA   NA   NA   NA   NA
[17]   NA   NA   NA   NA   NA   NA   NA 1269 1119  844 1123 1029 1055 1908
```
**Second step** Select for annual data (script create pastoral data)
```
> nbestive_v1
                                   2010 2011 2012 2013 2014 2015 2016 
   0    0    0    0    0    0    0  148  134   94  143  131  127  255 
```

**Third step** select only patoral units containing domestic animals (script create pastoral data)
```
> nbestive_v2
                                   2010 2011 2012 2013 2014 2015 2016 
   0    0    0    0    0    0    0  144  129   93  139  127  122  245 
```
**Fourth step** we make the presence data points +/- 1367m (all data on domestic animals not only sheep) buffer with the presence area pastures containing domestic animals (we did not chose only for those containing sheep!!) (script 17)

## CREATING DATA FRAME FOR ANALYSIS

**1** we extract (st_join) the pastoral data information for each attacks using shapefiles and attacks information (no need to rasterize pastoral data) (script 17)
**2** we extract for each point environmental data (per annual attack data) (script 18)
**3** we extract for each point per year bear density activity per annual attack data (script 18)
**4** we make only one data frame considering all of this information (script 18)

2. To select for absences, we take presence of brown bear's attacks buffered (1367m) randomly inside a square in Central Pyrenees (not only inside brown bear presence and sheep presence  
(here the random effect Pastures name will not be taken into account)

## EXPLORE DATA
*explore environmental data*  
See script 19

*how many times attacks happen in unguarded pastures : 
```
tab2%>%group_by(Occurence,nbGard)%>%summarise(compteur=n())
# A tibble: 11 x 3
# Groups:   Occurence [2]
   Occurence nbGard compteur
   <fct>      <int>    <int>
 1 0              0      204
 2 0              1      202
 3 0              2       79
 4 0              3       28
 5 0              4        6
 6 0              5        3
 7 1              0       17
 8 1              1      356
 9 1              2      100
10 1              3       37
11 1              4       12
```
