--
-- CWSSEC / USERS
--
DELIMITER //

DROP TABLE IF EXISTS CWSSEC.USERS //

CREATE TABLE CWSSEC.USERS (
    CN VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL UNIQUE,
    UID VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    USERPASSWORD VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    CWSROLE VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '3517632B-E77F-49FF-BD99-A42EA8335DCC',
    CWSFAILEDPWDCOUNT TINYINT DEFAULT '0',
    CWSLASTLOGIN TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    CWSISSUSPENDED BOOLEAN NOT NULL DEFAULT FALSE,
    CWSISOLRSETUP BOOLEAN NOT NULL DEFAULT TRUE,
    CWSISOLRLOCKED BOOLEAN NOT NULL DEFAULT FALSE,
    CWSISTCACCEPTED BOOLEAN NOT NULL DEFAULT FALSE,
    SN VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Surname',
    GIVENNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Given Name',
    DISPLAYNAME VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Display Name',
    CWSEXPIRYDATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    AUTHTOKEN VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    CWSSECQ1 VARCHAR(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    CWSSECQ2 VARCHAR(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    CWSSECANS1 VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    CWSSECANS2 VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    CWSPUBLICKEY VARBINARY(4352),
    PRIMARY KEY (CN),
    UNIQUE KEY USERID (UID),
    INDEX IDX_USERS (CN, UID),
    FULLTEXT KEY FT_USERS (UID, CWSROLE, GIVENNAME, SN, CN)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'appsrv.lan' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'localhost' //

--
--
--
DROP PROCEDURE IF EXISTS CWSSEC.removeSessionData //
DROP PROCEDURE IF EXISTS CWSSEC.getAuthToken //
DROP PROCEDURE IF EXISTS CWSSEC.addUserAccount //
DROP PROCEDURE IF EXISTS CWSSEC.getSecurityAnswers //
DROP PROCEDURE IF EXISTS CWSSEC.getUserByAttribute //
DROP PROCEDURE IF EXISTS CWSSEC.removeUserAccount //
DROP PROCEDURE IF EXISTS CWSSEC.listUserAccounts //
DROP PROCEDURE IF EXISTS CWSSEC.showUserAccount //
DROP PROCEDURE IF EXISTS CWSSEC.modifyUserSuspension //
DROP PROCEDURE IF EXISTS CWSSEC.modifyOlrLock //
DROP PROCEDURE IF EXISTS CWSSEC.modifyUserLock //
DROP PROCEDURE IF EXISTS CWSSEC.modifyUserPassword //
DROP PROCEDURE IF EXISTS CWSSEC.addOrUpdateSecurityQuestions //
DROP PROCEDURE IF EXISTS CWSSEC.removeUserAccount //
DROP PROCEDURE IF EXISTS CWSSEC.getSecurityQuestions //
DROP PROCEDURE IF EXISTS CWSSEC.getUserPassword //
DROP PROCEDURE IF EXISTS CWSSEC.getOlrStatus //
DROP PROCEDURE IF EXISTS CWSSEC.performSuccessfulLogin //
DROP PROCEDURE IF EXISTS CWSSEC.getAuthToken //

CREATE PROCEDURE CWSSEC.addUserAccount(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN userName VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN userPass VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN userRole VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN surname VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN givenName VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN saltValue VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN saltType VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN emailAddr VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN telNumber VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN pagerNumber VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    INSERT INTO CWSSEC.USERS (CN, UID, USERPASSWORD, CWSROLE, SN, GIVENNAME, DISPLAYNAME)
    VALUES (commonName, userName, userPass, userRole, surname, givenName, CONCAT(givenName, " ", surname));

    INSERT INTO CWSSEC.CONTACT_DATA (CN, EMAIL, TELEPHONENUMBER, PAGER)
    VALUES (commonName, emailAddr, telNumber, pagerNumber);

    INSERT INTO CWSSEC.LOGON_DATA (CN, SALT, SALT_TYPE)
    VALUES (commonName, saltValue, saltType);

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getSecurityAnswers(
    IN guid VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT CWSSECANS1, CWSSECANS2
    FROM CWSSEC.USERS
    WHERE CN = guid;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getSecurityQuestions(
    IN guid VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT CWSSECQ1, CWSSECQ2
    FROM CWSSEC.USERS
    WHERE CN = guid;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getUserByAttribute(
    IN attributeName VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT
        CN,
        UID,
    MATCH (UID, CWSROLE, GIVENNAME, SN, CN)
    AGAINST (+attributeName WITH QUERY EXPANSION)
    FROM CWSSEC.USERS
    WHERE MATCH (UID, CWSROLE, GIVENNAME, SN, CN)
    AGAINST (+attributeName IN BOOLEAN MODE);
END //
COMMIT //

CREATE PROCEDURE CWSSEC.listUserAccounts(
)
BEGIN
    SELECT
        UID,
        CWSROLE,
        SN,
        GIVENNAME,
        CN
    FROM CWSSEC.USERS;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.showUserAccount(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT
        T1.UID,
        T1.CN,
        T1.CWSROLE,
        T1.CWSFAILEDPWDCOUNT,
        T1.CWSLASTLOGIN,
        T1.SN,
        T1.GIVENNAME,
        T1.CWSEXPIRYDATE,
        T1.CWSISSUSPENDED,
        T1.CWSISOLRSETUP,
        T1.CWSISOLRLOCKED,
        T1.DISPLAYNAME,
        T1.CWSISTCACCEPTED,
        T2.EMAIL
    FROM CWSSEC.USERS T1
    INNER JOIN CWSSEC.CONTACT_DATA T2
    ON T1.CN = T2.CN
    WHERE T1.CN = commonName;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.modifyUserSuspension(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN isSuspended BOOLEAN,
    OUT updateCount INTEGER
)
BEGIN
    UPDATE CWSSEC.USERS
    SET CWSISSUSPENDED = isSuspended
    WHERE CN = commonName;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND CWSISSUSPENDED = isSuspended;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.modifyOlrLock(
    IN reqUserGuid VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN isLocked BOOLEAN,
    OUT updateCount INTEGER
)
BEGIN
    UPDATE CWSSEC.USERS
    SET CWSISOLRLOCKED = isLocked
    WHERE CN = reqUserGuid;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND CWSISOLRLOCKED = isLocked;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.modifyUserLock(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN isLocked BOOLEAN,
    IN lockCount INTEGER,
    OUT updateCount INTEGER
)
BEGIN
    IF (isLocked) THEN
        UPDATE CWSSEC.USERS
        SET CWSFAILEDPWDCOUNT = 3
        WHERE CN = commonName;

        COMMIT;
    ELSE
        IF ((isLocked IS FALSE) AND (lockCount = 0)) THEN
            UPDATE CWSSEC.USERS
            SET CWSFAILEDPWDCOUNT = 0
            WHERE CN = commonName;

            COMMIT;
        ELSEIF (lockCount != 0) THEN
            UPDATE CWSSEC.USERS
            SET CWSFAILEDPWDCOUNT = lockCount
            WHERE CN = commonName;

            COMMIT;
        ELSE
            SELECT CWSFAILEDPWDCOUNT
            FROM CWSSEC.USERS
            WHERE CN = commonName
            INTO @CURRENT_COUNT;

            UPDATE CWSSEC.USERS
            SET CWSFAILEDPWDCOUNT = @CURRENT_COUNT + 1
            WHERE CN = commonName;

            COMMIT;
        END IF;
    END IF;

    IF (isLocked)
    THEN
        SELECT COUNT(*)
        FROM CWSSEC.USERS
        INTO updateCount
        WHERE CWSFAILEDPWDCOUNT = 3;
    ELSE
        SELECT COUNT(*)
        FROM CWSSEC.USERS
        INTO updateCount
        WHERE CWSFAILEDPWDCOUNT = lockCount;
    END IF;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.modifyUserPassword(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN newPassword VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN isReset BOOLEAN,
    OUT updateCount INTEGER
)
BEGIN
    IF (isReset)
    THEN
        UPDATE CWSSEC.USERS
        SET
            USERPASSWORD = newPassword,
            CWSEXPIRYDATE = CURRENT_TIMESTAMP(),
            CWSFAILEDPWDCOUNT = 0
        WHERE CN = commonName;
    ELSE
        UPDATE CWSSEC.USERS
        SET
            USERPASSWORD = newPassword,
            CWSFAILEDPWDCOUNT = 0,
            CWSEXPIRYDATE = DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
        WHERE CN = commonName;
    END IF;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND USERPASSWORD = newPassword
    AND CWSFAILEDPWDCOUNT = 0;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.addOrUpdateSecurityQuestions(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN secQuestionOne VARCHAR(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN secQuestionTwo VARCHAR(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN secAnswerOne VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN secAnswerTwo VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    OUT updateCount INTEGER
)
BEGIN
    UPDATE CWSSEC.USERS
    SET
        CWSSECQ1 = secQuestionOne,
        CWSSECQ2 = secQuestionTwo,
        CWSSECANS1 = secAnswerOne,
        CWSSECANS2 = secAnswerTwo
    WHERE CN = commonName;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND CWSSECQ1 = secQuestionOne
    AND CWSSECQ2 = secQuestionTwo
    AND CWSSECANS1 = secAnswerOne
    AND CWSSECANS2 = secAnswerTwo;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.removeUserAccount(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    DELETE FROM CWSSEC.CONTACT_DATA
    WHERE CN = commonName;

    DELETE FROM CWSSEC.RESET_DATA
    WHERE CN = commonName;

    COMMIT;

    DELETE FROM CWSSEC.LOGON_DATA
    WHERE CN = commonName;

    COMMIT;

    DELETE FROM CWSSEC.KEY_DATA
    WHERE CN = commonName;

    COMMIT;

    DELETE FROM CWSSEC.USERS
    WHERE CN = commonName;

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getUserPassword(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN userName VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT USERPASSWORD
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND UID = userName;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getOlrStatus(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN userName VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT
        CWSISOLRSETUP,
        CWSISOLRLOCKED
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND UID = userName;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.performSuccessfulLogin(
    IN userId VARCHAR(45),
    IN userGuid VARCHAR(128),
    IN authToken VARCHAR(255),
    OUT updateCount INTEGER
)
BEGIN
    UPDATE CWSSEC.USERS
    SET
        CWSLASTLOGIN = CURRENT_TIMESTAMP(),
        CWSFAILEDPWDCOUNT = 0,
        AUTHTOKEN = authToken
    WHERE CN = userGuid
    AND UID = userId;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM CWSSEC.USERS
    WHERE CN = commonName
    AND CWSSECQ1 = secQuestionOne
    AND AUTHTOKEN = authToken;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getAuthToken(
    IN userId VARCHAR(45),
    IN userGuid VARCHAR(128)
)
BEGIN
    SELECT AUTHTOKEN
    FROM CWSSEC.USERS
    WHERE CN = userGuid
    AND UID = userId;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.removeSessionData(
    IN commonName VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN authToken VARCHAR(128)  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    UPDATE CWSSEC.USERS
    SET AUTHTOKEN = ''
    WHERE CN = commonName
    AND AUTHTOKEN = authToken;

    DELETE FROM CWSSEC.LOGONDATA
    WHERE CN = commonName
    AND SALT = authToken;

    COMMIT;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE CWSSEC.removeSessionData TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getAuthToken TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.addUserAccount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getSecurityAnswers TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserByAttribute TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.removeUserAccount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.listUserAccounts TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.showUserAccount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserSuspension TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyOlrLock TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserLock TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserPassword TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.addOrUpdateSecurityQuestions TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.removeUserAccount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getSecurityQuestions TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserPassword TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getOlrStatus TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.performSuccessfulLogin TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getAuthToken TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE CWSSEC.removeSessionData TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getAuthToken TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.addUserAccount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getSecurityAnswers TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserByAttribute TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.removeUserAccount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.listUserAccounts TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.showUserAccount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserSuspension TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyOlrLock TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserLock TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.modifyUserPassword TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.addOrUpdateSecurityQuestions TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.removeUserAccount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getSecurityQuestions TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserPassword TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getOlrStatus TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.performSuccessfulLogin TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getAuthToken TO 'appadm'@'appsrv.lan' //

DELIMITER ;
