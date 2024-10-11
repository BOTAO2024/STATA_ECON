****************************************** OUTAGE FIGURE 1, 2 CODE ***************************************
***********************************************BY BOTAO ZHAO********************************************************
*********************************************************************************************************************
* Instructions *
* Please change the path before the "/Outage_1523/". The path after this has been set. *
* In summary, this code has 2 sections: data and figure *
* The data section consists of 7 steps. e.g., "1. Appending All seperate combined files"
* The figure section consists of 2 steps. 


*** 2. Check the time 
clear all
*******
* open the un-checked document
use "~/Desktop/Outage_1523/Outage_appended.dta", clear 

* drop process /// drop the non reasonable time
drop if avedurmin == .
egen tag = tag(startdate starttime customersinterrupted avedurmin reason)
sum tag
drop if tag == 0
sort Date
drop tag
gen Date2 = startdate
replace Date2 = "." if Date < .
replace Date2 = "" if Date2 == "."
gen double Date3 = date(Date2, "MDY")
format Date3 %td
replace Date = Date3 if Date == .
drop Date2
drop Date3

******************************************************************************************

*** 3. Hourly Outage Allocation ***

* Drop the reasons that are not used in this research
drop if reason == "Planned"
drop if reason == "Planned Outage"
drop if mod(customersinterrupted, 1) > 0
* number fractional customer number was excluded from the dataset
* number events of Planned Outage
* 173,346 events of non-planned 
replace avedurmin = 30000 if avedurmin > 30000
* 20 events were capped at 30,000 minutes

* Drop seconds from start time
*The gen clean_starttime = substr(starttime, 1, 5) line extracts only the first 5 characters from the starttime variable (hours and minutes).
*This new variable clean_starttime is then used to generate the starting time without the seconds.
gen clean_starttime = substr(starttime, 1, 5)

* Generate Starting Time with Date
gen dt = startdate + " " + clean_starttime
gen double StartingTime = clock(dt, "DM20Y hm")
format StartingTime %tc
label variable StartingTime "Starting Time of the outage"
generate Date2 = dofc(StartingTime)
format Date2 %td

* Create the Hour that the outage starts, e.g., 13:00
gen hour = hh(StartingTime)
tostring hour, replace
gen WHOLEHOUR = hour + ":" + "00"
gen WHOLEHOUR_DAY = startdate + " " + WHOLEHOUR

gen double StartHour = clock(WHOLEHOUR_DAY, "DMY hm")
format StartHour %tc
label variable StartHour "Starting Hour of the outage"

gen Ngavedurmin = -avedurmin
sort Ngavedurmin

**** Save the allocation file 
save "~/Desktop/Outage_1523/Outage_hourly_allocation.dta", replace

******************************************************************************************


*** 4. Replace reasons with numbers 

clear all

use "~/Desktop/Outage_1523/Outage_hourly_allocation.dta", clear
* Trim leading and trailing spaces from reason
replace reason = trim(reason)

* Replace reasons with exact match
replace reason = "1" if reason == "Weather"
replace reason = "2" if reason == "Vegetation"
replace reason = "3" if reason == "Asset failure"
replace reason = "3" if reason == "Asset Failure"
replace reason = "3" if reason == "Equipment failure"
replace reason = "4" if reason == "Other"
replace reason = "5" if reason == "Animal"
replace reason = "6" if reason == "Third party"
replace reason = "6" if reason == "Third Party"
replace reason = "7" if reason == "Unknown"
replace reason = "8" if reason == "Network business"
replace reason = "8" if reason == "Network Business"
replace reason = "9" if reason == "Overloads"
replace reason = "9" if reason == "Overload"

replace reason = "10" if reason == "5 - STPIS Exclusion (3.3(a))"
*for typo in original data
replace reason = "10" if reason == "5 - STPIS Exclusion (3.3)(a)"
*********************
replace reason = "11" if reason == "6 - Exclusion (3.3(a))"
*for typo
replace reason = "11" if reason == "6 - STPIS Exclusion (3.3)(a)"
replace reason = "11" if reason == "6 - Exclusion (STPIS 3.3(a))"

replace reason = "11" if reason == "6 - STPIS (3.3(a))"
*********************
replace reason = "12" if reason == "7 - Exclusion (STPIS 3.3(a))"
*for typo in original data
replace reason = "12" if reason == "7 - STPIS Exclusion (3.3)(a)"
*********************
replace reason = "13" if reason == "4 - STPIS (3.3(a))"
replace reason = "13" if reason == "7 - STPIS Exclusion (3.3)(b)"

*for typo
replace reason = "13" if reason == "4 - STPIS Exclusion (3.3)(a)"
replace reason = "6" if reason == "8 - STPIS Exclusion (3.3)(c)"
replace reason = "6" if reason == "8 - STPIS Exclusion (3.3)(a)"
replace reason = "1" if reason == "3-STPIS Exclusion (3.3)(a)"


* Convert to numeric
destring reason, replace

* Calculate Customer_Minute_Outage
gen Customer_Minute_Outage = customersinterrupted * avedurmin

* Collapse the data
collapse (sum) avedurmin (sum) Customer_Minute_Outage, by(StartHour reason)

******************************************************************************************


*** 5. Reshape

drop avedurmin
rename Customer_Minute_Outage OutageTimeOS

* Proceed with the reshape using the numeric reason variable
reshape wide OutageTimeOS, i(StartHour) j(reason)
 
* Replace the null data
replace OutageTimeOS1 = 0 if OutageTimeOS1 >= .
replace OutageTimeOS2 = 0 if OutageTimeOS2 >= .
replace OutageTimeOS3 = 0 if OutageTimeOS3 >= .
replace OutageTimeOS4 = 0 if OutageTimeOS4 >= .
replace OutageTimeOS5 = 0 if OutageTimeOS5 >= .
replace OutageTimeOS6 = 0 if OutageTimeOS6 >= .
replace OutageTimeOS7 = 0 if OutageTimeOS7 >= .
replace OutageTimeOS8 = 0 if OutageTimeOS8 >= .
replace OutageTimeOS9 = 0 if OutageTimeOS9 >= .
replace OutageTimeOS10 = 0 if OutageTimeOS10 >= .
replace OutageTimeOS11 = 0 if OutageTimeOS11 >= .
replace OutageTimeOS12 = 0 if OutageTimeOS12 >= .
replace OutageTimeOS13 = 0 if OutageTimeOS13 >= .


* Rename the number of reasons back to readable reasons 
rename OutageTimeOS1 Weather_OS
rename OutageTimeOS2 Vegetation_OS
rename OutageTimeOS3 Asset_Failure_OS
rename OutageTimeOS4 Other_OS
rename OutageTimeOS5 Animal_OS
rename OutageTimeOS6 Third_Party_OS
rename OutageTimeOS7 Unknown_OS
rename OutageTimeOS8 Network_Business_fault_OS
rename OutageTimeOS9 Overloads_OS
rename OutageTimeOS10 Shared_Transmission_Failure_OS
rename OutageTimeOS11 Transmission_Asset_OS
rename OutageTimeOS12 Legislation_OS
rename OutageTimeOS13 Direction_of_AEMO_OS

* Save the file prepare for Figure 1
save "~/Desktop/Outage_1523/OnSet_OutageMinute.dta", replace

// Save another dta for merge
rename StartHour DateTime
save "~/Desktop/Outage_1523/Outage_Cause_Merge.dta", replace

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
***************************************
* The location classification *

*** 6. replace location with numbers 
clear all
* this document is from step 4
use "~/Desktop/Outage_1523/Outage_hourly_allocation.dta"

* Trim leading and trailing spaces from location
replace location = trim(location)

* Replace location with exact match
replace location = "1" if location == "Long Rural"
replace location = "1" if location == "Rural Long"
replace location = "1" if location == "Long rural"
replace location = "1" if location == "long rural"
replace location = "1" if location == "LONG RURAL"
replace location = "2" if location == "Short Rural"
replace location = "2" if location == "short rural"
replace location = "2" if location == "Short rural"
replace location = "2" if location == "SHORT RURAL"
replace location = "2" if location == "Rural Short"
replace location = "3" if location == "Urban"
replace location = "3" if location == "URBAN"
replace location = "3" if location == "CBD"

* Convert to numeric
destring location, replace

* Calculate Customer_Minute_Outage
gen Customer_Minute_Outage = customersinterrupted * avedurmin

* Collapse the data
collapse (sum) avedurmin (sum) Customer_Minute_Outage, by(StartHour location)


******************************************************************************************

*** 7. Reshape the location 

* prepare for the reshape 
drop avedurmin
rename Customer_Minute_Outage OutageTimeOS

* Proceed with the reshape using the numeric location variable
reshape wide OutageTimeOS, i(StartHour) j(location)
 

replace OutageTimeOS1 = 0 if OutageTimeOS1 >= .
replace OutageTimeOS2 = 0 if OutageTimeOS2 >= .
replace OutageTimeOS3 = 0 if OutageTimeOS3 >= .

// name the locations 

rename OutageTimeOS1 Long_Rural
rename OutageTimeOS2 Short_Rural
rename OutageTimeOS3 Urban_CBD

* Save the location file and prepare for the figure 2
save "~/Desktop/Outage_1523/Outage_Location_Final.dta", replace

// Save another dta for merge
rename StartHour DateTime
gen Total_Outage = Long_Rural + Short_Rural + Urban_CBD
save "~/Desktop/Outage_1523/Outage_Location_Merge.dta", replace


//////////////****************************////////////////
***************************************************************************
************************* Figure Part ******************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************


* Figure 1 code *
* by BOTAO ZHAO *

clear all

* Load the dataset
use "~/Desktop/Outage_1523/OnSet_OutageMinute.dta", clear

* Convert StartHour to a datetime format
gen double datetime = StartHour
format datetime %tc

* Extract the date portion (without time)
gen date = dofc(datetime)
format date %td

* Generate a monthly date variable
gen month = mofd(date)
format month %tm

* Collapse the data by month (summing the outage values)
collapse (sum) Weather_OS Vegetation_OS Asset_Failure_OS Other_OS Animal_OS Third_Party_OS Unknown_OS Network_Business_fault_OS Overloads_OS Shared_Transmission_Failure_OS Transmission_Asset_OS Legislation_OS Direction_of_AEMO_OS, by(month)

* Calculate cumulative sums for stacking
gen cum_Weather = Weather_OS
gen cum_Vegetation = cum_Weather + Vegetation_OS
gen cum_AssetFailure = cum_Vegetation + Asset_Failure_OS
gen cum_Total = cum_AssetFailure + Other_OS + Animal_OS + Third_Party_OS + Unknown_OS + Network_Business_fault_OS + Overloads_OS + Shared_Transmission_Failure_OS + Transmission_Asset_OS + Legislation_OS + Direction_of_AEMO_OS

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

* Step 2: Format the month to %tm
gen month_date = month  //
format month_date %tm                  // Format as monthly date

* Step 3: Generate 2 new empty variables to prepare for the text on bar
gen y_label = .
gen label_text = ""


*********** Step 4: Key Step ************
* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 50000000) if month_date >= tm(2018m12) & month_date <= tm(2018m12)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2018m12) & month_date <= tm(2018m12)

* continue the same steps to make other numbers display
replace y_label = (cum_Total - 80000000) if month_date >= tm(2019m12) & month_date <= tm(2019m12)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2019m12) & month_date <= tm(2019m12)

replace y_label = (cum_Total - 80000000) if month_date >= tm(2020m2) & month_date <= tm(2020m2)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2020m2) & month_date <= tm(2020m2)
* Plot the stacked bar chart
twoway ///
    (rbar zero cum_Weather month, color(blue)) ///
    (rbar cum_Weather cum_Vegetation month, color(green)) ///
    (rbar cum_Vegetation cum_AssetFailure month, color(orange)) ///
    (rbar cum_AssetFailure cum_Total month, color(purple)) ///
    (scatter y_label month, msymbol(none) ///
        mlabel(label_text) mlabcolor(black) mlabposition(above)), ///
    ylabel(, format(%9.0f) angle(0)) ///
    ytitle("Outage in customer-minutes") ///
    xlabel(`xlabels', angle(90)) ///
    xtitle("Month") ///
    legend(order(1 "Weather" 2 "Vegetation" 3 "Asset Failure" 4 "Other") ///
        cols(4) position(6)) ///
    title("Outage in Customer-Minutes by Cause (Monthly)")


* Export the graph to PNG format
graph export "~/Desktop/Outage_1523/OutageMinutes_Cause_Monthly.png", as(png) replace

//--------------------
*********** Step 4: Key Step ************
* Step 1: Create capped variables
gen Weather_capped = min(cum_Weather, 200000000)
gen Vegetation_capped = min(cum_Vegetation, 200000000)
gen AssetFailure_capped = min(cum_AssetFailure, 200000000)
gen Total_capped = min(cum_Total, 200000000)

* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 70000000) if month_date >= tm(2018m12) & month_date <= tm(2018m12)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2018m12) & month_date <= tm(2018m12)

* continue the same steps to make other numbers display
replace y_label = (cum_Total - 90000000) if month_date >= tm(2019m12) & month_date <= tm(2019m12)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2019m12) & month_date <= tm(2019m12)

* continue the same steps to make other numbers display
replace y_label = (cum_Total - 230000000) if month_date >= tm(2020m2) & month_date <= tm(2020m2)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2020m2) & month_date <= tm(2020m2)

* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 30000000) if month_date >= tm(2022m2) & month_date <= tm(2022m2)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2022m2) & month_date <= tm(2022m2)

* Plot the stacked bar chart
twoway ///
    (rbar zero Weather_capped month, color(blue)) ///
    (rbar Weather_capped Vegetation_capped month, color(green)) ///
    (rbar Vegetation_capped AssetFailure_capped month, color(orange)) ///
    (rbar AssetFailure_capped Total_capped month, color(purple)) ///
    (scatter y_label month, msymbol(none) ///
        mlabel(label_text) mlabcolor(black) mlabposition(above)), ///
    ylabel(, format(%9.0f) angle(0)) ///
    ytitle("Outage in customer-minutes") ///
    xlabel(`xlabels', angle(90)) ///
    xtitle("Month") ///
    legend(order(1 "Weather" 2 "Vegetation" 3 "Asset Failure" 4 "Other") ///
        cols(4) position(6)) ///
    title("Outage in Customer-Minutes by Cause (Monthly)")


* Export the graph to PNG format
graph export "~/Desktop/Outage_1523/OutageMinutes_Cause_Capped.png", as(png) replace
******************************
* Figure 2 code *
* by BOTAO ZHAO *

clear all

* Load the dataset
use "~/Desktop/Outage_1523/Outage_Location_Final.dta", clear

* Convert StartHour to a datetime format
gen double datetime = StartHour
format datetime %tc

* Extract the date portion (without time)
gen date = dofc(datetime)
format date %td

* Generate a monthly date variable
gen month = mofd(date)
format month %tm

* Collapse the data by month (summing the outage values)
collapse (sum) Long_Rural Short_Rural Urban_CBD, by(month)

* Calculate cumulative sums for stacking
gen cum_Long_Rural = Long_Rural
gen cum_Short_Rural = cum_Long_Rural + Short_Rural
gen cum_Total = cum_Short_Rural + Urban_CBD

* Create a variable with zeros for the base of the bars
gen zero = 0

* Decide on label frequency
local label_freq = 4

* Initialize xlabels macro
local xlabels

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
* Simple way to deal with the month xlabels, but not readable
* format month %tmMon_CCYY
/////

*** Exactly duplicate the graph in OP ****
*** !!!!!!! ***
* Step 1: Create capped variables
gen Long_Rural_capped = min(cum_Long_Rural, 300000000)
gen Short_Rural_capped = min(cum_Short_Rural, 300000000)
gen Urban_CBD_capped = min(cum_Total, 300000000)

* Step 2: Format the month to %tm
gen month_date = month  //
format month_date %tm                  // Format as monthly date

* Step 3: Generate 2 new empty variables to prepare for the text on bar
gen y_label = .
gen label_text = ""


*********** Step 4: Key Step ************
* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 50000000) if month_date >= tm(2018m12) & month_date <= tm(2018m12)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2018m12) & month_date <= tm(2018m12)

* continue the same steps to make other numbers display
replace y_label = (cum_Total - 80000000) if month_date >= tm(2019m12) & month_date <= tm(2019m12)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2019m12) & month_date <= tm(2019m12)

replace y_label = (cum_Total - 160000000) if month_date >= tm(2020m2) & month_date <= tm(2020m2)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2020m2) & month_date <= tm(2020m2)
**********************
* Step 5: Plot the stack bar chart with scatter but none symbol
twoway ///
    (rbar zero Long_Rural_capped month, color(blue)) ///
    (rbar Long_Rural_capped Short_Rural_capped month, color(green)) ///
    (rbar Short_Rural_capped Urban_CBD_capped month, color(orange)) ///
	(scatter y_label month, msymbol(none) ///
        mlabel(label_text) mlabcolor(black) mlabposition(above)), ///
    ylabel(, format(%9.0f) angle(0)) ///
    ytitle("Outage in customer-minutes") ///
    xlabel(`xlabels', angle(90)) ///
    xtitle("Month") ///
    legend(order(1 "Long_Rural" 2 "Short_Rural" 3 "Urban_CBD") ///
    cols(4) position(6)) ///
    title("Outage in Customer-Minutes by Location (Monthly)")

* Save the new graph
graph export "~/Desktop/Outage_1523/OutageMinutes_Location_Monthly_Final.png", as(png) replace

* Step 1: Create capped variables
gen Long_Rural_capped_2 = min(cum_Long_Rural, 200000000)
gen Short_Rural_capped_2 = min(cum_Short_Rural, 200000000)
gen Urban_CBD_capped_2 = min(cum_Total, 200000000)

*********** Step 4: Key Step ************
* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 70000000) if month_date >= tm(2018m12) & month_date <= tm(2018m12)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2018m12) & month_date <= tm(2018m12)

* continue the same steps to make other numbers display
replace y_label = (cum_Total - 90000000) if month_date >= tm(2019m12) & month_date <= tm(2019m12)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2019m12) & month_date <= tm(2019m12)

replace y_label = (cum_Total - 230000000) if month_date >= tm(2020m2) & month_date <= tm(2020m2)
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2020m2) & month_date <= tm(2020m2)

* y_label means to determine the y-axis position of text; if determines the x-axis position of text *
replace y_label = (cum_Total - 30000000) if month_date >= tm(2022m2) & month_date <= tm(2022m2)
* label_text means the content of text; if determines the x-axis position of text as before *
replace label_text = string(cum_Total, "%9.0f") if month_date >= tm(2022m2) & month_date <= tm(2022m2)

**********************
* Step 5: Plot the stack bar chart with scatter but none symbol
twoway ///
    (rbar zero Long_Rural_capped_2 month, color(blue)) ///
    (rbar Long_Rural_capped_2 Short_Rural_capped_2 month, color(green)) ///
    (rbar Short_Rural_capped_2 Urban_CBD_capped_2 month, color(orange)) ///
	(scatter y_label month, msymbol(none) ///
        mlabel(label_text) mlabcolor(black) mlabposition(above)), ///
    ylabel(, format(%9.0f) angle(0)) ///
    ytitle("Outage in customer-minutes") ///
    xlabel(`xlabels', angle(90)) ///
    xtitle("Month") ///
    legend(order(1 "Long_Rural" 2 "Short_Rural" 3 "Urban_CBD") ///
    cols(4) position(6)) ///
    title("Outage in Customer-Minutes by Location (Monthly)")

* Save the new graph
graph export "~/Desktop/Outage_1523/OutageMinutes_Location_Monthly_Capped.png", as(png) replace
******************************************************************************
******************************************************************************
******************************************************************************


