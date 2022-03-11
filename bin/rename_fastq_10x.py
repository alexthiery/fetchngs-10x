#!/usr/bin/env python

import argparse
import os
import sys


def parse_args(args=None):
    parser = argparse.ArgumentParser(
        description="Rename SRA fastq files to 10x format",
        epilog="Example usage: python rename_fastq_10x.py --suffix_1 R1 --suffix_2 R2 --suffix_3 I1",
    )
    parser.add_argument('--dir', type=str, help="directory containing files to rename", metavar='')
    parser.add_argument('--sample_id', type=str, help="sample ID used to name fastq files", metavar='')
    parser.add_argument('--suffix_1', type=str, help="string to replace suffix 1 with (i.e. R1)", metavar='', default='R1')
    parser.add_argument('--suffix_2', type=str, help="string to replace suffix 2 with (i.e. R2)", metavar='', default='R2')
    parser.add_argument('--suffix_3', type=str, help="string to replace suffix 3 with (i.e. I1)", metavar='', default='I1')
    parser.add_argument('--suffix_4', type=str, help="string to replace suffix 4 with (i.e. I2)", metavar='', default='I2')
    return parser.parse_args(args)


def rename_fastq(dir, args):
    files = os.listdir(dir)
    files = sorted(files)
    sample = files[0].split("_", 1)[0]
    ticker = 1 #add ticker to append seq runs if there is more than 1 unique sample name per experiment (i.e. multiple SRR ids)
    for file in files:
        if file.split("_", 1)[0] != sample:
            sample = file.split("_", 1)[0]
            ticker +=1

        if file.endswith("_1.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + str(ticker) + "_L001_" + args.suffix_1 + "_001.fastq.gz"
        elif file.endswith("_2.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + str(ticker) + "_L001_" + args.suffix_2 + "_001.fastq.gz"
        elif file.endswith("_3.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + str(ticker) + "_L001_" + args.suffix_3 + "_001.fastq.gz"
        elif file.endswith("_4.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + str(ticker) + "_L001_" + args.suffix_4 + "_001.fastq.gz"
        else:
            continue
        os.rename(dir+file, new_name)
    

def main(args=None):
    args = parse_args(args)
    rename_fastq(dir = args.dir, args = args)

if __name__ == "__main__":
    sys.exit(main())
