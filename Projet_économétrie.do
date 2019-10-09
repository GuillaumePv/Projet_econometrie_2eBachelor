// Création du log-file
cap log close

log using "H:\Stats\Projet\G-57.smcl", replace
use "H:\Stats\Projet\G-57.dta" , clear

// installation des modules nécessaires pour le projet

ssc install outreg
ssc install tabstatmat
ssc install coefplot

** 1. Nettoyage de la base de données **

//1.1
generate male = 0*(gender == "F")+1*(gender== "M")
label define male_label 0 "Féminin" 1 "Masculin"
label values male male_label

//1.2
generate cct = 1*(group == "CCT")+0*(group != "CCT")
generate ccttraining = 1*(group == "CCT + Training")+0*(group != "CCT + Training")
generate control = 1*(group != "CCT" & group != "CCT + Training")+0*(group == "CCT" | group == "CCT + Training")

//1.3
replace group = "1" if cct == 1
replace group = "2" if ccttraining == 1
replace group = "3" if control == 1
destring group, replace

//1.4
generate cct_male = male*cct
generate ccttraining_male = male*ccttraining

//1.5
label define group_label 1 "CCT" 2 "CCT + formation" 3 "Contrôle"
label values group group_label
label variable group "Groupe de traitement"

label define cct_label 1 "CCT" 0 "Non CCT"
label values cct cct_label
label variable cct "CCT"

label define ccttraining_label 1 "CCT + formation" 0 "Non CCT + Formation"
label values ccttraining ccttraining_label
label variable ccttraining "CCT + formation"

label define control_label 0 "Traitement" 1 "Contrôle"
label values control control_label
label variable control "Groupe de contrôle"

label variable male "Homme"

label variable age_transfer "Âge (en mois) au premier transfert"

label variable s2mother_inhs_05 "Mère vit dans le foyer"
label define s2mother_inhs_05_label 0 "Non" 1 "Oui"
label values s2mother_inhs_05 s2mother_inhs_05_label

label variable ed_mom "Années d’éducation de la mère"
label variable ed_dad "Années d’éducation du père"

rename z_tvip_06 tvip_05
label variable tvip_05 "Score au test de vocabulaire"

label variable bweight "Poids de naissance"


label variable s1male_head_05 "Homme chef de ménage"
label define s1male_head_05_label 0 "Non" 1 "Oui"
label values s1male_head_05 s1male_head_05_label

label variable s1hhsize_05 "Taille du ménage"

label variable s3awater_access_hh_05 "Accès à l’eau courante"
label define s3awater_access_hh_05_label 0 "Non" 1 "Oui"
label values s3awater_access_hh_05 s3awater_access_hh_05_label

label variable cons_food_pc_05 "Consommation de nourriture par tête"

//variable 2008

label variable z_language_08 "Score au test de langue (standardisé)"
label variable z_memory_08 "Score au test de mémoire (standardisé)"
label variable z_martians_08 "Score au test de mémoire associative (standardisé)"
label variable z_social_08 "Score au test de compétences interpersonnelles (standardisé)"
label variable z_grmotor_08 "Score au test de motricité globale (standardisé)"
label variable z_finmotor_08 "Score au test de motricité fine (standardisé)"

** 2. Statistiques Descriptives **
//2.1

tabstat male age_transfer s2mother_inhs_05 ed_mom ed_dad bweight ///
s1male_head_05 s1hhsize_05 s3awater_access_hh_05 cons_food_pc_05, ///
stat(mean sd count) by(group)  nototal save

// Tranformation matricielle
return list 
matlist r(Stat1)
matlist r(Stat2)
matlist r(Stat3)

matrix results1 = r(Stat1)'
matrix colnames results1 = Moy Ecart-type Obs
matrix coleq results1 = Groupe de Controle
matrix roweq results1 = "Homme" "Âge (en mois) au premier transfert" "Mère vit dans le foyer" "Années d’éducation de la mère" "Années d’éducation du père" "Poids de naissance" "Homme chef de ménage" "Taille du ménage" "Accès à l’eau courante" ///
"Consommation de nourriture par tête"
matlist results1

matrix results2 = r(Stat2)'
mat resultsF2 = results2[1...,1..3]
matrix colnames resultsF2 = Moy. Ecart-type Obs
matrix coleq resultsF2 = CCT CCT CCT
matlist resultsF2

matrix results3 = r(Stat3)' 
mat resultsF3 = results3[1...,1..3]
matrix colnames resultsF3 = Moy. Ecart-type Obs
matrix coleq resultsF3 = CCTTraining CCTTraining CCTTraining
matlist resultsF3

//Exportation des reésultats dans Excel

putexcel set StatDescrip.xlsx, sheet(example1) replace
putexcel A1 = matrix(results1), names nformat(number_d2)
putexcel E1 = matrix(resultsF2), names nformat(number_d2)
putexcel I1 = matrix(resultsF3), names nformat(number_d2)
putexcel A1:A11, right border(right) overwritefmt
putexcel A1:L1, hcenter bold border(bottom) overwritefmt

/* Test d'hypothèses sur la significativité de moyenne entre CCT & Contrôle 
et  CC&T + Formation & Contrôle*/

ttest male if group == 1 | group == 3, by(group)
ttest male if group == 2 | group == 3, by(group)

ttest age_transfer if group == 1 | group == 3, by(group)
ttest age_transfer if group == 2 | group == 3, by(group)

ttest s2mother_inhs_05 if group == 1 | group == 3, by(group)
ttest s2mother_inhs_05 if group == 2 | group == 3, by(group) 

ttest ed_mom if group == 1 | group == 3, by(group)
ttest ed_mom if group == 2 | group == 3, by(group)

ttest ed_dad if group == 1 | group == 3, by(group)
ttest ed_dad if group == 2 | group == 3, by(group)

ttest bweight if group == 1 | group == 3, by(group)
ttest bweight if group == 2 | group == 3, by(group)

ttest s1male_head_05 if group == 1 | group == 3, by(group)
ttest s1male_head_05 if group == 2 | group == 3, by(group)

ttest s1hhsize_05 if group == 1 | group == 3, by(group)
ttest s1hhsize_05 if group == 2 | group == 3, by(group)

ttest s3awater_access_hh_05 if group == 1 | group == 3, by(group)
ttest s3awater_access_hh_05 if group == 2 | group == 3, by(group)

ttest cons_food_pc_05 if group == 1 | group == 3, by(group)
ttest cons_food_pc_05 if group == 2 | group == 3, by(group) 

//2.2

reg male cct ccttraining
test cct = ccttraining
matrix resultsM = r(p)

reg age_transfer cct ccttraining 
test cct = ccttraining
matrix resultsA = r(p)

reg s2mother_inhs_05 cct ccttraining
test cct = ccttraining
matrix resultsSM = r(p)

reg ed_mom cct ccttraining
test cct = ccttraining
matrix resultsEM = r(p)

reg ed_dad cct ccttraining 
test cct = ccttraining
matrix resultsED = r(p)

reg bweight cct ccttraining
test cct = ccttraining
matrix resultsBW = r(p)

reg s1male_head_05 cct ccttraining
test cct = ccttraining
matrix resultsSMH = r(p)

reg s1hhsize_05 cct ccttraining
test cct = ccttraining
matrix resultsSH = r(p)

reg s3awater_access_hh_05 cct ccttraining
test cct = ccttraining
matrix resultsSW = r(p)

reg cons_food_pc_05 cct ccttraining
test cct = ccttraining
matrix resultsCF = r(p)

matrix t_all = resultsM\resultsA\resultsSM\resultsEM\resultsED\resultsBW\resultsSMH\ ///
resultsSH\resultsSW\resultsCF
matrix roweq t_all = "Homme" "Âge (en mois) au premier transfert" "Mère vit dans le foyer" "Années d’éducation de la mère" "Années d’éducation du père" "Poids de naissance" "Homme chef de ménage" "Taille du ménage" "Accès à l’eau courante" ///
"Consommation de nourriture par tête"
matlist t_all
putexcel M1 = matrix(t_all), names nformat(number_d2)

** 3. Analyse d'impact **

//3.1
// regression simple
reg z_language_08 cct ccttraining, robust
outreg2 z_language_08 using result.xls,replace label

reg z_memory_08 cct ccttraining, robust
outreg2 z_memory_08 using result.xls,append label

reg z_martians_08 cct ccttraining, robust
outreg2 z_martians_08 using result.xls,append label

reg z_social_08 cct ccttraining, robust
outreg2 z_social_08 using result.xls,append label

reg z_grmotor_08 cct ccttraining, robust
outreg2 z_grmotor_08 using result.xls,append label

reg z_finmotor_08 cct ccttraining, robust
outreg2 z_finmotor_08 using result.xls,append label

//Ajout variables de controle
reg z_language_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 , robust
outreg2 z_language_08 using result.xls,append label

reg z_memory_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, robust
outreg2 z_memory_08 using result.xls,append label

reg z_martians_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, robust
outreg2 z_martians_08 using result.xls,append label

reg z_social_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, robust
outreg2 z_social_08 using result.xls,append label

reg z_grmotor_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, robust
outreg2 z_grmotor_08 using result.xls,append label

reg z_finmotor_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, robust
outreg2 z_finmotor_08 using result.xls,append label

// Ajout du cluster + test d'hypothèses (CCT=CCTtraining)
reg z_language_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_language_08 using result.xls,append label

reg z_memory_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_memory_08 using result.xls,append label

reg z_martians_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_martians_08 using result.xls,append label

reg z_social_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_social_08 using result.xls,append label

reg z_grmotor_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_grmotor_08 using result.xls,append label

reg z_finmotor_08 cct ccttraining male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
test cct = ccttraining
outreg2 z_finmotor_08 using result.xls,append label

//3.2
ttest z_language_08, by(cct)
ttest z_language_08, by(ccttraining)

ttest z_memory_08, by(cct)
ttest z_memory_08, by(ccttraining)

ttest z_martians_08, by(cct)
ttest z_martians_08, by(ccttraining)

ttest z_social_08, by(cct)
ttest z_social_08, by(ccttraining)

ttest z_grmotor_08, by(cct)
ttest z_grmotor_08, by(ccttraining)

ttest z_finmotor_08, by(cct)
ttest z_finmotor_08, by(ccttraining)

// *** 4. Hétérogénéité ***

// regression de z_langage_08 et z_gmotor_08 (Sans la variable de controle male et avec cluster)
reg z_language_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)
outreg2 z_language_08 using heteroStrat1.xls,replace label alpha(0.01, 0.05, 0.1) ctitle("Garçons")

reg z_language_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
outreg2 z_language_08 using heteroStrat1.xls,append label alpha(0.01, 0.05, 0.1) ctitle("Filles")

reg z_grmotor_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)
outreg2 z_grmotor_08 using heteroStrat1.xls,append label alpha(0.01, 0.05, 0.1) ctitle("Garçons")

reg z_grmotor_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
outreg2 z_grmotor_08 using heteroStrat1.xls,append label alpha(0.01, 0.05, 0.1) ctitle("Filles")

//4.1.2

** test d'hypothèses pour le langage **

reg z_language_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)
return list
matrix reg = r(table)
matrix list reg

scalar blg = reg[1,1]
scalar eclg = reg[2,1]

reg z_language_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
return list
matrix reg = r(table)
matrix list reg

scalar blf = reg[1,1]
scalar eclf = reg[2,1]

// test de student au seil de 5%
scalar tstatl = (blg-blf)/(eclg+eclf)

// calcul de la p-valeur
scalar pvaluel = 1 - normal(tstatl)

** test d'hypothèses pour la motricité **
reg z_grmotor_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)
return list
matrix reg = r(table)
matrix list reg

scalar bmg = reg[1,1]
scalar ecmg = reg[2,1]

reg z_grmotor_08 cct age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
return list
matrix reg = r(table)
matrix list reg

scalar bmf = reg[1,1]
scalar ecmf = reg[2,1]

// test de student au seil de 5%
scalar tstat2 = (bmg-bmf)/(ecmg+ecmf)

// calcul de la p-valeur
scalar pvalue2 = 1 - normal(tstat2)
scalar list

test cct,by(male)
test blg = blf

// 4.2 2e Stratégie : termes d'interactions

// 4.2.1
reg z_language_08 cct male cct_male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
outreg2 z_language_08 using heteroStrat2.xls,replace label alpha(0.01, 0.05, 0.1) ctitle("langue")

reg z_grmotor_08 cct male cct_male age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05, cluster(unique_05)
outreg2 z_grmotor_08 using heteroStrat2.xls,append label alpha(0.01, 0.05, 0.1) ctitle("motricité global")

// **5. Graphiques **

// impact sur le test de langage
eststo LH: reg z_language_08 ccttraining age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)


eststo LF: reg z_language_08 ccttraining age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
coefplot (LF, label(Femme) barwidth(0.15) color(*.6))(LH, label(Homme) barwidth(0.15) color(*.6))  ///
, yline(0) ytitle(Pourcentage) ylabel(.0 "0" .1 "10" .2 "20" .3 "30" .4 "40") xtitle(Test de Langage) title(Impact sur le test de Langage, color(*.6)) recast(bar) drop(_cons age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05) citop vertical ciopts(recast(rcap)) barwidt(0.3) name(graph_langage, replace) nodraw graphregion(color(white))


// Impact sur le test de motricité globale
eststo MH: reg z_grmotor_08 ccttraining age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male == 1, cluster(unique_05)

eststo MF: reg z_grmotor_08 ccttraining age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05 if male != 1, cluster(unique_05)
coefplot (MF, label(Femme) barwidth(0.15) color(*.6))(MH, label(Homme) barwidth(0.15) color(*.6))  ///
, yline(0) ytitle(Pourcentage) ylabel( -.4 "-40"  -.2 "-20" "0" .2 "20" .4 "40") xtitle(Test de Motricité Globale) title(Impact sur le test de Motricité Globale, color(*.6)) recast(bar) drop(_cons age_transfer s2mother_inhs_05 ///
ed_mom ed_dad bweight s1male_head_05 s1hhsize_05 s3awater_access_hh_05 ///
cons_food_pc_05) citop vertical ciopts(recast(rcap)) barwidt(0.3) name(graph_motricite, replace) nodraw graphregion(color(white))


graph combine graph_langage graph_motricite, col(2)
save "H:\Stats\Projet\G-57-mod.dta", replace

//fermeture du fichier log
log close 

//Tranformation du fichier log en fichier PDF
translate G-57.smcl G-57.pdf
