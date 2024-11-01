# 36. Metadata Render Configuration

**Date**: 2024-11-01

## Context

To support user interaction with record metadata, and exporting metadata, TDR needs to render metadata in a variety of formats, for example HTML, CSV etc.

The rules for rendering metadata are currently stored in a set of database table: `DisplayProperties`. The table contains a set of information to rendering, for example ordering, display name etc.

This approach originally envisaged a limited set of rendering requirements and formats.

With development of additional TDR features, most notably metadata upload, has highlighted a number of limitations with storing rendering rules in a database table:
* Difficulty in extending and adapting rules with changing product requirements
* Lack of visibility of the rules for stakeholders: product, design, user research, digital transfer advisers, other Digital Archiving services;
* Does not fit with the use of JSON schemas for validation of metadata
* Requires additional calls to the database via API's when rendering on the fly within the application, slowing down the application and putting additional load on TDR infrastructure

## Decision

To address the issues with storing metadata rendering rules within a database table the following approach will be adopted.

The rendering rules will be stored in a configuration file (JSON) and this will be provided to clients as a library for use by clients to render metadata in the required format.

The configuration file will be held in a GitHub repository and published as a library to Maven as with the pattern for the Digital Archiving metadata schemas.

## Other Options Considered

Consideration was given to creating an end to end "render engine" that would hold the configration and also render the metadata to the required format.

This was rejected due the complexities of handling formatting within Excel.
