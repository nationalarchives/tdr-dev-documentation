# Metadata Field Release Strategy

## Overview

When releasing new metadata features/fields, changes are made to configuration and schema files that are read by the system to:
- Provide validation rules
- Support downloading of metadata files
- Enable export of CSV files

This document describes the strategy for releasing these features through different environments (Integration, Staging, and Production).

## Versioning Strategy

To allow new metadata fields to be released to Integration and Staging without affecting Production, we use a file-level versioning approach via the `METADATA_VERSION_OVERRIDE` environment variable set in Terraform.

### File Naming Convention

When a new feature or set of metadata fields is in development, create prefixed versions of the configuration and schema files:

**Development files (Integration & Staging):**
- `fab-note-config.json` (instead of `config.json`)
- `fab-note-baseSchema.schema.json` (instead of `baseSchema.schema.json`)

The `fab-note-` prefix indicates this is a feature branch version for the "note" feature.

### Environment Configuration

#### Production
```
METADATA_VERSION_OVERRIDE=fab-note-
```

This environment variable is set **only in Production** via Terraform. It tells the system to look for the `fab-note-*` versions of files. When features are finalized and merged, these files are deleted and the normal files are used.

#### Integration & Staging
No `METADATA_VERSION_OVERRIDE` is set. The system uses the normal configuration and schema files (`config.json`, `baseSchema.schema.json`, etc.).

## Workflow

### 1. Starting Development Work

At the beginning of feature development:
1. Copy `config.json` to `fab-note-config.json` - mapping and downloads
2. Copy `baseSchema.schema.json` to `fab-note-baseSchema.schema.json`  - basic validation
3. Copy `metadata-template.json` to `fab-note-metadata-template.json`  - quick guide
4. Add `METADATA_VERSION_OVERRIDE=fab-note-` to Terraform configuration for **Production environment only** ([see configuration](https://github.com/nationalarchives/tdr-terraform-environments/blob/master/root_locals.tf#L223)) 

### 2. Development and Testing

**On Integration and Staging:**
- All work continues on the normal files (`config.json`, `baseSchema.schema.json`, etc.)
- Changes follow the standard test and release process
- GitHub workflows run normally without any environment variable modifications

**On Production:**
- The system uses the `fab-note-*` versions of files, ie the version of the files that do not contain the changes
  - `fab-note-config.json`
  - `fab-note-baseSchema.schema.json`
  - `fab-note-metadata-template.json`
- If other work is started on new non-fab fields, those changes **must also be added to the fab-note versions** if they are needed in Production

### 3. Merging and Releasing

When the feature is complete and ready for production release:

1. Merge all changes from the feature branch into the main configuration files (`config.json`, `baseSchema.schema.json`, `metadata-template.json`, etc.)
2. Delete the prefixed versions:
   - Delete `fab-note-config.json`
   - Delete `fab-note-baseSchema.schema.json`
   - Delete `fab-note-metadata-template.json`
   - Delete all other `fab-note-*` files created for this feature
3. Remove `METADATA_VERSION_OVERRIDE=fab-note-` from the Terraform configuration for Production
4. Deploy the changes to Production

### 4. Updating Fab Versions During Development

If new, non-fab metadata fields are added during development and those fields need to be in Production before the fab-note feature is complete:

1. Add the new fields to both the normal files and the fab-note versions
2. This ensures consistency between what users see in Staging (normal files) and what will be in Production (fab-note versions)

## Advantages of This Approach

- **No workflow modifications**: All development uses normal files and normal test/release processes
- **No GitHub workflow changes**: CI/CD workflows don't need conditional logic based on environment variables
- **Environment isolation**: Integration and Staging always use production-ready files; Production can run an alternate version
- **Simple cleanup**: Feature removal is as simple as deleting the prefixed files and removing the environment variable
- **Clear tracking**: Prefixed files make it obvious which files are feature-specific

## Example Scenario

Suppose you're developing a "Note" feature for metadata:

1. **Day 1 - Start work:**
   - Create `fab-note-config.json` from `config.json`
   - Create `fab-note-baseSchema.schema.json` from `baseSchema.schema.json`
   - Create `fab-note-metadata-template.json` from `metadata-template.json`
   - Set `METADATA_VERSION_OVERRIDE=fab-note-` in Terraform for Production
   - Begin modifying `config.json` with new note fields
   - Deploy to Integration/Staging

2. 
3. **Week 2 - Feature complete:**
   - All note-related changes have been merged into `config.json`
   - Delete `fab-note-config.json`, `fab-note-baseSchema.schema.json`, and `fab-note-metadata-template.json`
   - Remove `METADATA_VERSION_OVERRIDE=fab-note-` from Production Terraform
   - Deploy to Production; Production now uses the normal files with all note features

### Managing Multiple Features (Unlikely but Possible)

When multiple fab versions exist for different features:

1. **During Development**: Each fab file remains in place. Production will pick up changes from the fab file that has the `METADATA_VERSION_OVERRIDE` set in Terraform, while Integration and Staging use the normal files.

2. **When Releasing One Feature**: 
   - Merge the completed feature changes into the normal files (`config.json`, `baseSchema.schema.json`, etc.)
   - **Do NOT delete the fab files** - they remain in place for Production
   - If other features have been started and have their own fab files (e.g., `fab-tags-config.json`), merge the newly released changes into those fab files as well
   - Deploy to Production - the `METADATA_VERSION_OVERRIDE` still points to the fab files, which now contain all released features plus any in-progress features
   
3. **Example with Two Concurrent Features**:
   - Feature A (note) is being developed: `fab-note-config.json` exists, `METADATA_VERSION_OVERRIDE=fab-note-`
   - Feature B (tags) is started: Create `fab-tags-config.json`
   - Feature A is ready to release:
     - Merge note changes into normal `config.json`
     - Merge note changes into `fab-tags-config.json` (so tags feature includes the released note feature)
     - Update `METADATA_VERSION_OVERRIDE=fab-tags-` in Terraform
     - Keep `fab-note-config.json` in place (it's now unused but doesn't cause issues)
     - Deploy - Production now gets the released note feature plus in-progress tags feature

This approach ensures that as each feature is released, all subsequent fab files incorporate those changes, creating a clean progression toward production readiness.
