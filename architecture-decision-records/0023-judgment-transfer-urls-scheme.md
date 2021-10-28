# 23. Court Judgment Urls Scheme 

**Date:** 2021-10-28

## Context

TDR application will support the upload of court judgments. 

The court judgments require a different UI and functionality compared to standard record transfers.

## Decision

To help support the court judgment transfers it was decided to use a different url scheme for such transfers.

The advantages of doing this are:
* providing a more descriptive Url for court judgment transfer users.
* improve accessibility for court judgement transfers.
* provide a more isolated domain for court judgment transfer to future proof against further requirements in the future.
* better support for any web analytics on TDR that are required.

The advantages introducing a different url scheme for court judgment transfer outweighed using the same url scheme for both types of transfers.

## Standard and Court Judgment Transfers Url Schemes

The two url schemes will be as follows:
* standard transfer: `{tdr domain address}/consignment/{consignmentId}/{pageName}`
  For example: https://tdr.nationalarchives.gov.uk/consignment/d939a56c-658a-4e6b-a3f3-19e8d57a6888/transfer-agreement
* judgment transfer: `{tdr domain address/judgment/{consignmentId}/{pageName}`
  For example: https://tdr.nationalarchives.gov.uk/judgment/d939a56c-658a-4e6b-a3f3-19e8d57a6888/transfer-agreement
