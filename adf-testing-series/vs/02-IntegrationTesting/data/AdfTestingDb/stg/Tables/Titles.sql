CREATE TABLE stg.[Titles] (
    [title_id]         CHAR (6)        NULL,
    [title]            VARCHAR (80)    NULL,
    [category]         VARCHAR (12)    NULL,
    [publisher_id]     CHAR (4)        NULL,
    [price]            DECIMAL (10, 2) NULL,
    [advance]          DECIMAL (10, 2) NULL,
    [royalty]          INT             NULL,
    [ytd_sales]        INT             NULL,
    [notes]            VARCHAR (200)   NULL,
    [publication_date] DATETIME        NULL,
    [RunId]    INT   CONSTRAINT [DF_Titles_RunId] DEFAULT ((-1)) NOT NULL
);

GO
CREATE CLUSTERED INDEX [IX__stg_Titles__title_id]
    ON [stg].Titles(title_id ASC);

