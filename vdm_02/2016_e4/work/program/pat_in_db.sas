/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/pat_in_db.sas
*
* FUNCTION:  Overall number of patients
*
* HISTORY:   07Mar2016  schnem44  File created
***********************************************************************************************************************/
%init;
 
libname td teradata tdpid=rochetd connection=global authdomain=teradataAuth;
 
%let q=%BQUOTE(');
 
*----------------------------------------------------------------------------------------------------------------------;
* Patients overview;
*----------------------------------------------------------------------------------------------------------------------;
%macro create_table;
   proc sql;
      connect to teradata as tera (tdpid=rochetd connection=global authdomain=teradataAuth);
 
      execute (
         create volatile table pat (
            db           char(4),
            patients     decimal(18,0)
         )
         on commit preserve rows
      ) by tera;
      execute (commit work) by tera;
      disconnect from tera;
   quit;
%mend create_table;
%create_table;
 
%macro pat(db=, vdm_version=);
   proc sql;
      connect to teradata as tera (tdpid=rochetd connection=global authdomain=teradataAuth);
 
      execute (
         insert into pat
         select &q.&db.&q as db,
            count(distinct enrolid) as patients
         from %upcase(rwd_vdm_&db..&vdm_version._&db._t)
      ) by tera;
      execute (commit work) by tera;
 
      disconnect from tera;
   quit;
%mend pat;
 
%pat(db=ccae, vdm_version=v02);
%pat(db=mdcr, vdm_version=v02);
 
proc sort data=td.pat out=pat;
   by db;
run;
 
data pat;
   set pat;
   format patients comma20.;
run;
 
proc print data=pat;
run;
 
%macro html;
   %local i db tit;
 
   %macro html_init;
      %local tit;
      filename html "&rep_dir/%lowcase(pat_in_db_v02_overview_ccae_mdcr).html" lrecl=3000;
      %let tit=Number of unique Patients in all snapshots of VDM v. 2 of CCAE-MDCR (&sysdate9);
      data _null_;
         file html new;
         put "<html><body>";
         put "<head><title>&tit</title></head>";
         put "<h1>&tit</h1>";
      run;
   %mend html_init;
   %html_init;
 
   %do i=1 %to 2;
      %if &i=1 %then %do;
         %let db=ccae;
         %let tit=Unique patients in all snapshots of VDM v. 2 of CCAE (MarketScan Commercial);
      %end;
      %else %do;
         %let db=mdcr;
         %let tit=Unique patients in all snapshots of VDM v. 2 of MDCR (MarketScan Medicare);
      %end;
 
      data _null_;
         file html mod;
         put "<h2>&tit</h2>";
         put "<table border='1'><tr>";
         put "<td><b>No. of Patients</b></td>";
         put "</tr>";
      run;
 
      data _null_;
         file html mod;
         set pat;
         if db="&db";
         put "<tr>";
         put "<td>" PATIENTS "</td>";
         put "</tr>";
      run;
 
      data _null_;
         file html mod;
         put "</table><br>";
      run;
   %end;
 
   %macro html_close;
      data _null_;
         file html mod;
         put "</table></body></html>";
      run;
   %mend html_close;
   %html_close;
   run;
%mend html;
%html;
 
%final;
