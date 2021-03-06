#!/usr/bin/env python

import argparse
import h5py
import pysam
import numpy as np
from collections import Counter, OrderedDict

from GenomicConsensus.io import BamReader, BamAlignment

# Note: there is a bug in the htslib bundled in pysam 0.8.0 that
# effects "tell".  In order to get this to work, you need pysam 0.8.0
# built against htslib 1.1.  Hopefully this will be fixed in pysam 0.8.1.

# Call: makePbi.py bamfile referenceFasta

PBI_VERSION = "0.1"

PBI_COLUMNS_AND_TYPES = [ ("ReadGroupID"       , np.int32),
                          ("tId"               , np.int32),
                          ("tStart"            , np.int32),
                          ("tEnd"              , np.int32),
                          ("isReverseStrand"   , np.uint8),
                          ("HoleNumber"        , np.int32),
                          ("rStart"            , np.int32),
                          ("rEnd"              , np.int32),
                          ("MapQV"             , np.uint8),
                          ("nM"                , np.int32),
                          ("nMM"               , np.int32),
                          ("nIns"              , np.int32),
                          ("nDel"              , np.int32),
                          ("virtualFileOffset" , np.int64)  ]

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("bamFile", type=argparse.FileType("r"))
    parser.add_argument("referenceFasta", type=argparse.FileType("r"))
    args = parser.parse_args()

    bamFname = args.bamFile.name
    refFname = args.referenceFasta.name

    pbi = h5py.File(bamFname + ".pbi", "w")

    B = BamReader(bamFname, refFname)
    p = pysam.Samfile(bamFname)

    shape = (len(B),)
    #shape = (len(B), len(PBI_COLUMNS_AND_TYPES))

    dsets = OrderedDict((columnName, np.zeros(shape=shape, dtype=dtype_))
                        for (columnName, dtype_) in PBI_COLUMNS_AND_TYPES)
    p.reset()
    for i in xrange(len(B)):
        offset = p.tell()
        rawAln = next(p)
        aln = BamAlignment(B, rawAln)

        transcript = aln.transcript()
        moveCounts = Counter(transcript)

        dsets["ReadGroupID"]      [i] = aln.readGroup.ID
        dsets["tId"]              [i] = aln.tId
        dsets["tStart"]           [i] = aln.tStart
        dsets["tEnd"]             [i] = aln.tEnd
        dsets["isReverseStrand"]  [i] = aln.isReverseStrand
        dsets["HoleNumber"]       [i] = aln.HoleNumber
        dsets["rStart"]           [i] = aln.rStart
        dsets["rEnd"]             [i] = aln.rEnd
        dsets["MapQV"]            [i] = aln.MapQV
        dsets["nM"]               [i] = moveCounts["M"]
        dsets["nMM"]              [i] = moveCounts["R"]
        dsets["nIns"]             [i] = moveCounts["I"]
        dsets["nDel"]             [i] = moveCounts["D"]
        dsets["virtualFileOffset"][i] = offset

    # Write to file, gzipped

    grp = pbi.create_group("PacBioBamIndex")
    grp.attrs["Version"] = PBI_VERSION
    columnsGrp = grp.create_group("Columns")
    for (name, ds) in dsets.iteritems():
        columnsGrp.create_dataset(name, data=ds, chunks=True, compression="gzip")
    pbi.close()



if __name__ == '__main__':
    main()
