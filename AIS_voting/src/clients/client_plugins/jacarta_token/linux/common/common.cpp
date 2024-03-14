#include <stdio.h>

#include "P11Loader.h"
#include "common.h"


/************************************************************************
 Функция выводит на экран название функции где произошла ошибка и ее код
 ************************************************************************/
void printError(char* func, CK_RV retCode)
{
	char* retCodeString;

	switch(retCode)
	{
		case CKR_CANCEL : retCodeString = "CKR_CANCEL"; break;
		case CKR_HOST_MEMORY : retCodeString = "CKR_HOST_MEMORY"; break;
		case CKR_SLOT_ID_INVALID : retCodeString = "CKR_SLOT_ID_INVALID"; break;

		case CKR_GENERAL_ERROR : retCodeString = "CKR_GENERAL_ERROR"; break;
		case CKR_FUNCTION_FAILED : retCodeString = "CKR_FUNCTION_FAILED"; break;

		case CKR_ARGUMENTS_BAD : retCodeString = "CKR_ARGUMENTS_BAD"; break;
		case CKR_NO_EVENT : retCodeString = "CKR_NO_EVENT"; break;
		case CKR_NEED_TO_CREATE_THREADS : retCodeString = "CKR_NEED_TO_CREATE_THREADS"; break;
		case CKR_CANT_LOCK : retCodeString = "CKR_CANT_LOCK"; break;

		case CKR_ATTRIBUTE_READ_ONLY : retCodeString = "CKR_ATTRIBUTE_READ_ONLY"; break;
		case CKR_ATTRIBUTE_SENSITIVE : retCodeString = "CKR_ATTRIBUTE_SENSITIVE"; break;
		case CKR_ATTRIBUTE_TYPE_INVALID : retCodeString = "CKR_ATTRIBUTE_TYPE_INVALID"; break;
		case CKR_ATTRIBUTE_VALUE_INVALID : retCodeString = "CKR_ATTRIBUTE_VALUE_INVALID"; break;
		case CKR_DATA_INVALID : retCodeString = "CKR_DATA_INVALID"; break;
		case CKR_DATA_LEN_RANGE : retCodeString = "CKR_DATA_LEN_RANGE"; break;
		case CKR_DEVICE_ERROR : retCodeString = "CKR_DEVICE_ERROR"; break;
		case CKR_DEVICE_MEMORY : retCodeString = "CKR_DEVICE_MEMORY"; break;
		case CKR_DEVICE_REMOVED : retCodeString = "CKR_DEVICE_REMOVED"; break;
		case CKR_ENCRYPTED_DATA_INVALID : retCodeString = "CKR_ENCRYPTED_DATA_INVALID"; break;
		case CKR_ENCRYPTED_DATA_LEN_RANGE : retCodeString = "CKR_ENCRYPTED_DATA_LEN_RANGE"; break;
		case CKR_FUNCTION_CANCELED : retCodeString = "CKR_FUNCTION_CANCELED"; break;
		case CKR_FUNCTION_NOT_PARALLEL : retCodeString = "CKR_FUNCTION_NOT_PARALLEL"; break;

		case CKR_FUNCTION_NOT_SUPPORTED : retCodeString = "CKR_FUNCTION_NOT_SUPPORTED"; break;
		case CKR_KEY_HANDLE_INVALID : retCodeString = "CKR_KEY_HANDLE_INVALID"; break;
		case CKR_KEY_SIZE_RANGE : retCodeString = "CKR_KEY_SIZE_RANGE"; break;
		case CKR_KEY_TYPE_INCONSISTENT : retCodeString = "CKR_KEY_TYPE_INCONSISTENT"; break;

		case CKR_KEY_NOT_NEEDED : retCodeString = "CKR_KEY_NOT_NEEDED"; break;
		case CKR_KEY_CHANGED : retCodeString = "CKR_KEY_CHANGED"; break;
		case CKR_KEY_NEEDED : retCodeString = "CKR_KEY_NEEDED"; break;
		case CKR_KEY_INDIGESTIBLE : retCodeString = "CKR_KEY_INDIGESTIBLE"; break;
		case CKR_KEY_FUNCTION_NOT_PERMITTED : retCodeString = "CKR_KEY_FUNCTION_NOT_PERMITTED"; break;
		case CKR_KEY_NOT_WRAPPABLE : retCodeString = "CKR_KEY_NOT_WRAPPABLE"; break;
		case CKR_KEY_UNEXTRACTABLE : retCodeString = "CKR_KEY_UNEXTRACTABLE"; break;

		case CKR_MECHANISM_INVALID : retCodeString = "CKR_MECHANISM_INVALID"; break;
		case CKR_MECHANISM_PARAM_INVALID : retCodeString = "CKR_MECHANISM_PARAM_INVALID"; break;

		case CKR_OBJECT_HANDLE_INVALID : retCodeString = "CKR_OBJECT_HANDLE_INVALID"; break;
		case CKR_OPERATION_ACTIVE : retCodeString = "CKR_OPERATION_ACTIVE"; break;
		case CKR_OPERATION_NOT_INITIALIZED : retCodeString = "CKR_OPERATION_NOT_INITIALIZED"; break;
		case CKR_PIN_INCORRECT : retCodeString = "CKR_PIN_INCORRECT"; break;
		case CKR_PIN_INVALID : retCodeString = "CKR_PIN_INVALID"; break;
		case CKR_PIN_LEN_RANGE : retCodeString = "CKR_PIN_LEN_RANGE"; break;

		case CKR_PIN_EXPIRED : retCodeString = "CKR_PIN_EXPIRED"; break;
		case CKR_PIN_LOCKED : retCodeString = "CKR_PIN_LOCKED"; break;

		case CKR_SESSION_CLOSED : retCodeString = "CKR_SESSION_CLOSED"; break;
		case CKR_SESSION_COUNT : retCodeString = "CKR_SESSION_COUNT"; break;
		case CKR_SESSION_HANDLE_INVALID : retCodeString = "CKR_SESSION_HANDLE_INVALID"; break;
		case CKR_SESSION_PARALLEL_NOT_SUPPORTED : retCodeString = "CKR_SESSION_PARALLEL_NOT_SUPPORTED"; break;
		case CKR_SESSION_READ_ONLY : retCodeString = "CKR_SESSION_READ_ONLY"; break;
		case CKR_SESSION_EXISTS : retCodeString = "CKR_SESSION_EXISTS"; break;

		case CKR_SESSION_READ_ONLY_EXISTS : retCodeString = "CKR_SESSION_READ_ONLY_EXISTS"; break;
		case CKR_SESSION_READ_WRITE_SO_EXISTS : retCodeString = "CKR_SESSION_READ_WRITE_SO_EXISTS"; break;

		case CKR_SIGNATURE_INVALID : retCodeString = "CKR_SIGNATURE_INVALID"; break;
		case CKR_SIGNATURE_LEN_RANGE : retCodeString = "CKR_SIGNATURE_LEN_RANGE"; break;
		case CKR_TEMPLATE_INCOMPLETE : retCodeString = "CKR_TEMPLATE_INCOMPLETE"; break;
		case CKR_TEMPLATE_INCONSISTENT : retCodeString = "CKR_TEMPLATE_INCONSISTENT"; break;
		case CKR_TOKEN_NOT_PRESENT : retCodeString = "CKR_TOKEN_NOT_PRESENT"; break;
		case CKR_TOKEN_NOT_RECOGNIZED : retCodeString = "CKR_TOKEN_NOT_RECOGNIZED"; break;
		case CKR_TOKEN_WRITE_PROTECTED : retCodeString = "CKR_TOKEN_WRITE_PROTECTED"; break;
		case CKR_UNWRAPPING_KEY_HANDLE_INVALID : retCodeString = "CKR_UNWRAPPING_KEY_HANDLE_INVALID"; break;
		case CKR_UNWRAPPING_KEY_SIZE_RANGE : retCodeString = "CKR_UNWRAPPING_KEY_SIZE_RANGE"; break;
		case CKR_UNWRAPPING_KEY_TYPE_INCONSISTENT : retCodeString = "CKR_UNWRAPPING_KEY_TYPE_INCONSISTENT"; break;
		case CKR_USER_ALREADY_LOGGED_IN : retCodeString = "CKR_USER_ALREADY_LOGGED_IN"; break;
		case CKR_USER_NOT_LOGGED_IN : retCodeString = "CKR_USER_NOT_LOGGED_IN"; break;
		case CKR_USER_PIN_NOT_INITIALIZED : retCodeString = "CKR_USER_PIN_NOT_INITIALIZED"; break;
		case CKR_USER_TYPE_INVALID : retCodeString = "CKR_USER_TYPE_INVALID"; break;

		case CKR_USER_ANOTHER_ALREADY_LOGGED_IN : retCodeString = "CKR_USER_ANOTHER_ALREADY_LOGGED_IN"; break;
		case CKR_USER_TOO_MANY_TYPES : retCodeString = "CKR_USER_TOO_MANY_TYPES"; break;
		case CKR_WRAPPED_KEY_INVALID : retCodeString = "CKR_WRAPPED_KEY_INVALID"; break;
		case CKR_WRAPPED_KEY_LEN_RANGE : retCodeString = "CKR_WRAPPED_KEY_LEN_RANGE"; break;
		case CKR_WRAPPING_KEY_HANDLE_INVALID : retCodeString = "CKR_WRAPPING_KEY_HANDLE_INVALID"; break;
		case CKR_WRAPPING_KEY_SIZE_RANGE : retCodeString = "CKR_WRAPPING_KEY_SIZE_RANGE"; break;
		case CKR_WRAPPING_KEY_TYPE_INCONSISTENT : retCodeString = "CKR_WRAPPING_KEY_TYPE_INCONSISTENT"; break;
		case CKR_RANDOM_SEED_NOT_SUPPORTED : retCodeString = "CKR_RANDOM_SEED_NOT_SUPPORTED"; break;

		case CKR_RANDOM_NO_RNG : retCodeString = "CKR_RANDOM_NO_RNG"; break;
		case CKR_BUFFER_TOO_SMALL : retCodeString = "CKR_BUFFER_TOO_SMALL"; break;
		case CKR_SAVED_STATE_INVALID : retCodeString = "CKR_SAVED_STATE_INVALID"; break;
		case CKR_INFORMATION_SENSITIVE : retCodeString = "CKR_INFORMATION_SENSITIVE"; break;
		case CKR_STATE_UNSAVEABLE : retCodeString = "CKR_STATE_UNSAVEABLE"; break;

		case CKR_CRYPTOKI_NOT_INITIALIZED : retCodeString = "CKR_CRYPTOKI_NOT_INITIALIZED"; break;
		case CKR_CRYPTOKI_ALREADY_INITIALIZED : retCodeString = "CKR_CRYPTOKI_ALREADY_INITIALIZED"; break;
		case CKR_MUTEX_BAD : retCodeString = "CKR_MUTEX_BAD"; break;
		case CKR_MUTEX_NOT_LOCKED : retCodeString = "CKR_MUTEX_NOT_LOCKED"; break;

		default : retCodeString = "Unknown function"; break;
	}

	printf("Error in function %s, code= 0x%x (%s)\n", func, retCode, retCodeString);
}

/************************************************************************
 Функция возвращает первый найденный объект соответствующий передаваемым 
 атрибутам. Если объект не найден, функция возвращает CK_INVALID_HANDLE
 ************************************************************************/
CK_OBJECT_HANDLE findFirstObj(CK_SESSION_HANDLE session, CK_ATTRIBUTE_PTR objAttribs, CK_ULONG attribsCount)
{
	CK_OBJECT_HANDLE found = CK_INVALID_HANDLE;
	CK_RV rv = CKR_OK;
	CK_ULONG count = 1;

	P11Loader& loader = GetLoader();
	if(loader.IsInitialized() == false)
	{
		return 1;
	}

	rv = CALL_P11(C_FindObjectsInit(session, objAttribs, attribsCount));
	if(rv != CKR_OK)
	{
		printError("C_FindObjectsInit", rv);
		return CK_INVALID_HANDLE;
	}

	rv = CALL_P11(C_FindObjects(session, &found, 1, &count));
	if (rv != CKR_OK)
	{
		printError("C_FindObjects", rv);
		return CK_INVALID_HANDLE;
	}

	rv = CALL_P11(C_FindObjectsFinal(session));
	if(rv != CKR_OK)
	{
		printError("C_FindObjectsFinal", rv);
		return CK_INVALID_HANDLE;
	}

	return found;
}
