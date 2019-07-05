
## ENVIRONMENTAL DREDGE

# For **pseudo-absences** selection :

if threshold for multicolinearity at r>0.6, we do not have to exclude pairs of variables from the same models. Actually, only ruggedness and slope are correlated at 0.98. Thus, based on several references on brown bear habitat use, we chose to display model selection only with the ruggedness. Moreover, the elevation was also removed from model selection as it is inherent part of our biologic models.  

1. Chose for random effect: we have an annual response variable thus we have the Year as random factor
```
> r.squaredGLMM(mran)
     R2m          R2c
[1,]   0 2.003815e-10
```  
2. Complete model 

```
> summary(MCenvtri)
 Family: binomial  ( logit )
Formula:          
Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + tri.std +  
    grass.std + ndwater.std + BA.std + patchdens.std + I(patchdens.std^2) +  
    ndtcd.std + I(ndtcd.std^2) + ndshrub.std + ndagri.std + (1 |      Annee)
Data: tab2

     AIC      BIC   logLik deviance df.resid 
   331.6    405.8   -150.8    301.6     1029 

Random effects:

Conditional model:
 Groups Name        Variance Std.Dev.
 Annee  (Intercept) 0.48     0.6928  
Number of obs: 1044, groups:  Annee, 7

Conditional model:
                    Estimate Std. Error z value Pr(>|z|)    
(Intercept)         -1.63329    0.52699  -3.099 0.001940 ** 
ndRoads.std          1.24754    0.43384   2.876 0.004033 ** 
ndbuild.std         -2.00060    0.75937  -2.635 0.008425 ** 
ndfoot.std          -2.44726    0.66718  -3.668 0.000244 ***
tri.std              0.03567    0.36935   0.097 0.923054    
grass.std            3.44886    0.41940   8.223  < 2e-16 ***
ndwater.std          0.13345    0.38372   0.348 0.728014    
BA.std               2.27892    0.66980   3.402 0.000668 ***
patchdens.std      -12.80946    2.83937  -4.511 6.44e-06 ***
I(patchdens.std^2) -24.83493    5.53679  -4.485 7.28e-06 ***
ndtcd.std            1.66930    0.54286   3.075 0.002105 ** 
I(ndtcd.std^2)      -1.04608    0.43225  -2.420 0.015518 *  
ndshrub.std          1.07632    0.62974   1.709 0.087422 .  
ndagri.std           5.11434    0.75105   6.810 9.79e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```  
3. Dredge  
the 13 first models are in a delta AICc <=2

4. Averaging on those 13 first models

5. Cheking model's assumption (spatial correlation) with bubble plot, corrplot and global moran's I on both full model and best model of dredge
Full model :
```
> tab <- tab2
> coordinates(tab) <- ~ X + Y
> xy <- coordinates(tab)
> tab2.nb <- dnearneigh(xy,0, 1367)
> tab2.listw <- nb2listw(tab2.nb,style='B',zero.policy=TRUE)
> tes.mor <- moran.test(residuals(MCenvtri,type="response"),listw=tab2.listw,randomisation=T,zero.policy = TRUE)
> tes.mor

	Moran I test under randomisation

data:  residuals(MCenvtri, type = "response")  
weights: tab2.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.3508, p-value = 9.853e-14
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
     0.0742726570     -0.0016638935      0.0001067176 
```  
Best model :
``` 
> tes.mor

	Moran I test under randomisation

data:  residuals(best.mod, type = "response")  
weights: tab2.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.0052, p-value = 1.233e-12
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
      0.070734485      -0.001663894       0.000106812 
 ```  
 
    
     

# For **true absences** selection :   

if threshold for multicolinearity at r>0.6, we do not have to exclude pairs of variables from the same models. Actually, only ruggedness and slope are correlated at 0.98. Thus, based on several references on brown bear habitat use, we chose to display model selection only with the ruggedness. Moreover, the elevation was also removed from model selection as it is inherent part of our biologic models.  

1. Chose for random effect: we have an annual response variable thus we have the Year as random factor but also attacks happen in pastures that possess particular characteristics thus we also have the PasturesID as random factor.  
```
mran.complet <- glmmTMB(Occurence ~ 1 + (1|Annee) + (1|Nom_Estive),data=tab2,family=binomial,REML=T)
summary(mran.complet)
mran.year <- glmmTMB(Occurence ~ 1 + (1|Annee),data=tab2,family=binomial,REML=T)
summary(mran.year)
mran.past <- glmmTMB(Occurence ~ 1 + (1|Nom_Estive),data=tab2,family=binomial,REML=T)
summary(mran.past)
```

```
> AIC(mran.complet)
[1] 707.2745
> AIC(mran.year)
[1] 1455.018
> AIC(mran.past)
[1] 706.4264
```

Delta AIC between mran.complet and mran.past is less than 1. Thus, choosing for the biological random effects is okay (year and pastures' ID).  
However, I would like to point out that 
```
> r.squaredGLMM(mran.past)
            R2m       R2c
theoretical   0 0.8361185
```  
It means that this random factor of pastures ID captures a lot of the pattern of the response variable... (spatial correlation).


2. Thus, the **complete model** for environment selection is: 

```
> summary(MCenvtri)
 Family: binomial  ( logit )
Formula:          
Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + tri.std +  
    grass.std + ndwater.std + BA.std + patchdens.std + I(patchdens.std^2) +  
    ndtcd.std + I(ndtcd.std^2) + ndshrub.std + ndagri.std + (1 |  
    Annee) + (1 | Nom_Estive)
Data: tab2

     AIC      BIC   logLik deviance df.resid 
   560.7    639.9   -264.4    528.7     1028 

Random effects:

Conditional model:
 Groups     Name        Variance  Std.Dev. 
 Annee      (Intercept) 5.885e-09 7.672e-05
 Nom_Estive (Intercept) 4.846e+01 6.961e+00
Number of obs: 1044, groups:  Annee, 7; Nom_Estive, 72

Conditional model:
                   Estimate Std. Error z value Pr(>|z|)    
(Intercept)        -5.78462    2.14019  -2.703  0.00687 ** 
ndRoads.std         0.05308    0.46642   0.114  0.90939    
ndbuild.std        -0.65539    0.41558  -1.577  0.11479    
ndfoot.std         -1.56323    0.39169  -3.991 6.58e-05 ***
tri.std            -0.52953    0.26340  -2.010  0.04439 *  
grass.std           2.27924    0.33265   6.852 7.30e-12 ***
ndwater.std         0.52483    0.33632   1.560  0.11864    
BA.std              0.46140    0.24820   1.859  0.06303 .  
patchdens.std      -0.08546    0.83484  -0.102  0.91847    
I(patchdens.std^2) -1.76168    1.45502  -1.211  0.22599    
ndtcd.std           1.59548    0.63091   2.529  0.01144 *  
I(ndtcd.std^2)     -1.01580    0.53534  -1.897  0.05777 .  
ndshrub.std         0.87650    0.39254   2.233  0.02556 *  
ndagri.std          0.36033    0.95621   0.377  0.70630    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

> r.squaredGLMM(MCenvtri)
                     R2m          R2c
theoretical 9.820576e-02 9.426671e-01
```
3. Dredge  
We computed the dredge on the complete model's formula. And we gave the specific information of quadratic relationships in the subset.
We select for averaging the 16 first models as they have a delta AICc<=2 with the best model (smallest AICc).

```
MSenvtriTrueA0.6[c(1:16)]
Global model call: glmmTMB(formula = Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + 
    tri.std + grass.std + ndwater.std + BA.std + patchdens.std + 
    I(patchdens.std^2) + ndtcd.std + I(ndtcd.std^2) + ndshrub.std + 
    ndagri.std + (1 | Annee) + (1 | Nom_Estive), data = tab2, 
    family = binomial, REML = F, ziformula = ~0, dispformula = ~1)
---
Model selection table 
     cnd((Int)) dsp((Int)) cnd(BA.std) cnd(grs.std) cnd(ndb.std) cnd(ndf.std) cnd(ndR.std) cnd(nds.std) cnd(ndt.std)
4563     -7.312          +      0.4830        2.250                    -1.541                    0.9102       1.5430
4571     -7.267          +      0.4663        2.287      -0.5443       -1.488                    0.8140       1.7540
5083     -7.479          +      0.5036        2.293      -0.5932       -1.577                    0.8614       1.7020
5075     -7.511          +      0.5163        2.251                    -1.628                    0.9602       1.4830
5587     -7.080          +      0.4809        2.278                    -1.526                    0.8941       1.4740
5595     -7.015          +      0.4629        2.316      -0.5626       -1.467                    0.7932       1.6870
6107     -7.235          +      0.4989        2.319      -0.6114       -1.554                    0.8356       1.6380
4570     -7.338          +                    2.212      -0.5727       -1.480                    0.8541       1.6440
8155     -5.855          +      0.4684        2.299      -0.6462       -1.540                    0.8651       1.6590
4562     -7.385          +                    2.173                    -1.535                    0.9532       1.4190
475      -7.135          +      0.4565        2.326      -0.6255       -1.567                    0.7835       1.8140
4819     -7.735          +      0.4886        2.486                    -1.592                    0.9387       0.7417
6099     -7.285          +      0.5129        2.276                    -1.610                    0.9401       1.4180
4307     -7.535          +      0.4498        2.502                    -1.497                    0.8856       0.7644
7643     -5.724          +      0.4314        2.298      -0.5871       -1.446                    0.8128       1.7130
4595     -7.350          +      0.4857        2.266                    -1.525      -0.1409       0.8892       1.6560
     cnd(I(ndt.std^2)) cnd(ndw.std) cnd(ptc.std) cnd(I(ptc.std^2)) cnd(tri.std) df   logLik  AICc weight
4563           -0.9849                                                  -0.5217 10 -267.763 555.7  0.111
4571           -1.1110                                                  -0.4833 11 -266.814 555.9  0.104
5083           -1.0540       0.4666                                     -0.5140 12 -265.811 555.9  0.102
5075           -0.9254       0.4202                                     -0.5540 11 -266.939 556.1  0.091
5587           -0.9582                  -0.57100                        -0.5367 11 -267.406 557.1  0.057
5595           -1.0890                  -0.61220                        -0.4985 12 -266.393 557.1  0.057
6107           -1.0330       0.4573     -0.58230                        -0.5275 13 -265.436 557.2  0.053
4570           -1.0540                                                  -0.4796 10 -268.518 557.2  0.052
8155           -1.0340       0.5056     -0.07998            -1.780      -0.5202 14 -264.446 557.3  0.051
4562           -0.9213                                                  -0.5198  9 -269.579 557.3  0.050
475            -1.1220                                                          10 -268.568 557.3  0.050
4819                         0.4681                                     -0.5524 10 -268.652 557.5  0.046
6099           -0.9008       0.4088     -0.53500                        -0.5670 12 -266.631 557.6  0.045
4307                                                                    -0.5160  9 -269.696 557.6  0.045
7643           -1.0960                  -0.16300            -1.486      -0.4880 13 -265.622 557.6  0.044
4595           -1.0160                                                  -0.5217 11 -267.713 557.7  0.042
Models ranked by AICc(x) 
Random terms (all models): 
‘cond(1 | Annee)’, ‘cond(1 | Nom_Estive)’
```

4. Averaging on the 16 first models (delta AICc <= 2) :   
```
Model-averaged coefficients:  
(full average) 
                          Estimate Std. Error Adjusted SE z value Pr(>|z|)    
cond((Int))              -7.189840   1.684295    1.686109   4.264 2.01e-05 ***
cond(BA.std)              0.432307   0.275693    0.275924   1.567   0.1172    
cond(grass.std)           2.293886   0.329739    0.330107   6.949  < 2e-16 ***
cond(ndfoot.std)         -1.539105   0.381305    0.381744   4.032 5.54e-05 ***
cond(ndshrub.std)         0.875314   0.384690    0.385132   2.273   0.0230 *  
cond(ndtcd.std)           1.538450   0.584083    0.584619   2.632   0.0085 ** 
cond(I(ndtcd.std^2))     -0.929565   0.580988    0.581487   1.599   0.1099    
cond(tri.std)            -0.493070   0.277855    0.278124   1.773   0.0763 .  
cond(ndbuild.std)        -0.300923   0.409013    0.409244   0.735   0.4621    
cond(ndwater.std)         0.175585   0.302384    0.302548   0.580   0.5617    
cond(patchdens.std)      -0.133530   0.467323    0.467736   0.285   0.7753    
cond(I(patchdens.std^2)) -0.156302   0.650650    0.650991   0.240   0.8103    
cond(ndRoads.std)        -0.005947   0.095158    0.095260   0.062   0.9502    
 
(conditional average) 
                         Estimate Std. Error Adjusted SE z value Pr(>|z|)    
cond((Int))               -7.1898     1.6843      1.6861   4.264 2.01e-05 ***
cond(BA.std)               0.4817     0.2468      0.2470   1.950   0.0512 .  
cond(grass.std)            2.2939     0.3297      0.3301   6.949  < 2e-16 ***
cond(ndfoot.std)          -1.5391     0.3813      0.3817   4.032 5.54e-05 ***
cond(ndshrub.std)          0.8753     0.3847      0.3851   2.273   0.0230 *  
cond(ndtcd.std)            1.5385     0.5841      0.5846   2.632   0.0085 ** 
cond(I(ndtcd.std^2))      -1.0221     0.5259      0.5265   1.941   0.0522 .  
cond(tri.std)             -0.5189     0.2605      0.2608   1.990   0.0466 *  
cond(ndbuild.std)         -0.5876     0.3978      0.3982   1.476   0.1401    
cond(ndwater.std)          0.4530     0.3320      0.3324   1.363   0.1729    
cond(patchdens.std)       -0.4351     0.7618      0.7627   0.570   0.5683    
cond(I(patchdens.std^2))  -1.6437     1.4167      1.4184   1.159   0.2465    
cond(ndRoads.std)         -0.1409     0.4422      0.4427   0.318   0.7503    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Relative variable importance: 
                     cond(grass.std) cond(ndfoot.std) cond(ndshrub.std) cond(ndtcd.std) cond(tri.std)
Importance:          1.00            1.00             1.00              1.00            0.95         
N containing models:   16              16               16                16              15         
                     cond(I(ndtcd.std^2)) cond(BA.std) cond(ndbuild.std) cond(ndwater.std) cond(patchdens.std)
Importance:          0.91                 0.90         0.51              0.39              0.31               
N containing models:   14                   14            8                 6                 6               
                     cond(I(patchdens.std^2)) cond(ndRoads.std)
Importance:          0.10                     0.04             
N containing models:    2                        1  
```

5. Checking model assumptions with bubble plot and correlogram and moran's I test on the full model and best model : 
For full model : 
```
> tes.mor

	Moran I test under randomisation

data:  res.mod  
weights: tabV.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.3251, p-value = 1.193e-13
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
     7.207171e-02     -1.059322e-03      9.967218e-05 
``` 


