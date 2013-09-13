#!/bin/bash
#----------------------------------------------------------------------------
#
#                          <Project name> PROJECT
#
#----------------------------------------------------------------------------
#
# COMPONENT                             :		<prog name>
#
# AUTHOR                                :       <who are you>
# DATE                                  :       <auto date>
#
#
#
# DESCRIPTION                   :       
#
#
#----------------------------------------------------------------------------
#
# HISTORY
# -------
#
# AUTHOR                        :
# DATE                          :
# RFC NUMBER                    : None
#
# DESCRIPTION           :
#
#----------------------------------------------------------------------------

# DEBUG LIBRARY FUNCTIONS SETTINGS
# ================================
PROG_NAME=`basename $0`
if [ "`dirname $0 | cut -c1`" = "/" ] ; then
  RUN_DIR=`dirname $0`
else
  RUN_DIR=`pwd`/`dirname $0`
fi

LOG_FILE=/tmp/$PROG_NAME.log	# LOG File
LOGGING=file	# Log level: file | none | interactive (Used with inform)
DEBUG=off    	# Debug Level: on | off | full (Used with check_status)

USAGE="usage: $PROG_NAME [-m] [other options]"
if [ $# -ne 0 ] ; then
  while [ $# -gt 0 ] ; do
    case $1 in
      -d ) DEBUG=full ;;
      -config ) shift; AUDIT_CONF=$1 ;;
      -v ) echo "VERSION[$PROG_NAME] $VERSION" ; exit 0 ;;
      -* ) echo "incorrect parameter ($1) specified" ; echo $USAGE ; exit 1 ;;
      * )  echo $USAGE ; exit 1 ;;
    esac
    shift
  done
fi

init()
{
  
  clear
  inform " Initialising. Please wait"

  AUDIT_CONF=${AUDIT_CONF:-/mnt/configs/audit/general.cfg}
  ls $AUDIT_CONF > /dev/null 2>&1
  if [ $? -eq 0 ] ; then
    . $AUDIT_CONF
  else
    echo " "
    check_status 1 "No config file"
    exit 1
  fi

  echo " "
  echo " Checking config. Please wait"
  echo " "
  ckconfig

  mkdir -p $SIGN_AREA > /dev/null 2>&1

  TEMP_FILE=/tmp/file
  echo -n "."


  echo " "
}

function_template()
{
  # AUTHOR		: <name>
  #
  # DATE CREATED: <date>
  #
  # DESCRIPTION	:  <it does this>
  #				  
  # IN 			: 
  # IN 			: 
  # OUT			: 
  # RETURN		: SUCCESS - 
  #      		: FAILURE -

  REFER_MODULE=`pop "$MODULE"`
  MODULE=`push "$MODULE" "function_name"`
  SCENE="Entering function"

  check_status 0 "Entering function"

  # COMMANDS GO HERE

  check_status 0 " Leaving function"
  MODULE=`cdr "$MODULE"`
}

function_1()
{
  # AUTHOR		: <name>
  #
  # DATE CREATED: <date>
  #
  # DESCRIPTION	:  <it does this>
  #				  
  # IN 			: NONE
  # OUT			: 
  # RETURN		: SUCCESS - 
  #      		: FAILURE -

  REFER_MODULE=`pop "$MODULE"`
  MODULE=`push "$MODULE" "function_1"`
  SCENE="Entering function 1"

  check_status 0 "Entering function 1"

  # COMMANDS GO HERE
  echo "1. option"
  echo "2. option"
  echo "3. option"
  echo " "
  echo
  _CHOICE=$(range 3)

  check_status 0 "Leaving function 1"
  MODULE=`cdr "$MODULE"`
}








##########################################################################
view_change_env()
{
  set | more
  echo " "
  echo "Enter new Variable <or leave blank> and press <RETURN>"
  echo " "
  read ans
  echo "Setting.."
  eval $ans
  sleep 1
}
##########################################################################
check_log()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# Add these parameters to your script before you use the debug library
#    PARAMETER=VALUE
#    PROG_NAME=`basename $0`
#    LOG_FILE=/tmp/smecontrol.log	# LOG File
#    LOGGING=file			# Log level: full | none | interactive
#    DEBUG=off				# Used with check_status: on | off | full

case $LOGGING in
  file|full)
    if [ "$LOG_FILE" ] ;	then
      if [ ! -f $LOG_FILE ] ;	then
        echo >$LOG_FILE "[${PROG_NAME}] log file created on `date`"
        if [ $? -ne 0 ] ;	then
          echo >&2 "WARNING[${PROG_NAME}] cannot create a new log file (${LOG_FILE})"
          LOGGING=interactive
          LOG_FILE=/dev/null
        fi
      else
        if [ ! -w $LOG_FILE ] ;	then
          echo >&2 "WARNING[${PROG_NAME}] cannot write to the log file (${LOG_FILE})"
          LOGGING=interactive
          LOG_FILE=/dev/null
        fi
      fi
    else
      echo >&2 "WARNING[${PROG_NAME}] no log file defined"
      LOGGING=interactive
      LOG_FILE=/dev/null
    fi
    ;;
    none|interactive)
      LOG_FILE=/dev/null
    ;;
    *)
      echo >&2 "WARNING[${PROG_NAME}] \$LOGGING set to an illegal value (${LOGGING})"
      LOGGING=interactive
      LOG_FILE=/dev/null
  esac
# LIBRARY FUNCTION 
# DO NOT MODIFY
}
##########################################################################
inform()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
# check_log expects a string or a quoted command and outputs the results
# to the specified location, normally to screen and a log file. The log file
# has the added information of a Date Time stamp
#
# Example:
# 	inform "The program found these files"
#	inform "`ls`"
#
check_log
if [ $LOGGING != none -o $LOGGING != file ] ;	then
  echo >&2 "$1"
fi
echo >> $LOG_FILE "INFORM[${PROG_NAME}] $1 (on `date '+%D %T'`)"
# LIBRARY FUNCTION 
# DO NOT MODIFY
}
##########################################################################
check_file()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# argument 1 = File to be checked
#
if [ `ls $1` ] ; then
  check_status 0 "Found $1"
else
  inform "check_file($1) DID NOT FIND A FILE"
  exit
fi
}
##########################################################################
get_choice()
{
  echo " "
  echo " x.     Exit"
  echo " "
  print -n " Enter choice: "
  CHOICE=`line`
  CHOICE=${CHOICE:-0}
}
##########################################################################
range()
{
# LIBRARY FUNCTION
# DO NOT MODIFY
#
# argument 1 = A range of numbers to create a list from i.e. "1-5,7-11"
# range also works in reverse i.e. "10 , 6 - 1"
#

  typeset input=`echo $1 | tr -d " " `
  input=`echo $input | tr -s "," " "`

  for item in ${input} ; do
    if [ $(echo ${item} | grep "-") ] ; then
      typeset part1=`echo ${item} | cut -d "-" -f1`
      typeset part2=`echo ${item} | cut -d "-" -f2`
      if [ $part1 -lt $part2 ] ; then
        while [[ $part1 -le $part2 ]] ; do
          echo "$part1 \c"
          ((part1+=1))
        done
      else
        while [[ $part1 -ge $part2 ]] ; do
          echo "$part1 \c"
          ((part1-=1))
        done
      fi
    else
      echo "${item} \c"
    fi
  done
}
##########################################################################
push()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# argument 1 = Stack list
# argument 2 = Item to add
# return     = new stack
#
echo "$1 $2"
}
##########################################################################
pop()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# argument 1 = Stack list
# return     = new stack
#
echo $1 | awk '{print $NF}'
}
##########################################################################
cdr()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# argument 1 = Stack list
# return     = new stack
#
echo $1 | awk '{for ( i = 1; i < NF; i++) print $i }'
}
##########################################################################
check_status()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
#
# argument 1 = status to be checked
# argument 2 = command name
# argument 3 = NOEXIT flag
#
# check_status can be used in 3 ways. 
# Either to provide useful information during the execution of a script
# when debugging is turned on (DEBUG=on or DEBUG=full).
#	check_status 0 "got here"
#
# to provide error checking and break points
# 	cp $A $B
# 	check_status $? "Copying File" 	(if copying fails the script will exit)
#
# 	ls $A
#	check_status $? "Checking for file" NOEXIT
#
# or an undocumented feature for use during development to run internal
# commands like changing environment variable in DEBUG=full mode.
# CHECK DEBUG and inform
# CHECK FOR ARGUMENTS
# ===================
if [ $1 -ne 0 ] ; then
  inform "$2 - FAILED with status code $1 ##################"
  if [ "$3" != "NOEXIT" ] ; then
    exit $1
  else
    return $1
  fi
else
  if [ $DEBUG != "off" ] ; then
    echo "[DEBUG]	$2"
    echo "[DEBUG]	$2" >> $LOG_FILE
    if [ $DEBUG = "full" ] ; then
      echo " "
      echo "             -- Press <return> or q to quit -- "
      read ans
      if [ "$ans" = "q" ] ; then
        exit 0 
      else
        if [ "$ans" != "" ] ; then
          eval $ans
        fi
      fi
    fi
  fi
  return 0
fi
# LIBRARY FUNCTION 
# DO NOT MODIFY
}
##########################################################################
log_trap()
{
# LIBRARY FUNCTION 
# DO NOT MODIFY
  inform "$1"
  inform " "
  inform "Nested Module    : 	${MODULE}"
  inform "Current Module   :	`pop \"$MODULE\"`"
  inform "Referring Module : 	$REFER_MODULE"
  inform "Scene            :	$SCENE"
  echo " "
  echo " <Press Enter>"
  read ans
  exit
}
trap "log_trap \"\n\nTERMINATED: User probably logged out\"" 1
trap "log_trap \"\n\nTERMINATED: User probably ctrl-c\"" 2
trap "log_trap \"\n\nTERMINATED: Illegal Instruction\"" 4
trap "log_trap \"\n\nTERMINATED: Probably via kill\"" 15
#trap "log_trap \"\n\nTERMINATED: ERR\"" ERR
# LIBRARY FUNCTION 
# DO NOT MODIFY
##########################################################################


#MAIN

MODULE=""

init

function_template
function_1


echo "Testing the inform function"
SCENE="Testing the inform function"
inform "This is logged to the screen and a log file"
echo " "
echo " "

echo "Do you want to try a Trap? (y/n) [n]"
read ans
if [ "$ans" = "y" ; then
  SCENE="Testing a log trap"
  echo "Sleeping for 60 seconds"
  echo " .... Test a log trap with <crtl C>....."
  sleep 60
fi

echo " "
echo "Testing the check_status command"
inform "I am turning DEBUG=full"
DEBUG=full
check_status 0 "Zero can be useful for debugging"
check_status 0 "But you can turn it off during the full mode"
check_status 0 "As it can be quite annoying. If you type DEBUG=on now"
check_status 0 "Then you will get this message"
check_status 0 "and this one, but wont have to interactively go top the next"

echo " "
echo "Testing the check_status command pt 2"
inform "I am turning DEBUG=full"
DEBUG=full
check_status 0 "Zero can be useful for debugging"
check_status 0 "But you can turn it off during the full mode"
check_status 0 "As it can be quite annoying. If you type DEBUG=off now"
check_status 0 "Then you wont get this message"
check_status 0 "or this one"

echo " "







exit
