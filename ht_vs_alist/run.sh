#!/bin/sh
# Full benchmark pipeline: run Guile 100x and export PNG plot

OUTFILE="benchmark_results.csv"
SCM="./benchmark.scm"
RUNS=100
PNGOUT="benchmark_plot.png"

# CSV header
echo "run,assoc_create,ht_create,assoc_lookup,ht_lookup,assoc_insert,ht_insert" > "$OUTFILE"

# Run 100 times
for i in $(seq 1 $RUNS); do
    echo "Running benchmark $i/$RUNS..."
    RESULT=$(guile "$SCM")
    ASSOC_CREATE=$(echo "$RESULT" | grep "Assoc-list creation" | awk '{print $3}')
    HT_CREATE=$(echo "$RESULT" | grep "Hashtable creation" | awk '{print $3}')
    ASSOC_LOOKUP=$(echo "$RESULT" | grep "Assoc-list lookup" | awk '{print $3}')
    HT_LOOKUP=$(echo "$RESULT" | grep "Hashtable lookup" | awk '{print $3}')
    ASSOC_INSERT=$(echo "$RESULT" | grep "Assoc-list insertion" | awk '{print $3}')
    HT_INSERT=$(echo "$RESULT" | grep "Hashtable insertion" | awk '{print $3}')
    echo "$i,$ASSOC_CREATE,$HT_CREATE,$ASSOC_LOOKUP,$HT_LOOKUP,$ASSOC_INSERT,$HT_INSERT" >> "$OUTFILE"
done

echo " Done running benchmarks. Generating plot..."

gnuplot -e "
set datafile separator ',';
set terminal pngcairo size 1280,720 enhanced font 'Sans,10';
set output '$PNGOUT';
set key left top;
set grid;
set title 'Assoc-list vs Hashtable Benchmark (2000 elements, 100 runs)';
set xlabel 'Run #';
set ylabel 'Time (ms)';
plot \
'$OUTFILE' using 1:2 with lines title 'Assoc Create', \
'$OUTFILE' using 1:3 with lines title 'Hashtable Create', \
'$OUTFILE' using 1:4 with lines title 'Assoc Lookup', \
'$OUTFILE' using 1:5 with lines title 'Hashtable Lookup', \
'$OUTFILE' using 1:6 with lines title 'Assoc Insert', \
'$OUTFILE' using 1:7 with lines title 'Hashtable Insert';
set output;"

echo " Plot saved to $PNGOUT"
