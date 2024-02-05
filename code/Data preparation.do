clear
cd "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi\Pubblicazione Tesi"

set more 	off
capture log close

global 	DATA "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi\Pubblicazione Tesi\AirBase Data"
log using  "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi\dataprep.log", replace

import 	excel "$DATA\PM10_2012.xlsx", firstrow

tab AirPollutionLevel
bysort 	NUTS2: egen pm10_regmean = mean(AirPollutionLevel)
tab pm10_regmean

gen region = NUTS2 
*replace	region = NUTSS if inlist(Country, "Albania","Cyprus", "Germany", "United Kingdom")

* Select only 1 obs per region
egen		pickone=tag(region)
keep if 	pickone==1

keep Country region pm10_regmean 

save	"$DATA\PM10_2012.dta", replace

*     Load ESS
use 	"$DATA\ESS6.dta", clear

gen 	weight = pweight*dweight
replace region = substr(region, 1, length(region) - 1) if cntry ==  "AL" | cntry ==  "BG" | cntry == "IE" | cntry =="IS" |cntry =="SK" | cntry == "HU" | cntry == "LT" | cntry == "SI" | cntry == "CZ"  | cntry == "EE" | cntry =="FI" | cntry =="SE"


*drop region
tab cntry
bysort 	region: egen counter=count(region)
tab region

* merge the two datasets  
keep if agea <=  80 | agea >= 18
drop if region == "-"
drop if region == ""
drop if cntry == "IL" | cntry == "RU" | cntry == "UA" | cntry == "XK"
*drop _merge
*replace	region = ESS6_reg if inlist(cntry, "IL", "RU", "UA", "XK")

merge	m:1 region using "$DATA\PM10_2012.dta"


* New Regression Model
gen pm10_regmean2 = pm10_regmean/1000

* First Index: (stflife missing from dataset)
recode pstvms (5=1) (4=2) (3=3) (2=4) (1=5), gen (posrec)
recode accdng (5=1) (4=2) (3=3) (2=4) (1=5), gen (posacc)
recode dclvlf (5=1) (4=2) (3=3) (2=4) (1=5), gen (posdec)
recode dngval (5=1) (4=2) (3=3) (2=4) (1=5), gen (posval)
gen selfsat = 2*posrec + 2*posacc + 2*posdec + 2*posval + tmimdng + tmabdng + tmendng + tnapsur + happy + stflife

tab selfsat

table region if _m == 3, c(mean selfsat)

* Second Index Unusable, as it is missing most variables.
* Control variables, to which pm10_regmean must be added.
recode health (5=1) (4=2) (3=3) (2=4) (1=5), gen(poshealth)
label def poshealth_label 1 "Very Bad" 2 "Bad" 3 "Fair" 4 "Good" 5 "Very Good" 
lab val poshealth poshealth_label


gen agea2 = agea*agea

encode region, gen(cregion)
* First Regression Attempt.

gen hinctnta2 = hinctnta
replace hinctnta2 = 11 if hinctnta == .a | hinctnta == .b | hinctnta == .c

save "DatasetArticle23", replace
// Too few observations!!! Also, how to check what is missing? Need to move on multilevel analysis.


**Multilevel regression     1) linear regression    2) empty model vs linear regression to see what changes.	3) Mixed with all the indipendent variables
reg selfsat b3.domicil i.gndr i.poshealth i.hinctnta2 agea agea2 c.pm10_regmean2


mixed selfsat  || cntry: || region: if counter >= 10, covariance(unstructured)

tab domicil, nola

mixed selfsat b3.domicil c.pm10_regmean2 i.gndr i.poshealth i.hinctnta agea agea2 || cntry: || region: if counter >= 10, covariance(unstructured)

mixed selfsat b3.domicil##c.pm10_regmean2 i.gndr i.poshealth i.hinctnta2 agea agea2 || cntry: || region:, covariance(unstructured)

tab hinctnta,nola missing


tab region pm10_regmean

table region, c(mean pm10_regmean)

corr pm10_regmean selfsat
*Redo without domicil
table domicil, c(mean pm10_regmean)

** Graphs: lines 
margins domicil#pm10_regmean2 at(pm10_regmean2=(10 (5)  40 ))


log close



