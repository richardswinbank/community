CREATE TABLE [dbo].[Titles] (
    [title_id]         CHAR (6)        NOT NULL CONSTRAINT PK__dbo_Titles PRIMARY KEY,
    [title]            VARCHAR (80)    NOT NULL,
    [category]         VARCHAR (12)    NULL,
    [publisher_id]     CHAR (4)        NULL,
    [price]            DECIMAL (10, 2) NULL,
    [advance]          DECIMAL (10, 2) NULL,
    [royalty]          INT             NULL,
    [ytd_sales]        INT             NULL,
    [notes]            VARCHAR (200)   NULL,
    [publication_date] DATETIME        NULL
);

