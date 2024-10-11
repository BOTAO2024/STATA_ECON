******************************************      FIGURE CODE         ***************************************
***********************************************BY BOTAO ZHAO********************************************************
*********************************************************************************************************************
// last update: 11 OCT 2024

clear all

* Load the dataset
use "~path/data.dta", clear

* Convert StartHour (your time series variable) to a datetime format
gen double datetime = StartHour
format datetime %tc

* Extract the date portion (without time)
gen date = dofc(datetime)
format date %td

* Generate a monthly date variable
gen month = mofd(date)
format month %tm

* Collapse the data by month (summing the outage values)
collapse (sum) independent_variable_1, independent_variable_2, independent_variable_3, by(month)

* Calculate cumulative sums for stacking
gen cum_independent_variable_1 = independent_variable_1
gen cum_independent_variable_2 = cum_independent_variable_1 + independent_variable_2
gen cum_independent_variable_3 = cum_independent_variable_2 + independent_variable_3

* Create a variable with zeros for the base of the bars
gen zero = 0

* Decide on label frequency
local label_freq = 4

* Initialize xlabels macro
local xlabels

/////
* Simple way to deal with the month xlabels, but not readable
* format month %tmMon_CCYY
/////

/////
* Here is a better way to deal with the month xlabels, which could make the data more readable *
* Loop over observations to create custom labels
forvalues i = 1/`=_N' {
    if mod(`i', `label_freq') == 1 {
        * Get the month value and its formatted label
        local month_value = month[`i']
        local month_label = "`=string(month[`i'], "%tmMon_CCYY")'"
        * Add to xlabels macro
        local xlabels `xlabels' `month_value' "`month_label'"
    }
}
/////

* Format the month to %tm
gen month_date = month  //
format month_date %tm                  // Format as monthly date

* Generate 2 new empty variables to prepare for the text on bar
gen y_label = .
gen label_text = ""

//--------------------
***********  Key Step ************
* Create capped variables
gen cum_independent_variable_1_capped = min(cum_independent_variable_1, 200000000)
gen cum_independent_variable_2_capped = min(cum_independent_variable_2, 200000000)
gen cum_independent_variable_3_capped = min(cum_independent_variable_3, 200000000)

// Locate the position of text or number on chart
* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_independent_variable_3 - 70000000) if month_date >= tm(2018m12) & month_date <= tm(2018m12)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_independent_variable_3, "%9.0f") if month_date >= tm(2018m12) & month_date <= tm(2018m12)

* continue the same steps to make other numbers display
replace y_label = (cum_independent_variable_3 - 90000000) if month_date >= tm(2019m12) & month_date <= tm(2019m12)
replace label_text = string(cum_independent_variable_3, "%9.0f") if month_date >= tm(2019m12) & month_date <= tm(2019m12)

replace y_label = (cum_independent_variable_3 - 230000000) if month_date >= tm(2020m2) & month_date <= tm(2020m2)
replace label_text = string(cum_independent_variable_3, "%9.0f") if month_date >= tm(2020m2) & month_date <= tm(2020m2)

* Plot the stacked bar chart
twoway ///
    (rbar zero cum_independent_variable_1_capped month, color(blue)) ///
    (rbar cum_independent_variable_1_capped cum_independent_variable_2_capped month, color(green)) ///
    (rbar cum_independent_variable_2_capped cum_independent_variable_3_capped month, color(orange)) ///
    (scatter y_label month, msymbol(none) ///
        mlabel(label_text) mlabcolor(black) mlabposition(above)), ///
    ylabel(, format(%9.0f) angle(0)) ///
    ytitle("y-name") ///
    xlabel(`xlabels', angle(90)) ///
    xtitle("Month") ///
    legend(order(1 "independent_variable_1" 2 "independent_variable_2" 3 "independent_variable_3") ///
        cols(4) position(6)) ///
    title("name of chart")


* Export the graph to PNG format
graph export "~path/name.png", as(png) replace
