#include <windows.h>
#include <gdiplus.h>
#include <strsafe.h>
#include <string.h>
using namespace Gdiplus;

#include <cstdlib>
#include <cstring>
#include <string>


HRESULT PropertyTypeFromWORD(WORD index, WCHAR* string, UINT maxChars)
{
	HRESULT hr = E_FAIL;

	WCHAR* propertyTypes[] = {
		L"Nothing",                   // 0
		L"PropertyTagTypeByte",       // 1
		L"PropertyTagTypeASCII",      // 2
		L"PropertyTagTypeShort",      // 3
		L"PropertyTagTypeLong",       // 4
		L"PropertyTagTypeRational",   // 5
		L"Nothing",                   // 6
		L"PropertyTagTypeUndefined",  // 7
		L"Nothing",                   // 8
		L"PropertyTagTypeSLONG",      // 9
		L"PropertyTagTypeSRational" }; // 10

	hr = StringCchCopyW(string, maxChars, propertyTypes[index]);
	return hr;
}

#define MAX_PROPTYPE_SIZE 30

wchar_t *convertCharArrayToLPCWSTR(const char* charArray)
{
	wchar_t wString[4096];
	MultiByteToWideChar(CP_ACP, 0, charArray, -1, wString, 4096);
	return &wString[0];
}

char* convertLPCWSTRToCharArray(LPCWSTR wideStr) {
	char buffer[500];
	wcstombs(buffer, wideStr, 500);
	return &buffer[0];
}

wchar_t* FullFileName(char* pPath, LPCWSTR pFilename) {
	char pFullName[500];
	strcpy(pFullName, pPath);
	strcat(pFullName, "\\");
	strcat(pFullName, convertLPCWSTRToCharArray(pFilename));
	return (convertCharArrayToLPCWSTR(pFullName));
}

void GetDateTaken(char* file, char* oTimestamp, int* oHeight, int* oWidth) {
	UINT  size = 0;
	UINT  count = 0;
	WCHAR strPropertyType[MAX_PROPTYPE_SIZE] = L"";
	int PropValInt;

	WCHAR* wfile = convertCharArrayToLPCWSTR(file);
	Bitmap* bitmap = new Bitmap(wfile, 0);

	bitmap->GetPropertySize(&size, &count);

	// Allocate a buffer large enough to receive that array.
	PropertyItem* pPropBuffer = (PropertyItem*)malloc(size);
	// Get the array of PropertyItem objects.
	bitmap->GetAllPropertyItems(size, count, pPropBuffer);

	strcpy(oTimestamp, "<NULL>");

	for (UINT j = 0; j < count; ++j) {
		// Convert the property type from a WORD to a string.
		PropertyTypeFromWORD(pPropBuffer[j].type, strPropertyType, MAX_PROPTYPE_SIZE);

		
		//if (pPropBuffer[j].id == PropertyTagDateTime) {
		if (pPropBuffer[j].id == PropertyTagExifDTOrig)	strcpy(oTimestamp, (char*)pPropBuffer[j].value);
		if (pPropBuffer[j].id == PropertyTagExifPixXDim) {
			PropValInt= (*(int*)pPropBuffer[j].value);
			(*oWidth) = PropValInt;
		}
		if (pPropBuffer[j].id == PropertyTagExifPixYDim) {
			PropValInt = (*(int*)pPropBuffer[j].value);
			(*oHeight) = PropValInt;
		}
		/*
		printf("Property Item %d\n", j);
		printf("  id: 0x%x\n", pPropBuffer[j].id);
		wprintf(L"  type: %s\n", strPropertyType);
		char* dt = (char*)pPropBuffer[j].value;
		printf("  value: %s\n", dt);
		printf("  length: %d bytes\n\n", pPropBuffer[j].length);
		*/
	}

	free(pPropBuffer);
	delete bitmap;

}

void DisplayErrorBox(LPTSTR lpszFunction){
	// Retrieve the system error message for the last-error code

	LPVOID lpMsgBuf;
	LPVOID lpDisplayBuf;
	DWORD dw = GetLastError();

	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM |
		FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL,
		dw,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR)&lpMsgBuf,
		0, NULL);

	// Display the error message and clean up

	lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT,
		(lstrlen((LPCTSTR)lpMsgBuf) + lstrlen((LPCTSTR)lpszFunction) + 40) * sizeof(TCHAR));
	StringCchPrintf((LPTSTR)lpDisplayBuf,
		LocalSize(lpDisplayBuf) / sizeof(TCHAR),
		TEXT("%s failed with error %d: %s"),
		lpszFunction, dw, lpMsgBuf);
	MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK);

	LocalFree(lpMsgBuf);
	LocalFree(lpDisplayBuf);
}


void ListFilesFromDir(char* path) {
	WIN32_FIND_DATA ffd;
	LARGE_INTEGER filesize;
	TCHAR szDir[MAX_PATH];
	char kaz[MAX_PATH];
	char path2[MAX_PATH];
	char fname[MAX_PATH];
	char ffname[MAX_PATH];
	char DateTaken[64];
	size_t length_of_arg;
	HANDLE hFind = 0;
	DWORD dwError = 0;
	int Width, Height;

	static int filecount = 0;

	MultiByteToWideChar(CP_ACP, 0, path, -1, szDir, MAX_PATH);
	StringCchCat(szDir, MAX_PATH, TEXT("/*"));

	hFind = FindFirstFile(szDir, &ffd);
	if (INVALID_HANDLE_VALUE == hFind) {
		DisplayErrorBox(TEXT("FindFirstFile"));
		return;
	}

	while (FindNextFile(hFind, &ffd)) {
		//Width = 0; Height = 0;
		if (ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
			wcstombs(kaz, ffd.cFileName, MAX_PATH);
			if (!(strcmp(kaz, ".") == 0 || strcmp(kaz, "..") == 0)) {
				strcpy(path2, path); strcat(path2, "/"); strcat(path2, kaz);
				ListFilesFromDir(path2);
			}
		} else {
			filecount++;
			wcstombs(fname, ffd.cFileName, MAX_PATH);
			strcpy(ffname, path);
			strcat(ffname, "/"); strcat(ffname, fname);
			filesize.LowPart = ffd.nFileSizeLow;
			filesize.HighPart = ffd.nFileSizeHigh;
			GetDateTaken(ffname, &DateTaken[0], &Height, &Width);
			printf("%d  %s %s   (%dx%d) %ld bytes\n", filecount, DateTaken, ffname, Width, Height, filesize.QuadPart);
			if (strcmp(DateTaken, "<NULL>") == 0) system("pause");

		}
	}

	FindClose(hFind);
	return;
}

INT main(){
	WIN32_FIND_DATA ffd;
	LARGE_INTEGER filesize;
	TCHAR szDir[MAX_PATH];
	size_t length_of_arg;
	HANDLE hFind = INVALID_HANDLE_VALUE;
	DWORD dwError = 0;


	// Initialize GDI+
	GdiplusStartupInput gdiplusStartupInput;
	ULONG_PTR gdiplusToken;
	GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);
/*
	//========================================================================
	UINT count = 0;
	Image* image = new Image(L"E:/Foto/2016-05-10/008.jpg");

	// How many types of metadata are in the image?
	count = image->GetPropertyCount();
	if (count == 0)
		return 0;

	// Allocate a buffer to receive an array of PROPIDs.
	PROPID* propIDs = new PROPID[count];

	image->GetPropertyIdList(count, propIDs);

	// List the retrieved IDs.
	for (UINT j = 0; j < count; ++j)
		printf("%x\n", propIDs[j]);

	delete[] propIDs;
	delete image;   
	//========================================================================
*/

	char* StartPath = "E:/Foto";	
	//ListFilesFromDir(StartPath);

	system("pause");

	GdiplusShutdown(gdiplusToken);
	return 0;
} // main

  // Helper function
