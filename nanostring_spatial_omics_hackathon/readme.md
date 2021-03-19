Data Set Introduction:

NanoString GeoMx DSP dataset of diabetic kidney disease (DKD) vs healthy kidney tissue.  Seven slides were analyzed, 4 DKD and 3 healthy. Regions of Interest (ROI) were focused two different parts of a kidney’s structure: tubules or glomeruli. One glomerulus ROI contains the entirety of a glomerulus. Individual glomeruli were identified by a pathologist as either behaving relatively healthy or diseased regardless on if the tissue was DKD or healthy. Tubule ROIs were segmented into distal (PanCK) and proximal (neg) tubules. While both distal and proximal tubules are called tubules, they perform very different functions in the kidney.  Segmented areas of an ROI are called Areas of Interest (AOI).

 

Image Origin: top left corner with the y-axis extending down and the x-axis extending right as per image editing software

Limit of Quantitation (LOQ) Calculation:

(GeoMean of 139 Negative Probes) x (SD of 139 Negative Probes)2

 

Filtering Methodologies:

ROI QC:

1.       removed ROIs with Raw Reads < 5000

a.       Raw Read count indicates coverage of ROI sequencing

2.       removed ROIs with Sequencing Saturation < 50%

a.       Sequencing Saturation indicates confidence in sequencing

Probe QC:

1.       removed probes that failed two-tailed outlier test in >50% of ROIs

2.       removed probes that fell below background in >99% of ROIs

 

Description of files:

All .txt files are tab delimited

Start Here:

1.       Sample Annotations: Kidney_Sample_Annotations.txt

o   Annotations of ROIs (i.e. samples) in files 3-5.

o   .rda files contain these annotations in the NanoStringGeoMxSet variable.

§  kidney_norm@phenoData@data

o   Explanation of columns:

§  SlideName: Name of slide

§  ScanName: Name of GeoMx scan used to match with image names

§  ROILabel: ROI label used to match with image names

§  SegmentLabel: segmentation of tubule ROIs in to distal (PanCK) and proximal (neg) tubules. Glomeruli segmentation is Geometric Segment.

§  SegmentDisplayName: unique identifier of an AOI

§  Sample_ID: unique identifier of an AOI that matches DCC file, used in NanoStringGeoMxSet

§  AOISurfaceArea: area of AOI in μm2

§  AOINucleiCount: number of nuclei (cell estimate) in the AOI

§  ROICoordinateX: X coordinate for center of mass of ROI

§  ROICoordinateY: Y coordinate for center of mass of ROI

§  Reads: Sequencing values

§  SequencingSaturation: % non-unique reads, confidence in sequencing

§  UMIQ30: % bases >Q30 in UMI, sequencing QC metric

§  RTSQ30: % bases >Q30 in RTS sequence, sequencing QC metric

§  disease_status: normal or DKD, disease state for tissue

§  pathology: pathological annotation of each glomerulus as relatively healthy or abnormal regardless of disease status, disease state of individual glomerulus

§  region: glomerulus or tubule, kidney structure

§  LOQ: limit of quantitation calculated using negative probes, estimation of background noise level

§  NormalizationFactor: 75th percentile normalization factor

2.       Feature Annotations: Kidney_Feature_Annotations.txt

o   Annotations:

§  RTS_ID:

·         RNA sequencing tag ID (another ID used for probe ID)

§  TargetName:

·         Target (i.e. gene) name

§  ProbeID:

·         a.k.a. ProbeName used for probe identification

§  Negative:

·         Boolean indicating if the probe is a negative control

3.       Probe Expression: Kidney_Raw_BioProbeCountMatrix.txt & kidney_probe.rda

o   Raw counts of targets and negative probes. All probes, not filtered, negative probes NOT collapsed. Only ROIs that passed QC are included.

o   Rows are probes and columns are samples

4.       Target Expression: Kidney_Raw_TargetCountMatrix.txt & kidney_target.rda

o   Raw target counts. All probes, not filtered. Targets with multiple probes get aggregated using the geometric mean across all probes for a target. In this panel, only the negative has multiple probes, and therefore is the only target count aggregated. Only ROIs that passed QC are included.

o   Rows are targets and columns are samples

5.       Normalized Expression: Kidney_Q3Norm_TargetCountMatrix.txt & kidney_norm.rda

o   75th percentile normalized counts. Only ROIs and genes that passed QC are included.

o   Rows are targets and columns are samples

R Objects:

6.       Kidney R Dataset: KidneyDatasetR.zip

o   R data package

o   Three GeoMxSet class objects which include sample, feature, and expression data within each object

§ kidney_probe.rda (#3)

§ kidney_target.rda (#4)

§ kidney_norm.rda (#5)

7.       Example Analysis: KidneyDatasetRVignette.html

o   Example analysis on the kidney dataset GeoMxSet object

Images:

8.       Slide Images: ROI_reports.zip

o   Scans and ROI images for 7 scans

o   File name structure using [Annotation Column Names] in brackets

§ Glomeruli

1.       [ScanName] /[ScanName] – [ROILabel].png

§ Tubule

1.       [ScanName] /[ScanName] – [ROILabel] – [SegmentLabel].png

9.       High Resolution Single Channel Images: high_res_scans.zip

o   High resolution single channel stacked tiff files

§ One disease and one normal scan

§ Each image shows a single fluorescence channel

1.       CD45 - immune

2.       DNA – nuclei stain

3.       PanCK – distal vs proximal tubules

4.       WT1 – podocytes (cells in glomeruli)


 

Example of Typical Analyses:

Cell Deconvolution:

10.   Decon Results: Kidney_Spatial_Decon

o   Results of cell deconvolution analysis on the kidney dataset (cell type x AOI)

§ cell matrix expression in #11 was used to estimate the cell populations and abundance within an AOI.

o   Rows are cell types and columns are samples

o   Values are abundance scores of cell types in AOIs. 

11.   Cell Annotations: Cell_Types_for_Spatial_Decon.txt

o   Known cell types pertinent to the kidney dataset from previous single cell RNA-seq (scRNA-seq) data

§ Young, M.D., et al. (2018). Single-cell transcriptomes from human kidneys reveal the cellular identity of renal tumors. Science 361, 594–599. Link to paper.

§ Subset of Supplemental Table 2, Cluster info

o   Explanation of columns:

§ ClusterID: ClusterID from scRNA-seq datasets either Normal (N) or Immune (IN)

§ Alias: shorthand ID for cluster based on given Cell Type

§ Data_set: scRNA-seq dataset cluster was derived from

§ Number_of_cells: number of single cells in each cluster

§ Cell_type1: cell type of cluster label 1

§ Cell_type2: cell type of cluster label 2, if necessary

§ Cell_type3: cell type of cluster label 3, if necessary

§ cell_type_specific: specific cell type label

§ cell_type_general: generalized cell type label, used to bucket clusters

§ cluster_name: Unique identifier of cluster, cell_type_specific & Alias

o   Marker genes in clusters were compared to canonical markers from literature.

§ See Table S3 in paper

12.   Average Gene Expression: Young_kidney_cell_profile_matrix.csv

o   Average gene expression for each cell type cluster in #10

o   Rows are cell types and columns are samples

o   Values are gene counts expected in a cell type X.

Gene Set Enrichment Analysis (GSEA):

13.   Single Sample GSEA Results: Kidney_ssGSEA.txt

o   Single-sample Gene Set Enrichment Analysis (ssGSEA) analysis results (pathway x AOI)

§  known groups of genes that work concordantly to perform a biological function are surveyed for enrichment of over- or under-expressed genes within each sample.

o   Rows are known gene sets and columns are samples

o   Values are abundance scores of biological pathways in AOIs.