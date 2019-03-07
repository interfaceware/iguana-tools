local CachedLookups = {}
local PurgeTimes    = {}  

local function Purge()
   local Now = os.ts.time()
   
   for i=1,#PurgeTimes do
      trace(PurgeTimes[i])
      if #PurgeTimes > 0 
         and PurgeTimes[i] ~= nil 
         and PurgeTimes[i].PurgeTime ~= nil 
         and PurgeTimes[i].PurgeTime <= Now then

         CachedLookups[PurgeTimes[i].CacheKey] = nil
         table.remove(PurgeTimes,i)
      else
         break
      end
   end
end

local function GetData(Sql, Conn, Value)
   if (Value) then 
      Sql = Sql:gsub("#VALUE#", Conn:quote(Value))
   end
   
   local ResultSet = Conn:query{sql=Sql}
   if #ResultSet == 0 then
      return false  
   end
   
   return ResultSet
end

local function Cache(Args)
   Purge()
   
   Args.default = Args.default or false
   Args.max_age = Args.max_age or 60*60
   
   local CacheKey  = Args.sql..":"..(Args.value or '')
   local PurgeTime = Args.max_age + os.ts.time()

   if CachedLookups[CacheKey] == nil then
      CachedLookups[CacheKey] = GetData(Args.sql, Args.db, Args.value, Args.default)
      
      if #PurgeTimes == 0 then
         table.insert(PurgeTimes,{['PurgeTime']=PurgeTime,['CacheKey']=CacheKey})
      else
         for i=#PurgeTimes, 1, -1 do
            if PurgeTimes[i].PurgeTime <= PurgeTime then
               table.insert(PurgeTimes,i+1,{['PurgeTime']=PurgeTime,['CacheKey']=CacheKey})
               break
            elseif i==1 then
               table.insert(PurgeTimes,i,{['PurgeTime']=PurgeTime,['CacheKey']=CacheKey})
            end
         end
      end
   end

   return CachedLookups[CacheKey] or Args.default
end

local function ListCache()
   return CachedLookups, PurgeTimes
end

local function Reset()
   CachedLookups = {}
   PurgeTimes    = {}
end

local HelpData =[[
{
   "Returns": [
      {
         "Desc": "The resultset from your query or false if there are no results <u>resultset node tree</u> or <u>boolean</u>."
      }
   ],
   "Title": "db.querycache",
   "Parameters": [
      {
         "sql": {
            "Desc": "The SQL query you would like to run. <u>string</u>"
         }
      },
      {
         "db": {
            "Desc": "Active database connection to look up data from. <u>db_connection object</u>"
         }
      },
      {
         "value": {
            "Opt": true,
            "Desc": "Value to substitute in place of \"#VALUE#\" in the SQL query. <u>string</u>"
         }
      },
      {
         "default": {
	         "Opt": true,
            "Desc": "Value to return if the query returns no results (default <u>boolean</u> false)"
         }
      },

      {
         "max_age": {
            "Opt": true,
            "Desc": "Max age in seconds (default 1 hour). <u>number</u>"
         }
      }
   ],
   "ParameterTable": true,
   "Usage": "db.querycache{sql, db [, value, default, max_age]}",
   "Examples": [
      "db.querycache{sql='SELECT * FROM Users WHERE USERID=#VALUE#',db=CONN,value=21,default='n/a',max_age=60*5}"
   ],
   "Desc": "Caches your SQL query in Lua memory. This can greatly improve the performance of high traffic interfaces that need to interract with a database.",
}]]

help.set{input_function=Cache, help_data=json.parse{data=HelpData}}


return {query=Cache,list=ListCache,clear=Reset}