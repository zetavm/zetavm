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
        'benchmarks/img_fill.pls',
        'benchmarks/incr_field_1m.pls',
        'benchmarks/fcalls_10m.zim',
        'benchmarks/fib29.pls',
        #'benchmarks/fib36.zim',
        'benchmarks/loop_cnt_100m.zim',
        'benchmarks/plush_parser.zim',
        'benchmarks/sqr_wave.pls'
    ]

    timeVals = []

    for benchPath in benchList:

        sys.stdout.write(benchPath.ljust(35))
        sys.stdout.flush()

        timeMs = bench(benchPath)
        timeVals += [timeMs]

        sys.stdout.write('%6d ms\n' % timeMs)

    meanTime = geoMean(timeVals)
    sys.stdout.write(44 * '-' + '\n')
    sys.stdout.write('geometric mean'.ljust(35))
    sys.stdout.write('%6d ms\n' % meanTime)

# TODO: trigger make, NDEBUG?

# Run the benchmarks
runBenchs()
