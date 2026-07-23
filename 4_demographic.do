
version 19
set more off

* ---- Guard: allow running standalone ----
if "$PROJ"=="" {
    global PROJ  "/Users/gunjansharma/Library/CloudStorage/OneDrive-PennO365/Work 2025/TMW_center_data_task/data"
    global XFILE "${PROJ}/Stata Exercise Data.xlsx"
    global CLEAN "${PROJ}/clean"
    global OUTPUT "${PROJ}/output"
    cap mkdir "${CLEAN}"
    cap mkdir "${OUTPUT}"
}


* Part 2: Analysis

*------------------------------------------------------
* 1.Demographic Variables:
*------------------------------------------------------

use "${CLEAN}/master_wide_cleaned.dta", clear

* datetime to daily date
gen bl_date = dofc(bl_timestamp)
format bl_date %td

gen el_date = dofc(el_timestamp)
format el_date %td

* Convert dates to month scale
gen dob_m = mofd(dob)
gen bl_m  = mofd(bl_date)
gen el_m  = mofd(el_date)

* Age in months
gen age_bl_months = bl_m - dob_m
gen age_el_months = el_m - dob_m


summ age_bl_months age_el_months
list id dob bl_date age_bl_months in 1/5

*difference b/w bl and el
gen age_diff = age_el_months - age_bl_months
summ age_diff
* it is aroubd 12 months 

summ age_bl_months age_el_months
summ age_diff


/*Note BL: 
- Around 4.2 years at youngest
- Around 7.3 years at oldest
- Average is around 5.6 years

EL:
- Around 5.3 years at youngest
- Around 8.3 years at oldest
- Avergae is around 6.6 years */


label variable age_bl_months "Age in months at baseline"
label variable age_el_months "Age in months at endline"
label variable age_diff "Age difference (months)"

save "${CLEAN}/master_analysis_ready.dta", replace
