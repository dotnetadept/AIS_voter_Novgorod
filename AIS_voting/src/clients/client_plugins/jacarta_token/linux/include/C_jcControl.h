#ifndef JC_CONTROL_H
#define JC_CONTROL_H

#include "jcPKCS11.h"

#include <stdint.h>
/*  ��� ������� � ��������� ��������� � ���� ����� �������� ����������� � �� ������������� ��� ������������� */


/*! 
* \typedef C_jcCtrl
* \deprecated 
* \brief ��������� �� �����, ����������� ��������� �������� �� SWYX-������������
* \param slotID - �������������(�����) �����. ��� ����� ����� �������� � ������� C_GetSlotList
* \param operation - ��� �������� (��. #C_JCCTRL_OPERATION_CODES)
* \param pData - ��������� �� ������ ���� � ������� ����� �������� �������� ������, ��� ��������� ��� �����������(� ������ �������� #JC_CTRL_SWYX_DISPLAY)
* ��� ����������� �������� ��������� � ��������� ������ �������� ��. �������� ��������� #C_JCCTRL_OPERATION_CODES
* \param ulDataLen - ��������� �� ����� ������� � ��������� ��� �������� (� ������ �������� #JC_CTRL_SWYX_DISPLAY) �������
* ��� ����������� �������� ��������� � ��������� ������ �������� ��. �������� ��������� #C_JCCTRL_OPERATION_CODES
* \return ��� ���������� � �������� PKCS11
**/
#ifdef __cplusplus
extern "C"
{
#endif

#define CK_PKCS11_FUNCTION_INFO(name) extern CK_DECLARE_FUNCTION(CK_RV, name)
CK_PKCS11_FUNCTION_INFO(C_jcCtrl)(CK_ULONG slotId, CK_ULONG operation, CK_VOID_PTR pData, CK_ULONG_PTR ulDataLen);
#undef CK_PKCS11_FUNCTION_INFO

#define CK_PKCS11_FUNCTION_INFO(name) typedef CK_DECLARE_FUNCTION_POINTER(CK_RV, __PASTE(FP_,name))
CK_PKCS11_FUNCTION_INFO(C_jcCtrl)(CK_ULONG slotId, CK_ULONG operation, CK_VOID_PTR pData, CK_ULONG_PTR ulDataLen);
#undef CK_PKCS11_FUNCTION_INFO

#ifdef __cplusplus
}
#endif

#pragma pack(push,1)

#define JC_CTRL_BIOMETRIC 0x8000

/* ���� �������� ��� ������ jc_ctrl */
enum C_JCCTRL_OPERATION_CODES
{
    /// �������� �������� SWYX-�����������. ��������� #C_JCCTRL: � pData  ����� �������� �������� � ���� ��������� #_SWYX_PROPERTIES_RESPONSE (����� ���� � little endian),
    /// ulDataLen ����� ��������� ������ ��������� �� ���������� (������ ���� 12 ����)
    JC_CTRL_GET_PROPERTIES = 0,
    /// �������� SWYX-�����.  ��������� pData � ulDataLen � #C_JCCTRL �� ������������
    JC_CTRL_SWYX_START = 1,
    /// ��������� SWYX-����� � �������� ��� + �������.  ��������� #C_JCCTRL: � pData ����� ������� ��� � ������� xml + 64 ����� ������� � �����,
    /// ulDataLen ����� ��������� ��������� ������ ���� � �������
    JC_CTRL_SWYX_STOP = 2,
    /// ���������� ����� �� ������ SWYX-����������� � ���������� ������������ ��������� ���. ��������� #C_JCCTRL: �
    /// pData ������ ��������� ��������� #SWYX_DISPLAY_ARGUMENTS, ulDataLen - ������ ���� ���������.
    /// � ������ ���� ������������ ������� �������� �������, ����� C_JCCTRL ������ CKR_FUNCTION_REJECTED (0x00000200),
    /// � ������ ����-���� - CKR_FUNCTION_CANCELED (0x00000050)
    JC_CTRL_SWYX_DISPLAY = 3,
    /// ������������� ����� �������� ���� �� SWYX-�����������. ��������� pData � ulDataLen � #C_JCCTRL �� ������������.
    /// � ������, ���� ������������ ������� �������� ����� C_JCCTRL ������ CKR_FUNCTION_REJECTED (0x00000200)
    JC_CTRL_PERSONALIZE = 4,
    /// �������� �������� ���� SWYX-�����������. ��������� #C_JCCTRL: pData - ������ ��������� �������� ����, ulDataLen - ������ ����� ����� (������ ���� 64 �����)
    JC_CTRL_ENROLL = 5,
    /// �������� �������� ����� �������, ������������ ������ SWYX-�����������. ��������� #C_JCCTRL: pData ������ ��������� �������� �����, ulDataLen - ��� ����� (������ ���� 8 ����)
    JC_CTRL_SWYX_GET_APPLET_SN = 6,
    /// ��������� ���-��� ������������. ��������� pData � ulDataLen � #C_JCCTRL �� ������������.  � ������, ���� ������������ ������� ��������,
    /// ����� #C_JCCTRL ������ CKR_FUNCTION_REJECTED (0x00000200), � ������ ���� ���� ����� (30 ������) - CKR_FUNCTION_CANCELED (0x00000050)
    JC_CTRL_PIN_VERIFY = 7,
    /// ���������� ����� ������������ ��� Jacarta MicroSD. ��������� #C_JCCTRL: pData - ������ ��������� ������ � ���������� ����� �� ����� ������������ Jacarta MicroSD, ulDataLen - ����� ���� ������
    JC_CTRL_SET_MOUNT_INFO = 8,
    /// �������� ����� ������������ ��� Jacarta MicroSD. ��������� #C_JCCTRL: pData - ����� ������ � ���������� ����� �� ����� ������������ Jacarta MicroSD, ulDataLen - ����� ���� ������
    JC_CTRL_GET_MOUNT_INFO = 9,
    /// �������� ������������� ������ ������� � ���� ������������
    JC_CTRL_GET_ISD_DATA = 10,
    // ��������� ���������� �������������� ��� PKI ������� (LASER). ��������� �� ���� ��������� �� ��������� JCCTRL_PerosnalizationData
    JC_CTRL_PKI_SET_COMPLEXITY = 13,
    /// ���������������� ��������� ��������������� ����� � ������� �����������-1. ����� ������� ������ ������������. ��������� �������.
    JC_CTRL_INIT_CT1_PRNG = 14,
    /// ��������� ���������� ����� � �������� ���� �����������-1. ����� ������� ������ ������������. ��������� �������.
    JC_CTRL_DO_TESTS_CT1 = 15,
    /// ��������� ���������� �������������� ��� PKI ������ (LASER). ��������� ��������� JCCTRL_PerosnalizationData �������� ����������� ��������������
    JC_CTRL_PKI_GET_COMPLEXITY = 16,
    /// ������� ����������� ����� Laser. ����� ������� ������ ��������������. ��������� �������.
    JC_CTRL_PKI_WIPE_CARD = 17,
    /// ������������� PIN - ���� ������������, ����� �������� ��������.���������: ��������� �� ��������� INIT_PIN_ARGUMENTS � �� ������.
    JC_CTRL_PIN_INIT = 18,
    /// ���������� ����� ������ - ��� ���� �������. ����� ������� ������ ������������. pData - ��������� �� ����� ���� CK_UTF8CHAR_PTR, ulDataLen - ������ ����� � ������, �� �� ����� 32
    JC_CTRL_SET_LABEL = 21,
    /// �������� �������� ���-����� ��� Laser. pData - ��������� �� ��������� JC_CTRL_PKI_PIN_INFO, ulDataLen - sizeof(JC_CTRL_PKI_PIN_INFO)
    JC_CTRL_PKI_GET_PIN_INFO = 26,
    /// �������� challenge ��� ������� �������������� Laser. pData - ��������� �� ����� ��� challenge, ulDataLen - ������ ������
    JC_CTRL_PKI_GET_CHALLENGE = 27,
    ///���������� ������������ ���� ��� BIO ��������. pData - HWND, ulDataLen - NULL
    JC_CTRL_PKI_SET_BIO_PARENT_HWND = 30,
    ///�������������� ��� ������������. ������� �������������� ���������������. pData - HWND, ulDataLen - NULL. ���������� CKR_CANNOT_UNLOCK ���� ������������� �� ��������
    JC_CTRL_PKI_UNLOCK_USER_PIN = 33,

    // �������������� �������
    // ��������� ��������� JC_BIO_SUPPORT_INFO � ����������� � �������������� ������ �������������� ������������
    JC_CTRL_BIOMETRIC_GET_SUPPORTED = JC_CTRL_BIOMETRIC | 12,
    // ��������� ��������� JC_CTRL_AUTHTYPE � ���������� � �������������� ������ ���������� ��������������
    JC_CTRL_BIOMETRIC_GET_AUTHTYPE = JC_CTRL_BIOMETRIC | 13,
    // ��������� ��������������� ������������������ ������� (0x01-0x0A) �� 0 �� 10 ����
    JC_CTRL_BIOMETRIC_GET_ENROLLED_FINGERS_INDEXES = JC_CTRL_BIOMETRIC | 14,
    // ��������� ��������� �������������� ���������� � ������ �� ��� �������. ������ �������� ������ ������ pData, ��������� ���������� � pData
    JC_CTRL_BIOMETRIC_GET_PUBLIC_DATA = JC_CTRL_BIOMETRIC | 15,
    // ����������� ��������� �� �����, pData ������ ��������� ������� �� ��������� JC_CTRL_BIOMETRIC_ENROLL_DATA
    JC_CTRL_BIOMETRIC_ENROLL_FINGER = JC_CTRL_BIOMETRIC | 16,
    // �������� ��������� �� �������, ������ ���� pData ������ ��������� ������ ���������
    JC_CTRL_BIOMETRIC_DELIST_FINGER = JC_CTRL_BIOMETRIC | 17,
    // ��������� ���� � �������������� ����������. �� ��������� ������������ jcBIO.dll � ������� �����
    JC_CTRL_BIOMETRIC_SET_LIBRARY = JC_CTRL_BIOMETRIC | 18
};

struct SWYX_DISPLAY_ARGUMENTS
{
    /// ����-��� ������������� �������. 1 ������� - 5 ������. 0 - ����� ����������
    CK_BYTE swyxDisplayTimeout;
    /// ����� ��� ����������� �� ������ ����������� � ��������� UTF8 ������ �� 5 �� 400 ��������
    CK_UTF8CHAR_PTR text;
    /// ����� ������
    CK_ULONG textLength;
};

struct CHECK_PIN_ARGUMENTS
{
    /// ��� ������������
    CK_USER_TYPE userType;
    /// ���-���
    CK_UTF8CHAR_PTR pPin;
    /// ����� ���-����
    CK_ULONG ulPinLen;
};

struct INIT_PIN_ARGUMENTS
{
    /// ��� �����. 0x0409 - ����������, 0x0419 - �������.
    CK_ULONG wLangId;
    /// ��������� �� ���������� ����� ���-���� ��� �������������.
    CK_BBOOL confirmRequired;
};

typedef struct
{
    // ������
    CK_UTF8CHAR model[32];
    // ���� ������������ � ������� �������� ( 1 ��� 2010 = 20100501 )
    CK_BYTE manufacturingDate[8];
} IDS_DATA;

enum JC_CTRL_BIOMETRY_TYPE
{
    JC_CTRL_BIOMETRY_TYPE_PRECISE_BIOMATCH = 0x81,
    JC_CTRL_BIOMETRY_TYPE_PRECISE_ANSI = 0x82,
    JC_CTRL_BIOMETRY_TYPE_NEUROTECHNOLOGY_MEGAMATCHER = 0x83,
    JC_CTRL_BIOMETRY_TYPE_PRECISE_ISO = 0x84,
    JC_CTRL_BIOMETRY_TYPE_ID3_ISO = 0x85
};

// ���� ������ ��� ��������� ���������
enum JC_CTRL_AUTHTYPE
{
    JC_CTRL_AUTHTYPE_PIN = 0x01,
    JC_CTRL_AUTHTYPE_BIO = 0x03,
    JC_CTRL_AUTHTYPE_PIN_OR_BIO = 0x04,
    JC_CTRL_AUTHTYPE_PIN_AND_BIO = 0x05
};

struct JC_CTRL_BIOMETRIC_ENROLL_DATA
{
    /**
     @brief ������������� ������ 1-������� ����� ���� - 10-������� ������ ����.
     */
    CK_BYTE m_FingerIndex;

    /**
     @brief ��������� �������������� ������ (���������� �� SDK)
     */
    CK_BYTE * m_PublicData;
    CK_ULONG m_PublicDataLen;
    /**
    @brief ������ �������������� ������ (���������� �� SDK)
    */
    CK_BYTE * m_PrivateData;
    CK_ULONG m_PrivateDataLen;
    /**
    @brief �������� ����������, ������������ ��� ���������� +++ �� ������ ������� ����� ��� ����� � ����� ���� ����������� �� ��� ��������
    */
    CK_BYTE * m_DeviceName;
    CK_ULONG m_DeviceNameLen;
};

struct JC_BIO_AUTH_DATA
{
    CK_BYTE * m_Image;
    CK_ULONG m_ImageLen;
    CK_ULONG m_FingerIndex;
};

struct JC_BIO_SUPPORT_INFO
{
    /** �������������� �� ���������
    */
    CK_BBOOL m_BiometryEnabled;

    /**
     @brief ��� ��������������, ��. �������� JC_CTRL_AUTHTYPE
     */
    enum JC_CTRL_AUTHTYPE m_AuthType;
    /** ����� �������������� ������ (������ 3)
    */
    CK_ULONG m_OptionalDataLength;
    /** ��������� �� �������������� ������. ������ ������� �� 0 � ����� 3-� �������� �������������������:
    1) ������������� ���������� ��������� (JC_CTRL_BIOMETRY_TYPE)
    2) ������������ ��� ��� �������� ���������� ��������� (01 ���� ������������)
    3) ������������ �� �������� ���������� ��������� �� ��������� (01 ���� ������������)
    */
    CK_BYTE_PTR m_OptionalData;
};

typedef enum
{
    UserPINTypeUndefined = 0x00,
    UserPINTypePIN = 0x01,
    UserPINTypeBio = 0x03,
    UserPINTypePINorBIO = 0x04,
    UserPINTypePINandBIO = 0x05
} EUserPINType;

typedef enum
{
    SecureMessagingMode_OFF = 0x00,
    SecureMessagingMode_RSA = 0x01,
    SecureMessagingMode_EC = 0x02
} ESecureMessagingMode;

enum JC_BIO_PURPOSE
{
    JC_BIO_PURPOSE_FAR_100      = (0x7fffffff / 100),
    JC_BIO_PURPOSE_FAR_1000     = (0x7fffffff / 1000),
    JC_BIO_PURPOSE_FAR_10000    = (0x7fffffff / 10000),
    JC_BIO_PURPOSE_FAR_100000   = (0x7fffffff / 100000),
    JC_BIO_PURPOSE_FAR_1000000  = (0x7fffffff / 1000000)
};

// ��������� �������� ��������, �� ������ ���� ����������� �������� �� ������� �������, ��� � ������������ C_Control set complexity
struct JCCTRL_PersonalizationData
{
    uint8_t IsPersonalized; // 1 - ������ ����������������, 0 - �� ����������������

    uint16_t MaxDFSize;
    uint8_t UserMaxAttempts;
    uint8_t UserMaxUnblock;
    uint8_t AdminMaxAttempts;
    uint8_t AdminIsChalResp;
    EUserPINType UserPinType;

    // not used
    uint8_t CardType;

    // 00
    uint8_t UserMinChars;
    uint8_t UserMaxChars;
    uint8_t UserMinAlphaChars;
    uint8_t UserMinLowerChars;
    uint8_t UserMinUpperChars;
    // 00
    uint8_t UserMinDigits;
    uint8_t UserMinNonAlphaChars;
    uint8_t UserPinHistorySize;

    // ��������� ��� ���� ��������������. ����������� ��� 3des
    // 00
    uint8_t AdminMinChars;
    uint8_t AdminMaxChars;
    uint8_t AdminMinAlphaChars;
    uint8_t AdminMinLowerChars;
    uint8_t AdminMinUpperChars;
    // 00
    uint8_t AdminMinDigits;
    uint8_t AdminMinNonAlphaChars;
    // 00

    uint32_t UserPINValidForSeconds;
    uint32_t UserPINExpiresAfterDays;
    uint8_t AllowCardWipe;
    uint8_t BioImageQuality;
    uint32_t BioPurpose;
    uint8_t BioMaxFingers;

    uint8_t X931Use;
    uint8_t BioMaxUnblock;
    uint8_t UserMustChangeAfterUnlock;

    uint8_t UserMaxRepeatingPin;
    uint8_t UserMaxSequencePin;

    uint8_t AdminMaxRepeatingPin;
    uint8_t AdminMaxSequencePin;

    // digital signature specific
    uint8_t DSSupport;
    uint8_t MaxRSA1024Keys;
    uint8_t MaxRSA2048Keys;

    uint8_t DSPinMaxChars;
    uint8_t DSPinMinChars;
    uint8_t DSPinMinDigits;
    uint8_t DSPinMinAlphaChars;
    uint8_t DSPinMinNonAlphaChars;
    // 00
    uint8_t DSPinMinLowerChars;
    uint8_t DSPinMinUpperChars;
    uint8_t DSPinMinAlphabeticChars;
    uint8_t DSPinMaxRepeatingPin;
    uint8_t DSPinMaxSequencePin;
    uint8_t DSPinMaxUnblock;
    uint8_t DSPinMaxAttempts;

    uint8_t DSPUKMaxChars;
    uint8_t DSPUKMinChars;
    uint8_t DSPUKMinDigits;
    uint8_t DSPUKMinAlphaChars;
    uint8_t DSPUKMinNonAlphaChars;
    // 00
    uint8_t DSPUKMinLowerChars;
    uint8_t DSPUKMinUpperChars;
    uint8_t DSPUKMinAlphabeticChars;
    uint8_t DSPUKMaxRepeatingPin;
    uint8_t DSPUKMaxSequencePin;
    uint8_t DSPUKMaxUnblock;
    uint8_t DSPUKMaxAttempts;

    uint8_t DSSynchronizationOption;
    uint8_t DSVerificationPolicy;
    uint8_t DSActivationPINValue[16];
    uint8_t DSActivationPINLen;
    uint8_t DSDeactivationPINValue[16];
    uint8_t DSDeactivationPINLen;

    uint8_t UserPinAlways;

    uint8_t BioType;

    uint8_t UserMustChangeAfterFirstUse;
    uint8_t StartDate[8];

    uint8_t DefaultFinger;

    //����� ������ ����� ������� � �����������
    ESecureMessagingMode SecureMessagingMode;

    //����� ������ ���-���� ��������������. �.�. = 0
    uint8_t NewAdminPinLength;
    //����� ������ ���-���� �������������
    uint8_t NewAdminPin[16];
};

struct JC_CTRL_PKI_PIN_INFO
{
    /**
    * ���������� ������� ����� ���-���� ������������
    */
    CK_BYTE UserPinRemains;
    /**
    * ���������� ������� �������������� ������������ ����� BIO
    */
    CK_BYTE UserBioPinRemains;
    /**
    * ���������� ������� ����� ���-���� ��������������
    */
    CK_BYTE AdminPinRemains;
};

/*!
* \brief ��������� �� �����, ����������� ��������� �������� �� SWYX-������������
* \param slotID - �������������(�����) �����. ��� ����� ����� �������� � ������� C_GetSlotList
* \param operation - ��� �������� (��. #JC_ANTIFRAUD_OPERATION_CODES)
* \param pArgument - ��������� �� ��������� ����������, ��� ����������� �������� ��������� � ��������� ������ ��������
* ��. �������� ��������� #JC_ANTIFRAUD_OPERATION_CODES
* \param ulArgumentDataLen - ����� ��������� �������
* \param pResultingData - ��������� �� ������ ���� � ������� ����� �������� �������� ������
* ��� ����������� �������� ��������� � ��������� ������ �������� ��. �������� ��������� #JC_ANTIFRAUD_OPERATION_CODES
* \param pulResultingDataLen - ��������� �� �����: ��� ����� ���������� ������� ���������� ����� ������ pResultingData,
* ��� ������ JC_AFT ���������� ����� ������
* ��� ����������� �������� ��������� � ��������� ������ �������� ��. �������� ��������� #JC_ANTIFRAUD_OPERATION_CODES
* \return ��� ���������� � �������� PKCS11
**/#ifdef __cplusplus
extern "C" {
#endif

#define CK_PKCS11_FUNCTION_INFO(name) extern CK_DECLARE_FUNCTION(CK_RV, name)
    CK_PKCS11_FUNCTION_INFO(JC_Antifraud)(CK_ULONG slotId, CK_ULONG operation, CK_BYTE_PTR pArgument, CK_ULONG ulArgumentDataLen, CK_BYTE_PTR pResultingData, CK_ULONG_PTR pulResultingDataLen);
#undef CK_PKCS11_FUNCTION_INFO

#define CK_PKCS11_FUNCTION_INFO(name) typedef CK_DECLARE_FUNCTION_POINTER(CK_RV, __PASTE(FP_,name))
    CK_PKCS11_FUNCTION_INFO(JC_Antifraud)(CK_ULONG slotId, CK_ULONG operation, CK_BYTE_PTR pArgument, CK_ULONG ulArgumentDataLen, CK_BYTE_PTR pResultingData, CK_ULONG_PTR pulResultingDataLen);
#undef CK_PKCS11_FUNCTION_INFO

#ifdef __cplusplus
}
#endif

enum JC_ANTIFRAUD_OPERATION_CODES
{
    /// ��������� PIN-���� (������������/�������������� �� ��������� ����� ��� ����� �������������.
    /// � ��������� �� ����� AFT_PIN_VERIFY_ARGUMENTS, ��������� AFT_PIN_VERIFY_RESPONCE
    AFT_GET_READER_VERSION = 0,
    AFT_PIN_VERIFY = 1,
    AFT_PIN_MODIFY = 2,
    AFT_PIN_GET_COPY = 3,
    AFT_SWYX_START = 4,
    AFT_SWYX_STOP = 5,
    AFT_SWYX_DISPLAY = 6,
    AFT_GET_PROPERTIES = 7,
    AFT_ENROLL = 8,
    AFT_CTRL_SWYX_GET_APPLET_SN = 9,

    AFT_ENTER_ADMIN_PIN = 10,
    AFT_SAVE_ADMIN_PIN = 11,
    AFT_INIT_CARD = 12,
    AFT_SET_USER_PIN = 13,
    AFT_VERIFY_PIN = 14,

    AFT_PERFORM_PERSONALIZATION = 15,

    AFT_IS_CARDLESS_MODE_SUPPORTED = 16,
};

#define AFT_MINIMAL_APPLICATION_VERSION_FOR_CARDLESS_MODE   34

// This specification splits the 1 - byte index into two nibbles : the lower nibble(4 bits) and the higher nibble(4 bits).
// In the lower nibble(4 bits) the original index(bMsgIndex) can be programmed.In the higher nibble(4 bits) additional information can be transferred.
// This additional information in the high nibble refers to an additional text which is to be displayed on the lines below the regular PIN entry.

// The JCR - 770 reader shall use the following text(bMsgIndex low nibble, line one) :
//   bMsgIndex       English message          Russian message
//   low nibble
//   0               �Enter PIN�              �������� PIN - ���
//   1               �Enter new PIN�          �������� ����� PIN�
//   2               �Repeat PIN�             ���������� PIN�

// The JCR-770 reader shall use the following text (bMsgIndex high nibble, line two):
//   bMsgIndex       English message          Russian message
//   high nibble
//   0               (empty)                  (empty)
//   1               �of user�                ��������������
//   2               �of admin�               ����������������
//   3               �for signature�          ��������

struct AFT_GET_READER_VERSION_RESPONCE
{
    CK_CHAR m_OSVersion[4]; // ������ �� �����������
    CK_CHAR m_ApplicationVersion[4]; // ������ ���������� �����������
};

struct AFT_PIN_VERIFY_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
    CK_BYTE  m_MessageIdx1;  // ������ �������� ������� ����� �������� �� �������� ���������: 0x10/0x20/0x30 �������� PIN ������������/��������������/�������
    CK_BYTE  m_MessageIdx2;  // ������ �������� ������� ����� �������� �� �������� ���������: 0x10/0x20/0x30 �������� PIN ������������/��������������/�������
};

struct AFT_SWYX_START_ARGUMENTS
{
    CK_BYTE m_bReference[8]; // reference �������� ����� ������� � SWYX ������ �� ��������� SWYX ������
};

struct AFT_SWYX_DISPLAY_ARGUMENTS
{
    /// ����-��� ������������� �������. 1 ������� - 5 ������. 0 - ����� ����������
    CK_BYTE m_swyxDisplayTimeout;
    /// 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_ULONG m_AFTLanguage;
    /// ����� ������
    CK_ULONG m_textLength;
    CK_BYTE m_DisplayIndex; // (optional) indicator (0..1) for the bottom line. Default=0.
    /// ����� ��� ����������� �� ������ ����������� � ��������� UTF8 ������ �� 5 �� 400 ��������
    //CK_UTF8CHAR m_text[];
};

struct ATF_SWYX_PROPERTIES
{
    CK_BYTE m_DisplayType; // 0=Text Only, 1=Graphical Display
    CK_ULONG m_LcdMaxCharacters; // Maximum number of characters on a single line
    CK_ULONG m_LcdMaxLines; // Maximum number of lines that can be used
    CK_ULONG m_GraphicMaxWidth; // Width of graphic display in pixels
    CK_ULONG m_GraphicMaxHeight; // Height of graphic display in pixels
    CK_BYTE m_GraphicColorDepth; // 1=Monochrome, 2=Grayscale(4bit), 4=Color(4bit)
    CK_ULONG m_MaxVirtualSize; // max nr of characters in VISIBLE buffer
};

struct AFT_PIN_VERIFY_RESPONCE
{
    CK_BYTE m_PIN[32]; // ����������� PIN
};

struct AFT_PIN_MODIFY_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
    CK_BYTE  m_Confirmation; // 0x01 ��������� ������������� ������ ��� ����, 0x00 �� �����������
    CK_BYTE  m_MessageIdx;
};

struct AFT_ENTER_ADMIN_PIN_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
    CK_BYTE  m_Confirmation; // 0x01 ��������� ������������� ������ ��� ����, 0x00 �� �����������
    CK_BYTE  m_Message1Idx;
    CK_BYTE  m_Message2Idx;
};

struct AFT_SAVE_ADMIN_PIN_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
    CK_BYTE  m_PINLength;
    //CK_BYTE  m_PINvalue[];
};

struct AFT_INIT_CARD_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
};

struct AFT_LOGIN_SO_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
};


struct AFT_SET_USER_PIN_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
};

struct AFT_VERIFY_PIN_ARGUMENTS
{
    CK_ULONG m_AFTLanguage; // 0x0419, 0x0409 �������, ���������� ���� ������������ AFT ���������� ��� ����������� ������������
    CK_BYTE  m_AFTTimeout;  // ������� �������� ����� ������������ �� AFT ��������� � ��������, 0 ������ �� ���������
    CK_BYTE  m_MessageIdx;
};

struct AFT_IS_CARDLESS_MODE_SUPPORTED_RESPONCE
{
    CK_BYTE m_CardlessSupport; // 0 no cardless mode, 1 cardless mode support
};

#pragma pack(pop)

#endif //JC_CONTROL_H
