DELIMITER //

DROP TABLE IF EXISTS ESOLUTIONS.SYSTEMS //

CREATE TABLE ESOLUTIONS.SYSTEMS (
    GUID VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL UNIQUE,
    SYSTEM_OSTYPE VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SYSSTATUS VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    REGION VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    NWPARTITION VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    DATACENTER_GUID VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SYSTYPE VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    DOMAIN_NAME VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    CPU_TYPE VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    CPU_COUNT INT NOT NULL DEFAULT 1,
    SERVER_RACK VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    RACK_POSITION VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    SERVER_MODEL VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SERIAL_NUMBER VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    INSTALLED_MEMORY INT NOT NULL,
    OPER_IP VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '127.0.0.1',
    OPER_HOSTNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'localhost.localdomain',
    MGMT_IP VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    MGMT_HOSTNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    BKUP_IP VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    BKUP_HOSTNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    NAS_IP VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    NAS_HOSTNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    NAT_ADDR VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    COMMENTS TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    ASSIGNED_ENGINEER VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    ADD_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DELETE_DATE TIMESTAMP,
    DMGR_PORT INT DEFAULT 9043,
    OWNING_DMGR VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    MGR_ENTRY VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci, -- this could be a port number (for dmgr) or a url (for vmgr)
    PRIMARY KEY (GUID),
    FULLTEXT KEY IDX_SEARCH (GUID, SYSTEM_OSTYPE, SYSSTATUS, REGION, NWPARTITION, DATACENTER_GUID, SYSTYPE, OPER_HOSTNAME, ASSIGNED_ENGINEER, OWNING_DMGR)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'appsrv.lan' //

--
--
--
DROP PROCEDURE IF EXISTS ESOLUTIONS.getServerByAttribute //
DROP PROCEDURE IF EXISTS ESOLUTIONS.validateServerHostName //
DROP PROCEDURE IF EXISTS ESOLUTIONS.insertNewServer //
DROP PROCEDURE IF EXISTS ESOLUTIONS.updateServerData //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retireServer //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getServerCount //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getServerList //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrServerData //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getRetiredServers //

CREATE PROCEDURE ESOLUTIONS.getServerByAttribute(
    IN attributeName VARCHAR(100),
    IN startRow INT
)
BEGIN
    SELECT
        T1.GUID,
        T1.REGION,
        T1.NWPARTITION,
        T1.OPER_HOSTNAME,
        T2.GUID,
        T2.DCNAME,
    MATCH (T1.GUID, T1.SYSTEM_OSTYPE, T1.SYSSTATUS, T1.REGION, T1.NWPARTITION, T1.DATACENTER_GUID, T1.SYSTYPE, T1.OPER_HOSTNAME, T1.ASSIGNED_ENGINEER, T1.OWNING_DMGR)
    AGAINST (attributeName WITH QUERY EXPANSION)
    FROM ESOLUTIONS.SYSTEMS T1
    INNER JOIN ESOLUTIONS.DATACENTERS T2
    ON T1.DATACENTER_GUID = T2.GUID
    WHERE MATCH (T1.GUID, T1.SYSTEM_OSTYPE, T1.SYSSTATUS, T1.REGION, T1.NWPARTITION, T1.DATACENTER_GUID, T1.SYSTYPE, T1.OPER_HOSTNAME, T1.ASSIGNED_ENGINEER, T1.OWNING_DMGR)
    AGAINST (attributeName IN BOOLEAN MODE)
    AND DELETE_DATE IS NULL
    LIMIT startRow, 20;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.validateServerHostName(
    IN operHostname VARCHAR(128)
)
BEGIN
    SELECT COUNT(*)
    FROM ESOLUTIONS.SYSTEMS
    WHERE OPER_HOSTNAME = operHostname;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.insertNewServer(
    IN systemGuid VARCHAR(128),
    IN systemOs VARCHAR(45),
    IN systemStatus VARCHAR(45),
    IN systemRegion VARCHAR(45),
    IN networkPartition VARCHAR(45),
    IN datacenter VARCHAR(128),
    IN systemType VARCHAR(45),
    IN domainName VARCHAR(255),
    IN cpuType VARCHAR(255),
    IN cpuCount INT,
    IN serverModel VARCHAR(255),
    IN serialNumber VARCHAR(255),
    IN installedMemory INT,
    IN operIp VARCHAR(50),
    IN operHostname VARCHAR(100),
    IN mgmtIp VARCHAR(50),
    IN mgmtHostname VARCHAR(100),
    IN backupIp VARCHAR(50),
    IN backupHostname VARCHAR(100),
    IN nasIp VARCHAR(50),
    IN nasHostname VARCHAR(100),
    IN natAddr VARCHAR(50),
    IN systemComments TEXT,
    IN engineer VARCHAR(100),
    IN mgrEntry VARCHAR(128),
    IN dmgrPort INT,
    IN serverRack VARCHAR(255),
    IN rackPosition VARCHAR(255),
    IN owningDmgr VARCHAR(255)
)
BEGIN
    IF (dmgrPort = 0)
    THEN
        INSERT INTO ESOLUTIONS.SYSTEMS
        (GUID, SYSTEM_OSTYPE, SYSSTATUS, REGION, NWPARTITION, DATACENTER_GUID, SYSTYPE, DOMAIN_NAME, CPU_TYPE, CPU_COUNT, SERVER_RACK, RACK_POSITION, SERVER_MODEL, SERIAL_NUMBER, INSTALLED_MEMORY, OPER_IP, OPER_HOSTNAME, MGMT_IP, MGMT_HOSTNAME, BKUP_IP, BKUP_HOSTNAME, NAS_IP, NAS_HOSTNAME, NAT_ADDR, COMMENTS, ASSIGNED_ENGINEER, ADD_DATE, MGR_ENTRY, OWNING_DMGR)
        VALUES
        (systemGuid, systemOs, systemStatus, systemRegion, networkPartition, datacenter, systemType, domainName, cpuType, cpuCount, serverRack, rackPosition, serverModel, serialNumber, installedMemory, operIp, operHostname, mgmtIp, mgmtHostname, backupIp, backupHostname, nasIp, nasHostname, natAddr, systemComments, engineer, NOW(), mgrEntry, owningDmgr);
    ELSE
        INSERT INTO ESOLUTIONS.SYSTEMS
        (GUID, SYSTEM_OSTYPE, SYSSTATUS, REGION, NWPARTITION, DATACENTER_GUID, SYSTYPE, DOMAIN_NAME, CPU_TYPE, CPU_COUNT, SERVER_RACK, RACK_POSITION, SERVER_MODEL, SERIAL_NUMBER, INSTALLED_MEMORY, OPER_IP, OPER_HOSTNAME, MGMT_IP, MGMT_HOSTNAME, BKUP_IP, BKUP_HOSTNAME, NAS_IP, NAS_HOSTNAME, NAT_ADDR, COMMENTS, ASSIGNED_ENGINEER, ADD_DATE, MGR_ENTRY, DMGR_PORT, OWNING_DMGR)
        VALUES
        (systemGuid, systemOs, systemStatus, systemRegion, networkPartition, datacenter, systemType, domainName, cpuType, cpuCount, serverRack, rackPosition, serverModel, serialNumber, installedMemory, operIp, operHostname, mgmtIp, mgmtHostname, backupIp, backupHostname, nasIp, nasHostname, natAddr, systemComments, engineer, NOW(), mgrEntry, dmgrPort, owningDmgr);
    END IF;

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.updateServerData(
    IN systemGuid VARCHAR(128),
    IN systemOs VARCHAR(45),
    IN systemStatus VARCHAR(45),
    IN systemRegion VARCHAR(45),
    IN networkPartition VARCHAR(45),
    IN datacenter VARCHAR(45),
    IN systemType VARCHAR(45),
    IN domainName VARCHAR(255),
    IN cpuType VARCHAR(255),
    IN cpuCount INT,
    IN serverModel VARCHAR(255),
    IN serialNumber VARCHAR(255),
    IN installedMemory INT,
    IN operIp VARCHAR(50),
    IN operHostname VARCHAR(100),
    IN mgmtIp VARCHAR(50),
    IN mgmtHostname VARCHAR(100),
    IN backupIp VARCHAR(50),
    IN backupHostname VARCHAR(100),
    IN nasIp VARCHAR(50),
    IN nasHostname VARCHAR(100),
    IN natAddr VARCHAR(50),
    IN systemComments TEXT,
    IN engineer VARCHAR(100),
    IN mgrEntry VARCHAR(128),
    IN dmgrPort INT,
    IN serverRack VARCHAR(255),
    IN rackPosition VARCHAR(255),
    IN owningDmgr VARCHAR(255),
    OUT updateCount INTEGER
)
BEGIN
    UPDATE ESOLUTIONS.SYSTEMS
    SET
        SYSTEM_OSTYPE = systemOs,
        SYSSTATUS = systemStatus,
        REGION = systemRegion,
        NWPARTITION = networkPartition,
        DATACENTER_GUID = datacenter,
        SYSTYPE = systemType,
        DOMAIN_NAME = domainName,
        CPU_TYPE = cpuType,
        CPU_COUNT = cpuCount,
        SERVER_RACK = serverRack,
        RACK_POSITION = rackPosition,
        SERVER_MODEL = serverModel,
        SERIAL_NUMBER = serialNumber,
        INSTALLED_MEMORY = installedMemory,
        OPER_IP = operIp,
        OPER_HOSTNAME = operHostname,
        MGMT_IP = mgmtIp,
        MGMT_HOSTNAME = mgmtHostname,
        BKUP_IP = backupIp,
        BKUP_HOSTNAME = backupHostname,
        NAS_IP = nasIp,
        NAS_HOSTNAME = nasHostname,
        NAT_ADDR = natAddr,
        COMMENTS = systemComments,
        ASSIGNED_ENGINEER = engineer,
        MGR_ENTRY = mgrEntry,
        DMGR_PORT = dmgrPort,
        OWNING_DMGR = owningDmgr
    WHERE GUID = systemGuid;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM ESOLUTIONS.SYSTEMS
    WHERE GUID = systemGuid
    AND SYSTEM_OSTYPE = systemOs
    AND SYSSTATUS = systemStatus
    AND REGION = systemRegion
    AND NWPARTITION = networkPartition
    AND DATACENTER_GUID = datacenter
    AND SYSTYPE = systemType
    AND DOMAIN_NAME = domainName
    AND CPU_TYPE = cpuType
    AND CPU_COUNT = cpuCount
    AND SERVER_RACK = serverRack
    AND RACK_POSITION = rackPosition
    AND SERVER_MODEL = serverModel
    AND SERIAL_NUMBER = serialNumber
    AND INSTALLED_MEMORY = installedMemory
    AND OPER_IP = operIp
    AND OPER_HOSTNAME = operHostname
    AND MGMT_IP = mgmtIp
    AND MGMT_HOSTNAME = mgmtHostname
    AND BKUP_IP = backupIp
    AND BKUP_HOSTNAME = backupHostname
    AND NAS_IP = nasIp
    AND NAS_HOSTNAME = nasHostname
    AND NAT_ADDR = natAddr
    AND COMMENTS = systemComments
    AND ASSIGNED_ENGINEER = engineer
    AND MGR_ENTRY = mgrEntry
    AND DMGR_PORT = dmgrPort
    AND OWNING_DMGR = owningDmgr;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getServerCount(
)
BEGIN
    SELECT COUNT(*)
    FROM ESOLUTIONS.SYSTEMS
    WHERE DELETE_DATE IS NULL;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getServerList(
    IN startRow INT
)
BEGIN
    SELECT
        T1.GUID,
        T1.REGION,
        T1.NWPARTITION,
        T1.OPER_HOSTNAME,
        T1.OWNING_DMGR,
        T2.GUID,
        T2.DCNAME
    FROM ESOLUTIONS.SYSTEMS
    INNER JOIN ESOLUTIONS.DATACENTERS T2
    ON T1.DATACENTER_GUID = T2.GUID
    WHERE DELETE_DATE IS NULL
    LIMIT startRow, 20;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrServerData(
    IN serverGuid VARCHAR(128)
)
BEGIN
    SELECT
        T1.GUID,
        T1.SYSTEM_OSTYPE,
        T1.SYSSTATUS,
        T1.REGION,
        T1.NWPARTITION,
        T1.SYSTYPE,
        T1.DOMAIN_NAME,
        T1.CPU_TYPE,
        T1.CPU_COUNT,
        T1.SERVER_RACK,
        T1.RACK_POSITION,
        T1.SERVER_MODEL,
        T1.SERIAL_NUMBER,
        T1.INSTALLED_MEMORY,
        T1.OPER_IP,
        T1.OPER_HOSTNAME,
        T1.MGMT_IP,
        T1.MGMT_HOSTNAME,
        T1.BKUP_IP,
        T1.BKUP_HOSTNAME,
        T1.NAS_IP,
        T1.NAS_HOSTNAME,
        T1.NAT_ADDR,
        T1.COMMENTS,
        T1.ASSIGNED_ENGINEER,
        T1.ADD_DATE,
        T1.DELETE_DATE,
        T1.DMGR_PORT,
        T1.OWNING_DMGR,
        T1.MGR_ENTRY,
        T2.GUID,
        T2.DCNAME
    FROM ESOLUTIONS.SYSTEMS T1
    INNER JOIN ESOLUTIONS.DATACENTERS T2
    ON T1.DATACENTER_GUID = T2.GUID
    WHERE T1.GUID = serverGuid
    AND DELETE_DATE IS NULL;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getRetiredServers(
)
BEGIN
    SELECT GUID
    FROM ESOLUTIONS.SYSTEMS
    WHERE DELETE_DATE IS NOT NULL;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retireServer(
    IN guid VARCHAR(128)
)
BEGIN
    INSERT INTO ESOLUTIONSARCHIVE.SYSTEMS
    SELECT *
    FROM ESOLUTIONS.SYSTEMS
    WHERE GUID = guid
    AND DELETE_DATE IS NOT NULL;

    COMMIT;

    DELETE FROM ESOLUTIONS.SYSTEMS
    WHERE GUID = guid
    AND DELETE_DATE IS NOT NULL;

    COMMIT;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerByAttribute TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.validateServerHostName TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.insertNewServer TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateServerData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retireServer TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerCount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerList TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServerData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getRetiredServers TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerByAttribute TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.validateServerHostName TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.insertNewServer TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateServerData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retireServer TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerCount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getServerList TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServerData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getRetiredServers TO 'appadm'@'appsrv.lan' //

DELIMITER ;