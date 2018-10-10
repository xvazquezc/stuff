# stuff
Place to store miscellaneous scripts

## Scripts

### `iprs2anvio.sh`
Script for parsing InterProScan annotations into table format suitable for importing into Anvi'o with [`anvi-import-functions`](http://merenlab.org/2016/06/18/importing-functions/)

`iprs2anvio.sh` allows you to indicate which sources of annotation you want to export and the possibility of creating individual files for each source.

> Note: tested on Linux.
>
> Requires GNU `getopt`, installable in Mac using [MacPorts](https://www.macports.org/install.php) with `sudo port install getopt`

Help:

```
iprs2anvio.sh v0.1

USAGE
iprs2anvio.sh -i iprs_output.tsv -o output_prefix
[-d|--db db_list] [-g|--go_terms] [-p|--pathways] [-r|--ipr] [-s|--split] [-h|--help]

REQUIRED
-i, --input      Output file from InterProScan in tsv format.
-o, --output     Prefix for the output file(s).

OPTIONAL
-d, --db         Only extract the annotations of specific databases. All annotations
                 will be extracted by default. For multiple databases, use a comma-separated
                 list.
-g, --go_terms   Extract GO terms.
-p, --pathways   Extract pathway annotations.
-r, --ipr        Extract InterPro cross-reference annotations.
-s, --split      Annotations from each database will be written in individual files.

MISCELLANEOUS
-h, --help       Show this help information and exits.
```

## Deprecated

### IPRS to Anvi'o scripts
Use `iprs2anvio.sh` instead.

`iprs2anvi_go.sh` parses GO terms from IPRS .tsv files to a table usable by anvi-import-functions. Output to `iprs_go_matrix.tsv` by default. Usage:
```
iprs2anvi_go.sh infile.tsv [outfile(optional)]
```

`iprsalt2anvio.sh` is similar to `iprs2anvi_go.sh` but also parses the output from the pathways.
