CREATE TABLE [dbo].[PipelineRun] (
    [RunId]        INT            IDENTITY (1, 1) NOT NULL,
    [PipelineName] NVARCHAR (255) NOT NULL,
    [RunStart]     DATETIME       CONSTRAINT [DF__dbo_PipelineRun__RunStart] DEFAULT (getutcdate()) NOT NULL,
    [RowsCopied]   INT            NULL,
    [RunEnd]       DATETIME       NULL,
    [Message]      NVARCHAR (255) NULL,
    CONSTRAINT [PK__dbo_PipelineRun] PRIMARY KEY CLUSTERED ([RunId] ASC)
);

