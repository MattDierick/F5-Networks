#!/usr/bin/env python3
"""
Transforms words from input.txt into pattern ves-io-{word}-sentence-re-lb
and writes to output.txt. Handles empty lines and strips whitespace.
"""

input_file = 'input-xc.txt'
output_file = 'output-xc.txt'
pattern = 'ves-io-{}-sentence-re-lb'

try:
    with open(input_file, 'r') as infile:
        words = [line.strip() for line in infile if line.strip()]
    
    with open(output_file, 'w') as outfile:
        for word in words:
            transformed = pattern.format(word)
            outfile.write(transformed + '\n')
    
    print(f'Success: Processed {len(words)} words. Output in {output_file}')
    
except FileNotFoundError:
    print(f'Error: {input_file} not found. Create it with one word per line.')
except Exception as e:
    print(f'Error: {e}')

