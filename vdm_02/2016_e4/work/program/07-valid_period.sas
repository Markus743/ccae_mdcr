/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/07-valid_period.sas
*
* FUNCTION:  Update VALID_START and VALID_END
*            UPDATE tablename SET column1=value1, column2=value2 ..... WHERE condition
*
* HISTORY:   11Jan2017  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters:;
* year version vdm_version lz_path lz_description lz_version main_tables valid_start valid_end load_id maxobs tp tp_id;
*----------------------------------------------------------------------------------------------------------------------;
%include "&prog_dir/00-parameters.sas"; run;
%let q=%BQUOTE(');
 
*----------------------------------------------------------------------------------------------------------------------;
* Update pervious VALID_END;
*----------------------------------------------------------------------------------------------------------------------;
%macro previous(db=, tab=, year=, version=, valid_end=);
   proc sql;
      connect to teradata as tera (tdpid=rochetd mode=teradata authDomain=teradataAuth);
      execute (
         update %upcase(&db..&tab) set
         valid_end=&q.&valid_end.&q
         where year_=&year and version_=&q.&version.&q
      ) by tera;
      disconnect from tera;
   quit;
%mend previous;
 
*----------------------------------------------------------------------------------------------------------------------;
* Update actual VALID_START and VALID_END;
*----------------------------------------------------------------------------------------------------------------------;
/*
%macro actual(db=, tab=, year=, version=, valid_start=, valid_end=);
   proc sql;
      connect to teradata as tera (tdpid=rochetd mode=teradata authDomain=teradataAuth);
      execute (
         update %upcase(&db..&tab) set
         valid_start=&q.&valid_start.&q,
         valid_end  =&q.&valid_end.&q
         where year_=&year and version_=&q.&version.&q
      ) by tera;
      disconnect from tera;
   quit;
%mend actual;
*/
 
*----------------------------------------------------------------------------------------------------------------------;
* This must always be done for all tables!;
*----------------------------------------------------------------------------------------------------------------------;
%let main_tables=A D F I O R S T; /* Keep always all 8 tables! */
 
%macro tables;
   %put MESSAGE: *** Macro &sysmacroname started;
   %local i j db_short db tab_short tab;
 
   %do i=1 %to 2;
      %if &i=1 %then %do;
         %let db_short=ccae;
         %let db      =PC_RWD_VDM_CCAE;
      %end;
      %else %if &i=2 %then %do;
         %let db_short=mdcr;
         %let db      =PC_RWD_VDM_MDCR;
      %end;
 
      %do j=1 %to %count_items(string=&main_tables);
         %let tab_short=%scan(&main_tables,&j," ");
         %let tab      =%upcase(&vdm_version._&db_short._&tab_short);
         %previous(db       =&db,
                   tab      =&tab,
                   year     =2016,
                   version  =E3,
                   valid_end=%str(2017-01-11 19:59:59)
         );
 
         /* No need to change anything for actual upload */
         %*actual  (db=&db, tab=&tab,
                   year       =2015,
                   version    =xx,
                   valid_start=%str(2015-mm-dd 19:00:00),
                   valid_end  =%str(9999-12-31 23:59:59)
         );
      %end;
   %end;
   %put MESSAGE: *** Macro &sysmacroname ended;
%mend tables;
%tables;
 
%final;
