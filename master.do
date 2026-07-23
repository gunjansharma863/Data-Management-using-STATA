/*----------------------------------------------------------------------
Author(s):  Gunjan Sharma
Date:       Feb 18, 2026      
------------------------------------------------------------------------ */


/*-----------------------------------------------------------------------
 Master do-file 
----------------------------------------------------------------------- */


clear all
version 19
set more off
set varabbrev off
cap log close

* Global
global PROJ "/Users/gunjansharma/Library/CloudStorage/OneDrive-PennO365/Work 2025/TMW_center_data_task"

* Folders
global DO     "${PROJ}/do"
global DATA   "${PROJ}/data"
global CLEAN  "${PROJ}/clean"
global OUTPUT "${PROJ}/output"
global LOGS   "${PROJ}/logs"

* Inputs
global XFILE  "${DATA}/Stata Exercise Data.xlsx"

* Folders 
cap mkdir "${CLEAN}"
cap mkdir "${OUTPUT}"
cap mkdir "${LOGS}"

* log
log using "${LOGS}/master_run.log", replace text


* Runing pipeline
do "${DO}/1_merge.do"
do "${DO}/2_variable_labels.do"
do "${DO}/3_clean.do"
do "${DO}/4_demographic.do"
do "${DO}/5_score_streak.do"
do "${DO}/6_pct_per_question.do"
do "${DO}/7_visualization.do"

cap log close



