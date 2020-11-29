/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/06-qc_lz2td.sas
*
* FUNCTION:  Do a PROC COMPARE between SAS datasets on LZ and the views in PROD
*
* HISTORY:   14Mar2016  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters:;
* year version vdm_version lz_path lz_description lz_version main_tables valid_start valid_end load_id maxobs tp tp_id;
*----------------------------------------------------------------------------------------------------------------------;
%include "&prog_dir/00-parameters.sas"; run;
 
%qc_lz2td; run;
 
%final;
