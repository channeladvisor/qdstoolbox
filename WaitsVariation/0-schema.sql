IF NOT EXISTS (SELECT 1 FROM [sys].[schemas] WHERE QUOTENAME([name]) = '[dbo]')
	EXECUTE ('CREATE SCHEMA [dbo];')