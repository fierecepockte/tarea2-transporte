-- Complemento para conservar las metricas originales de Viajes y los observados.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF DB_NAME() <> N'dw_transporte' THROW 51200, 'Conectese a dw_transporte.', 1;
BEGIN TRY
BEGIN TRANSACTION;
IF OBJECT_ID(N'bronze.ViajesAzure', N'U') IS NULL THROW 51201, 'Falta la tabla Bronze ViajesAzure.', 1;
IF COL_LENGTH(N'bronze.ViajesAzure', N'CodigoRutaOrigen') IS NULL
    ALTER TABLE bronze.ViajesAzure ADD [CodigoRutaOrigen] varchar(30) NULL;
IF COL_LENGTH(N'bronze.ViajesAzure', N'PasajerosReportados') IS NULL
    ALTER TABLE bronze.ViajesAzure ADD [PasajerosReportados] varchar(20) NULL;
IF COL_LENGTH(N'bronze.ViajesAzure', N'PasajerosEstimados') IS NULL
    ALTER TABLE bronze.ViajesAzure ADD [PasajerosEstimados] varchar(20) NULL;
IF COL_LENGTH(N'bronze.ViajesAzure', N'TipoMetrica') IS NULL
    ALTER TABLE bronze.ViajesAzure ADD [TipoMetrica] varchar(50) NULL;
IF COL_LENGTH(N'bronze.ViajesAzure', N'OrigenFuente') IS NULL
    ALTER TABLE bronze.ViajesAzure ADD [OrigenFuente] varchar(80) NULL;
IF SCHEMA_ID(N'auditoria') IS NULL EXEC(N'CREATE SCHEMA auditoria');
IF OBJECT_ID(N'auditoria.ParadasObservadas', N'U') IS NULL
BEGIN
CREATE TABLE auditoria.ParadasObservadas (
    AnioFuente         NVARCHAR(10)  NULL,
    ParadaHistoricaId  NVARCHAR(30)  NULL,
    CodigoPublicado    NVARCHAR(20)  NULL,
    NombreParada       NVARCHAR(120) NULL,
    Zona               NVARCHAR(40)  NULL,
    Latitud            NVARCHAR(30)  NULL,
    Longitud           NVARCHAR(30)  NULL,
    VigenciaDesde      NVARCHAR(30)  NULL,
    VigenciaHasta      NVARCHAR(30)  NULL,
    Estado             NVARCHAR(20)  NULL,
    Motivo NVARCHAR(500) NULL
);
END;
IF OBJECT_ID(N'auditoria.VehiculosObservados', N'U') IS NULL
BEGIN
CREATE TABLE auditoria.VehiculosObservados (
    AnioFuente          NVARCHAR(10) NULL,
    VehiculoId          NVARCHAR(20) NULL,
    Placa               NVARCHAR(20) NULL,
    TipoVehiculo        NVARCHAR(30) NULL,
    CapacidadEfectiva   NVARCHAR(20) NULL,
    VigenciaDesde       NVARCHAR(30) NULL,
    VigenciaHasta       NVARCHAR(30) NULL,
    Estado              NVARCHAR(20) NULL,
    Motivo NVARCHAR(500) NULL
);
END;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
THROW;
END CATCH;
