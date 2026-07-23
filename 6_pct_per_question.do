

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
* 3. IMPROVEMENT PER QUESTION
*------------------------------------------------------

use "${CLEAN}/master_analysis_ready.dta", clear

* A) Create improve_q1-improve_q20 (1=el>bl, 0=else, .=missing)
forvalues q = 1/20 {
    capture drop improve_q`q'
    gen byte improve_q`q' = .

    replace improve_q`q' = 1 if el_q_`q' > bl_q_`q'
    replace improve_q`q' = 0 if !missing(el_q_`q') & !missing(bl_q_`q') & el_q_`q' <= bl_q_`q'
}

summ improve_q1 improve_q2 improve_q3
tab improve_q1, missing



* B) Percent improved per question 
tempname handle
tempfile results

postfile `handle' int question double pct_improved using "`results'", replace

forvalues q = 1/20 {
    quietly count if improve_q`q' == 1
    local improved = r(N)

    quietly count if !missing(improve_q`q')
    local total = r(N)

    local pct = 100 * (`improved' / `total')

    post `handle' (`q') (`pct')
}

postclose `handle'

use "`results'", clear
list, noobs


* C) rename
rename pct_improved pct_improved
label var question "Question number"
label var pct_improved "Percent improved (endline > baseline)"

format pct_improved %6.2f

list, noobs


save "${CLEAN}/pct_improved_per_question.dta", replace
export excel using "${OUTPUT}/pct_improved_per_question.xlsx", firstrow(variables) replace


dir "${CLEAN}"



