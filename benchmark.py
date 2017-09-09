#!/usr/bin/env python

from subprocess import *
import os
import sys
import time
import csv

def bench(benchPath):

    startTime = time.time()

    benchCmd = './zeta %s' % benchPath
    pipe = Popen(benchCmd, shell=True, stdout=PIPE, stderr=PIPE)

    # Wait until the benchmark terminates
    pipe.wait()

    endTime = time.time()

    # Verify the return code
    ret = pipe.returncode
    if ret != 0:
        output = pipe.stdout.read()
        sys.stdout.write('\n')
        sys.stdout.write(output)
        raise Exception('invalid return code: ' + str(ret))

    # Compute the time in milliseconds
    deltaTime = 1000 * (endTime - startTime)

    return deltaTime

# Computes the geometric mean of a list of values
def geoMean(numList):
    if len(numList) == 1:
        return numList[0]

    prod = 1
    for val in numList:
        if val != 0:
            prod *= val

    return prod ** (1.0/len(numList))

def runBenchs():

    benchList = [
        'benchmarks/loop_cnt_100m.zim',
        'benchmarks/fcalls_10m.zim',
        'benchmarks/import_10m.zim',
        'benchmarks/loop_cnt.pls -- 7',
        'benchmarks/incr_field_1m.pls',
        'benchmarks/get_field_1m.pls',
        'benchmarks/set_field_1m.pls',
        'benchmarks/fib.pls -- 29',
        'benchmarks/fib36.zim',
        'benchmarks/plush_parser.zim',
        'benchmarks/img_fill.pls -- 256',
        'benchmarks/saw_wave.pls -- 10',
        'benchmarks/sine_wave.pls -- 10',
        'benchmarks/func_audio.pls -- 10',
        'benchmarks/rand_floats.pls -- 20',
        'benchmarks/zsdf.pls -- 512',
    ]

    timeVals = []

    for benchPath in benchList:

        sys.stdout.write(benchPath.ljust(40))
        sys.stdout.flush()

        timeMs = bench(benchPath)
        timeVals += [timeMs]

        sys.stdout.write('%6d ms\n' % timeMs)

    meanTime = geoMean(timeVals)
    sys.stdout.write(49 * '-' + '\n')
    sys.stdout.write('geometric mean'.ljust(40))
    sys.stdout.write('%6d ms\n' % meanTime)

# TODO: trigger make clean, make -j4 to make sure we have a fresh build
# Note: could ./configure with NDEBUG to disable assertions

# Run the benchmarks
runBenchs()
