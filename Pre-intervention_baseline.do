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
	save "$output\Base_0.dta", replacev
   restore
	
	use "$output\Linea_Base_pre-intervention.dta", clear
	destring admin_participant_id, replace
	
	//Append both files A + B
	append using "$output\Base_0.dta"
	
	//replace surveyor_verified = 0 if surveyor_verified == .
	drop in 207 //Duplicate entries
	drop in 95  //Test entries
	assert c(N) == 228
	
	save "$out/Linea_Base_pre-intervention.dta", replace
	export delimited using "$out/Linea_Base_pre-intervention.csv", nolabel quote replace

	
	erase "$output\Base_0.dta"
    //erase "$base\Linea_Base_pre-intervention.dta"
   
/////////////////////////////////////////////////////////////
//// 1. Clean variables           ////
////////////////////////////////////////////////////////////
	//Clean duplicate collumns (fh-hu;qk;rq;sw;uc;vi;wo;xu;za;zw-aag; v164-v709) due to change in survey
	//A. Check if columns are really duplicates, creating duplicate variables names *_DUP	
	
	// A.1
	foreach i in fh-hu {
	renvarlab `i', postfix(_D) label d
	}
	
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
	forvalues j = 1/11 /* No hay *_12_D */ {
		foreach var of local varlist1 {
			compare `var'_`j' `var'_`j'_D
    }
	}
 //set more off
 
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
	