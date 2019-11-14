#!/bin/bash
set -e  # Exit on first error

declare -a keys=(
  # LOW BATTERY
  "COM_LOW_BAT_ACT"
  "BAT_LOW_THR"
  "BAT_CRIT_THR"
  "BAT_EMERGEN_THR"
  # GPS LOST
  "COM_POS_FS_DELAY"
  "COM_POSCTL_NAVL"
  "CBRK_GPSFAIL"
  "CBRK_VELPOSERR"
  # OFFBOARD LOST
  "COM_OF_LOSS_T"
  "COM_OBL_ACT"
  "COM_OBL_RC_ACT"
);

for KEY in "${keys[@]}"; do
  read -r VAL <<< "$(rosrun mavros mavparam get "$KEY")"
  echo "$KEY: $VAL"
done
