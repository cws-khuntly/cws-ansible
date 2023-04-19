DELIMITER //

DROP TABLE IF EXISTS ESOLUTIONS.SVCMESSAGING //

CREATE TABLE ESOLUTIONS.SVCMESSAGING (
    ID VARCHAR(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL UNIQUE,
    TITLE VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    MESSAGE TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    AUTHOR VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SUBMIT_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ISACTIVE BOOLEAN NOT NULL DEFAULT TRUE,
    ALERT BOOLEAN NOT NULL DEFAULT FALSE,
    EXPIRES BOOLEAN NOT NULL DEFAULT FALSE,
    EXPIRES_ON TIMESTAMP,
    MODIFIED_ON TIMESTAMP,
    MODIFIED_BY VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    PRIMARY KEY (ID, TITLE), -- prevent the same message from being submitted twice (we hope)
    FULLTEXT KEY FTK_svcMessages (ID, TITLE, MESSAGE, AUTHOR)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'appsrv.lan' //

DROP PROCEDURE IF EXISTS ESOLUTIONS.getMessagesByAttribute //
DROP PROCEDURE IF EXISTS ESOLUTIONS.submitSvcMessage //
DROP PROCEDURE IF EXISTS ESOLUTIONS.updateServiceMessage //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrServiceMessage //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrServiceMessages //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrAlertMessages //

CREATE PROCEDURE ESOLUTIONS.getMessagesByAttribute(
    IN searchTerms VARCHAR(100)
)
BEGIN
    SELECT
        ID,
        TITLE,
        MESSAGE,
        AUTHOR,
        SUBMIT_DATE,
        ISACTIVE,
        ALERT,
        EXPIRES,
        EXPIRES_ON,
        MODIFIED_ON,
        MODIFIED_BY,
    MATCH (ID, TITLE, MESSAGE, AUTHOR)
    AGAINST (+searchTerms WITH QUERY EXPANSION)
    FROM ESOLUTIONS.SVCMESSAGING
    WHERE MATCH (ID, TITLE, MESSAGE, AUTHOR)
    AGAINST (+searchTerms IN BOOLEAN MODE)
    AND ISACTIVE  = TRUE
    AND (EXPIRES_ON > NOW() OR EXPIRES_ON = '0000-00-00 00:00:00' OR EXPIRES = FALSE)
    ORDER BY ID DESC;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.submitSvcMessage(
    IN messageId VARCHAR(128),
    IN messageTitle VARCHAR(100),
    IN messageText TEXT,
    IN messageAuthor VARCHAR(45),
    IN isActive BOOLEAN,
    IN isAlert BOOLEAN,
    IN expiry BOOLEAN,
    IN expiryDate BIGINT
)
BEGIN
    INSERT INTO ESOLUTIONS.SVCMESSAGING
    (ID, TITLE, MESSAGE, AUTHOR, SUBMIT_DATE, ISACTIVE , ALERT, EXPIRES, EXPIRES_ON)
    VALUES
    (messageId, messageTitle, messageText, messageAuthor, NOW(), isActive, isAlert, expiry, expiryDate);

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.updateServiceMessage(
    IN messageId VARCHAR(128),
    IN messageTitle VARCHAR(100),
    IN messageText TEXT,
    IN isActive BOOLEAN,
    IN isAlert BOOLEAN,
    IN expiry BOOLEAN,
    IN expiryDate BIGINT,
    IN modifyAuthor VARCHAR(45),
    OUT updateCount INTEGER
)
BEGIN
    UPDATE ESOLUTIONS.SVCMESSAGING
    SET
        TITLE = messageTitle,
        MESSAGE = messageText,
        ISACTIVE  = isActive,
        ALERT = isAlert,
        EXPIRES = expiry,
        EXPIRES_ON = expiryDate,
        MODIFIED_ON = NOW(),
        MODIFIED_BY = modifyAuthor
    WHERE ID = messageId;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM ESOLUTIONS.SVCMESSAGING
    WHERE ID = messageId
    AND TITLE = messageTitle
    AND MESSAGE = messageText
    AND ISACTIVE  = isActive
    AND ALERT = isAlert
    AND EXPIRES = expiry
    AND EXPIRES_ON = expiryDate
    AND MODIFIED_ON = CURRENT_TIMESTAMP()
    AND MODIFIED_BY = modifyAuthor;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrServiceMessage(
    IN requestId VARCHAR(45)
)
BEGIN
    SELECT
        ID,
        TITLE,
        MESSAGE,
        AUTHOR,
        SUBMIT_DATE,
        ISACTIVE,
        ALERT,
        EXPIRES,
        EXPIRES_ON,
        MODIFIED_ON,
        MODIFIED_BY
    FROM ESOLUTIONS.SVCMESSAGING
    WHERE ID = requestId;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrServiceMessages(
)
BEGIN
    SELECT
        ID,
        TITLE,
        MESSAGE,
        AUTHOR,
        SUBMIT_DATE,
        ISACTIVE,
        ALERT,
        EXPIRES,
        EXPIRES_ON,
        MODIFIED_ON,
        MODIFIED_BY
    FROM ESOLUTIONS.SVCMESSAGING
    WHERE ISACTIVE  = TRUE
    AND ALERT = FALSE
    AND (EXPIRES_ON > NOW() OR EXPIRES_ON = '0000-00-00 00:00:00' OR EXPIRES = FALSE)
    ORDER BY ID DESC;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrAlertMessages(
)
BEGIN
    SELECT
        ID,
        TITLE,
        MESSAGE,
        AUTHOR,
        SUBMIT_DATE,
        ISACTIVE,
        ALERT,
        EXPIRES,
        EXPIRES_ON,
        MODIFIED_ON,
        MODIFIED_BY
    FROM ESOLUTIONS.SVCMESSAGING
    WHERE ISACTIVE  = TRUE
    AND ALERT = TRUE
    AND (EXPIRES_ON > NOW() OR EXPIRES_ON = '0000-00-00 00:00:00' OR EXPIRES = FALSE)
    ORDER BY ID DESC;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getMessagesByAttribute TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.submitSvcMessage TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateServiceMessage TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServiceMessage TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServiceMessages TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrAlertMessages TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getMessagesByAttribute TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.submitSvcMessage TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateServiceMessage TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServiceMessage TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrServiceMessages TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrAlertMessages TO 'appadm'@'appsrv.lan' //

DELIMITER ;