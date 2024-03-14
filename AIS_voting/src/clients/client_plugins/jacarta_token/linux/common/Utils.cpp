
#include <iostream>
#include <iomanip>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>

#include "Utils.h"


std::string S_DEFAULT_LASER_USER_PIN = "11111111"; // ПИН-код по-умолчанию для апплета типа LASER
std::string S_DEFAULT_LASER_ADMIN_PIN = "00000000"; // ПИН-код по-умолчанию для апплета типа LASER

std::string S_LABEL_PUBLIC = "TEST RSA PUB KEY"; // метка для публичного ключа из ключевой пары
std::string S_LABEL_PRIVATE = "TEST RSA PRIV KEY";// метка для приватного ключа из ключевой пары
std::string S_LABEL_CERT = "TEST RSA CERT"; // метка для сертификата

std::string S_DEFAULT_STORAGE_USER_PIN = "1234567890";  // ПИН-код по-умолчанию для апплета типа DataStore
std::string S_DEFAULT_STORAGE_ADMIN_PIN = "1234567890";

std::string S_LABEL_DATA = "TEST DATA LABEL";

void P11Utils::PrintError(const char* pFunctionName, CK_RV retCode)
{
    char* retCodeString;

    switch(retCode)
    {
        case CKR_CANCEL :
            retCodeString = "CKR_CANCEL";
            break;
        case CKR_HOST_MEMORY :
            retCodeString = "CKR_HOST_MEMORY";
            break;
        case CKR_SLOT_ID_INVALID :
            retCodeString = "CKR_SLOT_ID_INVALID";
            break;

        case CKR_GENERAL_ERROR :
            retCodeString = "CKR_GENERAL_ERROR";
            break;
        case CKR_FUNCTION_FAILED :
            retCodeString = "CKR_FUNCTION_FAILED";
            break;

        case CKR_ARGUMENTS_BAD :
            retCodeString = "CKR_ARGUMENTS_BAD";
            break;
        case CKR_NO_EVENT :
            retCodeString = "CKR_NO_EVENT";
            break;
        case CKR_NEED_TO_CREATE_THREADS :
            retCodeString = "CKR_NEED_TO_CREATE_THREADS";
            break;
        case CKR_CANT_LOCK :
            retCodeString = "CKR_CANT_LOCK";
            break;

        case CKR_ATTRIBUTE_READ_ONLY :
            retCodeString = "CKR_ATTRIBUTE_READ_ONLY";
            break;
        case CKR_ATTRIBUTE_SENSITIVE :
            retCodeString = "CKR_ATTRIBUTE_SENSITIVE";
            break;
        case CKR_ATTRIBUTE_TYPE_INVALID :
            retCodeString = "CKR_ATTRIBUTE_TYPE_INVALID";
            break;
        case CKR_ATTRIBUTE_VALUE_INVALID :
            retCodeString = "CKR_ATTRIBUTE_VALUE_INVALID";
            break;
        case CKR_DATA_INVALID :
            retCodeString = "CKR_DATA_INVALID";
            break;
        case CKR_DATA_LEN_RANGE :
            retCodeString = "CKR_DATA_LEN_RANGE";
            break;
        case CKR_DEVICE_ERROR :
            retCodeString = "CKR_DEVICE_ERROR";
            break;
        case CKR_DEVICE_MEMORY :
            retCodeString = "CKR_DEVICE_MEMORY";
            break;
        case CKR_DEVICE_REMOVED :
            retCodeString = "CKR_DEVICE_REMOVED";
            break;
        case CKR_ENCRYPTED_DATA_INVALID :
            retCodeString = "CKR_ENCRYPTED_DATA_INVALID";
            break;
        case CKR_ENCRYPTED_DATA_LEN_RANGE :
            retCodeString = "CKR_ENCRYPTED_DATA_LEN_RANGE";
            break;
        case CKR_FUNCTION_CANCELED :
            retCodeString = "CKR_FUNCTION_CANCELED";
            break;
        case CKR_FUNCTION_NOT_PARALLEL :
            retCodeString = "CKR_FUNCTION_NOT_PARALLEL";
            break;

        case CKR_FUNCTION_NOT_SUPPORTED :
            retCodeString = "CKR_FUNCTION_NOT_SUPPORTED";
            break;
        case CKR_KEY_HANDLE_INVALID :
            retCodeString = "CKR_KEY_HANDLE_INVALID";
            break;
        case CKR_KEY_SIZE_RANGE :
            retCodeString = "CKR_KEY_SIZE_RANGE";
            break;
        case CKR_KEY_TYPE_INCONSISTENT :
            retCodeString = "CKR_KEY_TYPE_INCONSISTENT";
            break;

        case CKR_KEY_NOT_NEEDED :
            retCodeString = "CKR_KEY_NOT_NEEDED";
            break;
        case CKR_KEY_CHANGED :
            retCodeString = "CKR_KEY_CHANGED";
            break;
        case CKR_KEY_NEEDED :
            retCodeString = "CKR_KEY_NEEDED";
            break;
        case CKR_KEY_INDIGESTIBLE :
            retCodeString = "CKR_KEY_INDIGESTIBLE";
            break;
        case CKR_KEY_FUNCTION_NOT_PERMITTED :
            retCodeString = "CKR_KEY_FUNCTION_NOT_PERMITTED";
            break;
        case CKR_KEY_NOT_WRAPPABLE :
            retCodeString = "CKR_KEY_NOT_WRAPPABLE";
            break;
        case CKR_KEY_UNEXTRACTABLE :
            retCodeString = "CKR_KEY_UNEXTRACTABLE";
            break;

        case CKR_MECHANISM_INVALID :
            retCodeString = "CKR_MECHANISM_INVALID";
            break;
        case CKR_MECHANISM_PARAM_INVALID :
            retCodeString = "CKR_MECHANISM_PARAM_INVALID";
            break;

        case CKR_OBJECT_HANDLE_INVALID :
            retCodeString = "CKR_OBJECT_HANDLE_INVALID";
            break;
        case CKR_OPERATION_ACTIVE :
            retCodeString = "CKR_OPERATION_ACTIVE";
            break;
        case CKR_OPERATION_NOT_INITIALIZED :
            retCodeString = "CKR_OPERATION_NOT_INITIALIZED";
            break;
        case CKR_PIN_INCORRECT :
            retCodeString = "CKR_PIN_INCORRECT";
            break;
        case CKR_PIN_INVALID :
            retCodeString = "CKR_PIN_INVALID";
            break;
        case CKR_PIN_LEN_RANGE :
            retCodeString = "CKR_PIN_LEN_RANGE";
            break;

        case CKR_PIN_EXPIRED :
            retCodeString = "CKR_PIN_EXPIRED";
            break;
        case CKR_PIN_LOCKED :
            retCodeString = "CKR_PIN_LOCKED";
            break;

        case CKR_SESSION_CLOSED :
            retCodeString = "CKR_SESSION_CLOSED";
            break;
        case CKR_SESSION_COUNT :
            retCodeString = "CKR_SESSION_COUNT";
            break;
        case CKR_SESSION_HANDLE_INVALID :
            retCodeString = "CKR_SESSION_HANDLE_INVALID";
            break;
        case CKR_SESSION_PARALLEL_NOT_SUPPORTED :
            retCodeString = "CKR_SESSION_PARALLEL_NOT_SUPPORTED";
            break;
        case CKR_SESSION_READ_ONLY :
            retCodeString = "CKR_SESSION_READ_ONLY";
            break;
        case CKR_SESSION_EXISTS :
            retCodeString = "CKR_SESSION_EXISTS";
            break;

        case CKR_SESSION_READ_ONLY_EXISTS :
            retCodeString = "CKR_SESSION_READ_ONLY_EXISTS";
            break;
        case CKR_SESSION_READ_WRITE_SO_EXISTS :
            retCodeString = "CKR_SESSION_READ_WRITE_SO_EXISTS";
            break;

        case CKR_SIGNATURE_INVALID :
            retCodeString = "CKR_SIGNATURE_INVALID";
            break;
        case CKR_SIGNATURE_LEN_RANGE :
            retCodeString = "CKR_SIGNATURE_LEN_RANGE";
            break;
        case CKR_TEMPLATE_INCOMPLETE :
            retCodeString = "CKR_TEMPLATE_INCOMPLETE";
            break;
        case CKR_TEMPLATE_INCONSISTENT :
            retCodeString = "CKR_TEMPLATE_INCONSISTENT";
            break;
        case CKR_TOKEN_NOT_PRESENT :
            retCodeString = "CKR_TOKEN_NOT_PRESENT";
            break;
        case CKR_TOKEN_NOT_RECOGNIZED :
            retCodeString = "CKR_TOKEN_NOT_RECOGNIZED";
            break;
        case CKR_TOKEN_WRITE_PROTECTED :
            retCodeString = "CKR_TOKEN_WRITE_PROTECTED";
            break;
        case CKR_UNWRAPPING_KEY_HANDLE_INVALID :
            retCodeString = "CKR_UNWRAPPING_KEY_HANDLE_INVALID";
            break;
        case CKR_UNWRAPPING_KEY_SIZE_RANGE :
            retCodeString = "CKR_UNWRAPPING_KEY_SIZE_RANGE";
            break;
        case CKR_UNWRAPPING_KEY_TYPE_INCONSISTENT :
            retCodeString = "CKR_UNWRAPPING_KEY_TYPE_INCONSISTENT";
            break;
        case CKR_USER_ALREADY_LOGGED_IN :
            retCodeString = "CKR_USER_ALREADY_LOGGED_IN";
            break;
        case CKR_USER_NOT_LOGGED_IN :
            retCodeString = "CKR_USER_NOT_LOGGED_IN";
            break;
        case CKR_USER_PIN_NOT_INITIALIZED :
            retCodeString = "CKR_USER_PIN_NOT_INITIALIZED";
            break;
        case CKR_USER_TYPE_INVALID :
            retCodeString = "CKR_USER_TYPE_INVALID";
            break;

        case CKR_USER_ANOTHER_ALREADY_LOGGED_IN :
            retCodeString = "CKR_USER_ANOTHER_ALREADY_LOGGED_IN";
            break;
        case CKR_USER_TOO_MANY_TYPES :
            retCodeString = "CKR_USER_TOO_MANY_TYPES";
            break;
        case CKR_WRAPPED_KEY_INVALID :
            retCodeString = "CKR_WRAPPED_KEY_INVALID";
            break;
        case CKR_WRAPPED_KEY_LEN_RANGE :
            retCodeString = "CKR_WRAPPED_KEY_LEN_RANGE";
            break;
        case CKR_WRAPPING_KEY_HANDLE_INVALID :
            retCodeString = "CKR_WRAPPING_KEY_HANDLE_INVALID";
            break;
        case CKR_WRAPPING_KEY_SIZE_RANGE :
            retCodeString = "CKR_WRAPPING_KEY_SIZE_RANGE";
            break;
        case CKR_WRAPPING_KEY_TYPE_INCONSISTENT :
            retCodeString = "CKR_WRAPPING_KEY_TYPE_INCONSISTENT";
            break;
        case CKR_RANDOM_SEED_NOT_SUPPORTED :
            retCodeString = "CKR_RANDOM_SEED_NOT_SUPPORTED";
            break;

        case CKR_RANDOM_NO_RNG :
            retCodeString = "CKR_RANDOM_NO_RNG";
            break;
        case CKR_BUFFER_TOO_SMALL :
            retCodeString = "CKR_BUFFER_TOO_SMALL";
            break;
        case CKR_SAVED_STATE_INVALID :
            retCodeString = "CKR_SAVED_STATE_INVALID";
            break;
        case CKR_INFORMATION_SENSITIVE :
            retCodeString = "CKR_INFORMATION_SENSITIVE";
            break;
        case CKR_STATE_UNSAVEABLE :
            retCodeString = "CKR_STATE_UNSAVEABLE";
            break;

        case CKR_CRYPTOKI_NOT_INITIALIZED :
            retCodeString = "CKR_CRYPTOKI_NOT_INITIALIZED";
            break;
        case CKR_CRYPTOKI_ALREADY_INITIALIZED :
            retCodeString = "CKR_CRYPTOKI_ALREADY_INITIALIZED";
            break;
        case CKR_MUTEX_BAD :
            retCodeString = "CKR_MUTEX_BAD";
            break;
        case CKR_MUTEX_NOT_LOCKED :
            retCodeString = "CKR_MUTEX_NOT_LOCKED";
            break;

        case CKR_ICL_LIBRARY_NOT_FOUND:
            retCodeString = "CKR_ICL_LIBRARY_NOT_FOUND";
            break;

        case CKR_ICL_JCVERIFY_NOT_FOUND:
            retCodeString = "CKR_ICL_JCVERIFY_NOT_FOUND";
            break;

        case CKR_ICL_JCVERIFY_CHECKSUM_NOT_FOUND:
            retCodeString = "CKR_ICL_JCVERIFY_CHECKSUM_NOT_FOUND";
            break;

        case CKR_ICL_CHECKSUM_NOT_FOUND:
            retCodeString = "CKR_ICL_CHECKSUM_NOT_FOUND";
            break;

        case CKR_ICL_JCVERIFY_CHECKSUM:
            retCodeString = "CKR_ICL_JCVERIFY_CHECKSUM";
            break;

        case CKR_ICL_CHECKSUM:
            retCodeString = "CKR_ICL_CHECKSUM";
            break;

        default :
            retCodeString = "Unknown function";
            break;
    }

    std::cout << "Error in function " << pFunctionName << ", code = 0x" << std::hex << retCode << "(" << retCodeString << ")" << std::endl;
}

std::string P11Utils::CK2string(CK_BYTE * ptr, CK_ULONG len)
{
    std::string res;
    std::vector<CK_BYTE> buffer(len + 1);
    CK_ULONG i = 0;
    for (i = 0; i < len; i++)
    {
        buffer[i] = ptr[i];
    }
    buffer[len] = 0;
    res = (char *)(&buffer[0]);
    // обрезать пробелы в конце
    res.erase(res.find_last_not_of(" \n\r\t") + 1);
    return res;
}

std::string P11Utils::DecryptModel(CK_UTF8CHAR_PTR pModel, CK_ULONG modelSize)
{
    if (modelSize < 5)
    {
        return "Unknown model";
    }
    std::stringstream sstream;
    sstream << pModel[3] << pModel[4];
    std::string res = sstream.str();

    const int DecModel = atoi(sstream.str().c_str());
    switch (DecModel)
    {
        case 0:
            return std::string("JaCarta PKI");
        case 1:
            return std::string("JaCarta GOST");
        case 2:
            return std::string("JaCarta PKI (with backward compatibility)");
        case 3:
            return std::string("JaCarta PKI/BIO");
        case 4:
            return std::string("JaCarta PKI/GOST (with backward compatibility)");
        case 5:
            return std::string("JaCarta PKI/GOST");
        case 8:
            return std::string("JaCarta PKI/BIO/GOST");
        case 10:
            return std::string("JaCarta PKI/Flash");
        case 11:
            return std::string("JaCarta PKI/Flash");
        case 12:
            return std::string("JaCarta PKI/Flash");
        case 13:
            return std::string("JaCarta ГОСТ/Flash");
        case 14:
            return std::string("JaCarta ГОСТ/Flash");
        case 15:
            return std::string("JaCarta ГОСТ/Flash");
        case 16:
            return std::string("JaCarta PKI/GOST/Flash");
        case 17:
            return std::string("JaCarta PKI/GOST/Flash");
        case 18:
            return std::string("JaCarta PKI/GOST/Flash");
    }
    return "Unknown model";
}
