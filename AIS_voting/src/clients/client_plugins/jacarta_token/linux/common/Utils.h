#ifndef P11UTILS_H
#define P11UTILS_H

#include "jcPKCS11.h"

#include <string>
#include <vector>

//макрос для проверки результатов методов, которые возвращают CK_RV
#ifndef CHECK_RES
#define CHECK_RES(opRes,  funcName) \
if (opRes != CKR_OK) \
{ \
    P11Utils::PrintError(funcName, opRes); \
    goto end; \
}
#endif //CHECK_RES

class P11Utils
{
    public:
        // преобразовать набор символов определенный длины с пробелами в конце в строку
        static std::string CK2string(CK_BYTE * ptr, CK_ULONG len);
        // напечатать описание кода ошибки
        static void PrintError(const char * pFunctionName, CK_RV retCode);
        // преобразовать код модели в маркетинговое название
        static std::string DecryptModel(CK_UTF8CHAR_PTR pModel, CK_ULONG modelSize);
};

extern std::string S_DEFAULT_LASER_USER_PIN;  // ПИН-код по-умолчанию для апплета типа LASER
extern std::string S_DEFAULT_LASER_ADMIN_PIN; // ПИН-код по-умолчанию для апплета типа LASER

extern std::string S_DEFAULT_STORAGE_USER_PIN; // ПИН-код по-умолчанию для апплета типа DataStore
extern std::string S_DEFAULT_STORAGE_ADMIN_PIN;

extern std::string S_LABEL_PUBLIC;  // метка для публичного ключа из ключевой пары
extern std::string S_LABEL_PRIVATE; // метка для приватного ключа из ключевой пары
extern std::string S_LABEL_CERT; // метка для сертификата

extern std::string S_LABEL_DATA; // метка для объекта данных

#endif //P11UTILS_H
