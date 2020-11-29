/***********************************************************************************************************************
* FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_e4/work/program/web.sas
*
* FUNCTION:  SAS WebServer Tests
*            http://rkaustms01.kau.roche.com:7980/SASStoredProcess/
*
* HISTORY:   Sep2015  schnem44  File created
***********************************************************************************************************************/
%init;
 
*----------------------------------------------------------------------------------------------------------------------;
* Test;
*----------------------------------------------------------------------------------------------------------------------;
libname _WEBOUT xml xmlmeta=&_XMLSCHEMA;
 
%macro m1;
   %global regionname;
 
   %stpbegin;
 
   * PROC TABULATE code here;
   proc tabulate data = sashelp.shoes format = dollar14.;
   title "Shoe Sales for &regionname";
      where (product =: 'Men' or product =: 'Women') & region="&regionname";
      table Subsidiary all,
           (Product='Total Product Sales' all)*Sales=' '*Sum=' ';
      class Subsidiary Product;
      var Sales;
      keylabel All='Grand Total'
               Sum=' ';
   run;
   %stpend;
%mend m1;
%*m1;
 
%final;
