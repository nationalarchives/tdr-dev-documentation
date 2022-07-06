# 23. Court Judgment Transfers Url Scheme 

**Date:** 2021-10-28

## Context

TDR application will support the upload of court judgments. 

The court judgment transfers require a different UI and functionality compared to standard record transfers.

## Decision

To help support the court judgment transfers, it was decided to use a different url scheme for such transfers.

The advantages of doing this are:
* providing a more descriptive url for court judgment transfer users.
* improving accessibility for court judgment transfers.
* providing a more isolated domain for court judgment transfers to future proof against further requirements.
* providing better support for any web analytics on TDR that are required.

The advantages of introducing a different url scheme for court judgment transfers was felt to outweigh using the same url scheme for both types of transfers.

## Standard and Court Judgment Transfers' Url Schemes

The two url schemes will be as follows:
* *standard transfer*: `{tdr domain address}/consignment/{consignmentId}/{pageName}`
  For example: https://tdr.nationalarchives.gov.uk/consignment/d939a56c-658a-4e6b-a3f3-19e8d57a6888/transfer-agreement
* *judgment transfer*: `{tdr domain address/judgment/{consignmentId}/{pageName}`
  For example: https://tdr.nationalarchives.gov.uk/judgment/d939a56c-658a-4e6b-a3f3-19e8d57a6888/transfer-agreement
  
**Note**: "judgment" is the correct spelling when referring to a judgment of a court.
