-- Table: tdr."Body"

-- DROP TABLE tdr."Body";

CREATE TABLE tdr."Body"
(
    "BodyId" text COLLATE pg_catalog."default" NOT NULL,
    "Name" text COLLATE pg_catalog."default",
    "Code" text COLLATE pg_catalog."default",
    "Description" text COLLATE pg_catalog."default",
    CONSTRAINT "Body_pkey" PRIMARY KEY ("BodyId")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."Body"
    OWNER to postgres;
	
-- Table: tdr."User"

-- DROP TABLE tdr."User";

CREATE TABLE tdr."User"
(
    "UserId" text COLLATE pg_catalog."default" NOT NULL,
    "BodyId" text COLLATE pg_catalog."default",
    "Name" text COLLATE pg_catalog."default",
    "EMail" text COLLATE pg_catalog."default",
    "PhoneNo" text COLLATE pg_catalog."default",
    CONSTRAINT "User_pkey" PRIMARY KEY ("UserId"),
    CONSTRAINT "User_Body_fkey" FOREIGN KEY ("BodyId")
        REFERENCES tdr."Body" ("BodyId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."User"
    OWNER to postgres;
	
-- Table: tdr."Series"

-- DROP TABLE tdr."Series";
	
CREATE TABLE tdr."Series"
(
    "SeriesId" text COLLATE pg_catalog."default" NOT NULL,
    "BodyId" text COLLATE pg_catalog."default",
    "Name" text COLLATE pg_catalog."default",
    "Code" text COLLATE pg_catalog."default",
    "Description" text COLLATE pg_catalog."default",
    CONSTRAINT "Series_pkey" PRIMARY KEY ("SeriesId"),
    CONSTRAINT "Series_Body_fkey" FOREIGN KEY ("BodyId")
        REFERENCES tdr."Body" ("BodyId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."Series"
    OWNER to postgres;
	
-- Table: tdr."ConsignmentProperty"

-- DROP TABLE tdr."ConsignmentProperty";

CREATE TABLE tdr."ConsignmentProperty"
(
    "PropertyId" text COLLATE pg_catalog."default" NOT NULL,
    "Name" text COLLATE pg_catalog."default",
    "Description" text COLLATE pg_catalog."default",
    "Shortname" text COLLATE pg_catalog."default",
    CONSTRAINT "ConProperty_pkey" PRIMARY KEY ("PropertyId")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;


-- Table: tdr."FileProperty"

-- DROP TABLE tdr."FileProperty";

CREATE TABLE tdr."FileProperty"
(
    "PropertyId" text COLLATE pg_catalog."default" NOT NULL,
    "Name" text COLLATE pg_catalog."default",
    "Description" text COLLATE pg_catalog."default",
    "Shortname" text COLLATE pg_catalog."default",
    CONSTRAINT "FileProperty_pkey" PRIMARY KEY ("PropertyId")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."FileProperty"
    OWNER to postgres;
	
-- Table: tdr."Consignment"

-- DROP TABLE tdr."Consignment";

CREATE TABLE tdr."Consignment"
(
    "ConsignmentId" text COLLATE pg_catalog."default" NOT NULL,
    "SeriesId" text COLLATE pg_catalog."default",
    "UserId" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    CONSTRAINT "Consignment_pkey" PRIMARY KEY ("ConsignmentId"),
    CONSTRAINT "Consignment_Series_fkey" FOREIGN KEY ("SeriesId")
        REFERENCES tdr."Series" ("SeriesId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Consignment_User_fkey" FOREIGN KEY ("UserId")
        REFERENCES tdr."User" ("UserId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."Consignment"
    OWNER to postgres;


-- Table: tdr."ConsignmentMetadata"

-- DROP TABLE tdr."ConsignmentMetadata";

CREATE TABLE tdr."ConsignmentMetadata"
(
    "MetadataId" text COLLATE pg_catalog."default" NOT NULL,
    "ConsignmentId" text COLLATE pg_catalog."default",
    "PropertyId" text COLLATE pg_catalog."default",
    "Value" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    "UserId" text COLLATE pg_catalog."default",
    CONSTRAINT "ConMetadataId_pkey" PRIMARY KEY ("MetadataId"),
    CONSTRAINT "ConMetadata_Consignment_fkey" FOREIGN KEY ("ConsignmentId")
        REFERENCES tdr."Consignment" ("ConsignmentId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "ConMetadata_Property_fkey" FOREIGN KEY ("PropertyId")
        REFERENCES tdr."ConsignmentProperty" ("PropertyId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "ConMetadata_User_fkey" FOREIGN KEY ("UserId")
        REFERENCES tdr."User" ("UserId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."ConsignmentMetadata"
    OWNER to postgres;


-- Table: tdr."File"

-- DROP TABLE tdr."File";

CREATE TABLE tdr."File"
(
    "FileId" text COLLATE pg_catalog."default" NOT NULL,
    "ConsignmentId" text COLLATE pg_catalog."default",
    "UserId" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    CONSTRAINT "File_pkey" PRIMARY KEY ("FileId"),
    CONSTRAINT "File_Consignment_fkey" FOREIGN KEY ("ConsignmentId")
        REFERENCES tdr."Consignment" ("ConsignmentId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "File_User_fkey" FOREIGN KEY ("UserId")
        REFERENCES tdr."User" ("UserId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."File"
    OWNER to postgres;
	
-- Table: tdr."FileMetadata"

-- DROP TABLE tdr."FileMetadata";

CREATE TABLE tdr."FileMetadata"
(
    "MetadataId" text COLLATE pg_catalog."default" NOT NULL,
    "FileId" text COLLATE pg_catalog."default",
    "PropertyId" text COLLATE pg_catalog."default",
    "Value" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    "UserId" text COLLATE pg_catalog."default",
    CONSTRAINT "FileMetadata_pkey" PRIMARY KEY ("MetadataId"),
    CONSTRAINT "FileMetadata_Consignment_fkey" FOREIGN KEY ("FileId")
        REFERENCES tdr."File" ("FileId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "FileMetadata_Property_fkey" FOREIGN KEY ("PropertyId")
        REFERENCES tdr."FileProperty" ("PropertyId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "FileMetadata_User_fkey" FOREIGN KEY ("UserId")
        REFERENCES tdr."User" ("UserId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."FileMetadata"
    OWNER to postgres;
	
	
-- Table: tdr."AVMetadata"

-- DROP TABLE tdr."AVMetadata";

CREATE TABLE tdr."AVMetadata"
(
    "FileId" text COLLATE pg_catalog."default" NOT NULL,
    "Software" text COLLATE pg_catalog."default",
    "Value" text COLLATE pg_catalog."default",
    "SoftwareVersion" text COLLATE pg_catalog."default",
    "DatabaseVersion" text COLLATE pg_catalog."default",
    "Result" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    CONSTRAINT "AVMetadata_Consignment_fkey" FOREIGN KEY ("FileId")
        REFERENCES tdr."File" ("FileId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."AVMetadata"
    OWNER to postgres;
	
-- Table: tdr."FFIDMetadata"

-- DROP TABLE tdr."FFIDMetadata";

CREATE TABLE tdr."FFIDMetadata"
(
    "FileId" text COLLATE pg_catalog."default" NOT NULL,
    "Software" text COLLATE pg_catalog."default",
    "SoftwareVersion" text COLLATE pg_catalog."default",
    "DefinitionsVersion" text COLLATE pg_catalog."default",
    "Method" text COLLATE pg_catalog."default",
    "Extension" text COLLATE pg_catalog."default",
    "ExtensionMismatch" text COLLATE pg_catalog."default",
    "FormatCount" text COLLATE pg_catalog."default",
    "PUID" text COLLATE pg_catalog."default",
    "Datetime" timestamp with time zone,
    CONSTRAINT "FFIDMetadata_Consignment_fkey" FOREIGN KEY ("FileId")
        REFERENCES tdr."File" ("FileId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."FFIDMetadata"
    OWNER to postgres;
	
-- Table: tdr."ClientFileMetadata"

-- DROP TABLE tdr."ClientFileMetadata";

CREATE TABLE tdr."ClientFileMetadata"
(
    "FileId" text COLLATE pg_catalog."default" NOT NULL,
    "OriginalPath" text COLLATE pg_catalog."default",
    "Checksum" text COLLATE pg_catalog."default",
    "ChecksumType" text COLLATE pg_catalog."default",
    "LastModified" timestamp with time zone,
    "CreatedDate" timestamp with time zone,
    "Filesize" double precision,
	"Datetime" timestamp with time zone,
    CONSTRAINT "ClientFileMetadata_Consignment_fkey" FOREIGN KEY ("FileId")
        REFERENCES tdr."File" ("FileId") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE tdr."ClientFileMetadata"
    OWNER to postgres;
	