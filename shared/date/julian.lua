local julianDay = {}

local function JulianDayDiff(a,b)
   return jd.JDN(b) - jd.JDN(a)
end

local function previousYearEnd(t)
   local dt = {}
   dt.year = t.year - 1
   dt.month = 12
   dt.day = 31    
   return dt
end

-- public --
function julianDay.JDN(d)
   local A = d.year/100
   local B = A/4
   local C = 2-A+B
   local E = 365.25*(d.year+4716)
   local F = 30.6001*(d.month+1)
   return C+d.day+E+F-1524.5 
end

function julianDay.julianDayOfCurrentYear(t)   
   local function JulianDayDiff(a,b)
      return julianDay.JDN(b) - julianDay.JDN(a)
   end
   
   return JulianDayDiff(previousYearEnd(t),t)
end

local HELP_DEF=[[{
"Desc": "Calculates Julian Day in ongoing Julian Year.
",
"Returns": [
{
"Desc": "Julian Day number in current year, with fraction of last day, e.g. 245.7. <u>double</u>."
}
],
"SummaryLine": "Calculates ongoing Julian Day Number in current Year.",
"SeeAlso": [],
"Title": "julian.julianDayOfCurrentYear",
"Usage": "julian.julianDayOfCurrentYear(Data)",
"Parameters": [
{
"Data": {
"Desc": "DateTime table returned by dateparse.parse(Date) <u>table</u>. "
}
}
],
"Examples": [
"<pre>local J = julian.JulianDayOfCurrentYear(t) </pre>"
],
"ParameterTable": false
}]]

help.set{input_function=julianDay.julianDayOfCurrentYear, help_data=json.parse{data=HELP_DEF}}

local HELP_DEF=[[{
"Desc": "Calculates Julian Day in ongoing Julian Year.
",
"Returns": [
{
"Desc": "Julian Day number (JDN), with fraction of last day, e.g. 245.7. <u>double</u>."
}
],
"SummaryLine": "Calculates Julian Day Number (JDN).",
"SeeAlso": [],
"Title": "julian.JDN",
"Usage": "julian.JDN(t)",
"Parameters": [
{
"Data": {
"Desc": "DateTime table returned by dateparse.parse(Date) <u>table</u>. "
}
}
],
"Examples": [
"<pre>local J = julian.JDN(t) </pre>"
],
"ParameterTable": false
}]]

help.set{input_function=julianDay.JDN, help_data=json.parse{data=HELP_DEF}}

return julianDay