/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/03-lz2stage.sas
*
* FUNCTION:  Read from //LZ/staging and write to Teradata STAGE PROD
*            - This program is identical for all DB versions
*
* HISTORY:   11Jan2017  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters:;
* year version vdm_version lz_path ds_path lz_description lz_version main_tables valid_start valid_end load_id;
* maxobs tp tp_id;
*----------------------------------------------------------------------------------------------------------------------;
%include "&prog_dir/00-parameters.sas"; run;
 
*----------------------------------------------------------------------------------------------------------------------;
* The SAS datasets start with "CCAE" or "MDCR" for yeraly and quarterly versions;
* and with "EVCE" or "EVMC" for EarlyView versions;
*----------------------------------------------------------------------------------------------------------------------;
%macro ds_praefix;
   %global ds_praefix_ccae ds_praefix_mdcr;
   %if %substr(%upcase(&version),1,1)=E %then %do;
      %let ds_praefix_ccae=evce;
      %let ds_praefix_mdcr=evmc;
   %end;
   %else %do;
      %let ds_praefix_ccae=ccae;
      %let ds_praefix_mdcr=mdcr;
   %end;
%mend;
%ds_praefix;
 
%macro lz2stage;
   %local i stage_db tab lz_ds td_tab;
 
   %do i=1 %to %count_items(string=&main_tables);
      %let tab     =%scan(&main_tables,&i," ");
 
      %let load_id =%eval(&load_id + 1);
      %let stage_db=PS_RWD_VDM_CCAE;
      %let lz_ds   =%lowcase(&ds_praefix_ccae&tab&lz_version);
      %let td_tab  =%upcase(&vdm_version._ccae_&tab);
      %write_create_stage_bteq(lz_ds=&lz_ds, stage_db=&stage_db, td_tab=&td_tab);
      %write_lz2stage_sas(lz_ds=&lz_ds, stage_db=&stage_db, td_tab=&td_tab, year=&year,
         valid_start=&valid_start, valid_end=&valid_end, load_id=&load_id, maxobs=&maxobs);
 
      %let load_id =%eval(&load_id + 1);
      %let stage_db=PS_RWD_VDM_MDCR;
      %let lz_ds   =%lowcase(&ds_praefix_mdcr&tab&lz_version);
      %let td_tab  =%upcase(&vdm_version._mdcr_&tab);
      %write_create_stage_bteq(lz_ds=&lz_ds, stage_db=&stage_db, td_tab=&td_tab);
      %write_lz2stage_sas(lz_ds=&lz_ds, stage_db=&stage_db, td_tab=&td_tab, year=&year,
         valid_start=&valid_start, valid_end=&valid_end, load_id=&load_id, maxobs=&maxobs);
 
   %end;
%mend lz2stage;
%lz2stage;
 
%final;
