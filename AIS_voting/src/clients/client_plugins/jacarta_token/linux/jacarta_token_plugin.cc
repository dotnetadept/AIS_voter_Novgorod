#include "include/jacarta_token/jacarta_token_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include "common/P11Loader.h"
#include "common/Utils.h"
#include "include/pkcs11t.h"

#define JACARTA_TOKEN_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), jacarta_token_plugin_get_type(), \
                              JacartaTokenPlugin))

struct _JacartaTokenPlugin 
{
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(JacartaTokenPlugin, jacarta_token_plugin, g_object_get_type())

static CK_ULONG dataClass = CKO_DATA;
static CK_BBOOL bTrue = CK_TRUE;
static P11Loader& loader = GetLoader();

// 0 - ok, 1 - fail
static int initialize() {
	std::vector<CK_SLOT_ID> slots;
	CK_ULONG slotCount = 0;


	// Загрузка PKCS11 библиотеки
	if(loader.IsInitialized() == false) {
		return 1;
	}

	// инициализация библиотеки
	CK_RV rv = CALL_P11(C_Initialize(0));
	
	if(rv != CKR_OK) {
		return 1;
	}
	
	return 0;
}

// 0 - ok, 1 - fail
static int finalize() {
	CK_RV rv = CALL_P11(C_Finalize(NULL));

	if(rv != CKR_OK) {
		return 1;
	}

	return 0;
}

// current slot count, 0 if fails
static int get_slots() {
	CK_ULONG slotCount = 0;
  	std::vector<CK_SLOT_ID> slots;

	// получаем список слотов с подключенными токенами
	CK_RV rv = CALL_P11(C_GetSlotList(CK_TRUE, NULL, &slotCount));
	if(rv != CKR_OK) {
		return 0;
	}

	// таких слотов нет?
	if(slotCount == 0) {
		return 0;
	}
	else {
		return (int)slotCount;
	}
}

static std::string CK2string(CK_BYTE * ptr, CK_ULONG len)
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

// Fail, NotFound, JaCarta#4D310013
static std::string get_token() {
	CK_ULONG slotCount = 0;
  	std::vector<CK_SLOT_ID> slots;

	// получаем список слотов с подключенными токенами
	CK_RV rv = CALL_P11(C_GetSlotList(CK_TRUE, NULL, &slotCount));
	if(rv != CKR_OK) {
		return "Fail";
	}

	// таких слотов нет?
	if(slotCount == 0) {
		return "NotFound";
	}
	else {
		slots.resize(slotCount);

		rv = CALL_P11(C_GetSlotList(CK_TRUE, &slots[0], &slotCount));
		if(rv != CKR_OK) {
			return "Fail";
		}

		// Возвращаем токен первого слота
		CK_TOKEN_INFO tokenInfo = {};
		rv = CALL_P11(C_GetTokenInfo(slots[0], &tokenInfo));
		if(rv != CKR_OK) {
			return "Fail";
			
		}

    	return CK2string(tokenInfo.label, 32);
	}
}

// Called when a method call is received from Flutter.
static void jacarta_token_plugin_handle_method_call(
    JacartaTokenPlugin* self,
    FlMethodCall* method_call) {

  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "initialize") == 0) {
    int result = initialize();
	g_autoptr(FlValue) resultValue = fl_value_new_int(result);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(resultValue));
  }else if (strcmp(method, "initialize") == 0) {
    int result = finalize();
	g_autoptr(FlValue) resultValue = fl_value_new_int(result);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(resultValue));
  } else if (strcmp(method, "get_slots") == 0) {
    int result = get_slots();
	g_autoptr(FlValue) resultValue = fl_value_new_int(result);
	response = FL_METHOD_RESPONSE(fl_method_success_response_new(resultValue));
  } else if (strcmp(method, "get_token") == 0) {
   	std::string result = get_token();
	g_autoptr(FlValue) resultValue = fl_value_new_string(result.data());
	response = FL_METHOD_RESPONSE(fl_method_success_response_new(resultValue));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void jacarta_token_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(jacarta_token_plugin_parent_class)->dispose(object);
}

static void jacarta_token_plugin_class_init(JacartaTokenPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = jacarta_token_plugin_dispose;
}

static void jacarta_token_plugin_init(JacartaTokenPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  JacartaTokenPlugin* plugin = JACARTA_TOKEN_PLUGIN(user_data);
  jacarta_token_plugin_handle_method_call(plugin, method_call);
}

void jacarta_token_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  JacartaTokenPlugin* plugin = JACARTA_TOKEN_PLUGIN(
      g_object_new(jacarta_token_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "jacarta_token",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}