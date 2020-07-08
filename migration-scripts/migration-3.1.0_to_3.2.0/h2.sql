 CREATE TABLE IF NOT EXISTS AM_KEY_MANAGER (
  UUID VARCHAR(50) NOT NULL,
  NAME VARCHAR(100) NOT NULL,
  DISPLAY_NAME VARCHAR(100) NULL,
  DESCRIPTION VARCHAR(256) NULL,
  TYPE VARCHAR(45) NULL,
  CONFIGURATION BLOB NULL,
  ENABLED BOOLEAN DEFAULT 1,
  TENANT_DOMAIN VARCHAR(100) NULL,
  PRIMARY KEY (UUID),
  UNIQUE (NAME,TENANT_DOMAIN)
  );

 CREATE TABLE IF NOT EXISTS AM_GW_PUBLISHED_API_DETAILS (
  API_ID varchar(255) NOT NULL,
  TENANT_DOMAIN varchar(255),
  API_PROVIDER varchar(255),
  API_NAME varchar(255),
  API_VERSION varchar(255),
  PRIMARY KEY (API_ID)
  );

 CREATE TABLE IF NOT EXISTS AM_GW_API_ARTIFACTS (
  API_ID varchar(255) NOT NULL,
  ARTIFACT blob,
  GATEWAY_INSTRUCTION varchar(20),
  GATEWAY_LABEL varchar(255),
  TIME_STAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (GATEWAY_LABEL, API_ID),
  FOREIGN KEY (API_ID) REFERENCES AM_GW_PUBLISHED_API_DETAILS(API_ID) ON UPDATE CASCADE ON DELETE NO ACTION
 );

CREATE ALIAS IF NOT EXISTS DROP_FK AS $$ void executeSql(Connection conn, String sql)
throws SQLException { conn.createStatement().executeUpdate(sql); } $$;

call drop_fk('ALTER TABLE AM_APPLICATION_REGISTRATION DROP CONSTRAINT ' ||
(SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINTS
WHERE TABLE_NAME = 'AM_APPLICATION_REGISTRATION' AND COLUMN_LIST  = 'SUBSCRIBER_ID,APP_ID,TOKEN_TYPE'));

call drop_fk('ALTER TABLE AM_APPLICATION_KEY_MAPPING DROP CONSTRAINT ' ||
(SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINTS
WHERE TABLE_NAME = 'AM_APPLICATION_KEY_MAPPING' AND COLUMN_LIST  = 'APPLICATION_ID,KEY_TYPE'));
DROP ALIAS IF EXISTS DROP_FK;

ALTER TABLE AM_APPLICATION_REGISTRATION ADD KEY_MANAGER VARCHAR(255) DEFAULT 'Default';
ALTER TABLE AM_APPLICATION_REGISTRATION ADD UNIQUE (SUBSCRIBER_ID,APP_ID,TOKEN_TYPE,KEY_MANAGER);


ALTER TABLE AM_APPLICATION_KEY_MAPPING ADD UUID VARCHAR(512) NULL;
UPDATE AM_APPLICATION_KEY_MAPPING SET UUID = random_uuid() WHERE UUID IS NULL;
ALTER TABLE AM_APPLICATION_KEY_MAPPING ADD KEY_MANAGER VARCHAR(512) NOT NULL DEFAULT 'Default';
ALTER TABLE AM_APPLICATION_KEY_MAPPING ADD APP_INFO BLOB;
ALTER TABLE AM_APPLICATION_KEY_MAPPING ADD PRIMARY KEY(APPLICATION_ID,KEY_TYPE,KEY_MANAGER);

ALTER TABLE AM_WORKFLOWS ADD WF_METADATA BLOB NULL;
ALTER TABLE AM_WORKFLOWS ADD WF_PROPERTIES BLOB NULL;

ALTER TABLE AM_SUBSCRIPTION ADD TIER_ID_PENDING VARCHAR(50);

ALTER TABLE AM_POLICY_SUBSCRIPTION ADD MAX_COMPLEXITY INT(11) NOT NULL DEFAULT 0;
ALTER TABLE AM_POLICY_SUBSCRIPTION ADD MAX_DEPTH INT(11) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS AM_API_RESOURCE_SCOPE_MAPPING (
    SCOPE_NAME VARCHAR(255) NOT NULL,
    URL_MAPPING_ID INTEGER NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    FOREIGN KEY (URL_MAPPING_ID) REFERENCES   AM_API_URL_MAPPING(URL_MAPPING_ID) ON DELETE CASCADE,
    PRIMARY KEY(SCOPE_NAME, URL_MAPPING_ID)
);


CREATE TABLE IF NOT EXISTS AM_SHARED_SCOPE (
     NAME VARCHAR(255),
     UUID VARCHAR (256),
     TENANT_ID INTEGER,
     PRIMARY KEY (UUID)
);

DROP TABLE IF EXISTS AM_TENANT_THEMES;
CREATE TABLE IF NOT EXISTS AM_TENANT_THEMES (
  TENANT_ID INTEGER NOT NULL,
  THEME BYTEA NOT NULL,
  PRIMARY KEY (TENANT_ID)
);
