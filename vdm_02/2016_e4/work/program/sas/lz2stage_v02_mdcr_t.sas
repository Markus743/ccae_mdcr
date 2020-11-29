/*************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/sas/lz2stage_v02_mdcr_t.sas
* 
* FUNCTION:  Read from LZ and write to STAGE
* 
* HISTORY:   Written by 03-lz2stage
*************************************************************************************************/
%init;
 
libname lz '/data/RWD_SHARE/MDH/users/schnem44/rwd/ccae_mdcr/snapshot/2016_e4' access=readonly; run;
 
libname stage teradata tdpid=rochetd authDomain=teradataAuth database=PS_RWD_VDM_MDCR;
 
 
proc contents data=lz.evmct164; run;
 
data stage;
   set lz.evmct164
;
   attrib SEQNUM length=8;
   attrib VERSION_ length=$2;
   VERSION_=VERSION;
   drop VERSION;
   attrib EFAMID length=8;
   attrib ENROLID length=8;
   attrib DTEND length=8 format=DATE9.;
   attrib DTSTART length=8 format=DATE9.;
   attrib MEMDAYS length=8;
   attrib MHSACOVG length=$1;
   attrib PLANTYP length=8;
   attrib YEAR_ length=8;
   YEAR_=YEAR;
   drop YEAR;
   attrib AGE length=8;
   attrib DOBYR length=8;
   attrib REGION length=$1;
   attrib MSA length=8;
   attrib DATATYP length=8;
   attrib AGEGRP length=$1;
   attrib EECLASS length=$1;
   attrib EESTATU length=$1;
   attrib EGEOLOC length=$2;
   attrib EMPREL length=$1;
   attrib PHYFLAG length=$1;
   attrib RX length=$1;
   attrib SEX length=$1;
   attrib HLTHPLAN length=$1;
   attrib INDSTRY length=$1;
   attrib VALID_START length=8 format=datetime19.;
   attrib VALID_END length=8 format=datetime19.;
   attrib LOAD_ID length=8;
   attrib ROW_NUMBER_ length=8;
   VALID_START=input('11Jan2017 20:00:00',datetime19.);
   VALID_END  =input('31Dec9999 23:59:59',datetime19.);
   LOAD_ID    =468;
 
   retain ROW_NUMBER_ 0;
   row_number_ + 1;
run;
 
proc append base=stage.V02_MDCR_T
(fastload          =yes
tpt                =yes
TPT_TRACE_LEVEL    =2
TPT_TRACE_LEVEL_INF=12
TPT_TRACE_OUTPUT   ='/GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/output/sas_tpt_V02_MDCR_T.dat'
)
data=stage;
run;
 
%final;
