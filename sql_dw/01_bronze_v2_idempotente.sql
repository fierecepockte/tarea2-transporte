-- Tarea 2: misma estructura de 01_bronze_v2.sql; crea solo tablas faltantes.
-- Conserva las tablas existentes y comprueba su estructura. No carga datos.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF DB_NAME() <> N'dw_transporte' THROW 51000, 'Conectese a dw_transporte.', 1;
BEGIN TRY
    BEGIN TRANSACTION;
    IF SCHEMA_ID(N'bronze') IS NULL EXEC(N'CREATE SCHEMA bronze');
    IF OBJECT_ID(N'bronze.RutasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.RutasAzure (
    AnioFuente         VARCHAR(10)  NULL,
    RutaHistoricaId    VARCHAR(30)  NULL,
    CodigoRuta         VARCHAR(20)  NULL,
    NombreRuta         VARCHAR(120) NULL,
    Origen             VARCHAR(80)  NULL,
    Destino            VARCHAR(80)  NULL,
    VigenciaDesde      VARCHAR(30)  NULL,
    VigenciaHasta      VARCHAR(30)  NULL,
    Estado             VARCHAR(20)  NULL

        );
    END;
    IF OBJECT_ID(N'bronze.ParadasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.ParadasAzure (
    AnioFuente         VARCHAR(10)  NULL,
    ParadaHistoricaId  VARCHAR(30)  NULL,
    CodigoPublicado    VARCHAR(20)  NULL,
    NombreParada       VARCHAR(120) NULL,
    Zona               VARCHAR(40)  NULL,
    Latitud            VARCHAR(30)  NULL,
    Longitud           VARCHAR(30)  NULL,
    VigenciaDesde      VARCHAR(30)  NULL,
    VigenciaHasta      VARCHAR(30)  NULL,
    Estado             VARCHAR(20)  NULL

        );
    END;
    IF OBJECT_ID(N'bronze.VehiculosAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.VehiculosAzure (
    AnioFuente          VARCHAR(10) NULL,
    VehiculoId          VARCHAR(20) NULL,
    Placa               VARCHAR(20) NULL,
    TipoVehiculo        VARCHAR(30) NULL,
    CapacidadEfectiva   VARCHAR(20) NULL,
    VigenciaDesde       VARCHAR(30) NULL,
    VigenciaHasta       VARCHAR(30) NULL,
    Estado              VARCHAR(20) NULL

        );
    END;
    IF OBJECT_ID(N'bronze.ViajesAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.ViajesAzure (
    AnioFuente            VARCHAR(10) NULL,
    ViajeId               VARCHAR(30) NULL,
    RutaHistoricaId       VARCHAR(30) NULL,
    VehiculoId            VARCHAR(20) NULL,
    FechaServicio         VARCHAR(30) NULL,
    HoraProgramada        VARCHAR(30) NULL,
    HoraSalida            VARCHAR(30) NULL,
    HoraLlegada           VARCHAR(30) NULL,
    ValidacionesTarjeta   VARCHAR(20) NULL,
    KmRecorridos          VARCHAR(30) NULL,
    EstadoViaje           VARCHAR(20) NULL

        );
    END;
    IF OBJECT_ID(N'bronze.DemandaParadasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.DemandaParadasAzure (
    AnioFuente             VARCHAR(10) NULL,
    DemandaId              VARCHAR(30) NULL,
    FechaServicio          VARCHAR(30) NULL,
    RutaHistoricaId        VARCHAR(30) NULL,
    ParadaHistoricaId      VARCHAR(30) NULL,
    Franja                 VARCHAR(20) NULL,
    ValidacionesTarjeta    VARCHAR(20) NULL,
    Descensos              VARCHAR(20) NULL,
    DemandaNoAtendida      VARCHAR(20) NULL,
    Metodo                 VARCHAR(30) NULL

        );
    END;
    IF OBJECT_ID(N'bronze.IncidentesAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.IncidentesAzure (
    AnioFuente          VARCHAR(10)  NULL,
    IncidenteId         VARCHAR(30)  NULL,
    TipoIncidente       VARCHAR(30)  NULL,
    Severidad           VARCHAR(15)  NULL,
    FechaHoraInicio     VARCHAR(35)  NULL,
    FechaHoraFin        VARCHAR(35)  NULL,
    FechaHoraRegistro   VARCHAR(35)  NULL,
    VehiculoId          VARCHAR(20)  NULL,
    Descripcion         VARCHAR(200) NULL

        );
    END;
    IF OBJECT_ID(N'bronze.IncidenteRutaAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE bronze.IncidenteRutaAzure (
    AnioFuente        VARCHAR(10) NULL,
    IncidenteId       VARCHAR(30) NULL,
    RutaHistoricaId   VARCHAR(30) NULL,
    EsPrincipal       VARCHAR(10) NULL

        );
    END;
    DECLARE @Esperado TABLE (Tabla SYSNAME, Columna SYSNAME, Longitud SMALLINT, Posicion INT);
    INSERT INTO @Esperado (Tabla, Columna, Longitud, Posicion) VALUES
    (N'RutasAzure', N'AnioFuente', 10, 1),
    (N'RutasAzure', N'RutaHistoricaId', 30, 2),
    (N'RutasAzure', N'CodigoRuta', 20, 3),
    (N'RutasAzure', N'NombreRuta', 120, 4),
    (N'RutasAzure', N'Origen', 80, 5),
    (N'RutasAzure', N'Destino', 80, 6),
    (N'RutasAzure', N'VigenciaDesde', 30, 7),
    (N'RutasAzure', N'VigenciaHasta', 30, 8),
    (N'RutasAzure', N'Estado', 20, 9),
    (N'ParadasAzure', N'AnioFuente', 10, 1),
    (N'ParadasAzure', N'ParadaHistoricaId', 30, 2),
    (N'ParadasAzure', N'CodigoPublicado', 20, 3),
    (N'ParadasAzure', N'NombreParada', 120, 4),
    (N'ParadasAzure', N'Zona', 40, 5),
    (N'ParadasAzure', N'Latitud', 30, 6),
    (N'ParadasAzure', N'Longitud', 30, 7),
    (N'ParadasAzure', N'VigenciaDesde', 30, 8),
    (N'ParadasAzure', N'VigenciaHasta', 30, 9),
    (N'ParadasAzure', N'Estado', 20, 10),
    (N'VehiculosAzure', N'AnioFuente', 10, 1),
    (N'VehiculosAzure', N'VehiculoId', 20, 2),
    (N'VehiculosAzure', N'Placa', 20, 3),
    (N'VehiculosAzure', N'TipoVehiculo', 30, 4),
    (N'VehiculosAzure', N'CapacidadEfectiva', 20, 5),
    (N'VehiculosAzure', N'VigenciaDesde', 30, 6),
    (N'VehiculosAzure', N'VigenciaHasta', 30, 7),
    (N'VehiculosAzure', N'Estado', 20, 8),
    (N'ViajesAzure', N'AnioFuente', 10, 1),
    (N'ViajesAzure', N'ViajeId', 30, 2),
    (N'ViajesAzure', N'RutaHistoricaId', 30, 3),
    (N'ViajesAzure', N'VehiculoId', 20, 4),
    (N'ViajesAzure', N'FechaServicio', 30, 5),
    (N'ViajesAzure', N'HoraProgramada', 30, 6),
    (N'ViajesAzure', N'HoraSalida', 30, 7),
    (N'ViajesAzure', N'HoraLlegada', 30, 8),
    (N'ViajesAzure', N'ValidacionesTarjeta', 20, 9),
    (N'ViajesAzure', N'KmRecorridos', 30, 10),
    (N'ViajesAzure', N'EstadoViaje', 20, 11),
    (N'DemandaParadasAzure', N'AnioFuente', 10, 1),
    (N'DemandaParadasAzure', N'DemandaId', 30, 2),
    (N'DemandaParadasAzure', N'FechaServicio', 30, 3),
    (N'DemandaParadasAzure', N'RutaHistoricaId', 30, 4),
    (N'DemandaParadasAzure', N'ParadaHistoricaId', 30, 5),
    (N'DemandaParadasAzure', N'Franja', 20, 6),
    (N'DemandaParadasAzure', N'ValidacionesTarjeta', 20, 7),
    (N'DemandaParadasAzure', N'Descensos', 20, 8),
    (N'DemandaParadasAzure', N'DemandaNoAtendida', 20, 9),
    (N'DemandaParadasAzure', N'Metodo', 30, 10),
    (N'IncidentesAzure', N'AnioFuente', 10, 1),
    (N'IncidentesAzure', N'IncidenteId', 30, 2),
    (N'IncidentesAzure', N'TipoIncidente', 30, 3),
    (N'IncidentesAzure', N'Severidad', 15, 4),
    (N'IncidentesAzure', N'FechaHoraInicio', 35, 5),
    (N'IncidentesAzure', N'FechaHoraFin', 35, 6),
    (N'IncidentesAzure', N'FechaHoraRegistro', 35, 7),
    (N'IncidentesAzure', N'VehiculoId', 20, 8),
    (N'IncidentesAzure', N'Descripcion', 200, 9),
    (N'IncidenteRutaAzure', N'AnioFuente', 10, 1),
    (N'IncidenteRutaAzure', N'IncidenteId', 30, 2),
    (N'IncidenteRutaAzure', N'RutaHistoricaId', 30, 3),
    (N'IncidenteRutaAzure', N'EsPrincipal', 10, 4);
    IF EXISTS (
        SELECT 1 FROM @Esperado e
        LEFT JOIN sys.tables t ON t.name = e.Tabla AND t.schema_id = SCHEMA_ID(N'bronze')
        LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = e.Columna
        WHERE c.column_id IS NULL OR c.system_type_id <> TYPE_ID(N'varchar')
           OR c.max_length <> e.Longitud OR c.is_nullable <> 1 OR c.column_id <> e.Posicion
    ) OR EXISTS (
        SELECT 1 FROM sys.tables t
        JOIN sys.columns c ON c.object_id = t.object_id
        WHERE t.schema_id = SCHEMA_ID(N'bronze')
          AND t.name IN (SELECT Tabla FROM @Esperado)
          AND NOT EXISTS (SELECT 1 FROM @Esperado e WHERE e.Tabla = t.name AND e.Columna = c.name)
    )
        THROW 51001, 'Una tabla Bronze existente no coincide con la version 2. Se cancelo sin modificarla.', 1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
SELECT s.name AS Esquema, t.name AS Tabla
FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'bronze'
ORDER BY t.name;
