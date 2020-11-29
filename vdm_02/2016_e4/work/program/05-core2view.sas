endsas; run;
 
not needed!
 
/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/05-core2view.sas
*
* FUNCTION:  Read from CORE_PROD and write the views in VIEW_PROD and in PUB
*
* HISTORY:   06Mar2016  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters:;
* year version vdm_version lz_path lz_description lz_version main_tables valid_start valid_end load_id maxobs tp tp_id;
*----------------------------------------------------------------------------------------------------------------------;
%include "&prog_dir/00-parameters.sas"; run;
 
*----------------------------------------------------------------------------------------------------------------------;
* Get the password;
*----------------------------------------------------------------------------------------------------------------------;
%set_sys_opt;
%inc "/home/users/&sysuserid/.pw/&sysuserid._tms.sas"; run;
%set_nor_opt;
options sastrace=',,,d' sastraceloc=saslog nostsuffix bufsize=1M;
 
*----------------------------------------------------------------------------------------------------------------------;
* Write the views in VIEW_PROD and PUB;
*----------------------------------------------------------------------------------------------------------------------;
%macro write_view(table_db=, view_db=, td_tab=);
   proc sql;
      %set_sys_opt;
      connect to teradata as tera (tdpid=rochetd user=&sysuserid password=&&&sysuserid._tms mode=teradata);
      %set_nor_opt;
      %put MESSAGE: *** Read the table &table_db..&td_tab and write the view &view_db..&td_tab;
      execute (
         replace view &view_db..&td_tab as
         select * from &table_db..&td_tab
      ) by tera;
      disconnect from tera;
   quit;
%mend write_view;
 
%macro tables;
   %local i j db_short table_db view_db tab td_tab;
 
   %do i=1 %to 2;
      %if &i=1 %then %do;
         %let db_short=ccae;
         %let table_db=PC_RWD_VDM_CCAE;
         %let view_db =RWD_VDM_CCAE;
      %end;
      %else %if &i=2 %then %do;
         %let db_short=mdcr;
         %let table_db=PC_RWD_VDM_MDCR;
         %let view_db =RWD_VDM_MDCR;
      %end;
 
      %do j=1 %to %count_items(string=&main_tables);
         %let tab   =%scan(&main_tables,&j," ");
         %let td_tab=%upcase(&vdm_version._&db_short._&tab);
         %write_view(table_db=&table_db, view_db=&view_db, td_tab=&td_tab);
      %end;
   %end;
   %put MESSAGE: *** Macro &sysmacroname ended;
%mend tables;
%tables;
 
%final;
