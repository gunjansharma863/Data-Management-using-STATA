

version 19
set more off

* ---- guard: allow running standalone ----
if "$PROJ"=="" {
    global PROJ  "/Users/gunjansharma/Library/CloudStorage/OneDrive-PennO365/Work 2025/TMW_center_data_task/data"
    global XFILE "${PROJ}/Stata Exercise Data.xlsx"
    global CLEAN "${PROJ}/clean"
    global OUTPUT "${PROJ}/output"
    cap mkdir "${CLEAN}"
    cap mkdir "${OUTPUT}"
}

*--------------------------------------------------------------------
* 1) ADMINISTRATIVE
*--------------------------------------------------------------------
import excel using "${XFILE}", sheet("administrative") firstrow clear

* drop completely blank rows
drop if missing(participant)

destring participant, replace force
rename participant id

* drop remaining missing IDs
drop if missing(id)

* uniqueness
isid id

save "${CLEAN}/admin_clean.dta", replace


*--------------------------------------------------------------------
* 2) BASELINE
*--------------------------------------------------------------------
import excel using "${XFILE}", sheet("baseline") firstrow clear

* drop completely blank rows
egen rowmiss_all = rowmiss(_all)
drop if rowmiss_all == _N
drop rowmiss_all

* drop rows without ID
drop if missing(id)

destring id, replace force

* timestamp 
capture confirm string variable timestamp
if _rc==0 {
    gen double bl_timestamp = clock(timestamp,"YMDhms")
    format bl_timestamp %tc
    drop timestamp
}
else {
    rename timestamp bl_timestamp
}

* handle string question variables
ds q_*, has(type string)
if "`r(varlist)'" != "" {
    foreach v of varlist `r(varlist)' {
        replace `v' = "" if upper(`v')=="N/A"
        destring `v', replace force
    }
}

* prefix question variables
ds q_*
foreach v of varlist `r(varlist)' {
    rename `v' bl_`v'
}

isid id

save "${CLEAN}/baseline_clean.dta", replace


*--------------------------------------------------------------------
* 3) ENDLINE
*--------------------------------------------------------------------
import excel using "${XFILE}", sheet("endline") firstrow clear

* Drop completely blank rows
egen rowmiss_all = rowmiss(_all)
drop if rowmiss_all == _N
drop rowmiss_all

drop if missing(participant)

gen id = real(regexs(1)) if regexm(participant,"([0-9]+)")
drop participant

recast int id
drop if missing(id)

* Timestamp
capture confirm string variable timestamp
if _rc==0 {
    gen double el_timestamp = clock(timestamp,"YMDhms")
    format el_timestamp %tc
    drop timestamp
}
else {
    rename timestamp el_timestamp
}

* handle string question vars
ds question__*, has(type string)
if "`r(varlist)'" != "" {
    foreach v of varlist `r(varlist)' {
        replace `v' = "" if upper(`v')=="N/A"
        destring `v', replace force
    }
}

* rename to el_q_#
ds question__*
foreach v of varlist `r(varlist)' {
    local num = subinstr("`v'","question__","",.)
    local num = real("`num'")
    rename `v' el_q_`num'
}

keep id el_timestamp el_q_*

isid id

save "${CLEAN}/endline_clean.dta", replace


*--------------------------------------------------------------------
* 4) MERGE ALL (WIDE)
*--------------------------------------------------------------------

use "${CLEAN}/admin_clean.dta", clear

merge 1:1 id using "${CLEAN}/baseline_clean.dta"
tab _merge
assert _merge==3
drop _merge

merge 1:1 id using "${CLEAN}/endline_clean.dta"
tab _merge
assert _merge==3
drop _merge

isid id

save "${CLEAN}/master_wide.dta", replace

display "1_merge.do completed successfully."

*/imported the administrative, baseline, and endline datasets from the Excel workbook and merged them 1:1 by participant ID. I kept the data in wide format so baseline and endline item responses are stored side-by-side (e.g., bl_q_1 and el_q_1), which makes it straightforward to compute change scores and compare outcomes across time. All 50 participants matched across datasets with no unmatched IDs.
