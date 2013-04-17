
  $ export INPUT=/mnt/secondary/Share/Quiver/TestData/eichler/053727.cmp.h5
  $ export SANGER_REFERENCE=/mnt/secondary/Share/Quiver/TestData/eichler/CH17-157L1.finished.fa
  $ export ASSEMBLY_REFERENCE=/mnt/secondary/Share/Quiver/TestData/eichler/CH17_157L1_quiver_fasta.fasta

The QVs warning gets printed to stderr N times ... ignore it for now.

  $ quiver --noEvidenceConsensusCall=nocall \
  > -j${JOBS-8} $INPUT -r $ASSEMBLY_REFERENCE -o variants.gff -o css.fasta 2>/dev/null

Variant scores are currently miscalibrated (need to fix the
NoMergeQVModel; bug 22255).  Note that these variants listed below are
reckoned compared to the assembly reference, so they are not really
variants so much as errors in the assembly.  Variants assessed using
MuMMer at the end are compared to the Sanger reference.

  $ sed 's/\t/ /g' variants.gff
  ##gff-version 3
  ##pacbio-variant-version 1.4
  ##date Wed Apr 17 16:12:14 2013
  ##feature-ontology http://song.cvs.sourceforge.net/*checkout*/song/ontology/sofa.obo?revision=1.12
  ##source GenomicConsensus 0.6.1
  ##source-commandline /net/usmp-data3-10g/ifs/data/unixhome/dalexander/.virtualenvs/VE/bin/variantCaller.py --algorithm=quiver --noEvidenceConsensusCall=nocall -j20 /mnt/secondary/Share/Quiver/TestData/eichler/053727.cmp.h5 -r /mnt/secondary/Share/Quiver/TestData/eichler/CH17_157L1_quiver_fasta.fasta -o variants.gff -o css.fasta
  ##sequence-region CH17-157L1 1 230921
  CH17-157L1 . deletion 141 142 . . . reference=AC;coverage=100;confidence=47;length=2
  CH17-157L1 . deletion 797 797 . . . reference=G;coverage=100;confidence=48;length=1
  CH17-157L1 . deletion 805 805 . . . reference=T;coverage=100;confidence=47;length=1
  CH17-157L1 . deletion 26174 26175 . . . reference=AC;coverage=100;confidence=48;length=2
  CH17-157L1 . insertion 55888 55888 . . . variantSeq=A;coverage=100;confidence=48;length=1
  CH17-157L1 . deletion 93356 93357 . . . reference=CG;coverage=100;confidence=48;length=2
  CH17-157L1 . insertion 230679 230679 . . . variantSeq=A;coverage=100;confidence=49;length=1
  CH17-157L1 . insertion 230681 230681 . . . variantSeq=CA;coverage=100;confidence=48;length=2
  CH17-157L1 . insertion 230684 230684 . . . variantSeq=C;coverage=100;confidence=48;length=1


  $ fastacomposition css.fasta
  css.fasta A 65735 C 51391 G 50341 N 28 T 63419

Use the MuMMer suite to look at the differences from the reference.

  $ nucmer -mum $SANGER_REFERENCE css.fasta 2>/dev/null

First: no structural differences.

  $ show-diff -q out.delta | sed 's/\t/ /g'
  /mnt/secondary/Share/Quiver/TestData/eichler/CH17-157L1.finished.fa /ram/tmp/cramtests-R_1zZh/quiver-eichler-bac.t/css.fasta
  NUCMER
  
  [SEQ] [TYPE] [S1] [E1] [LEN 1]
  CH17-157L1|quiver BRK 1 29 29
  CH17-157L1|quiver BRK 230895 230914 20

Next, the SNPs.

  $ show-snps -H -C -x10 out.delta
     16035   . A   16059     |     8523    16035  |  AAAAAAAAAA.ATTGCTTGCC  AAAAAAAAAAAATTGCTTGCC  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     24558   . A   24583     |     8523    24558  |  AAAAAAAAAA.AGCCTGGATG  AAAAAAAAAAAAGCCTGGATG  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     51215   C .   51239     |     4658    51215  |  GGCCCGCCCCCCGGGCAGCCA  GGCCCGCCCC.CGGGCAGCCA  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     55873   . A   55898     |     4658    55873  |  AAAAAAAAAA.ATATATATAT  AAAAAAAAAAAATATATATAT  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     64634   C .   64658     |     8761    64634  |  GACCCCCCCCCCACCGGTCAG  GACCCCCCCC.CACCGGTCAG  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     85478   . T   85503     |     8834    85478  |  TTTTTTTTTT.TACTAACCAG  TTTTTTTTTTTTACTAACCAG  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
     94312   . T   94338     |     8834    94312  |  TTTTTTTTTT.TAGACAGAGT  TTTTTTTTTTTTAGACAGAGT  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
    106985   . T   107012    |        0   106985  |  TTTTTTTTTT.TCCTGAGCAG  TTTTTTTTTTTTTCCTGAGCA  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
    106985   . T   107013    |        0   106985  |  TTTTTTTTTT.TCCTGAGCAG  TTTTTTTTTTTTCCTGAGCAG  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
    182920   . A   182949    |    47946    47946  |  AAAAAAAAAA.ATGTGGTCTC  AAAAAAAAAAAATGTGGTCTC  |  1  1  CH17-157L1\tCH17-157L1|quiver (esc)
