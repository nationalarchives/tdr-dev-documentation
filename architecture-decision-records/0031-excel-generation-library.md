# 31. Excel Generation Library 

**Date:** 2024-05-15

## Context
TDR Users will have the option to upload metadata in bulk via a CSV file. Typically, when they edit a CSV file, they will use Microsoft Excel which can cause problems with things like format of dates when saving as a CSV.
In order to support users, the ability to download a template file in Excel format, prepopulated with system metadata values, allowed columns and with data type formatting preset will be added to TDR. A third party library is required to support this.  

## Assumptions
Although alternative spreadsheet applications are available, Excel is used as the main example as it's felt that most departments would have it as an option over applications such as LibreOffice etc. However, files will be produced in Office Open XML format (OOXML) which can be read and written by many other office products.

## Constraints
* There are few, if any, Excel generation packages natively written as Scala so the options considered are both written in Java.
* Both libraries have no ability to directly sort data in a spreadsheet. This would either need to be done in code, via an additional library (such as ASPOSE Java) or manually by the user.

## Options considered

### Apache POI ( https://poi.apache.org/ )

#### Advantages
* Well established project (version 1.0 released in 2001) run by Apache Software Foundation with regular releases over the last 20+ years
* Has advanced features including being able to use Excel templates (xlst), being able to protect worksheets, adding cell comments etc.
* Lots of available documentation and examples about how to use library

#### Disadvantages
* Convoluted code: API is quite complex and not entirely intuitive. Can be steep learning curve.
* Heavyweight package: extra features come at a cost and larger spreadsheets can consume more memory, slowing processes down.

### FastExcel ( https://github.com/dhatim/fastexcel )

#### Advantages
* Lightweight writer/reader packages developed as a faster alternative to Apache POI
* Efficient, lean API - very easy to quickly generate an Excel sheet in not many lines of code
* Active project - first release in 2016, 3 releases so far in 2024. 

#### Disadvantages
* Very limited feature set - basic style support, formatting and writing data
* Smaller community - less documentation and examples

## Decision
We have decided to use FastExcel initially because of the advantages it has in being lightweight, quicker and easier to code. Although POI has more features available, these are not needed initially and may not get added at all.
If the need to use features available in POI but not FastExcel arises in the future then following can be considered:
* Testing to replace FastExcel with POI proved to be straightforward (other than recoding functions in POIs API) and quick to do
* Testing has also shown that the libraries are compatible: a spreadsheet can be written in FastExcel and then passed to Apache POI for further manipulation. 



