set MQLPATH=C:\Users\gcaglion\AppData\Roaming\MetaQuotes\Terminal\91B85E7C52B57BF365F85A909F61CC9C

del %MQLPATH%\MQL5\Scripts\downloadRates.mq5
mklink /H %MQLPATH%\MQL5\Scripts\downloadRates.mq5 MQL\MT5RatesDownload\downloadRates.mq5
