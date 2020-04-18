CREATE TABLE [stg].[Authors] (
    [au_id]    VARCHAR (20) NULL,
    [au_lname] VARCHAR (40) NULL,
    [au_fname] VARCHAR (20) NULL,
    [phone]    CHAR (12)    NULL,
    [address]  VARCHAR (40) NULL,
    [city]     VARCHAR (20) NULL,
    [state]    CHAR (2)     NULL,
    [zip]      CHAR (5)     NULL,
    [contract] BIT          NULL,
    [RunId]    INT          CONSTRAINT [DF_Authors_RunId] DEFAULT ((-1)) NOT NULL
);




GO
CREATE CLUSTERED INDEX [IX__stg_Authors__au_id]
    ON [stg].[Authors]([au_id] ASC);

