/*---------------------------------------------------------------------
Author:  Gunjan Sharma
Purpose: visualization
Note: This is something I was exploring, is not part of the data task

---------------------------------------------------------------------*/

clear all
set more off
set varabbrev off

* ---- Guard: allow running standalone ----
if "$PROJ"=="" {
    global PROJ  "/Users/gunjansharma/Library/CloudStorage/OneDrive-PennO365/Work 2025/TMW_center_data_task/data"
    global XFILE "${PROJ}/Stata Exercise Data.xlsx"
    global CLEAN "${PROJ}/clean"
    global OUTPUT "${PROJ}/output"
    cap mkdir "${CLEAN}"
    cap mkdir "${OUTPUT}"
}


use "${CLEAN}/master_analysis_ready.dta", clear



* ----------------------- DESCRIPTIVE -----------------------
* Create mean scores

capture confirm variable bl_mean_score
if _rc {
    egen bl_mean_score = rowmean(bl_q_1-bl_q_20)
}

capture confirm variable el_mean_score
if _rc {
    egen el_mean_score = rowmean(el_q_1-el_q_20)
}


* 1) Box Plot- bl vs el Mean Score

graph box bl_mean_score el_mean_score, ///
    title("Figure 1. Baseline vs Endline Mean Scores") ///
    ytitle("Mean score (Q1–Q20)") ///
    legend(order(1 "Baseline" 2 "Endline")) ///
    scheme(s2mono)

graph export "${OUTPUT}/fig1_box_bl_el_mean.png", replace



* 2) Scatter Plot


twoway ///
(scatter el_mean_score bl_mean_score, mcolor(navy)) ///
(function y=x, range(bl_mean_score) lpattern(dash)), ///
title("Figure 2. Endline vs Baseline Mean Scores") ///
xtitle("Baseline mean score") ///
ytitle("Endline mean score") ///
legend(off) ///
scheme(s2mono)

graph export "${OUTPUT}/fig2_scatter_bl_el.png", replace


* 3) Histogram: bl 


histogram bl_mean_score, percent ///
    title("Figure 3. Distribution of Baseline Mean Scores") ///
    xtitle("Baseline mean score") ///
    ytitle("Percent") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig3_hist_baseline.png", replace


* 4) Histogram: el 

histogram el_mean_score, percent ///
    title("Figure 4. Distribution of Endline Mean Scores") ///
    xtitle("Endline mean score") ///
    ytitle("Percent") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig4_hist_endline.png", replace



*both bl and el
twoway ///
(histogram bl_mean_score, percent color(navy%40)) ///
(histogram el_mean_score, percent color(red%40)), ///
legend(label(1 "Baseline") label(2 "Endline")) ///
title("Baseline vs Endline Distribution")

graph export "${OUTPUT}/fig5_hist_el_bl.png", replace

* 5) Improvement % per Question (Sorted Bar Chart)

preserve

tempname handle
tempfile results

postfile `handle' int question double pct_improved using "`results'", replace

forvalues q = 1/20 {
    quietly count if el_q_`q' > bl_q_`q'
    local improved = r(N)

    quietly count if !missing(el_q_`q') & !missing(bl_q_`q')
    local total = r(N)

    local pct = 100 * (`improved' / `total')
    post `handle' (`q') (`pct')
}

postclose `handle'

use "`results'", clear
format pct_improved %6.1f

gsort -pct_improved

graph hbar pct_improved, ///
    over(question, sort(pct_improved) descending) ///
    title("Figure 5. Percent Improved by Question") ///
    ytitle("Percent improved") ///
    scheme(s2mono)
	

graph export "${OUTPUT}/fig6_pct_improved.png", replace


restore




* 6) Gender

* boxplot
graph box bl_mean_score el_mean_score, ///
    over(gender) ///
    title("Baseline vs Endline Mean Score by Gender") ///
    ytitle("Mean score (Q1–Q20)") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig_gender_box.png", replace

*bargraph
preserve
collapse (mean) bl_mean_score el_mean_score, by(gender)

graph bar bl_mean_score el_mean_score, ///
    over(gender) ///
    legend(order(1 "Baseline" 2 "Endline")) ///
    title("Mean Scores by Gender") ///
    ytitle("Mean score") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig_gender_bar.png", replace
restore



* 7) Age

*a age groups 
gen age_group = .
replace age_group = 1 if age_bl_months < 60
replace age_group = 2 if age_bl_months >= 60 & age_bl_months < 75
replace age_group = 3 if age_bl_months >= 75

label define agegrp 1 "Under 5" 2 "5–6 years" 3 "7+ years"
label values age_group agegrp


*boxplot
graph box bl_mean_score el_mean_score, ///
    over(age_group) ///
    title("Baseline vs Endline Mean Score by Age Group") ///
    ytitle("Mean score (Q1–Q20)") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig_age_box.png", replace


*mean
preserve
collapse (mean) bl_mean_score el_mean_score, by(age_group)

graph bar bl_mean_score el_mean_score, ///
    over(age_group) ///
    legend(order(1 "Baseline" 2 "Endline")) ///
    title("Mean Scores by Age Group") ///
    ytitle("Mean score") ///
    scheme(s2mono)

graph export "${OUTPUT}/fig_age_bar.png", replace
restore

* 8) Tables


* 8.1 Age group mean table + graph

preserve

collapse (mean) bl_mean_score el_mean_score, by(age_group)

format bl_mean_score el_mean_score %6.2f
label var bl_mean_score "Baseline mean score"
label var el_mean_score "Endline mean score"

* excel
export excel using "${OUTPUT}/table_age_group_means.xlsx", ///
    firstrow(variables) replace

restore




display "All visualizations saved to ${OUTPUT}"

