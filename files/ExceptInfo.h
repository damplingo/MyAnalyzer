#pragma once
#include <stdio.h>
#include <stdbool.h>

typedef struct {
    char** ExData;
    size_t Size;
    size_t Capacity;
    bool IsAll;
    int* level;
}  ExceptInfo;


void InitExceptInfo(ExceptInfo** Ex);
void TestPrint(ExceptInfo* Ex);
void AddExType(ExceptInfo* Ex, char* newThrowType);
bool FindExType(ExceptInfo* Ex, char* newThrowType);
void PrintExType(ExceptInfo* Ex);
void Terminate(ExceptInfo* ExThrow, ExceptInfo* StrExThrow, ExceptInfo* ExCatch, ExceptInfo* ExPrint);
void DelExceptInfo(ExceptInfo** Ex);
void trim(char *s);
