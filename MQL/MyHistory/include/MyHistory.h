#ifndef EXPORT
#ifdef __cplusplus
#define EXPORT extern "C" __declspec(dllexport)
#endif
#ifndef __cplusplus
#define EXPORT __declspec(dllexport)
#endif
#endif

//EXPORT char* __stdcall GetLastBar(int pDebugLevel, char* pLogFile, char* UserName, char* Password, char* DBString, char* pSymbol, int pPeriod);
//EXPORT int __stdcall InsertHistory(int pDebugLevel, char* pLogFile, char* UserName, char* Password, char* DBString, char* pSymbol, int pPeriod, char* pBarCloseTime, double pOpen, double pHigh, double pLow, double pClose, double pVolume);
//EXPORT int __stdcall InsertHistory(int pDebugLevel, char* pLogFile, char* UserName, char* Password, char* DBString, char* pSymbol, int pPeriod, int* pBarCount, int* pBarTimeYY, int* pBarTimeMM, int* pBarTimeDD, int* pBarTimeHH, int* pBarTimeMI, double* pOpen, double* pHigh, double* pLow, double* pClose, double* pVolume);
EXPORT char* __stdcall GetLastBar(int pDebugLevel, char* pLogFile, void* pCtx, char* pSymbol, int pPeriod);
EXPORT int __stdcall InsertHistory(int pDebugLevel, char* pLogFileName, void* pCtx, char* pSymbol, int pPeriod, int* pBarCount, int* pBarTimeYY, int* pBarTimeMM, int* pBarTimeDD, int* pBarTimeHH, int* pBarTimeMI, double* pOpen, double* pHigh, double* pLow, double* pClose, double* pVolume);

