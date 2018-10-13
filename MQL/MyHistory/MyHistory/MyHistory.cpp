#include "stdlib.h"
#include "stdio.h"
#include "sqlca.h"
#include "windows.h"
#include "time.h"

#include <MyGA.h>
#include <MyUtils.h>
#include <MyProCSubs.h>

#define MAX_THREADS	20

char* PeriodToTF(int p){
	if (p == 1) return "M1";
	else if (p == 5) return "M5";
	else if (p == 15) return "M15";
	else if (p == 30) return "M30";
	else if (p == 60) return "H1";
	else if (p == 240) return "H4";
	else if (p == 1440) return "D1";
	else if (p == 10080) return "W1";
	else return 0;
}

EXPORT char* __stdcall GetLastBar(int pDebugLevel, char* pLogFile, sql_context pCtx, char* pSymbol, int pPeriod){
	int vDebug;
	char stmt[1000];
	char vSymbol[12];
	char vLastBar[20];
	char* ret=(char*)malloc(20);
	int vpScale;
	int retval;
	FILE* LogFile;
	sql_context vCtx = pCtx;	//NULL;

	vDebug = pDebugLevel;
	LogFile = fopen(pLogFile, "a");

	//--- 0. First, Connect
	//retval = OraConnect(UserName, Password, DBString, pDebugLevel, LogFile, &vCtx);
	//if (retval != 0) return NULL;

	//--- 1. Then, convert Symbol  by looking it up in SYMBOL_LOOKUP
	SymbolLookup(vDebug, LogFile, vCtx, pSymbol, vSymbol, &vpScale);
	if (strlen(vSymbol) == 0){
		MyLogWrite(pDebugLevel, LogFile, "%s GetLastBar: Symbol %s could not be found in HISTORY.SYMBOL_LOOKUP table. Exiting.\n", 2, timestamp(), pSymbol);
		fclose(LogFile);
		return(NULL);
	}
	//--- 2. Then, build and execute query to retrieve last NewDateTime from the <Symbol_Timeframe> table
	strcpy(stmt, "select to_char(nvl(max(NewDateTime),to_date('01011990','DDMMYYYY')),'YYYY.MM.DD HH24:MI') from ");
	strcat(stmt, vSymbol);
	strcat(stmt, "_");
	strcat(stmt, PeriodToTF(pPeriod));

	MyLogWrite(pDebugLevel, LogFile, "%s GetLastBar executing: %s\n", 2, timestamp(), stmt);

	retval=GetCharPFromQuery(pDebugLevel, LogFile, vCtx, stmt, vLastBar); 
	strcpy(ret, vLastBar);
	if (retval<0){
		return NULL;
	} else{
		return ret;
	}
}

EXPORT int __stdcall InsertHistory(int pDebugLevel, char* pLogFileName, void* pCtx, char* pSymbol, int pPeriod, int* pBarCount, int* pBarTimeYY, int* pBarTimeMM, int* pBarTimeDD, int* pBarTimeHH, int* pBarTimeMI, double* pOpen, double* pHigh, double* pLow, double* pClose, double* pVolume){
	int i;
	char* vTimeFrame;
	char** vBarTime = (char**)malloc((*pBarCount)*sizeof(char*)); for (i = 0; i < (*pBarCount); i++) (char*)vBarTime[i] = (char*)malloc(19 + 1);
	char	cBarTimeBuffer[4 + 1];
	char	bCurrentStart[12 + 1];

	int retval;
	FILE* vLogFile;
	sql_context vCtx = pCtx;

	//-- 0. Open LogFile
	vLogFile = fopen(pLogFileName, "a");
	//for (i = 0; i < (*pBarCount); i++)	MyLogWrite(pDebugLevel, vLogFile, "pBarTimeYY[%d]=%d ; pBarTimeMM[%d]=%d ; pBarTimeDD[%d]=%d ; pBarTimeHH[%d]=%d ; pBarTimeMI[%d]=%d ; pOpen[%d]=%f ; pHigh[%d]=%f ; pLow[%d]=%f ; pClose[%d]=%f ; pVolume[%d]=%f\n", 20, i, pBarTimeYY[i], i, pBarTimeMM[i], i, pBarTimeDD[i], i, pBarTimeHH[i], i, pBarTimeMI[i], i, pOpen[i], i, pHigh[i], i, pLow[i], i, pClose[i], i, pVolume[i]);
	//MyLogWrite(pDebugLevel, vLogFile, "vCtx=%p\n", 1, vCtx);
	//--- 1. First, Connect
	//retval = OraConnect(UserName, Password, DBString, pDebugLevel, vLogFile, &vCtx);
	//if (retval != 0) return (retval);

	//--- 2. Then, convert timeframe
	vTimeFrame = PeriodToTF(pPeriod);

	//--- 3. Build array of pBarCloseTime
	for (i = 0; i < (*pBarCount); i++){
		sprintf(bCurrentStart, "%d", pBarTimeYY[i]);
		sprintf(cBarTimeBuffer, "%02d", pBarTimeMM[i]); strcat(bCurrentStart, cBarTimeBuffer);
		sprintf(cBarTimeBuffer, "%02d", pBarTimeDD[i]); strcat(bCurrentStart, cBarTimeBuffer);
		sprintf(cBarTimeBuffer, "%02d", pBarTimeHH[i]); strcat(bCurrentStart, cBarTimeBuffer);
		sprintf(cBarTimeBuffer, "%02d", pBarTimeMI[i]); strcat(bCurrentStart, cBarTimeBuffer);
		strcpy(vBarTime[i], bCurrentStart);
	}

	//--- 4. Then, call BulkBarInsert passing LogFile and Connection Context
	retval = BulkBarInsert(1, NULL, vCtx, pSymbol, vTimeFrame, pBarCount, vBarTime, pOpen, pHigh, pLow, pClose, pVolume);
	MyLogWrite(pDebugLevel, vLogFile, "MyHistory() - BulkBarInsert() returned %d. %d rows inserted.\n", 2, retval, (*pBarCount));

	//--- 5. Finally, Disconnect
	//OraDisconnect(vCtx);

/*
	//--- 3. Then, build the INSERT statement
	stmt = (char*)malloc(200);
	buf = (char*)malloc(20);
	strcpy(stmt, "insert into ");
	strcat(stmt, pSymbol);
	strcat(stmt, "_");
	strcat(stmt, vTimeFrame);
	strcat(stmt, "(NewDateTime, Open, High, Low, Close, Volume) values (to_date('");
	strcat(stmt, pBarCloseTime);
	strcat(stmt, "','YYYY.MM.DD HH24:MI:SS'), ");
	sprintf(buf, "%10.5f", pOpen); strcat(stmt, buf); strcat(stmt, ", ");
	sprintf(buf, "%10.5f", pHigh); strcat(stmt, buf); strcat(stmt, ", ");
	sprintf(buf, "%10.5f", pLow); strcat(stmt, buf); strcat(stmt, ", ");
	sprintf(buf, "%10.5f", pClose); strcat(stmt, buf); strcat(stmt, ", ");
	sprintf(buf, "%10.5f", pVolume); strcat(stmt, buf); strcat(stmt, ")");
	MyLogWrite(pDebugLevel, vLogFile, "%s InsertHistory executing: %s\n", 2, timestamp(), stmt);
	//--- 4. Then, execute the INSERT statement	
	retval = OraInsert(pDebugLevel, vLogFile, vCtx, stmt);
*/

	fclose(vLogFile);

	return retval;
}

