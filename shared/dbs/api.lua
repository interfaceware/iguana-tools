-- This module gives a convenient API around the DBS schema.
-- It has a method which can query a database and generate
-- the DBS schema.  DBS schema perform the same role as a vmd based table grammar
-- in allowing one to populate a set of records and use the db:merge{} function.
-- See http://help.interfaceware.com/api/#dbs_init
-- As of today the supported databases are:
-- * MySQL and MariaDB
-- * Microsoft SQL Server
-- * Oracle
-- * SQLite
-- It's relatively trivial to add support for other databases - if you need help adding support
-- for another database type please reach out.

-- http://help.interfaceware.com/v6/import-database-schema 
-- http://help.interfaceware.com/v6/manipulate-database-schema

-- We do set up some global constants
dbs.integer = 'integer'
dbs.string = 'string'
dbs.double = 'double'
dbs.datetime = 'datetime'
 
local Import = {}
-- SQLite implementation
local sqlite ={}

-- SQLite doesn't explicitly support datetime columns so the mapping is very simple.
sqlite.map = {}
sqlite.map.TEXT = 'string'
sqlite.map.BLOB = 'string'
sqlite.map.INT4 = 'integer'
sqlite.map.DOUB = 'double'
sqlite.map.REAL = 'double'
sqlite.map.INTE = 'integer' 

function sqlite.mapType(ColumnType)
   -- We convert to upper case since some SQLite databases
   -- will have PRAGMA table_info return lower case if the
   -- table was created with a different case.
   ColumnType = ColumnType:sub(1,4):upper()
   local DbsType = sqlite.map[ColumnType]
   if not DbsType then
      error('Data type '..ColumnType..' is not known')      
   end   
   return DbsType
end

function sqlite.tableDefinition(S, DB, Name)
   local Cols = DB:query{sql="PRAGMA table_info('"..Name.."')"}  
   local Table = S:table{name=Name}
   for i=1, #Cols do
      Table:addColumn{name=Cols[i].name:S(),type=sqlite.mapType(Cols[i].type:S()), key=Cols[i].pk:S() == '1'} 
   end
   return Def
end

Import[db.SQLITE] = function(S, DB, T)
   local TabResults = DB:query{sql="SELECT name FROM sqlite_master WHERE type='table'"}
   for i=1, #TabResults do
      sqlite.tableDefinition(S, DB, TabResults[i].name:S()) 
   end
end

-- End of SQLite implementation

-- Oracle Implementation

local oracle = {}
-- TODO - only a handful of data types mapped here - need to map more of them.

oracle.map ={}
oracle.map.CLOB = 'string'
oracle.map.VARCHAR2 = 'string'
oracle.map.NVARCHAR2 = 'string'
oracle.map.NUMBER   = 'integer'
oracle.map.DATE = 'datetime'
oracle.map['TIMESTAMP(6)'] = 'datetime'
oracle.map.FLOAT = 'double'

local ORACLE_SQL_DESCRIBE = [[
select COLUMN_NAME, DATA_TYPE from ALL_TAB_COLUMNS where TABLE_NAME='#TABLENAME#'
]]

local ORACLE_SQL_KEYS =[[
SELECT cols.table_name, cols.column_name, cols.position, cons.status, cons.owner
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = '#TABLENAME#'
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
ORDER BY cols.table_name, cols.position
]]

function oracle.mapType(ColumnType)
   local DbsType = oracle.map[ColumnType]
   if not DbsType then
      error('Data type '..ColumnType..' is not known')      
   end   
   return DbsType
end

function oracle.tableDefinition(S, DB, Name)
   local Sql = ORACLE_SQL_DESCRIBE:gsub("#TABLENAME#", Name)
   local Cols = DB:query{sql=Sql}  
   local Columns = {}
   for i=1, #Cols do
      local Column = {}
      Columns[i] = Column
      Column.name = Cols[i]["COLUMN_NAME"]:S()
      Column.type = oracle.mapType(Cols[i]["DATA_TYPE"]:S())
      Column.key = false 
   end
   Sql = ORACLE_SQL_KEYS:gsub("#TABLENAME#", Name)
   local Keys = DB:query{sql=Sql}
   -- Oracle performance is NxN - oh well - Oracle
   -- had to be the only database to not offer a way
   -- to query which columns were primary keys in the
   -- same query as the list of columns for a table
   for i=1, #Keys do
      local KeyColumn = Keys[1].COLUMN_NAME:S()
      for j=1, #Columns do
         if Columns[j].name == KeyColumn then
            Columns[j].key = true
         end
      end
   end
   local T = S:table{name=Name}
   for i=1, #Columns do 
      local Column = Columns[i]
      T:addColumn(Column)
   end   
end

Import[db.ORACLE_OCI] = function(S, DB, T)
   local TabResults = DB:query{sql="select * from user_tables"}
   for i=1, #TabResults do
      oracle.tableDefinition(S, DB, TabResults[i].TABLE_NAME:S()) 
   end
end

Import[db.ORACLE_ODBC] = Import[db.ORACLE_OCI]

-- End of Oracle Implementation

-- SQL SERVER
local sqlserver = {}
sqlserver.dataMap = {}
sqlserver.dataMap.tinyint    = 'integer'
sqlserver.dataMap.smallint   = 'integer'
sqlserver.dataMap.int        = 'integer'
sqlserver.dataMap.bigint     = 'integer'
sqlserver.dataMap.numeric    = 'integer'
sqlserver.dataMap.decimal    = 'integer'
sqlserver.dataMap.bit        = 'integer'
sqlserver.dataMap.smallmoney = 'integer'
sqlserver.dataMap.money      = 'integer'

sqlserver.dataMap.varchar    = 'string'
sqlserver.dataMap.char       = 'string'
sqlserver.dataMap.text       = 'string'
sqlserver.dataMap.nchar      = 'string'
sqlserver.dataMap.nvarchar   = 'string'
sqlserver.dataMap.ntext      = 'string'

sqlserver.dataMap.datetime       = 'datetime'
sqlserver.dataMap.date           = 'datetime'
sqlserver.dataMap.datetimeoffset = 'datetime'
sqlserver.dataMap.datetime2      = 'datetime'
sqlserver.dataMap.smalldatetime  = 'datetime'
sqlserver.dataMap.time           = 'datetime'

sqlserver.dataMap.float = 'double'
sqlserver.dataMap.real = 'double'

function sqlserver.mapType(ColumnType)
   local DbsType = sqlserver.dataMap[ColumnType]
   if not DbsType then
      error('Data type '..ColumnType..' is not known')      
   end   
   return DbsType
end

local SQL_SERVER_DESCRIBE=[[SELECT 
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE
    c.object_id = OBJECT_ID('#TABLENAME#')]]

function sqlserver.tableDefinition(S, DB, Name)
   local Sql = SQL_SERVER_DESCRIBE:gsub("#TABLENAME#", Name)
   local Cols = DB:query{sql=Sql}  
   local T = S:table{name=Name}
   for i=1, #Cols do
      local Column = {}
      Column.name = Cols[i]["Column Name"]
      Column.type = sqlserver.mapType(Cols[i]["Data type"]:S())
      Column.key = Cols[i]["Primary Key"]:S() ~= '0' 
      T:addColumn(Column)
   end
end

Import[db.SQL_SERVER] = function(S, DB, T)
   local TabResults = DB:query{sql="SELECT * FROM sys.Tables"}
   local Tables = {}
   for i=1, #TabResults do
      sqlserver.tableDefinition(S, DB, TabResults[i].name:S()) 
   end
   return Tables
end

-- End oF SQL SERVER

-- Start of MySQL 
local mysql = {}
-- Mappings of native MySQL types to the few built in types
mysql.dataMap = {}
mysql.dataMap.int     = 'integer'
mysql.dataMap.tinyint = 'integer'

mysql.dataMap.varchar    = 'string'
mysql.dataMap.enum       = 'string'
mysql.dataMap.text       = 'string'
mysql.dataMap.longtext   = 'string'
mysql.dataMap.mediumblob = 'string'

mysql.dataMap.datetime  = 'datetime'
mysql.dataMap.date      = 'datetime'
mysql.dataMap.timestamp = 'datetime'

mysql.dataMap.float = 'double'

function mysql.mapType(DataType)
   if (DataType:find("%(")) then
      DataType = DataType:split("(")[1]   
   end
   local DbsType = mysql.dataMap[DataType]
   if not DbsType then
      error('Data type '..DataType..' is not known')      
   end   
   return DbsType
end

function mysql.tableDefinition(S, DB, Name)
   local TInfo = DB:query{sql="DESCRIBE "..Name}
   local Table = S:table{name=Name}
   for i=1, #TInfo do
      Table:addColumn{name=TInfo[i].Field:S(), type=mysql.mapType(TInfo[i].Type:S()),key=#TInfo[i].Key:S()>0}
   end
   return Table
end

Import[db.MY_SQL] = function(S,DB, T)
   local TabResults = DB:query{sql="SHOW TABLES"}
   for i=1, #TabResults do
       mysql.tableDefinition(S, DB, TabResults[i][1])      
   end
   return Tables
end

-- Support for Maria DB is easy!
Import[db.MARIA_DB] = Import[db.MY_SQL]

-- End of MYSQL

local tablemethod = {}
local tablemeta   = {__index=tablemethod}

local LegalType={
   integer=true,
   string =true,
   double=true,
   datetime=true
}

function tablemethod.addColumn(S,T)
   local IsKey = T.key or false
   if not T.type then 
      error("The type argument is required.", 2)
   end
   if not LegalType[T.type] then 
      error("The column type of "..T.type.." is illegal. It must be integer, string, double or datetime.",2)
   end
   S.columns[#S.columns+1] = {name = T.name, type=T.type, key=IsKey}
end

local Help = {
   Title="table:addColumn",
   Usage="Table:addColumn{name=&lt;column name&gt;, type=&lt;data type&gt;, key=&lt;true|false&gt;}",
   ParameterTable=true,
   Parameters={
      {name={Desc="Name of the column to add <u>string</u>."}},
      {type={Desc="Data type of the column to add <u>string</u>."}},
      {key={Desc="Set to true is this column is a key column (default = false) <u>boolean</u>.", Opt=true}},
   },
   Returns={},
   Examples={[[-- create a new non-key column
Table:addColumn{name='LastName', type='string'}"]],
      [[-- create a new key column
Table:addColumn{name='PatientId', type='integer', key=true}"]]},
   Desc="Adds a column to a table definition."
}

help.set{input_function=tablemethod.addColumn,help_data=Help}

local method = {}
local meta={__index=method}

function method.table(S, T)
   if not S.tables[T.name] then
      S.tables[T.name] = {name=T.name, columns={}}
      setmetatable(S.tables[T.name], tablemeta)
   end
   return S.tables[T.name]
end

local Help = {
   Title="schema:table",
   Usage="schema:table{name=&lt;table name&gt;}",
   ParameterTable=true,
   Parameters={
      {name={Desc="Name of the table <u>string</u>."}},
   },
   Returns={{Desc="Schema definition of the added table <u>table</u>."}},
   Examples={[[-- add definition for existing table "Invoice"
   Schema:table{name='Invoice'}]],
      [[-- add empty definition for new table "Patient"
Schema:table{name='Patient'},
]]},
   Desc="Fetch a table definition from a database connection and add it to schema, if the table does not exist in the database an empty definition is created."
}

help.set{input_function=method.table,help_data=Help}

local function TableDef(N, C)
   if #C.columns == 0 then return '' end
   local R = "create table ["..N.."](\n"
   local K = ''
   for i=1, #C.columns do
      local Column = C.columns[i]
      R = R.."   ["..Column.name..'] '..Column.type..',\n'
      if Column.key then
         K = K.."["..Column.name.."],"
      end
   end
   trace(K)
   if #K > 0 then
      R = R.."   key("..K:sub(1, #K-1)..")\n);\n\n"
   else
      R = R:sub(1, #R-2).."\n);\n\n"
   end
   return R
end

local function GroupDef(N, C)
   local R = 'group ['..N..'] ('
   for i=1, #C do
      R = R..'['..C[i]..']'
      if i == #C then
         R = R..");\n"
      else
         R = R..","   
      end
   end
   return R
end

function method.clear(S, T)
   S.tables = {}
end

local Help = {
   Title="schema:clear",
   Usage="Schema:clear{}",
   ParameterTable=true,
   Parameters={},
   Returns={},
   Examples={[[-- clear the schema
Schema:clear{}]]},
   Desc="Clears the schema."
}

help.set{input_function=method.clear,help_data=Help}

function method.import(S, T)
   local Count = 0
   for K in pairs(S.tables) do 
      Count = Count + 1
   end
   local DB = T.connection
   if not Import[DB:info().api] then
      error("Data base with API "..DB:info().api.." type is not supported.",2)   
   end
   Import[DB:info().api](S,DB)
   local NewCount = 0
   for K in pairs(S.tables) do 
      NewCount = NewCount + 1
   end
   if NewCount - Count == 0 then
      return "WARNING - no tables imported."
   end
   return NewCount-Count.." tables were imported."
end

local Help = {
   Title="schema:import",
   Usage="Schema:import{connection=<DB connection>}",
   ParameterTable=true,
   Parameters={
      {connection={Desc="Live database connection <u>db_connection object</u>."}}
   },
   Returns={{Desc="Message indicating the number of tables imported <u>string</u>."}},
   Examples={[[-- import table schemas from a database
Schema:import{connection=DB} ]]},
   Desc="Queries the given database connection to create a set of schemas matching the tables in the database."
}

help.set{input_function=method.import,help_data=Help}


function method.addGroup(S, T)
   S.groups[T.name] = T.table_list
end

local Help = {
   Title="schema:addGroup",
   Usage="Schema:addGroup{name=&lt;group name&gt;, table_list&lt;array of tables&gt;}",
   ParameterTable=true,
   Parameters={
      {name={Desc="Name of the group to add."}},
      {table_list={Desc="Table array of tables to contain in the group."}},
   },
   Returns={},
   Examples={[[-- import table schemas from a database
Schema:addGroup{name = "My new Group", table_list = NewGroupTables;} ]]},
   Desc="Adds a table group to the schema."
}

help.set{input_function=method.addGroup, help_data=Help}


function method.dbs(S)
   local R = ''
   for N,C in pairs(S.tables) do 
      R = R..TableDef(N, C)
   end
   for N,G in pairs(S.groups) do
      R = R..GroupDef(N,G)
   end
   return R
end

local Help = {
   Title="schema:dbs",
   Usage="Schema:dbs()",
   Examples={[[
-- Generate DBS schema
local DbsSchema = Schema:dbs()
-- NOTE: The curly brace syntax also works
local DbsSchema = Schema:dbs{}
      
-- Initialize DBS instance off the grammar
local D = dbs.init{definition=Def}
      
-- Produce a recordset from the DBS instance
local Records = D:tables()  
]]},
   ParameterTable=false,
   Parameters={},
   Returns={{Desc="The generated DBS schema <u>string</u>."}},
  Desc="Generates DBS schema from the definitions given."
}

help.set{input_function=method.dbs,help_data=Help}

function method.tableList(S)
   local List = {}
   for K in pairs(S.tables) do
      List[#List + 1 ] = K
   end
   return List
end

local Help = {
   Title="schema:tableList",
   ParameterTable=false,
   Usage="Schema:tableList()",
   Parameters={},
   Returns={
      {Desc="List of tables <u>table</u>."}
   },
   Examples={[[-- list the tables in the schema
local List = Schema:tableList()]]},
   Desc="Gets a list of the names of the tables defined in the schema."
}

help.set{input_function=method.tableList,help_data=Help}

local function NewSchema()
   local S = {}
   S.tables = {}
   S.groups = {}
   setmetatable(S, meta)
   return S
end

local Help = {
   Title="NewSchema",
   Usage="NewSchema()",
   ParameterTable=false,
   Parameters={},
   Returns={
      {Desc="Empty database schema <u>table</u>."}
   },
   Examples={[[-- create an empty schema
local Schema = NewSchema()]]},
   Desc="Creates an empty database schema table, with various functions for working with databases, creating a DBS file, etc.",
   SeeAlso={
      {
         Title="Import Database Schema",
         Link="http://help.interfaceware.com/v6/import-database-schema"
      },
      {
         Title="Source code for the dbs.api.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/dbs/api.lua"
      }
   },
}

help.set{input_function=NewSchema, help_data=Help}

return NewSchema
