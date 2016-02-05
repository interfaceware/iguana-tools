-- In accounting we often talk about the "Financial Year" of a company.
-- This is the when the company finishes it's year for tax purposes.
-- For instance the financial year of a company might begin at the
-- start of April and end at the end of March.

-- It's useful for reporting to be able to translate dates into the financial
-- year.  This module is a simple example of doing this.

local calendar_financial=require 'calendar_financial'

require 'encrypt.password'

function main()
   -- Let's say our financial year is February - then we start_month=2
   -- See the results for the months of the year.
   calendar_financial.convert{time=os.ts.time{year=2016,month=1,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=2,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=3,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=4,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=5,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=6,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=7,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=8,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=9,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=10,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=11,day=1}, start_month=2}
   calendar_financial.convert{time=os.ts.time{year=2016,month=12,day=1}, start_month=2}

   -- Let's say our financial year is June - then we start_month=6
   -- See the results for the months of the year.
   calendar_financial.convert{time=os.ts.time{year=2016,month=1, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=2, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=3, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=4, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=5, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=6, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=7, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=8, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=9, day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=10,day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=11,day=1}, start_month=6}
   calendar_financial.convert{time=os.ts.time{year=2016,month=12,day=1}, start_month=6}
end