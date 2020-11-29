/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/autoexec.sas
*
* FUNCTION:  This code is automatically included by the SAS system at the beginning of each job
*
* HISTORY:   01Sep2016  schnem44  File created
***********************************************************************************************************************/
%let td_server       =rochetd;
%let root_project_dir=;
%let project_dir     =;
 
*---------------------------------------------------------------------------------------------------------------------*;
* Macro search path: start from Working Directory: pwd;
*---------------------------------------------------------------------------------------------------------------------*;
filename getenv pipe 'pwd';
 
data _null_;
   infile getenv truncover;
   input env $3000.;
   length level_1 root_project_dir temp $300 pos 8;
 
   env=strip(env);
   call symput('env',env);
 
   pos    =index(env,'/work/program');
   temp   =substr(env,1,pos-1);
 
   level_1=strip(temp);
   call symput('project_dir',strip(level_1));
 
   pos             =find(temp,'/',-99);
   root_project_dir=substr(temp,1,pos-1);
   call symput('root_project_dir',strip(root_project_dir));
run;
 
%put %sysfunc(repeat(*,120));
%put MESSAGE: *** Level 1 macros are in &root_project_dir/work/function (look here first);
%put MESSAGE: *** Level 2 macros are in &project_dir/work/function (look here last);
%put MESSAGE: *** ROOT_PROJECT_DIR is &root_project_dir;
%put MESSAGE: *** PROJECT_DIR is &project_dir;
 
%let sasautos=options sasautos=("&root_project_dir/work/function" "&project_dir/work/function", sasautos);
%put MESSAGE: *** SASAUTOS in autoexec.sas:;
%put MESSAGE: *** &sasautos;
&sasautos;
 
*---------------------------------------------------------------------------------------------------------------------*;
* Connect to the SAS metadata server;
*---------------------------------------------------------------------------------------------------------------------*;
%macro opt;
   %global options;
   %if &td_server=rochetd %then %do;
      %let options=metaport=8561 metaprotocol=bridge metarepository="Foundation" metaserver="rkaustms01.kau.roche.com";
   %end;
%mend opt;
%opt;
 
%put MESSAGE: *** OPTIONS in autoexec.sas:;
%put MESSAGE: *** &options;
%put %sysfunc(repeat(*,120));
options &options;
%let options=;
run;
