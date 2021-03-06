\name{kidney_norm_}
\docType{data}
\alias{kidney_norm}
\title{NanoString GeoMx normalized kidney dataset for NanoString Spatial-omics Hackathon 2021}
\description{
  This is an R package containing normalized GeoMx count data and metadata for NanoString Spatial-omics Hackathon 2021. Data was normalized using 75th quantile normalization. 
}
\usage{data("kidney_norm")}
\format{
  The format is:
Formal class 'NanoStringGeoMxSet' [package "GeomxTools"] with 7 slots including experimentData, assayData, phenoData, featureData, annotation, protocolData, and .__classVersion__. 
}
\section{Slots}{
   Introduced in \code{GeomxSet}:
   \describe{
      \item{\code{assayData}:}{Contains matrices with equal
	dimensions, and with column number equal to
	\code{nrow(phenoData)}. }
      \item{\code{phenoData}:}{Contains experimenter-supplied variables
      describing sample (i.e., columns in \code{assayData}) phenotypes.}
      \item{\code{featureData}:}{Contains variables describing features
	(i.e., rows in \code{assayData}) unique to this experiment. Use
	the \code{annotation} slot to efficiently reference feature data
	common to the annotation package used in the experiment. }
      \item{\code{experimentData}:}{Contains details of experimental
	methods.}
      \item{\code{annotation}:}{Label associated with the annotation
	package used in the experiment. }
      \item{\code{protocolData}:}{Contains microarray equipment-generated
      variables describing sample (i.e., columns in \code{assayData}) phenotypes}
      \item{\code{.__classVersion__}:}{A \code{Versions} object describing
    the R and Biobase version numbers used to created the instance.
    Intended for developer use.}
  }
}
\keyword{datasets}