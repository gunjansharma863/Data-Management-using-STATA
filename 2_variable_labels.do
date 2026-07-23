
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
* 2) VARIABLE LABELS (generate label commands, then run)
*------------------------------------------------------

use "${CLEAN}/master_wide.dta", clear

* temporary do-file of label commands
tempname fh
tempfile lbl_do

file open `fh' using "`lbl_do'", write text replace
file write `fh' "* Auto-generated variable label commands" _n

preserve
    * Import label sheet (comes in as A and B)
    import excel using "${XFILE}", sheet("variable labels") clear
    rename A qname
    rename B qlabel

    * Drop header row and blanks
    drop if lower(qname)=="variable"
    drop if missing(qname)

    * Build suffix: "Question 1" to "1", "Question 10_Old" to "10_old"
    gen suf = lower(qname)
    replace suf = subinstr(suf, "question", "", .)
    replace suf = subinstr(suf, " ", "", .)
    replace suf = strtrim(suf)

    quietly count
    forvalues i = 1/`r(N)' {
        local s = suf[`i']
        local l = qlabel[`i']

        file write `fh' `"capture label variable bl_q_`s' "`l'""' _n
        file write `fh' `"capture label variable el_q_`s' "`l'""' _n
    }
restore

file close `fh'

* Run the generated label commands on the master dataset
do "`lbl_do'"


save "${CLEAN}/master_wide_labeled.dta", replace

