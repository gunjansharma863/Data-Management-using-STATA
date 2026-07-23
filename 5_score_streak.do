
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
* 2. SCORE STREAK
*------------------------------------------------------

use "${CLEAN}/master_analysis_ready.dta", clear

*----------- BASELINE -----------

gen bl_streak = .
gen str200 bl_streak_list = ""

quietly {

    forvalues i = 1/`=_N' {

        local maxstreak = 1
        local currstreak = 1
        local bestlist ""
        local currlist = string(bl_q_1[`i'])

        forvalues q = 2/20 {

            local prev = bl_q_`=`q'-1'[`i']
            local curr = bl_q_`q'[`i']

            if missing(`prev') | missing(`curr') {
                local currstreak = 1
                local currlist = string(`curr')
            }
            else if `curr' >= `prev' {
                local currstreak = `currstreak' + 1
                local currlist = "`currlist', " + string(`curr')
            }
            else {
                local currstreak = 1
                local currlist = string(`curr')
            }

            if `currstreak' > `maxstreak' {
                local maxstreak = `currstreak'
                local bestlist = "`currlist'"
            }
        }

        replace bl_streak = `maxstreak' in `i'
        replace bl_streak_list = "`bestlist'" in `i'
    }
}


*----------- ENDLINE -----------


gen el_streak = .
gen str200 el_streak_list = ""

quietly {

    forvalues i = 1/`=_N' {

        local maxstreak = 1
        local currstreak = 1
        local bestlist ""
        local currlist = string(el_q_1[`i'])

        forvalues q = 2/20 {

            local prev = el_q_`=`q'-1'[`i']
            local curr = el_q_`q'[`i']

            if missing(`prev') | missing(`curr') {
                local currstreak = 1
                local currlist = string(`curr')
            }
            else if `curr' >= `prev' {
                local currstreak = `currstreak' + 1
                local currlist = "`currlist', " + string(`curr')
            }
            else {
                local currstreak = 1
                local currlist = string(`curr')
            }

            if `currstreak' > `maxstreak' {
                local maxstreak = `currstreak'
                local bestlist = "`currlist'"
            }
        }

        replace el_streak = `maxstreak' in `i'
        replace el_streak_list = "`bestlist'" in `i'
    }
}


*--------

list id bl_streak bl_streak_list in 1/5
list id el_streak el_streak_list in 1/5


gen bl_count_check = wordcount(bl_streak_list)
gen el_count_check = wordcount(el_streak_list)

list id bl_streak bl_count_check if bl_streak != bl_count_check
list id el_streak el_count_check if el_streak != el_count_check


*label
label variable bl_streak "Baseline longest non-decreasing score streak"
label variable el_streak "Endline longest non-decreasing score streak"
label variable bl_streak_list "Baseline score streak values"
label variable el_streak_list "Endline score streak values"


save "${CLEAN}/score_streaks.dta", replace
export excel using "${OUTPUT}/score_streaks.xlsx", firstrow(variables) replace

save "${CLEAN}/master_analysis_ready.dta", replace

