#ifndef appletStatus_common_h
#define appletStatus_common_h

#include "../include/cryptoki.h"

#ifdef __cplusplus
extern "C" {
#endif
    
	void printError(char* func, CK_RV retCode);
    
    CK_OBJECT_HANDLE findFirstObj(CK_SESSION_HANDLE session, CK_ATTRIBUTE_PTR objAttribs, CK_ULONG attribsCount);
    
#ifdef __cplusplus
}
#endif

#endif
