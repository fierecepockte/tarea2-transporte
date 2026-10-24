/* Adaptacion idempotente de 02_silver_v2.sql del curso.
   Crea las tablas ausentes y conserva las existentes si coinciden con v2.
   No carga datos. No contiene DROP, DELETE ni TRUNCATE.
   Solo para dw_transporte. */
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF DB_NAME() <> N'dw_transporte'
    THROW 51100, 'Conectese a dw_transporte.', 1;

BEGIN TRY
    BEGIN TRANSACTION;
    IF SCHEMA_ID(N'silver') IS NULL EXEC(N'CREATE SCHEMA silver');

    IF OBJECT_ID(N'silver.RutasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.RutasAzure (
    AnioFuente         SMALLINT      NOT NULL,
    RutaHistoricaId    NVARCHAR(30)  NOT NULL,
    CodigoRuta         NVARCHAR(20)  NOT NULL,
    NombreRuta         NVARCHAR(120) NOT NULL,
    Origen             NVARCHAR(80)  NOT NULL,
    Destino            NVARCHAR(80)  NOT NULL,
    VigenciaDesde      DATE          NOT NULL,
    VigenciaHasta      DATE          NOT NULL,
    Estado             NVARCHAR(20)  NOT NULL,
    CONSTRAINT PK_silver_RutasAzure PRIMARY KEY (AnioFuente, RutaHistoricaId)
        );
    END;

    IF OBJECT_ID(N'silver.ParadasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.ParadasAzure (
    AnioFuente         SMALLINT      NOT NULL,
    ParadaHistoricaId  NVARCHAR(30)  NOT NULL,
    CodigoPublicado    NVARCHAR(20)  NOT NULL,
    NombreParada       NVARCHAR(120) NOT NULL,
    Zona               NVARCHAR(40)  NOT NULL,
    Latitud            DECIMAL(9,6)  NOT NULL,
    Longitud           DECIMAL(9,6)  NOT NULL,
    VigenciaDesde      DATE          NOT NULL,
    VigenciaHasta      DATE          NOT NULL,
    Estado             NVARCHAR(20)  NOT NULL,
    CONSTRAINT PK_silver_ParadasAzure PRIMARY KEY (AnioFuente, ParadaHistoricaId)
        );
    END;

    IF OBJECT_ID(N'silver.VehiculosAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.VehiculosAzure (
    AnioFuente          SMALLINT     NOT NULL,
    VehiculoId          NVARCHAR(20) NOT NULL,
    Placa               NVARCHAR(20) NOT NULL,
    TipoVehiculo        NVARCHAR(30) NOT NULL,
    CapacidadEfectiva   INT          NOT NULL,
    VigenciaDesde       DATE         NOT NULL,
    VigenciaHasta       DATE         NOT NULL,
    Estado              NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_silver_VehiculosAzure PRIMARY KEY (AnioFuente, VehiculoId)
        );
    END;

    IF OBJECT_ID(N'silver.ViajesAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.ViajesAzure (
    AnioFuente            SMALLINT      NOT NULL,
    ViajeId               NVARCHAR(30)  NOT NULL,
    RutaHistoricaId       NVARCHAR(30)  NOT NULL,
    VehiculoId            NVARCHAR(20)  NOT NULL,
    FechaServicio         DATE          NOT NULL,
    HoraProgramada        TIME          NOT NULL,
    HoraSalida            TIME          NOT NULL,
    HoraLlegada           TIME          NOT NULL,
    ValidacionesTarjeta   INT           NOT NULL,
    KmRecorridos          DECIMAL(8,1)  NOT NULL,
    EstadoViaje           NVARCHAR(20)  NOT NULL,
    CONSTRAINT PK_silver_ViajesAzure PRIMARY KEY (AnioFuente, ViajeId),
    CONSTRAINT FK_silver_Viajes_Rutas FOREIGN KEY (AnioFuente, RutaHistoricaId)
        REFERENCES silver.RutasAzure (AnioFuente, RutaHistoricaId),
    CONSTRAINT FK_silver_Viajes_Vehiculos FOREIGN KEY (AnioFuente, VehiculoId)
        REFERENCES silver.VehiculosAzure (AnioFuente, VehiculoId)
        );
    END;

    IF OBJECT_ID(N'silver.DemandaParadasAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.DemandaParadasAzure (
    AnioFuente             SMALLINT      NOT NULL,
    DemandaId              NVARCHAR(30)  NOT NULL,
    FechaServicio          DATE          NOT NULL,
    RutaHistoricaId        NVARCHAR(30)  NOT NULL,
    ParadaHistoricaId      NVARCHAR(30)  NOT NULL,
    Franja                 NVARCHAR(20)  NOT NULL,
    ValidacionesTarjeta    INT           NOT NULL,
    Descensos              INT           NOT NULL,
    DemandaNoAtendida      INT           NOT NULL,
    Metodo                 NVARCHAR(30)  NOT NULL,
    CONSTRAINT PK_silver_DemandaParadasAzure PRIMARY KEY (AnioFuente, DemandaId),
    CONSTRAINT FK_silver_Demanda_Rutas FOREIGN KEY (AnioFuente, RutaHistoricaId)
        REFERENCES silver.RutasAzure (AnioFuente, RutaHistoricaId),
    CONSTRAINT FK_silver_Demanda_Paradas FOREIGN KEY (AnioFuente, ParadaHistoricaId)
        REFERENCES silver.ParadasAzure (AnioFuente, ParadaHistoricaId)
        );
    END;

    IF OBJECT_ID(N'silver.IncidentesAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.IncidentesAzure (
    AnioFuente          SMALLINT       NOT NULL,
    IncidenteId         NVARCHAR(30)   NOT NULL,
    TipoIncidente       NVARCHAR(30)   NOT NULL,
    Severidad           NVARCHAR(15)   NOT NULL,
    FechaHoraInicio     DATETIME2(0)   NOT NULL,
    FechaHoraFin        DATETIME2(0)   NOT NULL,
    FechaHoraRegistro   DATETIME2(0)   NOT NULL,
    VehiculoId          NVARCHAR(20)   NULL,
    Descripcion         NVARCHAR(200)  NOT NULL,
    CONSTRAINT PK_silver_IncidentesAzure PRIMARY KEY (AnioFuente, IncidenteId),
    CONSTRAINT FK_silver_Incidentes_Vehiculos FOREIGN KEY (AnioFuente, VehiculoId)
        REFERENCES silver.VehiculosAzure (AnioFuente, VehiculoId)
        );
    END;

    IF OBJECT_ID(N'silver.IncidenteRutaAzure', N'U') IS NULL
    BEGIN
        CREATE TABLE silver.IncidenteRutaAzure (
    AnioFuente        SMALLINT      NOT NULL,
    IncidenteId       NVARCHAR(30)  NOT NULL,
    RutaHistoricaId   NVARCHAR(30)  NOT NULL,
    EsPrincipal       BIT           NOT NULL,
    CONSTRAINT PK_silver_IncidenteRutaAzure PRIMARY KEY (AnioFuente, IncidenteId, RutaHistoricaId),
    CONSTRAINT FK_silver_IncidenteRuta_Incidente FOREIGN KEY (AnioFuente, IncidenteId)
        REFERENCES silver.IncidentesAzure (AnioFuente, IncidenteId),
    CONSTRAINT FK_silver_IncidenteRuta_Ruta FOREIGN KEY (AnioFuente, RutaHistoricaId)
        REFERENCES silver.RutasAzure (AnioFuente, RutaHistoricaId)
        );
    END;

    DECLARE @Expected TABLE (
        TableName sysname, ColumnName sysname, TypeName sysname,
        MaxLength smallint, PrecisionValue tinyint, ScaleValue tinyint, IsNullable bit
    );
    INSERT INTO @Expected VALUES
    (N'RutasAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'RutasAzure', N'RutaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'RutasAzure', N'CodigoRuta', N'nvarchar', 40, 0, 0, 0),
    (N'RutasAzure', N'NombreRuta', N'nvarchar', 240, 0, 0, 0),
    (N'RutasAzure', N'Origen', N'nvarchar', 160, 0, 0, 0),
    (N'RutasAzure', N'Destino', N'nvarchar', 160, 0, 0, 0),
    (N'RutasAzure', N'VigenciaDesde', N'date', 3, 10, 0, 0),
    (N'RutasAzure', N'VigenciaHasta', N'date', 3, 10, 0, 0),
    (N'RutasAzure', N'Estado', N'nvarchar', 40, 0, 0, 0),
    (N'ParadasAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'ParadasAzure', N'ParadaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'ParadasAzure', N'CodigoPublicado', N'nvarchar', 40, 0, 0, 0),
    (N'ParadasAzure', N'NombreParada', N'nvarchar', 240, 0, 0, 0),
    (N'ParadasAzure', N'Zona', N'nvarchar', 80, 0, 0, 0),
    (N'ParadasAzure', N'Latitud', N'decimal', 5, 9, 6, 0),
    (N'ParadasAzure', N'Longitud', N'decimal', 5, 9, 6, 0),
    (N'ParadasAzure', N'VigenciaDesde', N'date', 3, 10, 0, 0),
    (N'ParadasAzure', N'VigenciaHasta', N'date', 3, 10, 0, 0),
    (N'ParadasAzure', N'Estado', N'nvarchar', 40, 0, 0, 0),
    (N'VehiculosAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'VehiculosAzure', N'VehiculoId', N'nvarchar', 40, 0, 0, 0),
    (N'VehiculosAzure', N'Placa', N'nvarchar', 40, 0, 0, 0),
    (N'VehiculosAzure', N'TipoVehiculo', N'nvarchar', 60, 0, 0, 0),
    (N'VehiculosAzure', N'CapacidadEfectiva', N'int', 4, 10, 0, 0),
    (N'VehiculosAzure', N'VigenciaDesde', N'date', 3, 10, 0, 0),
    (N'VehiculosAzure', N'VigenciaHasta', N'date', 3, 10, 0, 0),
    (N'VehiculosAzure', N'Estado', N'nvarchar', 40, 0, 0, 0),
    (N'ViajesAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'ViajesAzure', N'ViajeId', N'nvarchar', 60, 0, 0, 0),
    (N'ViajesAzure', N'RutaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'ViajesAzure', N'VehiculoId', N'nvarchar', 40, 0, 0, 0),
    (N'ViajesAzure', N'FechaServicio', N'date', 3, 10, 0, 0),
    (N'ViajesAzure', N'HoraProgramada', N'time', 5, 16, 7, 0),
    (N'ViajesAzure', N'HoraSalida', N'time', 5, 16, 7, 0),
    (N'ViajesAzure', N'HoraLlegada', N'time', 5, 16, 7, 0),
    (N'ViajesAzure', N'ValidacionesTarjeta', N'int', 4, 10, 0, 0),
    (N'ViajesAzure', N'KmRecorridos', N'decimal', 5, 8, 1, 0),
    (N'ViajesAzure', N'EstadoViaje', N'nvarchar', 40, 0, 0, 0),
    (N'DemandaParadasAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'DemandaParadasAzure', N'DemandaId', N'nvarchar', 60, 0, 0, 0),
    (N'DemandaParadasAzure', N'FechaServicio', N'date', 3, 10, 0, 0),
    (N'DemandaParadasAzure', N'RutaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'DemandaParadasAzure', N'ParadaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'DemandaParadasAzure', N'Franja', N'nvarchar', 40, 0, 0, 0),
    (N'DemandaParadasAzure', N'ValidacionesTarjeta', N'int', 4, 10, 0, 0),
    (N'DemandaParadasAzure', N'Descensos', N'int', 4, 10, 0, 0),
    (N'DemandaParadasAzure', N'DemandaNoAtendida', N'int', 4, 10, 0, 0),
    (N'DemandaParadasAzure', N'Metodo', N'nvarchar', 60, 0, 0, 0),
    (N'IncidentesAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'IncidentesAzure', N'IncidenteId', N'nvarchar', 60, 0, 0, 0),
    (N'IncidentesAzure', N'TipoIncidente', N'nvarchar', 60, 0, 0, 0),
    (N'IncidentesAzure', N'Severidad', N'nvarchar', 30, 0, 0, 0),
    (N'IncidentesAzure', N'FechaHoraInicio', N'datetime2', 6, 19, 0, 0),
    (N'IncidentesAzure', N'FechaHoraFin', N'datetime2', 6, 19, 0, 0),
    (N'IncidentesAzure', N'FechaHoraRegistro', N'datetime2', 6, 19, 0, 0),
    (N'IncidentesAzure', N'VehiculoId', N'nvarchar', 40, 0, 0, 1),
    (N'IncidentesAzure', N'Descripcion', N'nvarchar', 400, 0, 0, 0),
    (N'IncidenteRutaAzure', N'AnioFuente', N'smallint', 2, 5, 0, 0),
    (N'IncidenteRutaAzure', N'IncidenteId', N'nvarchar', 60, 0, 0, 0),
    (N'IncidenteRutaAzure', N'RutaHistoricaId', N'nvarchar', 60, 0, 0, 0),
    (N'IncidenteRutaAzure', N'EsPrincipal', N'bit', 1, 1, 0, 0);

    IF EXISTS (
        SELECT 1 FROM @Expected e
        LEFT JOIN sys.tables t ON t.name=e.TableName AND t.schema_id=SCHEMA_ID(N'silver')
        LEFT JOIN sys.columns c ON c.object_id=t.object_id AND c.name=e.ColumnName
        WHERE c.column_id IS NULL OR TYPE_NAME(c.system_type_id)<>e.TypeName
           OR c.max_length<>e.MaxLength OR c.precision<>e.PrecisionValue
           OR c.scale<>e.ScaleValue OR c.is_nullable<>e.IsNullable
    ) OR EXISTS (
        SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id=c.object_id
        WHERE t.schema_id=SCHEMA_ID(N'silver')
          AND t.name IN (SELECT TableName FROM @Expected)
          AND NOT EXISTS (SELECT 1 FROM @Expected e WHERE e.TableName=t.name AND e.ColumnName=c.name)
    )
        THROW 51120, 'Las tablas Silver existentes no coinciden con el SQL v2. No se modificaron ni borraron.', 1;

    DECLARE @PK TABLE (TableName sysname, ColumnName sysname, Ordinal int);
    INSERT INTO @PK VALUES
    (N'RutasAzure', N'AnioFuente', 1),
    (N'RutasAzure', N'RutaHistoricaId', 2),
    (N'ParadasAzure', N'AnioFuente', 1),
    (N'ParadasAzure', N'ParadaHistoricaId', 2),
    (N'VehiculosAzure', N'AnioFuente', 1),
    (N'VehiculosAzure', N'VehiculoId', 2),
    (N'ViajesAzure', N'AnioFuente', 1),
    (N'ViajesAzure', N'ViajeId', 2),
    (N'DemandaParadasAzure', N'AnioFuente', 1),
    (N'DemandaParadasAzure', N'DemandaId', 2),
    (N'IncidentesAzure', N'AnioFuente', 1),
    (N'IncidentesAzure', N'IncidenteId', 2),
    (N'IncidenteRutaAzure', N'AnioFuente', 1),
    (N'IncidenteRutaAzure', N'IncidenteId', 2),
    (N'IncidenteRutaAzure', N'RutaHistoricaId', 3);
    IF EXISTS (
        SELECT TableName, ColumnName, Ordinal FROM @PK
        EXCEPT
        SELECT t.name, c.name, ic.key_ordinal
        FROM sys.tables t
        JOIN sys.indexes i ON i.object_id=t.object_id AND i.is_primary_key=1 AND i.is_disabled=0
        JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
        JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
        WHERE t.schema_id=SCHEMA_ID(N'silver')
    ) OR EXISTS (
        SELECT t.name, c.name, ic.key_ordinal
        FROM sys.tables t
        JOIN sys.indexes i ON i.object_id=t.object_id AND i.is_primary_key=1
        JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
        JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
        WHERE t.schema_id=SCHEMA_ID(N'silver') AND t.name IN (SELECT TableName FROM @PK)
        EXCEPT SELECT TableName, ColumnName, Ordinal FROM @PK
    )
        THROW 51121, 'Una clave primaria Silver no coincide con v2. Revise el esquema existente.', 1;

    DECLARE @FK TABLE (ConstraintName sysname, TableName sysname, ColumnName sysname,
        ParentTable sysname, ParentColumn sysname, Ordinal int);
    INSERT INTO @FK VALUES
    (N'FK_silver_Viajes_Rutas', N'ViajesAzure', N'AnioFuente', N'RutasAzure', N'AnioFuente', 1),
    (N'FK_silver_Viajes_Rutas', N'ViajesAzure', N'RutaHistoricaId', N'RutasAzure', N'RutaHistoricaId', 2),
    (N'FK_silver_Viajes_Vehiculos', N'ViajesAzure', N'AnioFuente', N'VehiculosAzure', N'AnioFuente', 1),
    (N'FK_silver_Viajes_Vehiculos', N'ViajesAzure', N'VehiculoId', N'VehiculosAzure', N'VehiculoId', 2),
    (N'FK_silver_Demanda_Rutas', N'DemandaParadasAzure', N'AnioFuente', N'RutasAzure', N'AnioFuente', 1),
    (N'FK_silver_Demanda_Rutas', N'DemandaParadasAzure', N'RutaHistoricaId', N'RutasAzure', N'RutaHistoricaId', 2),
    (N'FK_silver_Demanda_Paradas', N'DemandaParadasAzure', N'AnioFuente', N'ParadasAzure', N'AnioFuente', 1),
    (N'FK_silver_Demanda_Paradas', N'DemandaParadasAzure', N'ParadaHistoricaId', N'ParadasAzure', N'ParadaHistoricaId', 2),
    (N'FK_silver_Incidentes_Vehiculos', N'IncidentesAzure', N'AnioFuente', N'VehiculosAzure', N'AnioFuente', 1),
    (N'FK_silver_Incidentes_Vehiculos', N'IncidentesAzure', N'VehiculoId', N'VehiculosAzure', N'VehiculoId', 2),
    (N'FK_silver_IncidenteRuta_Incidente', N'IncidenteRutaAzure', N'AnioFuente', N'IncidentesAzure', N'AnioFuente', 1),
    (N'FK_silver_IncidenteRuta_Incidente', N'IncidenteRutaAzure', N'IncidenteId', N'IncidentesAzure', N'IncidenteId', 2),
    (N'FK_silver_IncidenteRuta_Ruta', N'IncidenteRutaAzure', N'AnioFuente', N'RutasAzure', N'AnioFuente', 1),
    (N'FK_silver_IncidenteRuta_Ruta', N'IncidenteRutaAzure', N'RutaHistoricaId', N'RutasAzure', N'RutaHistoricaId', 2);
    IF EXISTS (
        SELECT TableName, ColumnName, ParentTable, ParentColumn, Ordinal FROM @FK
        EXCEPT
        SELECT ct.name, cc.name, pt.name, pc.name, fkc.constraint_column_id
        FROM sys.foreign_keys fk
        JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
        JOIN sys.tables ct ON ct.object_id=fkc.parent_object_id
        JOIN sys.columns cc ON cc.object_id=ct.object_id AND cc.column_id=fkc.parent_column_id
        JOIN sys.tables pt ON pt.object_id=fkc.referenced_object_id
        JOIN sys.columns pc ON pc.object_id=pt.object_id AND pc.column_id=fkc.referenced_column_id
        WHERE ct.schema_id=SCHEMA_ID(N'silver') AND pt.schema_id=SCHEMA_ID(N'silver')
          AND fk.is_disabled=0 AND fk.is_not_trusted=0
    )
        THROW 51122, 'Falta una relacion Silver de v2 o esta deshabilitada. Revise el esquema existente.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'silver.ViajesAzure') AND name=N'IX_silver_Viajes_FechaRuta')
        CREATE INDEX IX_silver_Viajes_FechaRuta ON silver.ViajesAzure (FechaServicio, RutaHistoricaId);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'silver.DemandaParadasAzure') AND name=N'IX_silver_Demanda_FechaFranja')
        CREATE INDEX IX_silver_Demanda_FechaFranja ON silver.DemandaParadasAzure (FechaServicio, Franja);
    COMMIT TRANSACTION;
    SELECT N'silver' AS Esquema, name AS Tabla
    FROM sys.tables WHERE schema_id=SCHEMA_ID(N'silver') ORDER BY name;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;