/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/02-check_obs.sas
*
* FUNCTION:  Compare the number of observations in the datasets against the Excel from TruvenHealth
*            Save the two received Excel files as "csv" and copy them to &PROJECT_DIR/input
*
* HISTORY:   11Jan2017  schnem44  File created
*                                 NOTE: The Excel file does still have the p-tables listed! Lines removed by hand
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
 
%macro expected(dir=&final_dir);
   %local i j db_short csv_file ds dsid nobs nobs_ccae nobs_mdcr;
 
   /* EarlyView versions: one csv file */
   %if %substr(%upcase(&version),1,1)=E %then %do;
      %let csv_file=mediaev_&year._v0%substr(&version,2,1)_SAS_GZ.csv;
 
      data csv;
         infile "&project_dir/work/input/&csv_file" dsd dlm=',' missover pad lrecl=2000 firstobs=6;
         length v1-v5 $30;
         input  v1-v5;
      run;
 
      data csv;
         set csv;
         length db $10 file $30 obs 8;
         file=scan(v1,1,'.');
         obs =putn(compress(v5,","),20);
         format obs comma20.;
         db  ='ccae_mdcr';
         keep db file obs;
         rename obs=obs_expected;
      run;
 
      proc sort data=csv nodupkey;
         by file;
         where not missing(file);
      run;
 
      /* Initiate obs_found */
      data obs_found;
         length db $10 file $30 obs_found 8;
         format obs_found comma20.;
         call missing(of _all_);
         stop;
      run;
 
      %do j=1 %to %count_items(string=&main_tables);
         %let ds  =%lowcase(%scan(&main_tables,&j));
 
         %let dsid=%sysfunc(open(lz.&ds_praefix_ccae.&ds.&lz_version,in));
         %let nobs_ccae=%sysfunc(attrn(&dsid,nobs));
         %if &dsid > 0 %then %let rc=%sysfunc(close(&dsid));
 
         %let dsid=%sysfunc(open(lz.&ds_praefix_mdcr.&ds.&lz_version,in));
         %let nobs_mdcr=%sysfunc(attrn(&dsid,nobs));
         %if &dsid > 0 %then %let rc=%sysfunc(close(&dsid));
 
         data temp;
            length db $10 file $30 obs_found 8;
            format obs_found comma20.;
 
            db       ='ccae_mdcr';
            file     ="&ds_praefix_ccae.&ds.&lz_version";
            obs_found=&nobs_ccae;
            output;
 
            db       ='ccae_mdcr';
            file     ="&ds_praefix_mdcr.&ds.&lz_version";
            obs_found=&nobs_mdcr;
            output;
         run;
 
         data obs_found;
            set obs_found temp;
         run;
      %end; /* j: all DS per DB */
   %end; /* End of EarlyView version */
 
   /* Yearly or quarterly version: two csv files */
   %else %do;
      %do i=1 %to 2;
         %if       &i=1 %then %do;
            %let db_short=ccae;
         %end;
         %else %if &i=2 %then %do;
            %let db_short=mdcr;
         %end;
 
         %let csv_file=media&db_short._&year._v&version._SAS_GZ.csv;
 
         data csv_&db_short;
            infile "&project_dir/work/input/&csv_file" dsd dlm=',' missover pad lrecl=2000 firstobs=6;
            length v1-v5 $30;
            input  v1-v5;
         run;
 
         data csv_&db_short;
            set csv_&db_short;
            length db $10 file $30 obs 8;
            db  ="%lowcase(&db_short)";
            file=scan(v1,1,'.');
            obs =putn(compress(v5,","),20);
            format obs comma20.;
            keep db file obs;
            rename obs=obs_expected;
            if substr(file,1,4)=db;
         run;
 
         proc sort data=csv_&db_short nodupkey;
            by file;
            where not missing(file);
         run;
 
         /* Initiate obs_found */
         data obs_found_&db_short;
            length db $10 file $30 obs_found 8;
            format obs_found comma20.;
            call missing(of _all_);
            stop;
         run;
 
         %do j=1 %to %count_items(string=&main_tables);
            %let ds  =%lowcase(%scan(&main_tables,&j));
 
            %let dsid=%sysfunc(open(lz.&db_short.&ds.&lz_version,in));
            %let nobs=%sysfunc(attrn(&dsid,nobs));
            %if &dsid > 0 %then %let rc=%sysfunc(close(&dsid));
 
            data temp;
               length db $10 file $30 obs_found 8;
               format obs_found comma20.;
               db       ="%lowcase(&db_short)";
               file     ="&db_short.&ds.&lz_version";
               obs_found=&nobs;
            run;
 
            data obs_found_&db_short;
               set obs_found_&db_short temp;
            run;
         %end; /* j: all DS per DB */
      %end; /* i: CCAE or MDCR */
 
      data csv;
         set csv_ccae csv_mdcr;
      run;
 
      data obs_found;
         set obs_found_ccae obs_found_mdcr;
      run;
   %end; /* End of yearly or quarterly version */
 
   proc sort data=csv       nodupkey; by db file; run;
   proc sort data=obs_found nodupkey; by db file; run;
 
   data obs_check;
      merge csv obs_found;
      by db file;
      if lowcase(file) ne 'redbook'; /* The redbook goes into the dictionary folder */
   run;
 
   data obs_check;
      set obs_check end=eof;
      by db file;
      length ok $20;
      retain flag;
      if _n_=1 then flag=0;
      if obs_expected ne obs_found then do;
         flag=1;
         ok='!!!NOT OK!!!';
      end;
      else do;
         ok='***OK***';
      end;
      if eof then call symput('flag',flag);
   run;
 
   %print(ds=obs_check, var=db file obs_expected obs_found ok,
          path=&rep_dir, file=&prog..txt,
          tit1=Check if the number of observations is as specified - &lz_description,
          tit2=LZ path is &lz_path);
 
   %if &flag=0 %then %do;
      %put MESSAGE: *** The datasets have the expected number of observations;
   %end;
   %else %do;
      %put MESSAGE: !!! The datasets do not have the expected number of observations!!!;
      run;
      %final(endsas=yes, endsas_error=yes); run; endsas; run;
   %end;
   run;
%mend expected;
%expected;
 
%final;
