/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/04-stage2core.sas
*
* FUNCTION:  Read from STAGE_PROD and write to CORE_PROD
*            - Write the BTEQ file which will be submitted by run.sh to INCLUDE the data
*            - This program is identical for all DB versions
*
* HISTORY:   14Mar2016  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters:;
* year version vdm_version lz_path lz_description lz_version main_tables valid_start valid_end load_id maxobs tp tp_id;
*----------------------------------------------------------------------------------------------------------------------;
%include "&prog_dir/00-parameters.sas"; run;
 
*----------------------------------------------------------------------------------------------------------------------;
* Write the BTEQ program which will read from %upcase(&stage_db..&td_tab) and write to %upcase(&core_db..&td_tab);
*----------------------------------------------------------------------------------------------------------------------;
%macro write_stage2core(tab=, td_tab=, pi=);
   %put MESSAGE: *** Macro &sysmacroname started;
   %put MESSAGE: *** Write %lowcase(stage2core_&td_tab..bteq);
   %put MESSAGE: *** This BTEQ program will read from %upcase(&stage_db..&td_tab) and write to %upcase(&core_db..&td_tab);
 
   filename bteq "&prog_dir/bteq/%lowcase(stage2core_&td_tab..bteq)" lrecl=500;
 
   data _null_;
      file bteq new;
 
      length stars $200;
      stars=repeat('*',120);
      put stars;
      put "* FILE:      &prog_dir/bteq/%lowcase(stage2core_&td_tab..bteq)";
      put "*";
      put "* FUNCTION:  Read from %upcase(&stage_db..&td_tab) and write to %upcase(&core_db..&td_tab)";
      put "*";
      put "* HISTORY:   Written by &prog_ext";
      put stars;
      put " ";
 
      put "*** Options***";
      put ".width 200";
      put " ";
 
      put "*** Logon ***";
      put ".logmech ldap";
      put ".RUN FILE /home/users/&sysuserid/.pw/&sysuserid._tms_eu_ldap.bteq";
      put " ";
   run;
 
   *----------------------------------------------------------------------------------------------------------------------;
   * Libname DBC;
   *----------------------------------------------------------------------------------------------------------------------;
   libname dbc teradata tdpid=rochetd database=dbc access=readonly connection=global mode=teradata authDomain=teradataAuth;
 
   data dbc;
      set dbc.ColumnsVX (where=(DataBaseName="&stage_db" and TableName="&td_tab") );
   run;
   %*print(ds=dbc, var=DataBaseName TableName ColumnName CommentString); run;
 
   proc sort data=dbc;
      by ColumnName;
      where upcase(ColumnName) ne "%upcase(&pi)";
   run;
 
   data insert;
      set dbc end=eof;
      length line $300;
      if _n_=1 then do;
         line="INSERT INTO %upcase(&core_db..&td_tab)";   output;
         line="(";                                        output;
         line="%upcase(&pi),";                            output;
         line=strip(ColumnName)!!",";                     output;
      end;
      else if not eof then do;
         line=strip(ColumnName)!!",";                     output;
      end;
      else do;
         line=strip(ColumnName);                          output;
         line=")";                                        output;
      end;
      keep line;
   run;
 
   data select;
      set dbc end=eof;
      length line $300;
      if _n_=1 then do;
         line="SELECT";                                   output;
         line="%upcase(&pi),";                            output;
         line=strip(ColumnName)!!",";                     output;
      end;
      else if not eof then do;
         line=strip(ColumnName)!!",";                     output;
      end;
      else do;
         line=strip(ColumnName);                          output;
         line="FROM %upcase(&stage_db..&td_tab);";        output;
         line=" ";                                        output;
      end;
      keep line;
   run;
 
   data bteq;
      set insert select;
   run;
 
   data _null_;
      file bteq mod;
      set bteq;
      put line;
   run;
 
   data _null_;
      file bteq mod;
      put "*** LOGOFF and QUIT ***";
      put ".LOGOFF;";
      put ".QUIT;";
   run;
 
   %put MESSAGE: *** Macro &sysmacroname ended;
%mend write_stage2core;
 
%macro tables;
   %local i j db_short stage_db core_db tab td_tab pi;
 
   %do i=1 %to 2;
      %if &i=1 %then %do;
         %let db_short=ccae;
         %let stage_db=PS_RWD_VDM_CCAE;
         %let core_db =PC_RWD_VDM_CCAE;
      %end;
      %else %if &i=2 %then %do;
         %let db_short=mdcr;
         %let stage_db=PS_RWD_VDM_MDCR;
         %let core_db =PC_RWD_VDM_MDCR;
      %end;
 
      %do j=1 %to %count_items(string=&main_tables);
         %let tab   =%scan(&main_tables,&j," ");
         %let td_tab=%upcase(&vdm_version._&db_short._&tab);
         %if %upcase(&tab)=P %then %do;
            %let pi=ROW_NUMBER_;
         %end;
         %else %do;
            %let pi=ENROLID;
         %end;
         %write_stage2core(tab=&tab, td_tab=&td_tab, pi=&pi);
      %end;
   %end;
   %put MESSAGE: *** Macro &sysmacroname ended;
%mend tables;
%tables;
 
%final;
