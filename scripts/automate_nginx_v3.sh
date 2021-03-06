#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

iRetry=5 
iCount=0
while true; do
    apt-get update
    iWorks=$(echo $?)
    if [ $iWorks -eq 0 ]; then
        apt-get install -y nginx
        iWorks=$(echo $?)
        if [ $iWorks -eq 0 ]; then
            echo "Hello World from updated host" $HOSTNAME "!" | sudo tee /var/www/html/index.html
            if [ $iWorks -eq 0 ]; then
                break
            fi
        fi
    fi

    if (( iCount++ == iRetry )); then
            printf 'Upgrade failed\n' 
            return 1
    else
         sleep 30
    fi
done;

