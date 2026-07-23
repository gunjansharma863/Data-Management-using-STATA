
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


* Part 1: Data Preparation

*------------------------------------------------------
* 3. Data cleaning:
*------------------------------------------------------

use "${CLEAN}/master_wide_labeled.dta", clear

*1. duplicates and sample size

count
duplicates report id

*2.  gender
tab gender, missing

* trim spaces and standardize capitalization
replace gender = strtrim(gender)
replace gender = strproper(gender)

* fix 
replace gender = "Female" if gender=="F"
replace gender = "Male"   if gender=="M"
replace gender = "Male" if gender=="Maale"

*numric
encode gender, gen(gender_num)
label variable gender_num "Gender"
drop gender
rename gender_num gender


*3. dob
describe dob
list id dob if missing(dob) 
*note: this is string 

gen dob_date = date(dob,"YMD")
format dob_date %td
drop dob
rename dob_date dob


*4. checking range 
summ bl_q_*
summ el_q_*

foreach v of varlist bl_q_* el_q_* {
    count if `v' < 1 | `v' > 5
}

*5. checking missing 
misstable summarize bl_q_* el_q_*

egen bl_missing = rowmiss(bl_q_*)
egen el_missing = rowmiss(el_q_*)

list id bl_missing el_missing if bl_missing==20 | el_missing==20
* note: No participant is missing all 20 items at baseline or endline. 

*6. timestamps 

format bl_timestamp el_timestamp %tc
list id bl_timestamp el_timestamp in 1/5

gen time_diff = el_timestamp - bl_timestamp
summ time_diff
*endline occurred after baseline for all participants. The average time between waves was approximately one year.

save "${CLEAN}/master_wide_cleaned.dta", replace
