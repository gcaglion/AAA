// PropertyStore.cpp : Defines the entry point for the console application.
//


#include "targetver.h"
#include <stdio.h>
#include <tchar.h>

#include <propsys.h>
#include <propkey.h>
#include <shobjidl.h>

int _tmain(int argc, _TCHAR* argv[]){

	CoInitialize(NULL);
	HRESULT hr = S_OK;
	IPropertyStore* store = NULL;
	hr = SHGetPropertyStoreFromParsingName(L"E:\\music\\ACDC\\1978 - Powerage\\AC-DC - Powerage - 02 - Down Payment Blues.mp3", NULL, GPS_READWRITE, __uuidof(IPropertyStore), (void**)&store);

	PROPVARIANT variant;
	hr = store->GetValue(PKEY_Media_Duration, &variant);
	printf("duration: %f\n", variant.ulVal);
	double temp = (double)variant.ulVal * 0.0001;
	printf("Temp: %f\n", temp);
	// conver to seconds
	double seconds = (double)(temp / 1000);
	printf("Converted: %f\n", (double)seconds);
	hr = store->GetValue(PKEY_Music_Artist, &variant);
	hr = store->GetValue(PKEY_Audio_SampleRate, &variant);
	store->Release();

	system("pause");
	return 0;
}
