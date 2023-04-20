CREATE TABLE Object (
  objectid NUMBER NOT NULL,
  timest timestamp,
  versioninfo varchar2(30),
  isclosed NUMBER(1) DEFAULT 0,
  isextension NUMBER(1) DEFAULT 0,
  name varchar2(50),
  defbody clob,
  metadata clob,
  userid NUMBER DEFAULT NULL,
  basedon NUMBER DEFAULT NULL,
  type varchar2(20),
  infoid NUMBER,
  PRIMARY KEY (objectid)
);
CREATE SEQUENCE Object_seq;
CREATE TABLE Method (
  methodid NUMBER NOT NULL,
  timest timestamp,
  versioninfo varchar2(30),
  name varchar2(50),
  category varchar2(50),
  objectname varchar2(50),
  basedon NUMBER DEFAULT NULL,
  userid NUMBER DEFAULT NULL,
  body clob,
  type varchar2(20),
  infoid NUMBER,
  PRIMARY KEY (methodid)
);
CREATE SEQUENCE Method_seq;
CREATE TABLE ObjectMethod (
  objectid NUMBER NOT NULL,
  methodid NUMBER NOT NULL,
  PRIMARY KEY (objectid,methodid)
);
CREATE TABLE Component (
  componentid NUMBER NOT NULL,
  timest timestamp,
  versioninfo varchar2(30),
  isclosed NUMBER(1) DEFAULT 0,
  name varchar2(50),
  userid NUMBER DEFAULT NULL,
  defcounter NUMBER DEFAULT 0,
  basedon NUMBER DEFAULT NULL,
  infoid NUMBER,
  PRIMARY KEY (componentid)
);
CREATE SEQUENCE Component_seq;
CREATE TABLE ComponentObject (
  componentid NUMBER NOT NULL,
  objectid NUMBER NOT NULL,
  deforder NUMBER,
  PRIMARY KEY (componentid,objectid)
);
CREATE TABLE ComponentRequire (
  componentid NUMBER NOT NULL,
  name varchar2(50)
);
CREATE TABLE Userlib (
  userid NUMBER NOT NULL,
  name varchar2(30),
  longname varchar2(60),
  PRIMARY KEY (userid)
);
CREATE SEQUENCE Userlib_seq;
CREATE TABLE Info (
  infoid NUMBER NOT NULL,
  infotext clob,
  PRIMARY KEY (infoid)
);
CREATE SEQUENCE Info_seq;
CREATE TABLE Configmap (
  configmapid NUMBER NOT NULL,
  name varchar2(50),
  timest timestamp,
  versioninfo varchar2(30),
  isclosed NUMBER(1) DEFAULT 0,
  userid NUMBER DEFAULT NULL,
  basedon NUMBER DEFAULT NULL,
  prescript clob,
  postscript clob,
  infoid NUMBER,
  PRIMARY KEY (configmapid)
);
CREATE SEQUENCE Configmap_seq;
CREATE TABLE ConfigmapComponent (
  configmapid NUMBER NOT NULL,
  componentid NUMBER NOT NULL,
  loadorder float,
  PRIMARY KEY (configmapid,componentid)
);
CREATE TABLE ConfigmapChildren (
  configmapid NUMBER NOT NULL,
  configmapchildid NUMBER NOT NULL,
  loadorder float,
  PRIMARY KEY (configmapid,configmapchildid)
);
