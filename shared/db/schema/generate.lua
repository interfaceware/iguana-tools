-- db.schema.generate - See http://help.interfaceware.com/v6/import-database-schema 
-- This channel shows the use of a module which can query a database and generate
-- a DBS schema file.  DBS schema perform the same role as a vmd based table grammar
-- in allowing one to populate a set of records and use the db:merge{} function.
-- See http://help.interfaceware.com/api/#dbs_init
-- As of today the supported databases are:
-- * MySQL and MariaDB
-- * Microsoft SQL Server
-- * Oracle
-- * SQLite
-- It's relatively trivial to add support for other databases - if you need help adding support
-- for another database type please reach out.

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

function sqlite.mapType(ColumnType)
   ColumnType = ColumnType:sub(1,4)
   local DbsType = sqlite.map[ColumnType]
   if not DbsType then
      error('Data type '..ColumnType..' is not known')      
   end   
   return DbsType
   
end


function sqlite.tableDefinition(DB, Name)
   local Cols = DB:query{sql="PRAGMA table_info('"..Name.."')"}  
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #Cols do
      local Column = {}
      Def.columns[i] = Column
      Column.name = Cols[i].name
      Column.type = sqlite.mapType(Cols[i].type:S())
      Column.key = Cols[i].pk:S() == '1' 
   end
   return Def
end


Import[db.SQLITE] = function(DB, T)
   local TabResults = DB:query{sql="SELECT name FROM sqlite_master WHERE type='table'"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = sqlite.tableDefinition(DB, TabResults[i].name:S()) 
   end
   return Tables
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

function oracle.tableDefinition(DB, Name)
   local Sql = ORACLE_SQL_DESCRIBE:gsub("#TABLENAME#", Name)
   local Cols = DB:query{sql=Sql}  
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #Cols do
      local Column = {}
      Def.columns[i] = Column
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
      for j=1, #Def.columns do
         if Def.columns[j].name == KeyColumn then
            Def.columns[j].key = true
         end
      end
   end
   
   return Def
end

Import[db.ORACLE_OCI] = function(DB, T)
   local TabResults = DB:query{sql="select * from user_tables"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = oracle.tableDefinition(DB, TabResults[i].TABLE_NAME:S()) 
   end
   return Tables
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

function sqlserver.tableDefinition(DB, Name)
   local Sql = SQL_SERVER_DESCRIBE:gsub("#TABLENAME#", Name)
   local Cols = DB:query{sql=Sql}  
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #Cols do
      local Column = {}
      Def.columns[i] = Column
      Column.name = Cols[i]["Column Name"]
      Column.type = sqlserver.mapType(Cols[i]["Data type"]:S())
      Column.key = Cols[i]["Primary Key"]:S() ~= '0' 
     -- local Key = TInfo[i].Key
     -- Column.key = #Key:S() > 0 
   end
   return Def
end

Import[db.SQL_SERVER] = function(DB, T)
   local TabResults = DB:query{sql="SELECT * FROM sys.Tables"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = sqlserver.tableDefinition(DB, TabResults[i].name:S()) 
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

function mysql.tableDefinition(DB, Name)
   local TInfo = DB:query{sql="DESCRIBE "..Name}
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #TInfo do
      local Column = {}
      Def.columns[i] = Column
      Column.name = TInfo[i].Field
      Column.type = mysql.mapType(TInfo[i].Type:S())
      local Key = TInfo[i].Key
      Column.key = #Key:S() > 0 
   end
   return Def
end

Import[db.MY_SQL] = function(DB, T)
   local TabResults = DB:query{sql="SHOW TABLES"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = 
         mysql.tableDefinition(DB, TabResults[i].Tables_in_CRM:S())      
   end
   return Tables
end

-- Support for Maria DB is easy!
Import[db.MARIA_DB] = Import[db.MY_SQL]

-- End of MYSQL


local function GenerateDbsTable(Def)
   local R = "create table ["..Def.name .. "](\n"
   local K = ''
   for i=1, #Def.columns do
      local Column = Def.columns[i]
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

local function Generate(DB)
   if not Import[DB:info().api] then
      error("Data base with API "..DB:info().api.." type is not supported.",2)   
   end
   local Dbs = {}
   local TableDefs = Import[DB:info().api](DB)
   for i=1, #TableDefs do
      Dbs[i] = GenerateDbsTable(TableDefs[i])
   end
   local Result = table.concat(Dbs)
   return Result
end


return Generate