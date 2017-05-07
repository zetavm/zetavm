#!/usr/bin/env python

from subprocess import *
import os
import sys
import time
import csv

def bench(benchPath):

    benchNamePad = benchPath + max((35 - len(benchPath)), 0) * ' '
    sys.stdout.write(benchNamePad)
    sys.stdout.flush()

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

    sys.stdout.write('%6d ms\n' % deltaTime)

# TODO: trigger make, NDEBUG?

bench('benchmarks/img_fill.pls')
bench('benchmarks/incr_field_1m.pls')
bench('benchmarks/fib29.pls')
#bench('benchmarks/fib36.zim')
bench('benchmarks/loop_cnt_100m.zim')
bench('benchmarks/plush_parser.zim')
bench('benchmarks/sqr_wave.pls')
