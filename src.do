* ************************************************************
* just-click.do - Self-organizing, reproducible lab file
* Designed for OS-agnostic use + graceful handoff to others
* ************************************************************

clear all
set more off

* 🌊 INIT: Declare root & core folders (relative to current location)
global root = c(pwd)
foreach folder in data output code notes {
    local `folder' "$root/`folder'"
    capture mkdir ``folder''
}

* ❤️ COMMIT: Move all .dta files into /data/ so it's clean + modular
local dtafiles : dir "$root" files "*.dta"
foreach f of local dtafiles {
    local src  "$root/`f'"
    local dest "`data'/`f'"
    copy "`src'" "`dest'", replace
    erase "`src'"
}

* 🌀 FORK: Create structure for logging & error checking
capture drop _all
log using "`output'/lab5_output.log", replace

* 🐬 BRANCH: Load and prepare data
use "`data'/transplants.dta", clear
merge 1:1 fake_id using "`data'/donors_recipients.dta"
drop if _merge != 3

* 🔁 MERGE: Create variables, apply formats, and set survival time
gen over50 = age > 50
gen f_time = end_d - transplant_d
format transplant_d end_d %td
stset f_time, failure(died)

* 📊 OUTPUT: Graph and export results
sts graph, by(over50)
graph export "`output'/survival_over50.png", replace

* ✅ CLOSE: Log and finish
log close
display "✅ All done. No errors. Outputs created."
