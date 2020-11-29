#!/bin/bash
#***********************************************************************************************************************
# FILE:      /GLIDE_RWD_Work/project/DATAHUB/users/schnem44/rwd/db/marketscan/ccae_mdcr/vdm_02/2016_01/work/program/run.sh
#
# FUNCTION:  Master shell script which submits all programs related to this project
#            Submit with nohup:
#            - nohup bash run.sh > ../log/run.sh.log  2> ../log/run.sh.err < /dev/null  &
#            - say: n run.sh (if you have the function "n" defined in your .bashrc)
#
# HISTORY:   10Jan2017  schnem44  File created
#***********************************************************************************************************************

# ----------------------------------------------------------------------------------------------------------------------
# Abort in case of an error and store the start time
# ----------------------------------------------------------------------------------------------------------------------
set -e
START_TIME=`perl -e 'print(time)'`

# ----------------------------------------------------------------------------------------------------------------------
# Basic parameters
# ----------------------------------------------------------------------------------------------------------------------
WD=$(pwd)                             # Working directory
PROJECT_DIR="${WD%/work/program}"     # remove /work/project from $WD
PROJECT=$(basename $PROJECT_DIR)      # project short name
THIS_SH=${0##*/}                      # Name of this shell, e.g. "run.sh"

export WD
export PROJECT_DIR

echo '-----------------------------------------------------------------------------------------------------------------'
echo "File        : ${THIS_SH} (Name of this shell in project $PROJECT)" 
echo "Directory   : ${WD} (Directory of this shell)" 
echo "Project Root: ${PROJECT_DIR}"
echo "Start       :" `date`
echo '-----------------------------------------------------------------------------------------------------------------'
echo ' '

# ----------------------------------------------------------------------------------------------------------------------
# SAS call
# ----------------------------------------------------------------------------------------------------------------------
SAS_DIR="/opt/sas/home/SASFoundation/9.4/sas"
PROG_DIR="${WD%/*}/program"
LOG_DIR="${WD%/*}/log"
OUT_DIR="${WD%/*}/output"

export SAS_DIR
export PROG_DIR
export LOG_DIR
export OUT_DIR

# ----------------------------------------------------------------------------------------------------------------------
# Define some utilities
# ----------------------------------------------------------------------------------------------------------------------
[ -z $BASH ] || shopt -s expand_aliases
alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"

function sas {
   i=$[$i+1]
   if [ $i = 120 ] 
      then 
      echo " "
      echo "waiting ...."
      echo " "
      wait
      i=0
   fi
   PROG=$1
   export PROG
   echo "$PROG_DIR/$1"
   $SAS_DIR -noterminal -log $LOG_DIR -print $OUT_DIR -work /data/saswork $PROG_DIR/$1 &
}

function bteq_f {
   BTEQ=$1
   export BTEQ
   echo "$PROG_DIR/bteq/$1"
   bteq < $PROG_DIR/bteq/$1 > $LOG_DIR/$1.log 2> $LOG_DIR/$1.err &
}

function bteq_ {
   BTEQ=$1
   export BTEQ
   echo "$PROG_DIR/$1"
   bteq < $PROG_DIR/$1 > $LOG_DIR/$1.log 2> $LOG_DIR/$1.err &
}

echo '-----------------------------------------------------------------------------------------------------------------'
echo "01-lz_sas_ds_rewrite: Unzip and rewrite all unzipped SAS datasets so that access will be faster"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 01-lz_sas_ds_rewrite.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "02-check_obs: Compare the number of observations in the datasets against the Excel from TruvenHealth"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 02-check_obs.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "03-lz2stage: Read from //LZ/staging and write to Teradata STAGE PROD"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 03-lz2stage.sas
wait
echo ' '

BEGINCOMMENT
FILES=$PROG_DIR/bteq/create_stage_*.bteq
for F in $FILES 
do
  FILENAME=$(basename $F)
# bteq_f $FILENAME 
done
wait

FILES=$PROG_DIR/sas/lz2stage_*.sas
for F in $FILES 
do
   FILENAME=$(basename $F)
#  sas sas/$FILENAME 
done
wait
ENDCOMMENT

echo '-----------------------------------------------------------------------------------------------------------------'
echo "04-stage2core: Read from STAGE_PROD and write to CORE_PROD"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 04-stage2core.sas
wait
echo ' '

BEGINCOMMENT
FILES=$PROG_DIR/bteq/stage2core_*.bteq
for F in $FILES 
do
  FILENAME=$(basename $F)
#  bteq_f $FILENAME 
done
wait
ENDCOMMENT

echo '-----------------------------------------------------------------------------------------------------------------'
echo "NOT NEEDED: 05-core2view: Read from CORE_PROD and write the views in VIEW_PROD and in PUB"
echo '-----------------------------------------------------------------------------------------------------------------'
###sas 05-core2view.sas: NOT NEEDED
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "06-qc_lz2td: Do a PROC COMPARE between SAS datasets on LZ and the views in PROD"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 06-qc_lz2td.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "07-valid_period: Update VALID_START and VALID_END"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 07-valid_period.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "10-lkp_format2ds: Store the SAS formats in PROJECT_DIR/work/input as datasets"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 10-lkp_format2ds.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "11-lkp_lz2stage: Read SAS datasets and write to PROD STAGE"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 11-lkp_lz2stage.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "12-lkp_stage2core: Read the lookup tables from STAGE_PROD and write to CORE_PROD"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 12-lkp_stage2core.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "13-lkp_core2view: Read from PROD CORE and write to PROD VIEW and PUB VIEW"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 13-lkp_core2view.sas
wait
echo ' '

echo '-----------------------------------------------------------------------------------------------------------------'
echo "14-update_valid_end: Reset the superseded VALID_END date"
echo '-----------------------------------------------------------------------------------------------------------------'
#sas 14-update_valid_end.sas
wait
echo ' '

# ----------------------------------------------------------------------------------------------------------------------
# Utility programs. Not really needed for this project.
# ----------------------------------------------------------------------------------------------------------------------
#sas t.sas
#sas update_file_head.sas
wait 
echo ' '

# ----------------------------------------------------------------------------------------------------------------------
# Retired programs
# ----------------------------------------------------------------------------------------------------------------------

echo '-----------------------------------------------------------------------------------------------------------------'
echo "Message : run.sh has finished"
echo 'End     : '`date`
dur=`perl -e "print int(time) - '$START_TIME'"`

perl -e "printf('Duration: %d hours, %d minutes, %d seconds', '$dur'/3600, ('$dur'%3600)/60, ('$dur'%60))"
echo ' '
echo '-----------------------------------------------------------------------------------------------------------------'
echo ' '

# ---------------------------------------------------------------------------------------------------------------------'
# Activate this block to get a copy of the run.sh.log with a date time stamp
# ---------------------------------------------------------------------------------------------------------------------'
END_DATE=`date +%y_%m_%d_%H_%M_%S`
LOG_COPY=run.sh.$END_DATE.log
echo 'This file saved as:' $LOG_COPY
cp $LOG_DIR/run.sh.log $LOG_DIR/$LOG_COPY
