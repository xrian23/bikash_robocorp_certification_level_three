import sys


def set_recursion_limit_for_system():
    limit = sys.getrecursionlimit()
    print('Before changing, limit of stack =', limit)
    sys.setrecursionlimit(15000)
    limit = sys.getrecursionlimit()
    print('After changing, limit of stack =', limit)
