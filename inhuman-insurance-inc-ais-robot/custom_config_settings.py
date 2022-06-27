import sys
import json


def set_recursion_limit_for_system(json_str: str, key: str) -> str:
    limit = sys.getrecursionlimit()
    print('Before changing, limit of stack =', limit)
    sys.setrecursionlimit(15000)
    limit = sys.getrecursionlimit()
    print('After changing, limit of stack =', limit)

    json_str = json_str.replace("\'", "\"")
    # load the json to a string
    resp = json.loads(json_str)
    # print the resp
    print(resp)

    # extract an element in the response
    print(resp[key])

    return resp[key]
