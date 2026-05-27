#!/usr/bin/env python3
"""Remove SemanticsService.announce() calls (including multi-line) without damaging unrelated syntax."""
import re, sys, glob

def remove_announce_calls(text):
    """Remove all SemanticsService.announce(...) call expressions."""
    # We handle nested parens by counting
    result = []
    i = 0
    while i < len(text):
        # Look for SemanticsService.announce(
        match = re.search(r'SemanticsService\.announce\(', text[i:])
        if not match:
            result.append(text[i:])
            break
        start = i + match.start()
        result.append(text[i:start])
        # Find matching closing paren
        depth = 1
        j = start + len('SemanticsService.announce(')
        while j < len(text) and depth > 0:
            if text[j] == '(':
                depth += 1
            elif text[j] == ')':
                depth -= 1
            j += 1
        # j now points past the matching )
        # Also consume a trailing semicolon if present
        if j < len(text) and text[j] == ';':
            j += 1
        i = j
    return ''.join(result)

def process_file(path):
    with open(path) as f:
        orig = f.read()
    fixed = remove_announce_calls(orig)
    if fixed != orig:
        with open(path, 'w') as f:
            f.write(fixed)
        print(f'Fixed {path}')
    else:
        print(f'OK {path}')

for p in glob.glob('lib/screens/*.dart'):
    process_file(p)
