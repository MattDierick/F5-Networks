#!/usr/bin/env python3
"""
Transforms words from input-bigip.txt into pattern ves-io-demo-app-waap-{word}
and writes to output-bigip.txt. Handles empty lines and strips whitespace.
"""

input_file = 'input-bigip.txt'
output_file = 'output-bigip.txt'
pattern = 'ves-io-demo-app-waap-{}'

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

