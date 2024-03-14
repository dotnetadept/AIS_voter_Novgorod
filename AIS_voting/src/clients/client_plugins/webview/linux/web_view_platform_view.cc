#include "web_view_platform_view.h"
#include <webkit2/webkit2.h>
#include <unistd.h>
#include <iostream>
#include <string>
using namespace std;

struct _WebViewPlatformView {
  FlPlatformView parent_instance;

  int64_t view_identifier;

  WebKitWebView* webview;
};

G_DEFINE_TYPE(WebViewPlatformView,
              webview_platform_view,
              fl_platform_view_get_type())

static void webview_platform_view_dispose(GObject* object) {
  WebViewPlatformView* self = WEBVIEW_PLATFORM_VIEW(object);

  g_clear_object(&self->webview);

  G_OBJECT_CLASS(webview_platform_view_parent_class)->dispose(object);
}

static GtkWidget* webview_platform_view_get_view(
    FlPlatformView* platform_view) {
  g_return_val_if_fail(WEBVIEW_IS_PLATFORM_VIEW(platform_view), nullptr);
  WebViewPlatformView* self = WEBVIEW_PLATFORM_VIEW(platform_view);
  return GTK_WIDGET(self->webview);
}

static void webview_platform_view_class_init(WebViewPlatformViewClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = webview_platform_view_dispose;

  FL_PLATFORM_VIEW_CLASS(klass)->get_view = webview_platform_view_get_view;
}

static void webview_platform_view_init(WebViewPlatformView* platform_view) {}

static void on_resource_load (WebKitWebView* web_view,
               WebKitWebResource* resource,
               WebKitURIRequest* request,
               gpointer user_data) {   
    gtk_widget_queue_resize(GTK_WIDGET(web_view));
}

WebViewPlatformView* webview_platform_view_new(FlBinaryMessenger* messenger,
                                               int64_t view_identifier,
                                               FlValue* args) {
                                                 
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    g_error("WebView creation params expected a map");
    return nullptr;
  }

  WebKitWebContext* ctx = webkit_web_context_get_default();

  //Find path
  char cwd[100];
  if (getcwd(cwd, sizeof(cwd)) != NULL) {
      printf("Текущая рабочая директория: %s\n", cwd);
  }

  const char* path= "/data/flutter_assets/assets/cookie/cookie.txt";

  char* full_path = new char[strlen(cwd)+strlen(path)+1]; 
  strcpy(full_path, cwd); 
  strcat(full_path, path);

  printf("Файл куки: %s\n", full_path);

  //Set cookie storage
  webkit_cookie_manager_set_persistent_storage
                               (webkit_web_context_get_cookie_manager(ctx),
                                full_path,
                                WEBKIT_COOKIE_PERSISTENT_STORAGE_TEXT);

  //Init new webview
  WebKitWebView* webview = WEBKIT_WEB_VIEW(webkit_web_view_new_with_context(ctx));

  //Connect signals
  g_signal_connect(webview, "resource-load-started", G_CALLBACK(on_resource_load), NULL);

  //Load url
  FlValue* uri = fl_value_lookup_string(args, "uri");
  if (uri && fl_value_get_type(uri) == FL_VALUE_TYPE_STRING) {
    printf("URI: %s\n", fl_value_get_string(uri));
    webkit_web_view_load_uri(webview, fl_value_get_string(uri));
  }

  WebViewPlatformView* view = WEBVIEW_PLATFORM_VIEW(
      g_object_new(webview_platform_view_get_type(), nullptr));

  gtk_widget_queue_resize(GTK_WIDGET(webview));
  view->webview = webview;
  view->view_identifier = view_identifier;
  return view;
}

