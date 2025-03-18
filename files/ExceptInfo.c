#include "ExceptInfo.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>


const int MaxPrintSize = 100;
void trim(char *s)
{
     // удаляем пробелы и табы с начала строки:
     int i=0,j;
     while((s[i]==' ')||(s[i]=='\t')) 
     {
          i++;
     }
     if(i>0) 
     {
          for(j=0; j < strlen(s); j++)
          {
              s[j]=s[j+i];
          }
          s[j]='\0';
     }
 
     // удаляем пробелы и табы с конца строки:
     i=strlen(s)-1;
     while((s[i]==' ')||(s[i]=='\t')) 
     {
          i--;
     }
     if(i < (strlen(s)-1))
     {
          s[i+1]='\0';
     }
}
void InitExceptInfo(ExceptInfo** Ex) {
    if (*Ex != NULL) return;
    *Ex = (ExceptInfo*)calloc(1, sizeof(ExceptInfo));
    (*Ex)->ExData = NULL;
    (*Ex)->Size = 0;
    (*Ex)->Capacity = 0;
    (*Ex)->IsAll = false;
    (*Ex)->level = (int*)calloc(1, 100*sizeof(int));//массив уровней где на i-м месте уровень i-го исключения;
    if (*Ex == NULL) {
        printf("Ex is NULL\n");
    }
}

void DelExceptInfo(ExceptInfo** Ex) {
    if (*Ex == NULL) return;
    (*Ex)->IsAll = false;
    if ((*Ex)->level != NULL) free((*Ex)->level);
    for (int i = 0; i < (*Ex)->Size; ++i) {
        free((*Ex)->ExData[i]);
        (*Ex)->ExData[i] = NULL;
    }
    if ((*Ex)->ExData != NULL) {free((*Ex)->ExData); (*Ex)->ExData = NULL;}
    if (*Ex !=NULL) {
        free(*Ex);
        *Ex = NULL;
    }
    Ex = NULL;
}


bool FindExType(ExceptInfo* Ex, char* newEx) {//в переменную level записывается уровень найденного  выражения
    for (int i = 0; i < Ex->Size; ++i) {
        if (strcmp(Ex->ExData[i], newEx) == 0) {
            return true;
        }
    }
    return false;
}

int FindLevel(ExceptInfo* Ex, char* newEx) {
    for (int i = 0; i < Ex->Size; ++i) {
        if (strcmp(Ex->ExData[i], newEx) == 0) {
            return Ex->level[i];
        }
    }
    return -1;
}

void PrintExType(ExceptInfo* Ex){
    for (int i = 0; i < Ex->Size; ++i) {
        printf("%s %d\n", Ex->ExData[i], Ex->level[i]);
    }
}

void AddExType(ExceptInfo* Ex, char* newEx) {
    if (Ex->ExData == NULL) {
        Ex->Capacity = 1;
        Ex->ExData = (char**)calloc(1, sizeof(char*));
        Ex->Size = 1;
        Ex->ExData[0] = (char*)calloc(1, strlen(newEx)+1);
        strcpy(Ex->ExData[0], newEx);
        return;
    }

    else {
        if (FindExType(Ex, newEx)) {
            return;
        }
    }
    if (Ex->Size == Ex->Capacity) {
        Ex->Capacity *= 2;
        Ex->ExData = (char**)realloc(Ex->ExData, Ex->Capacity*sizeof(char*));
        
    }
    Ex->Size += 1;
    Ex->ExData[Ex->Size - 1] = (char*)calloc(1, strlen(newEx)+1);
    strcpy(Ex->ExData[Ex->Size - 1], newEx);
}

void PrintSameLevel(int level, ExceptInfo* ExPrint) {
    for (int i = ExPrint->Size - 1; i >= 0; --i) {
        if (ExPrint->level[i] == level) {
            printf("%s\n", ExPrint->ExData[i]);
        }
    }
}
void Terminate(ExceptInfo* ExThrow, ExceptInfo* StrExThrow, ExceptInfo* ExCatch, ExceptInfo* ExPrint) {
    int level;
    if (ExCatch->IsAll) {
        printf("all exceptions processed by ... option\n");
    }

    for (int i = 0; i < ExThrow->Size; ++i) {
        bool isFind = FindExType(ExCatch, ExThrow->ExData[i]);
        //isFind += ExCatch->IsAll;
        if (isFind == false && !ExCatch->IsAll) {
            printf("    Terminate   \n");
            printf("Exception %s type not processed\n", ExThrow->ExData[i]);
            return;
        }
        else if (isFind == true){
            level = FindLevel(ExCatch, ExThrow->ExData[i]);
            printf("Exception %s type processed\n", ExThrow->ExData[i]);
            PrintSameLevel(level, ExPrint);
        }
    }
    if (StrExThrow != NULL) {
        if (StrExThrow->Size != 0 && FindExType(ExCatch, "const char*") == false && !ExCatch->IsAll) {
            printf("    Terminate   \n");
            printf("String exception not processed\n");
            return;
        }
        else if (FindExType(ExCatch, "const char*") && StrExThrow->Size > 0) {
            for (int i = 0; i < StrExThrow->Size; ++i) {
                printf("Exception with info %s processed\n", StrExThrow->ExData[i]);
            }
            level = FindLevel(ExCatch, "const char*");
            PrintSameLevel(level, ExPrint);
        }
    }
    
}
