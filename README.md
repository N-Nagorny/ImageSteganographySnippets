There are MATLAB image steganography code snippets.

All presented steganography methods implementations are inspired (with using of code more or less) by [1].

# LSB
Implementation of Least Significant Bit steganography. It can use about 1/8 of container size for digital watermark hiding, but it has low robustness.

A hidden watermark can be restored absolutely precisely. There is *SimpleComparison.m* which can compare containers (before and after embedding) and watermarks (before and after extracting) using different metrics.

# Kutter-Jordan-Bossen
Originally presented in [2]. The strong sides are high bandwidth and robustness but extracting is not so precisely. Thus, it's recommended for grayscale images hiding.

There are three pairs of scripts: for grayscale images embedding and extracting, for files embedding and extracting and for container and watermark comparison.

Embedders generates *bin_wmark_size.csv*, *coords.csv* and *wmark_size.csv* which are a key used by extractors.

# Bruyndockx

Originally presented in [3]. To be honest, it's about impossible to find the original paper, so I based on the algorithm's description in [1]. The scripts tested only with square image containers with sides dividable by 8.

# Koch-Zhao

There are two pairs of scripts: for monochromatic images embedding and extracting and for bitstream embedding and extracting. The embedding scripts print result of comparison between a container before and after embedding and create *xys.csv* which is a key for extracting scripts.

The scripts are tested only with square image containers with sides dividable by 8 and bitstreams of 64-bit length.

# References
[1] Шелухин О. И. Стеганография. Алгоритмы и программная реализация / О. И. Шелухин, С. Д. Канаев. — ООО «Научно-техническое издательство «Горячая линия–Телеком», 2017.
[2] Kutter M., Jordan F., Bossen F. Digital Signature Of Color Images Using Amplitude Modulation // Proc. of the SPIE Storage and Retrieval for Image and Video Databases V. 1997. Vol. 3022. Pp. 518-526.
[3] Bruyndonckx, O., J.J. Quisquater and B. Macq, 1995. Spatial method for copyright labeling of digital images. Proc. IEEE Workshop on Nonlinear Signal and Image Processing, Neos Marmaras, Greece, 20-22 Jun, pp: 456-459.
