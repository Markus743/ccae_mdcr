/*************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/sas/lz2stage_v02_ccae_f.sas
* 
* FUNCTION:  Read from LZ and write to STAGE
* 
* HISTORY:   Written by 03-lz2stage
*************************************************************************************************/
%init;
 
libname lz '/data/RWD_SHARE/MDH/users/schnem44/rwd/ccae_mdcr/snapshot/2016_e4' access=readonly; run;
 
libname stage teradata tdpid=rochetd authDomain=teradataAuth database=PS_RWD_VDM_CCAE;
 
 
proc contents data=lz.evcef164; run;
 
data stage;
   set lz.evcef164
;
   attrib SEQNUM length=8;
   attrib VERSION_ length=$2;
   VERSION_=VERSION;
   drop VERSION;
   attrib DX1 length=$7;
   attrib DX2 length=$7;
   attrib PROC1 length=$7;
   attrib FACHDID length=8;
   attrib EFAMID length=8;
   attrib ENROLID length=8;
   attrib DOBYR length=8;
   attrib YEAR_ length=8;
   YEAR_=YEAR;
   drop YEAR;
   attrib AGE length=8;
   attrib BILLTYP length=$3;
   attrib CAP_SVC length=$1;
   attrib CASEID length=8;
   attrib COB length=8;
   attrib COINS length=8;
   attrib COPAY length=8;
   attrib DEDUCT length=8;
   attrib DX3 length=$7;
   attrib DX4 length=$7;
   attrib DX5 length=$7;
   attrib DX6 length=$7;
   attrib DX7 length=$7;
   attrib DX8 length=$7;
   attrib DX9 length=$7;
   attrib DXVER length=$1;
   attrib MHSACOVG length=$1;
   attrib NETPAY length=8;
   attrib NTWKPROV length=$1;
   attrib PAIDNTWK length=$1;
   attrib PDDATE length=8 format=DATE9.;
   attrib PLANTYP length=8;
   attrib PROC2 length=$7;
   attrib PROC3 length=$7;
   attrib PROC4 length=$7;
   attrib PROC5 length=$7;
   attrib PROC6 length=$7;
   attrib PROVID length=8;
   attrib SVCDATE length=8 format=DATE9.;
   attrib TSVCDAT length=8 format=DATE9.;
   attrib MDC length=$2;
   attrib DSTATUS length=$2;
   attrib REGION length=$1;
   attrib MSA length=8;
   attrib STDPLAC length=8;
   attrib STDPROV length=8;
   attrib DATATYP length=8;
   attrib AGEGRP length=$1;
   attrib EECLASS length=$1;
   attrib EESTATU length=$1;
   attrib EGEOLOC length=$2;
   attrib EIDFLAG length=$1;
   attrib EMPREL length=$1;
   attrib ENRFLAG length=$1;
   attrib PHYFLAG length=$1;
   attrib RX length=$1;
   attrib SEX length=$1;
   attrib HLTHPLAN length=$1;
   attrib INDSTRY length=$1;
   attrib MSCLMID length=8;
   attrib NPI length=$10;
   attrib VALID_START length=8 format=datetime19.;
   attrib VALID_END length=8 format=datetime19.;
   attrib LOAD_ID length=8;
   attrib ROW_NUMBER_ length=8;
   VALID_START=input('11Jan2017 20:00:00',datetime19.);
   VALID_END  =input('31Dec9999 23:59:59',datetime19.);
   LOAD_ID    =459;
 
   retain ROW_NUMBER_ 0;
   row_number_ + 1;
run;
 
proc append base=stage.V02_CCAE_F
(fastload          =yes
tpt                =yes
TPT_TRACE_LEVEL    =2
TPT_TRACE_LEVEL_INF=12
TPT_TRACE_OUTPUT   ='/GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/output/sas_tpt_V02_CCAE_F.dat'
)
data=stage;
run;
 
%final;
