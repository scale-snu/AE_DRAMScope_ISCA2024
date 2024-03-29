#!/bin/bash

params_list="bitfile_name"

allowed_bitfile_name="hbm2_35ns_10k.bit  hbm2_7800ns_1k.bit"

bitfile_name=${1}
echo ${bitfile_name}

function contains() 
{
  token=${1}
  list=${2}
  for _token in ${list};
  do
    if [ "${_token}" == "${token}" ]; 
    then
      return 1
    fi
  done
  return 0
}

input_OK=true
for param in ${params_list};
do
  list_name=allowed_${param}
  
  if contains ${!param} "${!list_name}";
  then
    echo "Unrecognized ${param} \"${!param}\", supported values: ${!list_name}"
    input_OK=false
  fi
done
if ! ${input_OK};
then
  exit -1
fi

board_id=0


#bitfile_name=${board}/${board}_${slot}_${dimm_type}_${rank}_${DQ}.bit
#probesfile_name=${board}/${board}_${slot}_${dimm_type}_${rank}_${DQ}.ltx

export VIVADO_EXEC='/tools/Xilinx/Vivado/2020.2/bin/vivado'
if [ -z "$VIVADO_EXEC" ]
then
  echo "Please assign vivado executable's path to VIVADO_EXEC variable first!"
else
  echo "Trying to program the board with the prebuilt files ${bitfile_name}..."
  $VIVADO_EXEC -mode tcl -source $( dirname "${BASH_SOURCE[0]}")/programFPGA.tcl -nolog -nojournal -tclargs ${bitfile_name} #${probesfile_name}
  echo "Done programming the board!"
fi
