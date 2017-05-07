#!/usr/bin/env python
#language "lang/python/0"

def fib(n):
    if n < 2:
        return n

    return fib(n-1) + fib(n-2)

r = fib(36)

print(r)
