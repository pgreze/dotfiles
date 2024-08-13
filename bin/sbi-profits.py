#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Parse the CSV downloaded from SBI realized profits/loss page:
https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETacR010Control&_PageID=DefaultPID&_DataStoreID=DSWPLETacR010Control&_SeqNo=1723457391145_default_task_35372_DefaultPID_DefaultAID&getFlg=on&_ActionID=DefaultAID

To print the CSV to terminal, use:
```
iconv -f SHIFT-JIS file.csv
```
"""

import sys

def tokenize(line):
    def _tokenize():
        for p in line.strip().split(','):
            column = p.strip(' "')
            if not column:
                continue
            yield column
    return list(_tokenize())

def move_first(l, i):
    res = [l[i]] + l[:i] + l[(i+1):]
    # print(f"before={l} after={res}")
    return res

def convert_int(l, i):
    if l[i].startswith('+'):
        return l[:i] + [l[i][1:]] + l[(i+1):]
    return l

def parse_line(line):
    if '外国株式売' in line:
        # Foreign stock sell
        items = tokenize(line)
        items = move_first(items, 1) # date
        items = move_first(items, 3) # type
        items = convert_int(items, len(items)-1)
        print(','.join(items))
    elif '現物売' in line:
        # JP stock sell
        items = tokenize(line)
        # Merge stock code + ticker
        items = [f"{items[0]} {items[1]}"] + items[2:]
        items = move_first(items, 1) # date
        items = move_first(items, 3) # type
        items = convert_int(items, len(items)-1)
        print(','.join(items))
    elif '譲渡益税徴収額' in line:
        # Capital gains tax collected
        print(','.join(tokenize(line)))
    elif '譲渡益税還付金' in line:
        # Capital Gains Tax Refund
        print(','.join(tokenize(line)))
    # print(f'Ignore {line}')

if __name__ == '__main__':
    skipped_headers = False
    with open(sys.argv[1], encoding='shift_jis') as file:
        for line in file.readlines():
            if not skipped_headers:
                skipped_headers = '銘柄コード' in line
            else:
                parse_line(line)
