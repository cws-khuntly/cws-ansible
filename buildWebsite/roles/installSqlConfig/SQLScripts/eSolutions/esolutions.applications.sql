DELIMITER //

DROP TABLE IF EXISTS ESOLUTIONS.APPLICATIONS //

CREATE TABLE ESOLUTIONS.APPLICATIONS (
    GUID VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL UNIQUE UNIQUE,
    APPNAME VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    VERSION VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT "1.0",
    INSTALLATION_PATH TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL, -- where do files get installed to ?
    PACKAGE_LOCATION TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, -- package location, either provided or scm'd or whatnot
    PACKAGE_INSTALLER TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, -- installer file for standalones
    INSTALLER_OPTIONS TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, -- only matters for standalone installs with an installer
    LOGS_DIRECTORY TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, -- applies only to web and standalone
    PLATFORM_GUID TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL, -- MULTIPLE platforms per app
    APP_ONLINE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(), -- when did the app get added
    APP_OFFLINE_DATE TIMESTAMP,
    PRIMARY KEY (GUID),
    FULLTEXT KEY IDX_APPLICATIONS (APPNAME)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'appsrv.lan' //

--
--
--
DROP PROCEDURE IF EXISTS ESOLUTIONS.getApplicationCount //
DROP PROCEDURE IF EXISTS ESOLUTIONS.listApplications //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getApplicationData //
DROP PROCEDURE IF EXISTS ESOLUTIONS.removeApplicationData //
DROP PROCEDURE IF EXISTS ESOLUTIONS.updateApplicationData //
DROP PROCEDURE IF EXISTS ESOLUTIONS.insertNewApplication //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getApplicationByAttribute //

CREATE PROCEDURE ESOLUTIONS.getApplicationByAttribute(
    IN attributeName VARCHAR(100),
    IN startRow INT
)
BEGIN
    SELECT
        GUID,
        APPNAME,
    MATCH (APPNAME)
    AGAINST (+attributeName WITH QUERY EXPANSION)
    FROM ESOLUTIONS.APPLICATIONS
    WHERE MATCH (APPNAME)
    AGAINST (+attributeName IN BOOLEAN MODE)
    AND APP_OFFLINE_DATE IS NULL
    LIMIT startRow, 20;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.insertNewApplication(
    IN appGuid VARCHAR(128),
    IN appName VARCHAR(45),
    IN appVersion VARCHAR(45),
    IN installPath TEXT,
    IN packageLocation TEXT,
    IN packageInstaller TEXT,
    IN installerOptions TEXT,
    IN logsDirectory TEXT,
    IN platformGuid TEXT
)
BEGIN
    INSERT INTO ESOLUTIONS.APPLICATIONS
    (
        GUID, APPNAME, VERSION, INSTALLATION_PATH, PACKAGE_LOCATION, PACKAGE_INSTALLER,
        INSTALLER_OPTIONS, LOGS_DIRECTORY, PLATFORM_GUID, APP_ONLINE_DATE
    )
    VALUES
    (
        appGuid, appName, appVersion, installPath, packageLocation, packageInstaller,
        installerOptions, logsDirectory, platformGuid, NOW()
    );

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.updateApplicationData(
    IN appGuid VARCHAR(128),
    IN appName VARCHAR(45),
    IN appVersion VARCHAR(45),
    IN installPath TEXT,
    IN packageLocation TEXT,
    IN packageInstaller TEXT,
    IN installerOptions TEXT,
    IN logsDirectory TEXT,
    IN platformGuid TEXT,
    OUT updateCount INTEGER
)
BEGIN
    UPDATE ESOLUTIONS.APPLICATIONS
    SET
        APPNAME = appName,
        VERSION = appVersion,
        INSTALLATION_PATH = installPath,
        PACKAGE_LOCATION = packageLocation,
        PACKAGE_INSTALLER = packageInstaller,
        INSTALLER_OPTIONS = installerOptions,
        LOGS_DIRECTORY = logsDirectory,
        PLATFORM_GUID = platformGuid
    WHERE GUID = appGuid;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM ESOLUTIONS.APPLICATIONS
    WHERE GUID = appGuid
    AND APPNAME = appName
    AND VERSION = appVersion
    AND INSTALLATION_PATH = installPath
    AND PACKAGE_LOCATION = packageLocation
    AND PACKAGE_INSTALLER = packageInstaller
    AND INSTALLER_OPTIONS = installerOptions
    AND LOGS_DIRECTORY = logsDirectory
    AND PLATFORM_GUID = platformGuid;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.removeApplicationData(
    IN appGuid VARCHAR(128)
)
BEGIN
    UPDATE ESOLUTIONS.APPLICATIONS
    SET APP_OFFLINE_DATE = CURRENT_TIMESTAMP()
    WHERE GUID = appGuid;

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getApplicationData(
    IN appGuid VARCHAR(128)
)
BEGIN
    SELECT
        GUID,
        APPNAME,
        VERSION,
        INSTALLATION_PATH,
        PACKAGE_LOCATION,
        PACKAGE_INSTALLER,
        INSTALLER_OPTIONS,
        LOGS_DIRECTORY,
        PLATFORM_GUID
    FROM ESOLUTIONS.APPLICATIONS
    WHERE GUID = appGuid
    AND APP_OFFLINE_DATE IS NULL;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getApplicationCount(
)
BEGIN
    SELECT COUNT(*)
    FROM ESOLUTIONS.APPLICATIONS
    WHERE APP_OFFLINE_DATE IS NULL;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.listApplications(
    IN startRow INT
)
BEGIN
    SELECT
        GUID,
        APPNAME
    FROM ESOLUTIONS.APPLICATIONS
    WHERE APP_OFFLINE_DATE IS NULL
    LIMIT startRow, 20;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationCount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.listApplications TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.removeApplicationData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateApplicationData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.insertNewApplication TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationByAttribute TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationCount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.listApplications TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.removeApplicationData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateApplicationData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.insertNewApplication TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getApplicationByAttribute TO 'appadm'@'appsrv.lan' //

DELIMITER ;
