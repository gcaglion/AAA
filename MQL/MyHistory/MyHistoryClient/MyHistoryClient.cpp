// MyHistoryClient.cpp : Defines the entry point for the console application.
//

#include <stdlib.h>
#include <stdio.h>
#include <MyHistory.h>
#include <MyGA.h>
#include <MyProCSubs.h>

int main(int argc, char* argv[]){
	int ret; int i;
	void* vCtx = NULL;
	int vBarTimeYY[5]; int vBarTimeMM[5]; int vBarTimeDD[5]; int vBarTimeHH[5]; int vBarTimeMI[5];
	double vOpen[5], vHigh[5], vLow[5], vClose[5], vVolume[5];

	int nrec = 5;

	//-- Build fake bars
	for (i = 0; i < 5; i++){
		vBarTimeYY[i] = 2015;
		vBarTimeMM[i] = 2;
		vBarTimeDD[i] = 1;
		vBarTimeHH[i] = i;
		vBarTimeMI[i] = 0;
		vOpen[i] = i + 0.1; vHigh[i] = i + 0.3; vLow[i] = i + 0.0; vClose[i] = i + 0.2; vVolume[i] = i;
	}

	/*
	for (i = 0; i < 5; i++){
			//vLastBar[i].Open = i + 0.1; vLastBar[i].High = i + 0.3; vLastBar[i].Low = i + 0.0; vLastBar[i].Close = i + 0.2;
		vOpen[i] = i + 0.1; vHigh[i] = i + 0.3; vLow[i] = i + 0.0; vClose[i] = i + 0.2; vVolume[i] = i;
		vNewDateTime[i] = (char*)malloc(20);
	}

	strcpy(vNewDateTime[0], "2015.02.01 01:00:00");
	strcpy(vNewDateTime[1], "2015.02.01 02:00:00");
	strcpy(vNewDateTime[2], "2015.02.01 03:00:00");
	strcpy(vNewDateTime[3], "2015.02.01 04:00:00");
	strcpy(vNewDateTime[4], "2015.02.01 05:00:00");
*/	
	
	char* UserName = "Hist2"; char* Password = "Hist2"; char* DBString = "Algo"; int pDebugLevel = 2; char* vLogFileName = "c:/temp/MyHistoryClient.log";
	ret = OraConnect_MQ4(UserName, Password, DBString, pDebugLevel, vLogFileName, &vCtx);
	
	printf("GetLastBar() returned: %s\n", GetLastBar(1, vLogFileName, vCtx, "GBPNZD", 60));

	ret = InsertHistory(2, "c:/temp/MyHistoryClient.log", vCtx, "GBPUSD", 1, &nrec, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vOpen, vHigh, vLow, vClose, vVolume);
	printf("InsertHistory returned %d\n", ret);

/*
	if (OraConnect("Hist2", "Hist2", "Algo", 1, NULL , &vCtx) != 0) return -1;

	ret = BulkBarInsert(1, NULL, vCtx, "GBPUSD", "M1", &nrec, vNewDateTime, vOpen, vHigh, vLow, vClose, vVolume);
	printf("BulkBarInsert() returned %d. %d rows inserted.\n", ret, nrec);
*/
	system("pause");
	return 0;
}

