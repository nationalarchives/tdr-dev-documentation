# base25 encoding for consignment references

**Date:** 2020-11-13

## Context

As part of the 'transfer summary' page, the user will see a 'consignment reference' to identify their consignment (which can be useful if a user needs to contact us about a specific consignment). We came to the decision that we liked the format:

`TDR-YEAR-base25reference`

`TDR` - since the consignment will be transferred using the TDR service

`YEAR` - year the consignment is created (not completed)

`base25reference` - created once the consignment is assigned an incremental ID, which will be encoded to a base25 alpha-numeric code.

Base25 was specifically chosen due to its ability to represent numeric identifiers through alpha-numeric codes. It also allows for specific letters and numbers to be removed from the list of possible characters, limiting the possibility that a reference can be created that is un-intentionally offensive.
Base25 (specifically GCRb25) is also used within other TNA projects, and TDR utilising it will keep references to a similar standard to those used within different projects.

## Options considered for the incremental ID

We need an incremental ID to feed into the encoding method to create the base25 alpha-numeric reference, there are two options for the incremental id creation.

### Option 1: PostgreSQL Serial ID

PostgreSQL has a built-in incremental ID feature (Serial). A serial is a pseudo-type that a column can use that tells PostgreSQL to automatically create a sequence and put it's value in the assocciated column of the linked table.

#### Advantages

* Creates own sequence and reference to this
* Can be added to columns in an existing table

#### Disadvantages

* Not very customisable

### Option 2: PostgreSQL Sequence

A sequence is a database object that can generate a big-int (8-bit) and be associated with specific tables. Using a sequence is slightly more manual, but  allows for many customisable options (min/max value, starting point, cycle/no-cycle).

#### Advantages

* We can state specifically that we don't want the value to cycle when max-value is reached (extremely unlikely to happen)
* We can start from a specific value, which would be useful if tables/db is dropped and sequence needs to be initiated again.
* Can be added to existing tables

#### Disadvantages

* A slightly more manual set up, but behaves the same as serial once initiated.

## Options considered for encoding

### Option 1: DRI code

We could manually encode these ID numbers to base25 utilising code that is similar to that written for the [DRI](https://nationalarchivesuk.sharepoint.com/sites/DA_DPT/Systems/Forms/AllItems.aspx?id=%2Fsites%2FDA%5FDPT%2FSystems%2FDigital%20Records%20Infrastructure%2FDocumentation%2FGenerated%20Catalogue%20References%20%2D%20Draft%20v1%2E0%2Epdf&parent=%2Fsites%2FDA%5FDPT%2FSystems%2FDigital%20Records%20Infrastructure%2FDocumentation&RootFolder=%2Fsites%2FDA%5FDPT%2FSystems%2FDigital%20Records%20Infrastructure%2FDocumentation&FolderCTID=0x012000E56AFAD10E754045898F8F352035CA1F00E09F204D3696E04193FD4FFBF9EA85B7) project in 2014. 
This code could be copy and pasted within the TDR consignment API to be used as we see fit. We would explicitly define the required list of available alpha-numeric values and create our own encode/decode functions according to this 'alphabet'.

#### Advantages

* Customisable to what we want - especially if our requirements change
* Easy to read for humans and see what it does at first glance

#### Disadvantages

* Based on code that is slightly older
* Could potentially be bulky to incorporate into the consignment API

### Option 2: [Omega Catalog Identifier tools (Scala)](https://github.com/nationalarchives/oci-tools-scala)

This [library](https://search.maven.org/artifact/uk.gov.nationalarchives.oci/oci-tools-scala_2.13/0.2.0/jar) can encode to any specified base*N*, and decode back to base10. The Omega library has some pre-specified 'alphabets' included within, one of which is GCRb25, meaning an alphabet does not need to be explicitly created to utilise this code.
The library is a little more complex than utilising the 2014 DRI code, and more than one function needs to be called to encode from an integer to the correct code, but working with this is relatively straight-forward.

#### Advantages

* Can encode to any base*N* not just base25/GCRb25
* Already exists as a tool, meaning encoding functionality does not need to be created by TDR team
* Error handling built in

#### Disadvantages

* Open source - the aim of the project may change and affect the way the TDR team can use the library
* Less customisable - more generalised

## Decisions

The PostgreSQL sequence is much more customisable to our needs and can be started from any specified value, which would be very helpful should any tables be dropped from the database.

Utilising the Omega library is a good way to start working on the encoding. If the project changes (like any open-source project can) we have the option to use the 2014 DRI code if needed.
