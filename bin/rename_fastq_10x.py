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
    parser.add_argument('--seq_run', type=int, help="numeric identifier for samples resequenced on separate flowcells", metavar='', default=1)
    parser.add_argument('--seq_run', type=str, help="sample ID used to name fastq files", metavar='')
    parser.add_argument('--suffix_1', type=str, help="string to replace suffix 1 with (i.e. R1)", metavar='')
    parser.add_argument('--suffix_2', type=str, help="string to replace suffix 2 with (i.e. R2)", metavar='')
    parser.add_argument('--suffix_3', type=str, help="string to replace suffix 3 with (i.e. I1)", metavar='')
    parser.add_argument('--suffix_4', type=str, help="string to replace suffix 4 with (i.e. I2)", metavar='')
    return parser.parse_args(args)

def rename_fastq(dir, args):
    for file in os.listdir(dir):
        if file.endswith("_1.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + args.seq_run + "_L001_" + args.suffix_1 + "_001.fastq.gz"
        elif file.endswith("_2.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + args.seq_run + "_L001_" + args.suffix_2 + "_001.fastq.gz"
        elif file.endswith("_3.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + args.seq_run + "_L001_" + args.suffix_3 + "_001.fastq.gz"
        elif file.endswith("_4.fastq.gz"):
            new_name = dir + args.sample_id + "_S" + args.seq_run + "_L001_" + args.suffix_4 + "_001.fastq.gz"
        else:
            continue
        os.rename(dir+file, new_name)


def main(args=None):
    args = parse_args(args)
    rename_fastq(dir = args.dir, args = args)

if __name__ == "__main__":
    sys.exit(main())
