#!/usr/bin/env python
#
# Usage: python _modify_ini.py file.ini section key value
#

import sys

try:
    from ConfigParser import RawConfigParser
except ImportError:
    from configparser import RawConfigParser
    
    
if __name__ == '__main__':
    _, ini, section, k, v = sys.argv
    cp = RawConfigParser()
    cp.read(ini)
    cp.set(section, k, v)
    
    with open(ini, 'w') as fp:
        cp.write(fp)
