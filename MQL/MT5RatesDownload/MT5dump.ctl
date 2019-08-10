load data 
infile 'c:\temp\EURUSD_H1_fix.csv' 
append into table eurusd_h1_mt5 fields terminated by "," (OrigDate, OrigTime, Open, High, Low, Close, NewDateTime expression "to_date((:OrigDate||:OrigTime),'YYYY.MM.DD.HH24:MI')") 
