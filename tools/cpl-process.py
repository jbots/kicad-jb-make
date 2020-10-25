#!/usr/bin/python3

from pathlib import Path
import csv


def process_cpl(in_path, out_path):

    data = []

    with open(in_path, newline="") as f:
        data = list(csv.DictReader(f))

    # Fix rotation for bottom sides (make negative)
    for row in data:
        if row["Side"] == "bottom":
            row["Rotation"] = "-" + str(row["Rotation"])

    with open(out_path, mode="w") as f:
        fieldnames = [
            "Reference Designator",
            "Center X",
            "Center Y",
            "Rotation",
            "Side",
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)

        writer.writeheader()
        for row in data:
            writer.writerow(row)


if __name__ == "__main__":
    from argparse import ArgumentParser

    parser = ArgumentParser(description="Fix CPL output including bottom side rotation")
    parser.add_argument("in_file", type=Path, help="Input CPL csv file")
    parser.add_argument("out_file", type=Path, help="Output CPL csv file")

    args = parser.parse_args()

    process_cpl(args.in_file, args.out_file)
