#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 [--add-timestamp] <ping host>"
  exit 99
fi

opts=""
for opt in $*; do
  if [ "$opt" == "--add-timestamp" ]; then
    opts="$opts $opt"
    shift
  fi
done

trap echo 0

TIMEOUT=120
SAMPLE_TIME=0.2
COUNT=$(echo "$TIMEOUT/$SAMPLE_TIME" | bc)

ping -c$COUNT -i$SAMPLE_TIME $* | while read line; do

  # Skip header
  [[ "$line" =~ ^PING ]] && continue

  # Skip non-positive responses
  [[ ! "$line" =~ "bytes from" ]] && continue

  # Extract address field
  addr=${line##*bytes from }
  addr=${addr%%:*}

  # Extract seq
  seq=${line##*icmp_seq=}
  seq=${seq%% *}

  # Extract time
  time=${line##*time=}
  time=${time%% *}

  echo -n "$addr,$seq,$time"

  # Calculate date (not totally accurate)
  if [[ "$opts" =~ "--add-timestamp" ]]; then
    timestamp=$(date +%s%N)
    echo -n ",$timestamp"
  fi
  echo
done
