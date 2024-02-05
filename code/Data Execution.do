clear
cd "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi 1\Pubblicazione Tesi"

set more 	off
capture log close

global 	DATA "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi 1\Pubblicazione Tesi\AirBase Data"
log using  "C:\Users\patri\Desktop\PATRICK\Università\Didattica\Altro\Tesi 1\dataprep.log", replace

use 	"DatasetArticle23.dta", clear

*reg selfsat b3.domicil i.gndr i.poshealth i.hinctnta2 agea agea2 c.pm10_regmean2  marsts 

label def chldhm_label 1 "Yes" 2 "No"
lab val chldhm chldhm_label

recode hinctnta (missing = 11)
label def hinctnta_label 11 "missing"
lab val hinctnta hinctnta_label

recode mnactic (1=1) (2=2) (3=3) (4=3) (5=3) (6=3) (7=1) (8=3) (9=3), gen(mnactic2)
label def mnactic2_label 1 "Working" 2 "Studying" 3 "Retired or Unemployed" 
lab val mnactic2 mnactic2_label

recode edulvlb (0/229=1) (311/423=2) (else=3), gen(edulvlb2)
label def edulvlb_label 1 "Low" 2 "Medium" 3 "High" 
lab val edulvlb2 edulvlb_label

/*recode marsts (1=1) (2=1) (3=2) (4=2) (5=2) (6=3) (missing=4),  gen(marsts2)
label def marsts2_label 1 "In a couple" 2 "Divorced/Separated/Widowed" 3 "Single" 4 "Missing"
lab val marsts2 marsts2_label*/

mixed selfsat  || cntry: || region: if counter >= 10, covariance(unstructured)

mixed selfsat b3.domicil##c.pm10_regmean2 i.gndr b3.poshealth b5.hinctnta  i.edulvlb2 b2.chldhm i.mnactic2 agea agea2 b2.icpart1 || cntry: || region: , covariance(unstructured)

mixed selfsat b3.domicil##c.pm10_regmean2 i.gndr b3.poshealth b5.hinctnta  i.edulvlb2 b2.chldhm i.mnactic2 agea agea2 b2.icpart1|| cntry: || region: if counter >= 10, covariance(unstructured)

* We perform a robustness check
mixed stflife b3.domicil##c.pm10_regmean2 i.gndr b3.poshealth b5.hinctnta  i.edulvlb2 b2.chldhm i.mnactic2 agea agea2 b2.icpart1 || cntry: || region: , covariance(unstructured)


margins b3.domicil, at(pm10_regmean2=(10 (10) 40))
outreg2 using myreg.doc, replace ctitle(Model 1) label
/* Why is edulvlb, marsts, chldm missing?? Add them */

marginsplot

log close
