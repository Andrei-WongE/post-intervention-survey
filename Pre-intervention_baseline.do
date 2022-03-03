/// Project: Acelaracion de la Innovacion - FONCYTEC/WB.
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off            // Disable partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // Clear all macros
    capture log close       // Close existing log files
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
	0. Import and merge files
    1. Cleaning variables
        //Finds long variable names
        //Saves original variables order
        //General cleaning
    2. Label variables
    3. Order variables in original sequence and saves dta
	4. Runs automatic checks on key variables

    */
///-----------------------------------------------------------------------------

    //Set directory

    global base "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Pre-intervention"
    cd "$base"

    global data "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Pre-intervention\Data"

    global output "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Pre-intervention\Output"

    //Install required packages
	//ssc install renvarlab
	
/////////////////////////////////////////////////////////////
//// 0. Import files           ////
////////////////////////////////////////////////////////////	
	
	//A. Import and merge files that where modified by monitors
    local names "Araceli David JoséLuis Paolo Rocío"
    local i = 0	
	
    foreach var of local names {
    //frame create `var' 
    import excel "$data\Linea_Base_`var'.xlsx", firstrow sheet("datos_ajustes") clear all
    tempfile Linea_Base_`var'
	save "Linea_Base_`var'", replace
	local ++i
	di "`i'---Linea_Base_`var'"
	//frame `var': use Linea_Base_`var'.dta 
   }

    local names1 "Rocío"
	local names : list names - names1
	di "`names'"
	
    foreach var of local names {
    append using "Linea_Base_`var'"
    }
	
	rename *, lower
	destring admin_participant_id, replace
    unique admin_participant_id 
	
	gen surveyor_verified = 1
	order surveyor_verified, after(admin_enumerator_name)

	save "$output\Linea_Base_pre-intervention.dta", replace
    d,s //Vars. 975
	
	//B. Import file frome SurveyCTO
   preserve		
	import delimited using "$data\CONCYTEC_PreIntervencion_Linea_Base_WIDE.csv", varnames(1) bindq(strict) maxquotedrows(unlimited) case(lower) stringc(_all) clear //Problems with importing several variables names
	
	
	destring admin_participant_id, replace
	sort admin_participant_id
	
	drop in 1/15 //Test entries
	drop in 53   //Duplicate entries
	drop in 126  //Duplicate entries
	assert c(N) == 228
	
	replace admin_business_name = "We Are Tibet S.A.C." if admin_participant_id == 68466 //Correct error in business name
	
	gen surveyor_verified = 0 
	order surveyor_verified, after(admin_enumerator_name)

	# delimit ;
	drop if inlist(admin_participant_id, 67987,
	74818,
	68296,
	74534,
	75056,
	68484,
	75014,
	74941,
	68887,
	68417,
	68336,
	68149,
	68132,
	68026,
	74864,
	74756,
	67568,
	74973,
	68192,
	67973,
	68303,
	74785,
	74981,
	68016,
	74971,
	67824,
	74970,
	75047,
	67947,
	74678,
	74833,
	68295,
	75000,
	68838,
	67963,
	74676,
	74579,
	67724,
	67627,
	68795,
	68378,
	68021,
	68277,
	68536,
	68101,
	74688,
	74658,
	68175,
	67801,
	68013,
	74752,
	74809,
	74523,
	74873,
	74879,
	67944,
	74565,
	68429,
	74956,
	74909,
	74769,
	75035,
	67662,
	74519,
	74961,
	74711,
	68144,
	68676,
	74935,
	67720,
	68002,
	74983,
	74926,
	68011,
	74531,
	68518,
	68314,
	74763,
	68006,
	68010,
	75117,
	74841,
	74510,
	74884,
	74824,
	68339,
	74667,
	68129,
	68406,
	68461,
	74876,
	68383,
	74714,
	74774,
	12345,
	67859,
	75037,
	68695,
	74524,
	68790,
	68835,
	74910,
	74744,
	75025,
	75006,
	68072,
	75052,
	74698,
	74571,
	75005,
	68173,
	75027,
	68329,
	74561,
	74700,
	68032,
	68323,
	68137,
	74748,
	68147,
	68139,
	67708,
	74732,
	68094,
	68472,
	68713,
	74707,
	68698,
	68432,
	68070,
	68516,
	74854,
	75067,
	74968,
	74942,
	68164,
	74936,
	74831,
	68886,
	74753,
	74701,
	74807,
	74836,
	75100,
	74513,
	74557,
	67965,
	68067,
	74795,
	67690,
	74772,
	68550,
	74933,
	75095,
	74733,
	74556,
	68448,
	74963,
	75096,
	74525,
	74925,
	75043,
	68471,
	74480,
	74958,
	74757,
	67749,
	74846,
	68454,
	74921,
	67819,
	67773,
	68793,
	68187,
	75081,
	67746,
	67932,
	74844,
	68056,
	67725,
	75053,
	74738,
	74791,
	75071,
	68084);
    # delimit cr
	
	//tempfile Base_0
	save "$output\Base_0.dta", replace
   restore
	
	use "$output\Linea_Base_pre-intervention.dta", clear
	destring admin_participant_id, replace
	
	//Append both files A + B
	append using "$output\Base_0.dta"
	
	//replace surveyor_verified = 0 if surveyor_verified == .
	drop in 207 //Duplicate entries
	drop in 95  //Test entries
	assert c(N) == 228
		
	save "$output/Linea_Base_pre-intervention-raw.dta", replace
	export delimited using "$out/Linea_Base_pre-intervention-raw.csv", nolabel quote replace
	
	do import_CONCYTEC_PreIntervencion_Linea_Base.do
	
	erase "$output\Base_0.dta"
    //erase "$base\Linea_Base_pre-intervention.dta"
   
/////////////////////////////////////////////////////////////
//// 1. Clean variables           ////
////////////////////////////////////////////////////////////
	
	
	//Clean duplicate collumns (fh-hu;qk;rq;sw;uc;vi;wo;xu;za;zw-aag; v164-v709) due to change in survey
	//A. Check if columns are really duplicates, creating duplicate variables names *_DUP	
	clear
	use "$output/Linea_Base_pre-intervention-raw.dta", replace
	
	// A.1
	foreach i in fh-hu {
	renvarlab `i', postfix(_D) d
	}
	//problem: no lable anymore
	
    #delimit ;
    local varlist1
	emp_executive_name
	emp_executive_title 
	emp_executive_area
	emp_executive_partner
	emp_executive_phone
	emp_executive_mail;
    #delimit cr
	
 //set more on
 /*
	forvalues j = 1/11 /* No hay *_12_D */ {
		foreach var of local varlist1 {
			compare `var'_`j' `var'_`j'_D
    }
	}
 //set more off
 */
 	//problem: how did you get var_D?
	
	br emp_executive_phone_7*
	br emp_executive_phone_4*
	br emp_executive_phone_2*
	br emp_executive_name_2*
	
	//Result_ *_D are redundant, now 995 var.
	drop *_D
	d,s
	
	//A.2 
	br emp_executive_name_1 v164
	br emp_executive_title_1 v165
	
	//Result all v164-v229 have less information than emp_*
	drop v164-v229
	
	//A.3	
	foreach i in * {
	renvarlab `i', subst(interactions interct) d 
	}
	
	br pe v421 
	br qk v453
	br rq v485
	
	destring pe v421 qk v453 rq v485 sw v517 uc v549 vi v581 wo v613 xu v645 za v677 zw v709, replace
	/*
		program define egen2

		gettoken firstarg 0 : 0, parse("=")
		egen `firstarg' `0'
		order `firstarg'

		end
	*/
	forvalues j = 1/9 {
	rename cust_impt`j'_interct_total_99  cust_impt`j'_interct_total_97
	}
	
	egen cust_impt1_interct_total_99  = rowtotal(pe v421), missing
	order cust_impt1_interct_total_99, b(pe)
	egen cust_impt2_interct_total_99  = rowtotal(qk v453), missing
	order cust_impt2_interct_total_99, b(qk)
	egen cust_impt3_interct_total_99  = rowtotal(rq v485), missing
	order cust_impt3_interct_total_99, b(rq)	
	egen cust_impt4_interct_total_99  = rowtotal(sw v517), missing
	order cust_impt4_interct_total_99, b(sw)		
	egen cust_impt5_interct_total_99  = rowtotal(uc v549), missing
	order cust_impt5_interct_total_99, b(uc)	
	egen cust_impt6_interct_total_99  = rowtotal(vi v581), missing
	order cust_impt6_interct_total_99, b(vi)	
	egen cust_impt7_interct_total_99  = rowtotal(wo v613), missing
	order cust_impt7_interct_total_99, b(wo)	
	egen cust_impt8_interct_total_99  = rowtotal(xu v645), missing
	order cust_impt8_interct_total_99, b(xu)	
	egen cust_impt9_interct_total_99  = rowtotal(za v677), missing
	order cust_impt9_interct_total_99, b(za)	
	egen cust_impt10_interct_total_99 = rowtotal(zw v709), missing
	order cust_impt10_interct_total_99, b(zw)	
	
	drop pe v421 qk v453 rq v485 sw v517 uc v549 vi v581 wo v613 xu v645 za v677 zw v709
	
	drop v699 -v708 //All empty
	
	gen cust_impt10_interct_total_11 = zx, before(zx)
	gen cust_impt10_interct_total_12 = zy, before(zy)
	gen cust_impt10_interct_total_13 = zz, before(zz)
	gen cust_impt10_interct_total_14 = aaa, before(aaa)
	gen cust_impt10_interct_total_15 = aab, before(aab)
	gen cust_impt10_interct_total_16 = aac, before(aac)
	gen cust_impt10_interct_total_17 = aad, before(aad)
	//gen cust_impt10_interct_total_18 = zx, before(zx)
	gen cust_impt10_interct_total_19 = aae, before(aae)
	gen cust_impt10_interct_total_97 = aaf, before(aaf)
	order cust_impt10_interct_total_99, before(aag)	
	
	drop zx zy zz aaa aab aac aad aae aaf aag
	
	//908 Var.
	d,s
	
	save "$output/Linea_Base_pre-intervention-clean.dta", replace
	
 window stopbox rusure "Do you want to continue to run high frequency checks?`=char(13)'Yes=continue; No=stop here."
 window stopbox note "Good choice!"
 
/////////////////////////////////////////////////////////////
//// 4. Run checks          ////
////////////////////////////////////////////////////////////

  //Create output files

	local hfc_file "$Dailyhfc_$filename$filedate.csv"
	destring admin_participant_id,replace

	export excel using  "$Dailyhfc_$filename$filedate.csv", replace

  //Fix data
	foreach var of varlist _all{
		char `var'[charname] "`var'"
	}

	global biz_info "admin_participant_id  admin_respondent_name"

	duplicates tag admin_participant_id, generate(id_dup)

	listtab $biz_info  using `hfc_file' if id_dup==1, delimiter(",") replace headlines("Duplicate Respondent ID") headchars(charname)

  // Respondent haven't made a sale and sales not =0

	listtab $biz_info  bo_transactions_frequency sales_last_month_2 profits_last_month_2 if bo_transactions_frequency==0 & sales_last_month !=0,delimiter(",")appendto(`hfc_file') replace headlines("Respondent haven't made a sale and sales not 0 (As of FEBRUARY 2020)") headchars(charname)


  // Respondent with sales less than 100

 	listtab $biz_info  bo_transactions_frequency sales_last_month_2 profits_last_month_2 if sales_last_month <=100 ,delimiter(",")appendto(`hfc_file') replace headlines("Respondent with sales less than 100 (As of FEBRUARY 2020)") headchars(charname)


  // Sales/Profit ratios for different business types

	destring sales_last_month sales_typical_month profits_last_month profits_typical_month, replace

	gen sales_profit_ratio = profits_last_month/sales_last_month

	listtab $biz_info sales_last_month profits_last_month   if sales_profit_ratio > .5 & bo_primary_how_BuyResell ==1, delimiter(",")appendto(`hfc_file') replace headlines("Resellers with sales/Profits off") headchars(charname)

	listtab $biz_info  sales_last_month profits_last_month if sales_profit_ratio > .75 & bo_primary_how_Manufacture ==1, delimiter(",")appendto(`hfc_file') replace headlines("Manufacturers with sales/Profits off") headchars(charname)

	listtab $biz_info  sales_last_month profits_last_month if sales_profit_ratio > .75 & bo_primary_how_Services ==1, delimiter(",")appendto(`hfc_file') replace headlines("service providers with sales/Profits off") headchars(charname)

	//As of FEBRUARY 2020
	destring sales_last_month_2 profits_last_month_2, replace

	gen sales_profit_ratio_2 = profits_last_month_2/sales_last_month_2

	listtab $biz_info sales_last_month_2 profits_last_month_2  if sales_profit_ratio_2 > .5 & bo_primary_how_BuyResell ==1, delimiter(",")appendto(`hfc_file') replace headlines("Resellers with sales/Profits off (As of FEBRUARY 2020)") headchars(charname)

	listtab $biz_info sales_last_month_2 profits_last_month_2 if sales_profit_ratio_2 > .75 & bo_primary_how_Manufacture ==1, delimiter(",")appendto(`hfc_file') replace headlines("Manufacturers with sales/Profits off (As of FEBRUARY 2020) ") headchars(charname)

	listtab $biz_info sales_last_month_2 profits_last_month_2 if sales_profit_ratio_2 > .75 & bo_primary_how_Services ==1, delimiter(",")appendto(`hfc_file') replace headlines("service providers with sales/Profits off (As of FEBRUARY 2020)") headchars(charname)


	//// Checking outliers in sales and profits

	set trace off
			gen flag_outlier = 0
			foreach x in 1.5 3 {
			foreach var of varlist sales_last_month profits_last_month  {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds
			}
		}

	//As of FEBRUARY 2020
	set trace on
			drop flag_outlier
			gen flag_outlier = 0
			foreach x in 1.5 3 {
			foreach var of varlist  sales_last_month_2 profits_last_month_2  {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean) (As of FEBRUARY 2020):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds
			}
		}

	//// Outliers in number of employees
	destring emp_total,replace ignore(",")
	drop flag_outlier
	gen flag_outlier = 0

		foreach x in 1.5 3 {
			foreach var of varlist emp_total {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds
			}
		}

	//// Check of total employees
	tempvar total_empl
	egen `total_empl' =  rowtotal(emp_partners emp_executives emp_fulltime emp_parttime)
	tempvar error_empl
	gen `error_empl' = `total_empl' != emp_total


	listtab $biz_info emp_partners emp_executives emp_fulltime emp_parttime emp_total if `error_empl' ==1  & bo_transactions_frequency==0,delimiter(",") appendto(`hfc_file') replace headlines("Total employmend doesnt add-up") headchars(charname)


	//// Outliers in asset value by asset groups

	drop flag_outlier
	gen flag_outlier = 0
	local asset asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value

		foreach var of local asset {
			destring `var',force replace
				foreach x in 1.5 3 {
						egen mean = mean(`var')
						egen sd = sd(`var')
						generate sds = (`var' - mean) / sd
						format mean sd sds %9.2f
						sort admin_participant_id
						char sd [charname] "SD"
						char sds [charname] "Standard SD"
						char mean [charname] "Mean"
						listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in op_`var'_value (`x' SDs from the mean):") headchars(charname)
						replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
						drop mean sd sds
			}
		}

	//As of FEBRUARY 2020
	drop flag_outlier
	gen flag_outlier = 0
	local asset asset_land_value_2 asset_building_value_2 asset_lgvehicle_value_2 asset_smvehicle_value_2 asset_machine_value_2 asset_tools_value_2 asset_itech_value_2 asset_furniture_value_2 asset_wc1_stock_value_2 asset_wc2_materials_value_2 asset_wc3_money_value_2 asset_ip_value_2

		foreach var of local asset {
			destring `var',force replace
				foreach x in 1.5 3 {
						egen mean = mean(`var')
						egen sd = sd(`var')
						generate sds = (`var' - mean) / sd
						format mean sd sds %9.2f
						sort admin_participant_id
						char sd [charname] "SD"
						char sds [charname] "Standard SD"
						char mean [charname] "Mean"
						listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in op_`var'_value (`x' SDs from the mean) (As of FEBRUARY 2020):") headchars(charname)
						replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
						drop mean sd sds
			}
		}

	//// Checking outliers in stock value, materials value, and working capital

	drop flag_outlier
	gen flag_outlier = 0

		foreach x in 1.5 3 {
			foreach var of varlist asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value   {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean) :") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds
				}
		}

	//As of FEBRUARY 2020
	drop flag_outlier
	gen flag_outlier = 0

		foreach x in 1.5 3 {
			foreach var of varlist asset_wc1_stock_value_2 asset_wc2_materials_value_2 asset_wc3_money_value_2  {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean) (As of FEBRUARY 2020):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds
				}
		}

	drop flag_outlier


	///* Check answers text coded responses
	foreach var of varlist {
		tostring `var', replace
		replace `var'="" if `var'=="."
		listtab $biz_info `var' if `var' !="" , delimiter(",") appendto(`hfc_file') replace headlines(" "`var'" others") headchars(charname)
		}
*/


// Sales Scale does not correspond with the sales amount

	destring sales_last_month, replace

	replace sales_last_month=0 if sales_last_month==.

	gen sales_last_month_scale_dum= sales_last_month_scale
	order sales_last_month_scale_dum,after(sales_last_month_scale)
	tostring sales_last_month_scale_dum,replace           //values that will be used for comparison
	destring sales_last_month_scale_dum,replace


	gen sales_comparison =0
	replace sales_comparison =1 if sales_last_month	>=1 & sales_last_month <=50000
	replace sales_comparison =2 if sales_last_month	>=50001  & sales_last_month <= 100000
	replace sales_comparison =3 if sales_last_month	>=100001 & sales_last_month <= 150000
	replace sales_comparison =4 if sales_last_month	>=150001 & sales_last_month <= 200000
	replace sales_comparison =5 if sales_last_month	>=200001 & sales_last_month <= 250000
	replace sales_comparison =6 if sales_last_month	>=250001 & sales_last_month <= 300000
	replace sales_comparison =7 if sales_last_month	>=300001 & sales_last_month <= 350000
	replace sales_comparison =8 if sales_last_month	>=350001 & sales_last_month <= 400000
	replace sales_comparison =9 if sales_last_month	>=400001  & sales_last_month <= 450000
	replace sales_comparison =10 if sales_last_month >=450001  & sales_last_month <= 500000
	replace sales_comparison =11 if sales_last_month >=500001  & sales_last_month <= 550000
	replace sales_comparison =12 if sales_last_month >=550001  & sales_last_month <= 600000
	replace sales_comparison =13 if sales_last_month >=600001  & sales_last_month <= 650000
	replace sales_comparison =14 if sales_last_month >=650001  & sales_last_month <= 700000
	replace sales_comparison =15 if sales_last_month >=700001  & sales_last_month <= 750000
	replace sales_comparison =16 if sales_last_month >=750001  & sales_last_month <= 800000
	replace sales_comparison =17 if sales_last_month >=800001  & sales_last_month <= 850000
	replace sales_comparison =18 if sales_last_month >=850001  & sales_last_month <= 900000
	replace sales_comparison =19 if sales_last_month >=900001  & sales_last_month <= 950000
	replace sales_comparison =20 if sales_last_month >=950001  & sales_last_month <= 1000000
	replace sales_comparison =21 if sales_last_month >= 1000001

	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}


	listtab $biz_info   sales_last_month sales_last_month_scale_dum sales_comparison if sales_comparison !=sales_last_month_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Sales value and enumerator scale are different?") headchars(charname)

	listtab $biz_info  bo_primary_how sales_last_month  sales_typical_month   if sales_last_month - sales_typical_month >3000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and typical month have difference greater than 3K") headchars(charname)

	listtab $biz_info  bo_primary_how sales_last_month  sales_typical_month   if sales_last_month -sales_typical_month >3000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and Typical sales have huge differences") headchars(charname)

	//As of FEBRUARY 2020
	destring sales_last_month_2, replace

	replace sales_last_month_2=0 if sales_last_month_2==.

	gen sales_last_month_scale_dum_2= sales_last_month_scale_2
	order sales_last_month_scale_dum_2,after(sales_last_month_scale_2)
	tostring sales_last_month_scale_dum_2,replace //values that will be used for comparison
	destring sales_last_month_scale_dum_2,replace

	drop sales_comparison
	gen sales_comparison =0
	replace sales_comparison =1 if sales_last_month_2	>=1 & sales_last_month_2 <=50000
	replace sales_comparison =2 if sales_last_month_2	>=50001  & sales_last_month_2 <= 100000
	replace sales_comparison =3 if sales_last_month_2	>=100001 & sales_last_month_2 <= 150000
	replace sales_comparison =4 if sales_last_month_2	>=150001 & sales_last_month_2 <= 200000
	replace sales_comparison =5 if sales_last_month_2	>=200001 & sales_last_month_2 <= 250000
	replace sales_comparison =6 if sales_last_month_2	>=250001 & sales_last_month_2 <= 300000
	replace sales_comparison =7 if sales_last_month_2	>=300001 & sales_last_month_2 <= 350000
	replace sales_comparison =8 if sales_last_month_2	>=350001 & sales_last_month_2 <= 400000
	replace sales_comparison =9 if sales_last_month_2	>=400001  & sales_last_month_2 <= 450000
	replace sales_comparison =10 if sales_last_month_2 >=450001  & sales_last_month_2 <= 500000
	replace sales_comparison =11 if sales_last_month_2 >=500001  & sales_last_month_2 <= 550000
	replace sales_comparison =12 if sales_last_month_2 >=550001  & sales_last_month_2 <= 600000
	replace sales_comparison =13 if sales_last_month_2 >=600001  & sales_last_month_2 <= 650000
	replace sales_comparison =14 if sales_last_month_2 >=650001  & sales_last_month_2 <= 700000
	replace sales_comparison =15 if sales_last_month_2 >=700001  & sales_last_month_2 <= 750000
	replace sales_comparison =16 if sales_last_month_2 >=750001  & sales_last_month_2 <= 800000
	replace sales_comparison =17 if sales_last_month_2 >=800001  & sales_last_month_2 <= 850000
	replace sales_comparison =18 if sales_last_month_2 >=850001  & sales_last_month_2 <= 900000
	replace sales_comparison =19 if sales_last_month_2 >=900001  & sales_last_month_2 <= 950000
	replace sales_comparison =20 if sales_last_month_2 >=950001  & sales_last_month_2 <= 1000000
	replace sales_comparison =21 if sales_last_month_2 >= 1000001

	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}

	listtab $biz_info   sales_last_month_2 sales_last_month_scale_dum_2 sales_comparison if sales_comparison !=sales_last_month_scale_dum_2 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Sales value and enumerator scale are different? (As of FEBRUARY 2020)") headchars(charname)


*Profit in scale does not align with profit value
	cap drop profits_comparison
	gen profits_comparison =profits_last_month
	replace profits_comparison=0 if profits_last_month <=0
	replace profits_comparison=1 if profits_last_month >=1 &  profits_last_month <= 10000
	replace profits_comparison=2 if profits_last_month >=10001 &  profits_last_month <= 20000
	replace profits_comparison=3 if profits_last_month >=20001 &  profits_last_month <= 30000
	replace profits_comparison=4 if profits_last_month >=30001 &  profits_last_month <= 40000
	replace profits_comparison=5 if profits_last_month >=40001 &  profits_last_month <= 50000
	replace profits_comparison=6 if profits_last_month >=50001 &  profits_last_month <= 60000
	replace profits_comparison=7 if profits_last_month >=60001 &  profits_last_month <= 70000
	replace profits_comparison=8 if profits_last_month >=70001 &  profits_last_month <= 80000
	replace profits_comparison=9 if profits_last_month >=80001 &  profits_last_month <= 90000
	replace profits_comparison=10 if profits_last_month >=90001 &  profits_last_month <= 100000
	replace profits_comparison=11 if profits_last_month >=100001 &  profits_last_month <= 110000
	replace profits_comparison=12 if profits_last_month >=110001 &  profits_last_month <= 120000
	replace profits_comparison=13 if profits_last_month >=120001 &  profits_last_month <= 130000
	replace profits_comparison=14 if profits_last_month >=130001 &  profits_last_month <= 140000
	replace profits_comparison=15 if profits_last_month >=140001 &  profits_last_month <= 150000
	replace profits_comparison=16 if profits_last_month >=150001 &  profits_last_month <= 160000
	replace profits_comparison=17 if profits_last_month >=160001 &  profits_last_month <= 170000
	replace profits_comparison=18 if profits_last_month >=170001 &  profits_last_month <= 180000
	replace profits_comparison=19 if profits_last_month >=180001 &  profits_last_month <= 190000
	replace profits_comparison=20 if profits_last_month >=190001 &  profits_last_month <= 200000
	replace profits_comparison=21  if profits_last_month >= 200001 &  profits_last_month !=.

	cap drop profits_last_month_scale_dum
	gen profits_last_month_scale_dum=profits_last_month_scale
	order profits_last_month_scale_dum, after (profits_last_month_scale)
	tostring profits_last_month_scale_dum,replace
	destring profits_last_month_scale_dum,replace

	foreach var of varlist _all{
		char `var'[charname] "`var'"
	}

		listtab $biz_info profits_comparison profits_last_month_scale_dum profits_last_month  if profits_comparison !=profits_last_month_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Profit value and scale are off?") headchars(charname)

		listtab $biz_info profits_last_month  profits_typical_month   if profits_last_month - profits_typical_month>50000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and Typical sales have huge differences?") headchars(charname)

		//As of FEBRUARY 2020
		cap drop profits_comparison
		gen profits_comparison =profits_last_month_2
		replace profits_comparison=0 if profits_last_month_2 <=0
		replace profits_comparison=1 if profits_last_month_2 >=1 &  profits_last_month_2 <= 10000
		replace profits_comparison=2 if profits_last_month_2 >=10001 &  profits_last_month_2 <= 20000
		replace profits_comparison=3 if profits_last_month_2 >=20001 &  profits_last_month_2 <= 30000
		replace profits_comparison=4 if profits_last_month_2 >=30001 &  profits_last_month_2 <= 40000
		replace profits_comparison=5 if profits_last_month_2 >=40001 &  profits_last_month_2 <= 50000
		replace profits_comparison=6 if profits_last_month_2 >=50001 &  profits_last_month_2 <= 60000
		replace profits_comparison=7 if profits_last_month_2 >=60001 &  profits_last_month_2 <= 70000
		replace profits_comparison=8 if profits_last_month_2 >=70001 &  profits_last_month_2 <= 80000
		replace profits_comparison=9 if profits_last_month_2 >=80001 &  profits_last_month_2 <= 90000
		replace profits_comparison=10 if profits_last_month_2 >=90001 &  profits_last_month_2 <= 100000
		replace profits_comparison=11 if profits_last_month_2 >=100001 &  profits_last_month_2 <= 110000
		replace profits_comparison=12 if profits_last_month_2 >=110001 &  profits_last_month_2 <= 120000
		replace profits_comparison=13 if profits_last_month_2 >=120001 &  profits_last_month_2 <= 130000
		replace profits_comparison=14 if profits_last_month_2 >=130001 &  profits_last_month_2 <= 140000
		replace profits_comparison=15 if profits_last_month_2 >=140001 &  profits_last_month_2 <= 150000
		replace profits_comparison=16 if profits_last_month_2 >=150001 &  profits_last_month_2 <= 160000
		replace profits_comparison=17 if profits_last_month_2 >=160001 &  profits_last_month_2 <= 170000
		replace profits_comparison=18 if profits_last_month_2 >=170001 &  profits_last_month_2 <= 180000
		replace profits_comparison=19 if profits_last_month_2 >=180001 &  profits_last_month_2 <= 190000
		replace profits_comparison=20 if profits_last_month_2 >=190001 &  profits_last_month_2 <= 200000
		replace profits_comparison=21  if profits_last_month_2 >= 200001 &  profits_last_month_2 !=.

		cap drop profits_last_month_scale_dum
		gen profits_last_month_scale_dum_2=profits_last_month_scale_2
		order profits_last_month_scale_dum_2, after (profits_last_month_scale_2)
		tostring profits_last_month_scale_dum_2,replace
		destring profits_last_month_scale_dum_2,replace

		foreach var of varlist _all{
				char `var'[charname] "`var'"
			}


		listtab $biz_info profits_comparison profits_last_month_scale_dum_2 profits_last_month_2  if profits_comparison !=profits_last_month_scale_dum_2 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Profit value and scale are off? (As of FEBRUARY 2020)") headchars(charname)


	*Sales last year in scale does not align with sales value last year
		destring sales_last_year, replace

		replace sales_last_year=0 if sales_last_year==.

		gen sales_last_year_scale_dum= sales_last_year_scale
		order sales_last_year_scale_dum,after(sales_last_year_scale)
		tostring sales_last_year_scale_dum,replace           //values that will be used for comparison
		destring sales_last_year_scale_dum,replace

		gen sales_comparison_last =0
		replace sales_comparison_last =1 if sales_last_year	>=1 & sales_last_year <=50000
		replace sales_comparison_last =2 if sales_last_year	>=50001  & sales_last_year <= 100000
		replace sales_comparison_last =3 if sales_last_year	>=100001 & sales_last_year <= 150000
		replace sales_comparison_last =4 if sales_last_year	>=150001 & sales_last_year <= 200000
		replace sales_comparison_last =5 if sales_last_year	>=200001 & sales_last_year <= 250000
		replace sales_comparison_last =6 if sales_last_year	>=250001 & sales_last_year <= 300000
		replace sales_comparison_last =7 if sales_last_year	>=300001 & sales_last_year <= 350000
		replace sales_comparison_last =8 if sales_last_year	>=350001 & sales_last_year <= 400000
		replace sales_comparison_last =9 if sales_last_year	>=400001  & sales_last_year <= 450000
		replace sales_comparison_last =10 if sales_last_year >=450001  & sales_last_year <= 500000
		replace sales_comparison_last =11 if sales_last_year >=500001  & sales_last_year <= 550000
		replace sales_comparison_last =12 if sales_last_year >=550001  & sales_last_year <= 600000
		replace sales_comparison_last =13 if sales_last_year >=600001  & sales_last_year <= 650000
		replace sales_comparison_last =14 if sales_last_year >=650001  & sales_last_year <= 700000
		replace sales_comparison_last =15 if sales_last_year >=700001  & sales_last_year <= 750000
		replace sales_comparison_last =16 if sales_last_year >=750001  & sales_last_year <= 800000
		replace sales_comparison_last =17 if sales_last_year >=800001  & sales_last_year <= 850000
		replace sales_comparison_last =18 if sales_last_year >=850001  & sales_last_year <= 900000
		replace sales_comparison_last =19 if sales_last_year >=900001  & sales_last_year <= 950000
		replace sales_comparison_last =20 if sales_last_year >=950001  & sales_last_year <= 1000000
		replace sales_comparison_last =21 if sales_last_year >= 1000001

		foreach var of varlist _all{
				char `var'[charname] "`var'"
			}

		listtab $biz_info   sales_last_year sales_last_year_scale_dum sales_comparison_last if sales_comparison_last !=sales_last_year_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Sales value and enumerator scale LAST YEAR are different?") headchars(charname)


	*Profit last year in scale does not align with profit value last year
		destring profits_last_year, replace ignore(",")

		cap drop profits_comparison_last
		gen profits_comparison_last =profits_last_year
		replace profits_comparison_last=0 if profits_last_year <=0
		replace profits_comparison_last=1 if profits_last_year >=1 &  profits_last_year <= 10000
		replace profits_comparison_last=2 if profits_last_year >=10001 &  profits_last_year <= 20000
		replace profits_comparison_last=3 if profits_last_year >=20001 &  profits_last_year <= 30000
		replace profits_comparison_last=4 if profits_last_year >=30001 &  profits_last_year <= 40000
		replace profits_comparison_last=5 if profits_last_year >=40001 &  profits_last_year <= 50000
		replace profits_comparison_last=6 if profits_last_year >=50001 &  profits_last_year <= 60000
		replace profits_comparison_last=7 if profits_last_year >=60001 &  profits_last_year <= 70000
		replace profits_comparison_last=8 if profits_last_year >=70001 &  profits_last_year <= 80000
		replace profits_comparison_last=9 if profits_last_year >=80001 &  profits_last_year <= 90000
		replace profits_comparison_last=10 if profits_last_year >=90001 &  profits_last_year <= 100000
		replace profits_comparison_last=11 if profits_last_year >=100001 &  profits_last_year <= 110000
		replace profits_comparison_last=12 if profits_last_year >=110001 &  profits_last_year <= 120000
		replace profits_comparison_last=13 if profits_last_year >=120001 &  profits_last_year <= 130000
		replace profits_comparison_last=14 if profits_last_year >=130001 &  profits_last_year <= 140000
		replace profits_comparison_last=15 if profits_last_year >=140001 &  profits_last_year <= 150000
		replace profits_comparison_last=16 if profits_last_year >=150001 &  profits_last_year <= 160000
		replace profits_comparison_last=17 if profits_last_year >=160001 &  profits_last_year <= 170000
		replace profits_comparison_last=18 if profits_last_year >=170001 &  profits_last_year <= 180000
		replace profits_comparison_last=19 if profits_last_year >=180001 &  profits_last_year <= 190000
		replace profits_comparison_last=20 if profits_last_year >=190001 &  profits_last_year <= 200000
		replace profits_comparison_last=21  if profits_last_year >= 200001 &  profits_last_year !=.

		cap drop profits_last_year_scale_dum
		gen profits_last_year_scale_dum=profits_last_year_scale
		order profits_last_year_scale_dum, after (profits_last_year_scale)
		tostring profits_last_year_scale_dum,replace
		destring profits_last_year_scale_dum,replace

		foreach var of varlist _all{
				char `var'[charname] "`var'"
			}

		listtab $biz_info profits_comparison_last profits_last_year_scale_dum profits_last_year  if profits_comparison_last !=profits_last_year_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Profit value and scale LAST YEAR are off?") headchars(charname)


	//Calculated Assets doesn't equal survey totals
		cap drop assets_total_Check
		local assets asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value
		foreach var of  local assets {
		destring `var', replace
		replace `var'=0 if `var'==. & bo_operational==1
		}

		egen long assets_total_Check = rowtotal( asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value),missing

		foreach var of varlist _all{
				char `var'[charname] "`var'"
			}

		*replace assets_total = subinstr(assets_total,",","",.)
		destring assets_total  assets_total_Check ,replace ignore(",")
		listtab $biz_info assets_total assets_total_Check if assets_total != assets_total_Check  , delimiter(",") appendto(`hfc_file') replace headlines("Calculated Assets doesn't equal survey totals") headchars(charname)

		//As of FEBRUARY 2020
		cap drop assets_total_Check_2
		local assets_2 asset_land_value_2 asset_building_value_2 asset_lgvehicle_value_2 asset_lgvehicle_value_2 asset_machine_value_2 asset_tools_value_2 asset_itech_value_2 asset_furniture_value_2 asset_wc1_stock_value_2 asset_wc2_materials_value_2 asset_wc3_money_value_2 asset_ip_value_2
		foreach var of local assets_2 {
		destring `var', replace
		replace `var'=0 if `var'==. & bo_operational==1
		}

		egen long assets_total_Check_2 = rowtotal( asset_land_value_2 asset_building_value_2 asset_lgvehicle_value_2 asset_smvehicle_value_2 asset_machine_value_2 asset_tools_value_2 asset_itech_value_2 asset_furniture_value_2 asset_wc1_stock_value_2 asset_wc2_materials_value_2 asset_wc3_money_value_2 asset_ip_value_2),missing

		foreach var of varlist _all{
				char `var'[charname] "`var'"
			}

		destring assets_total_2	assets_total_Check_2 ,replace ignore(",")
		listtab $biz_info assets_total_2 assets_total_Check_2 if assets_total_2 != assets_total_Check_2, delimiter(",") appendto(`hfc_file') replace headlines("Calculated Assets doesn't equal survey totals (As of FEBRUARY 2020)") headchars(charname)

	//Respondent with  more than 100 employees
		listtab $biz_info   bo_operational emp_total  bo_primary_what if emp_total >=100&emp_total!=.  , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with  more than 100 employees") headchars(charname)


	//Respondent with more higher level practices than lower level practices eg has buget but doesnt seperate finances

		egen level1_practices=rowtotal(practices_q1 practices_q2 practices_q3 practices_q4 practices_q5 practices_q6 practices_q7),missing
		egen level2_practices= rowtotal(practices_q8 practices_q9 practices_q10 practices_q11 practices_q12),missing

		listtab $biz_info  bo_primary_how practices_q1- practices_q12 if level2_practices > level1_practices , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more higher level practices than lower level practices") headchars(charname)

	//Respondent with more than 1 capital type

		foreach var of varlist	capital_loan1_amount capital_loan2_amount capital_loan3_amount capital_loan4_amount capital_loan5_amount capital_loan6_amount capital_loan7_amount capital_loan8_amount capital_loan9_amount capital_loan10_amount {
		gen `var'_count=0
		replace `var'_count =1 if `var'>0 & `var' !=.
		}

		egen capital_loan_count= rowtotal (capital_loan1_amount_count capital_loan2_amount_count capital_loan3_amount_count capital_loan4_amount_count capital_loan5_amount_count capital_loan6_amount_count capital_loan7_amount_count capital_loan8_amount_count capital_loan9_amount_count capital_loan10_amount_count),missing

		foreach var of varlist capital_equity1_amount capital_equity2_amount capital_equity3_amount capital_equity4_amount capital_equity5_amount {
		gen `var'_count=0
		replace `var'_count	=1 if `var'>0 & `var' !=.
		}

		egen capital_equity_count = rowtotal(capital_equity1_amount_count capital_equity2_amount_count capital_equity3_amount_count capital_equity4_amount_count capital_equity5_amount_count),missing



	foreach var of varlist capital_grant1_value capital_grant2_value capital_grant3_value capital_grant4_value capital_grant5_value{
		gen `var'_count=0
		replace `var'_count	=1 if `var'>0 & `var' !=.
	}
	
	egen capital_grant_count = rowtotal(capital_grant1_value_count capital_grant2_value_count capital_grant3_value_count capital_grant4_value_count capital_grant5_value_count),missing

		
  listtab $biz_info  capital_equity if capital_equity != capital_equity_count  & capital_equity !=., delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 equity capital") headchars(charname)
  listtab $biz_info  capital_loans if capital_loans != capital_loan_count & capital_loans !=. , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 loan capital") headchars(charname)
	listtab $biz_info  capital_grants if capital_grants != capital_grant_count & capital_grants !=., delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 grant capital") headchars(charname)

	