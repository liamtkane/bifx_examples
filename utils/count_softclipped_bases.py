#!/usr/bin/env python3

# count_softclipped_bases.py

import argparse
import pysam

def parse_arguments():
	parser = argparse.ArgumentParser(description='Input BAM files for softclipped base counting')
	parser.add_argument('-i', '--infiles', nargs = '+', help = 'BAM file to investigate', required = True, dest = 'infiles')
	args = parser.parse_args()
	infiles = args.infiles

	return infiles

def count_softclipped_bases(files):

	for file in files:

		file_name = file.split('.')[0]
	
		bam_file = pysam.AlignmentFile(file, 'rb')

		total_softclipped_length = 0

		read_softclipped_lengths = []

		for read in bam_file:

			if read.is_unmapped:
			
				continue

			softclip_length = 0

			for cigar_op, length in read.cigartuples:
				if cigar_op == 4:  # 4 = soft-clipping
					softclip_length += length

			if softclip_length > 0:
				read_softclipped_lengths.append(softclip_length)
				total_softclipped_length += softclip_length

		bam_file.close()    	

		print(f'\nSoftclipping stats for {file_name}:\n')

		print(f"Total soft-clipped bases: {total_softclipped_length}")
		print(f"Number of reads with soft-clipping: {len(read_softclipped_lengths)}")
		print(f"Average soft-clipped length per read: {total_softclipped_length / len(read_softclipped_lengths):.2f}" if read_softclipped_lengths else "No soft-clipped reads found.")

def main():
	
	infiles = parse_arguments()
	count_softclipped_bases(infiles)

if __name__ == '__main__':
	main()		