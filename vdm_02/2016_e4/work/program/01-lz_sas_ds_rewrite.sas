/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/01-lz_sas_ds_rewrite.sas
*
* FUNCTION:  Unzip and rewrite all unzipped SAS datasets so that access will be faster
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
 
libname lz_ "&ds_path"; run; /* access is read-write */
 
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
 
%macro read_write;
   %local i ds;
 
   /* Unzip from LZ_PATH to DS_PATH as DATASET_temp.sas7bdat */
   %do i=1 %to %count_items(string=&main_tables);
      %let ds=%lowcase(%scan(&main_tables,&i));
 
      /* "gunzip -c": keep original files unchanged. */
      x "gunzip -c &lz_path/&ds_praefix_ccae.&ds.&lz_version..sas7bdat.gz > &ds_path/&ds_praefix_ccae.&ds.&lz_version._temp.sas7bdat";
      x "gunzip -c &lz_path/&ds_praefix_mdcr.&ds.&lz_version..sas7bdat.gz > &ds_path/&ds_praefix_mdcr.&ds.&lz_version._temp.sas7bdat";
      run;
   %end;
 
   /* Read DATASET_temp.sas7bdat and write DATASET.sas7bdat */
   %do i=1 %to %count_items(string=&main_tables);
      %let ds=%lowcase(%scan(&main_tables,&i));
      data lz_.&ds_praefix_ccae.&ds.&lz_version;
         set lz_.&ds_praefix_ccae.&ds.&lz_version._temp;
      run;
      data lz_.&ds_praefix_mdcr.&ds.&lz_version;
         set lz_.&ds_praefix_mdcr.&ds.&lz_version._temp;
      run;
   %end;
 
   /* Remove DATASET_temp.sas7bdat */
/* %do i=1 %to %count_items(string=&main_tables);
      %let ds=%lowcase(%scan(&main_tables,&i));
      %remove_ds(ds=&ds_praefix_ccae.&ds.&lz_version._temp, lib=lz_);
      %remove_ds(ds=&ds_praefix_mdcr.&ds.&lz_version._temp, lib=lz_);
      run;
   %end;
*/
   run;
%mend read_write;
%read_write;
 
%final;
