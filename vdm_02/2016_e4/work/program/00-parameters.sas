/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/00-parameters.sas
*
* FUNCTION:  Parameters for this task
*            - Included by most main programs
*
* HISTORY:   09Jan2017  schnem44  File created. All parameters checked
***********************************************************************************************************************/
*----------------------------------------------------------------------------------------------------------------------;
* Version specific parameters;
*----------------------------------------------------------------------------------------------------------------------;
%let year          =2016;
%let version       =e4;
%let vdm_version   =V02;
%let lz_path       =/staging/inbound/marketscan/ccae_mdcr/&year._&version;
%let ds_path       =/data/RWD_SHARE/MDH/users/schnem44/rwd/ccae_mdcr/snapshot/&year._&version;
%let lz_description=%str(MarketScan CCAE-MDCR &year V. e4);
%let lz_version    =164; /* 2015 ev-version: evced154.sas7bdata, 2015 q-versions: ccaea150.sas7bdat */
 
/* All 8 tables:    A D F I O R S T : No A- and R-Tables in EV; no R-Table in 0.x */
%let main_tables   =D F I O S T; /* 6 tables */
 
%let valid_start   =%str(11Jan2017 20:00:00);
%let valid_end     =%str(31Dec9999 23:59:59);
 
/* The first new LOAD_ID will be LOAD_ID + 1: SELECT max(load_id) FROM PC_RWD_VDM_MDCR.V02_MDCR_T; */
%let load_id       =456; /* 12 tables: 456 - 471 */
 
/* Set MAXOBS gt 0 for doing some tests */
%let maxobs=;
 
/* Used by the QC program for HTML-links */
%let tp=http://we2.collaboration.roche.com/team/20122cdc/db/files/MarketScan/CCAE-MDCR/Data Model/VDM v. 2/qc;
%let tp_id=DATAHUB-18-426; /* Document ID of release notes page */
*-END OF PARAMETERS-------------------------------------------------------------------------------------------------;
 
libname lz "&ds_path" access=readonly; run;
