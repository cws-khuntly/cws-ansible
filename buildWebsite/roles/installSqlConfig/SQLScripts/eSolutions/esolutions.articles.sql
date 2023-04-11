DELIMITER //

DROP TABLE IF EXISTS ESOLUTIONS.ARTICLES //

CREATE TABLE ESOLUTIONS.ARTICLES (
    ID VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL UNIQUE,
    HITS TINYINT NOT NULL default 0,
    CREATE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    AUTHOR VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL default '',
    KEYWORDS VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL default '',
    TITLE VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL default '',
    SYMPTOMS VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL default '',
    CAUSE VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL default '',
    RESOLUTION TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    ARTICLESTATUS VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'NEW',
    REVIEWED_BY VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    REVIEW_DATE TIMESTAMP,
    MODIFIED_DATE TIMESTAMP,
    MODIFIED_BY VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    PRIMARY KEY  (ID),
    FULLTEXT KEY articles (ID, KEYWORDS, TITLE, SYMPTOMS, CAUSE, RESOLUTION)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'appsrv.lan' //
--
--
--
DROP PROCEDURE IF EXISTS ESOLUTIONS.getArticleByAttribute //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrTopArticles //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrArticle //
DROP PROCEDURE IF EXISTS ESOLUTIONS.addNewArticle //
DROP PROCEDURE IF EXISTS ESOLUTIONS.updateArticle //
DROP PROCEDURE IF EXISTS ESOLUTIONS.updateArticleStatus //
DROP PROCEDURE IF EXISTS ESOLUTIONS.getArticleCount //
DROP PROCEDURE IF EXISTS ESOLUTIONS.retrPendingArticles //

CREATE PROCEDURE ESOLUTIONS.getArticleByAttribute(
    IN searchTerms VARCHAR(100),
    IN startRow INT
)
BEGIN
    SELECT
        HITS,
        ID,
        CREATE_DATE,
        AUTHOR,
        KEYWORDS,
        TITLE,
        SYMPTOMS,
        CAUSE,
        RESOLUTION,
        ARTICLESTATUS,
        REVIEWED_BY,
        REVIEW_DATE,
        MODIFIED_DATE,
        MODIFIED_BY,
    MATCH (ID, KEYWORDS, TITLE, SYMPTOMS, CAUSE, RESOLUTION)
    AGAINST (+searchTerms WITH QUERY EXPANSION)
    FROM ESOLUTIONS.articles
    WHERE MATCH (ID, KEYWORDS, TITLE, SYMPTOMS, CAUSE, RESOLUTION)
    AGAINST (+searchTerms IN BOOLEAN MODE)
    AND ARTICLESTATUS = 'APPROVED'
    LIMIT startRow, 20;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrTopArticles(
)
BEGIN
    SELECT
        HITS,
        ID,
        CREATE_DATE,
        AUTHOR,
        KEYWORDS,
        TITLE,
        SYMPTOMS,
        CAUSE,
        RESOLUTION,
        ARTICLESTATUS,
        REVIEWED_BY,
        REVIEW_DATE,
        MODIFIED_DATE,
        MODIFIED_BY
    FROM articles
    WHERE HITS >= 10
    AND ARTICLESTATUS = 'APPROVED'
    LIMIT 15;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrArticle(
    IN articleId VARCHAR(100),
    IN isApproval BOOLEAN
)
BEGIN
    IF (isApproval)
    THEN
        SELECT
            HITS,
            ID,
            CREATE_DATE,
            AUTHOR,
            KEYWORDS,
            TITLE,
            SYMPTOMS,
            CAUSE,
            RESOLUTION,
            ARTICLESTATUS,
            REVIEWED_BY,
            REVIEW_DATE,
            MODIFIED_DATE,
            MODIFIED_BY
        FROM ESOLUTIONS.ARTICLES
        WHERE ID = articleId
        AND ARTICLESTATUS IN ('NEW', 'REVIEW');
    ELSE
        UPDATE articles
        SET HITS = HITS + 1
        WHERE ID = articleId;

        COMMIT;

        SELECT
            HITS,
            ID,
            CREATE_DATE,
            AUTHOR,
            KEYWORDS,
            TITLE,
            SYMPTOMS,
            CAUSE,
            RESOLUTION,
            ARTICLESTATUS,
            REVIEWED_BY,
            REVIEW_DATE,
            MODIFIED_DATE,
            MODIFIED_BY
        FROM ESOLUTIONS.ARTICLES
        WHERE ID = articleId
        AND ARTICLESTATUS = 'APPROVED';
    END IF;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.addNewArticle(
    IN articleId VARCHAR(45),
    IN author VARCHAR(45),
    IN keywords VARCHAR(100),
    IN title VARCHAR(100),
    IN symptoms VARCHAR(100),
    IN cause VARCHAR(100),
    IN resolution TEXT
)
BEGIN
    INSERT INTO ESOLUTIONS.ARTICLES
    (
        HITS, ID, CREATE_DATE, AUTHOR,
        KEYWORDS, TITLE, SYMPTOMS, CAUSE,
        RESOLUTION, ARTICLESTATUS
    )
    VALUES
    (
        0, articleId, CURRENT_TIMESTAMP(), author, keywords, title,
        symptoms, cause, resolution, 'NEW'
    );

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.updateArticle(
    IN articleId VARCHAR(45),
    IN keywords VARCHAR(100),
    IN title VARCHAR(100),
    IN symptoms VARCHAR(100),
    IN cause VARCHAR(100),
    IN resolution TEXT,
    IN modifiedBy VARCHAR(45),
    OUT updateCount INTEGER
)
BEGIN
    UPDATE ESOLUTIONS.ARTICLES
    SET
        KEYWORDS = keywords,
        TITLE = title,
        SYMPTOMS = symptoms,
        CAUSE = cause,
        RESOLUTION = resolution,
        MODIFIED_BY = modifiedBy,
        MODIFIED_DATE = CURRENT_TIMESTAMP(),
        ARTICLESTATUS = 'NEW'
    WHERE ID = articleId;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM ESOLUTIONS.ARTICLES
    WHERE ID = articleId
    AND KEYWORDS = keywords
    AND TITLE = title
    AND SYMPTOMS = symptoms
    AND CAUSE = cause
    AND RESOLUTION = resolution
    AND MODIFIED_BY = modifiedBy
    AND ARTICLESTATUS = 'NEW';
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.updateArticleStatus(
    IN articleId VARCHAR(45),
    IN modifiedBy VARCHAR(45),
    IN reviewedBy VARCHAR(45),
    IN articleStatus VARCHAR(15),
    OUT updateCount INTEGER
)
BEGIN
    UPDATE ESOLUTIONS.ARTICLES
    SET
        ARTICLESTATUS = articleStatus,
        MODIFIED_BY = modifiedBy,
        MODIFIED_DATE = UNIX_TIMESTAMP(),
        REVIEWED_BY = reviewedBy,
        REVIEW_DATE = UNIX_TIMESTAMP()
    WHERE ID = articleId;

    COMMIT;

    SELECT COUNT(*)
    INTO updateCount
    FROM ESOLUTIONS.ARTICLES
    WHERE ID = articleId
    AND ARTICLESTATUS = articleStatus
    AND MODIFIED_BY = modifiedBy
    AND REVIEWED_BY = reviewedBy;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.getArticleCount(
    IN reqType VARCHAR(45)
)
BEGIN
    SELECT COUNT(*)
    FROM ESOLUTIONS.ARTICLES
    WHERE ARTICLESTATUS = reqType
    AND AUTHOR != requestorId;
END //
COMMIT //

CREATE PROCEDURE ESOLUTIONS.retrPendingArticles(
    IN requestorId VARCHAR(100),
    IN startRow INT
)
BEGIN
    SELECT
        HITS,
        ID,
        CREATE_DATE,
        AUTHOR,
        KEYWORDS,
        TITLE,
        SYMPTOMS,
        CAUSE,
        RESOLUTION,
        ARTICLESTATUS,
        REVIEWED_BY,
        REVIEW_DATE,
        MODIFIED_DATE,
        MODIFIED_BY
    FROM ESOLUTIONS.ARTICLES
    WHERE ARTICLESTATUS IN ('NEW', 'REJECTED', 'REVIEW')
    AND AUTHOR != requestorId
    ORDER BY CREATE_DATE DESC
    LIMIT startRow, 20;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getArticleByAttribute TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrTopArticles TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrArticle TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.addNewArticle TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateArticle TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateArticleStatus TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getArticleCount TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrPendingArticles TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getArticleByAttribute TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrTopArticles TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrArticle TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.addNewArticle TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateArticle TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.updateArticleStatus TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.getArticleCount TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE ESOLUTIONS.retrPendingArticles TO 'appadm'@'appsrv.lan' //

DELIMITER ;
