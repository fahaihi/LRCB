                                                                                                                            
                                                                                                                                                      
## About The LRCB 
LRCB (Long Reads Compression Benchmark) is a comprehensive benchmark evaluation of the SOTA lossless dedicated and general compressors for long reads data. 

In our benchmark, we performed examinations on 26 reference-free lossless compressors, including 11 specialized for long reads collection and 14 general-purpose ones, using
31 real-world datasets with differing sequencing lengths, platforms, and species. Each loss-less compressor was evaluated on 13 performance measures, including compression robustness, compression strength, as well as time and peak memory required for compression and
decompression.

## Benchmark DataSets
We evaluated the compression performance and robustness of SOTA long reads collection compression toolkits using a comprehensive datasets consisting of 31 groups of large-scale real datasets. 
The detailed link address of the benchmark datasets are as follows:

D1:  https://www.ebi.ac.uk/ena/browser/view/ERR3077524

D2:  https://www.ebi.ac.uk/ena/browser/view/ERR11274574

D3:  https://www.ebi.ac.uk/ena/browser/view/SRR25685106

D4:  https://www.ebi.ac.uk/ena/browser/view/ERR3077535

D5:  https://www.ebi.ac.uk/ena/browser/view/ERR2708436

D6:  https://www.ebi.ac.uk/ena/browser/view/ERR2708427

D7:  https://www.ebi.ac.uk/ena/browser/view/SRR1204468

D8:  http://gembox.cbcb.umd.edu/mhap/raw/yeast_filtered.fastq.gz

D9:  https://www.ebi.ac.uk/ena/browser/view/ERR11011595

D10: https://www.ebi.ac.uk/ena/browser/view/SRR25689478

D11: https://downloads.pacbcloud.com/public/dataset/MicrobialMultiplexing_48plex/48-plex_sequences/lima.bc1019--bc1019.subreadset.fastq.gz

D12: https://www.ebi.ac.uk/ena/browser/view/SRR25503121

D13: https://www.ebi.ac.uk/ena/browser/view/ERR4179766

D14: https://www.ebi.ac.uk/ena/browser/view/SRR25743051

D15: https://www.ebi.ac.uk/ena/browser/view/SRR25503117

D16: https://www.ebi.ac.uk/ena/browser/view/ERR4179765

D17: https://downloads.pacbcloud.com/public/dataset/MicrobialMultiplexing_48plex/48-plex_sequences/lima.bc1099--bc1099.subreadset.fastq.gz

D18: https://www.ebi.ac.uk/ena/browser/view/SRR25655962

D19: https://www.ebi.ac.uk/ena/browser/view/SRR25601474

D20: https://www.ebi.ac.uk/ena/browser/view/SRR12121586

D21: https://www.ebi.ac.uk/ena/browser/view/SRR25731491


D22: https://www.ebi.ac.uk/ena/browser/view/SRR25555001

D23: https://www.ebi.ac.uk/ena/browser/view/SRR12121585

D24: https://www.ebi.ac.uk/ena/browser/view/SRR25750558

D25: https://www.ebi.ac.uk/ena/browser/view/SRR25750949

D26: https://www.ebi.ac.uk/ena/browser/view/SRR25647249

D27: https://www.ebi.ac.uk/ena/browser/view/SRR23822210

D28: https://www.ebi.ac.uk/ena/browser/view/ERR5396170

D29: http://gembox.cbcb.umd.edu/mhap/raw/athal_filtered.fastq.gz

D30: https://www.ebi.ac.uk/ena/browser/view/SRR11292120

D31: https://www.ebi.ac.uk/ena/browser/view/SRR10382244

## Algorithms Details
In our comparison examinations, we benchmarked 16 advanced general-purpose methods: Lzma, Lzma2, Pigz, XZ, Brotli, Zstd, LZ4, Brieflz, Lzop, SnZip, PBzip2, BSC, Zpaq and PPMD. For dedicated long reads data compressors, we selected the most SOTA long reads data compression algorithms, NanoSpring, CoLoRd, FastqCLS, GenoZip, Enano, and Spring. At the same time, we also include the widely used DNA sequences
compressors GeCo, GeCo2, GeCo3, NAF, and MFCompress into the dedicated compression evaluation.

We also provide test code for these algorithms, found at https://github.com/fahaihi/LRCB/tree/master/script. We recommend users run these script files using absolute paths to avoid environmental errors. A summary description of the testing of compression algorithms can be found in our supplementary materials (https://github.com/fahaihi/LRCB/tree/master/Supplementary.pdf).

## Experimental Configuration
Our experiment was conducted on the SUGON-7000A supercomputer system at the Nanning Branch of the National Supercomputing Center (https://hpc.gxu.edu.cn), using a queue of CPU/GPU heterogeneous computing nodes. The compute nodes used in the experiment were configured as follows: 
  
  2\*Intel Xeon Gold 6230 CPU (2.1Ghz, total 40 cores), 
  
  2\*NVIDIA Tesla-T4 GPU (16GB CUDA memory, 2560 CUDA cores), 
  
  192GB DDR4 memory, and 
  
  8\*900GB external storage.


## Acknowledgements
- Thanks to [@HPC-GXU](https://hpc.gxu.edu.cn) for the computing device support.   
- Thanks to [@NCBI](https://www.freelancer.com/u/Ostokhoon) for all available datasets.

## Additional Information
**Source-Version-Date：**    2023.05.18.

**Latest-Version-Date：**    2023.10.07.

**Authors:**     NBJL-BioGrop.

**Contact us:**  https://nbjl.nankai.edu.cn OR sunh@nbjl.naikai.edu.cn
