#include "include/pdf_view/pdf_view_plugin.h"

#include "pdf_view_view_factory.h"

#include <flutter_linux/flutter_linux.h>

#define PDF_VIEW_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), pdf_view_plugin_get_type(), PdfViewPlugin))

struct _PdfViewPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(PdfViewPlugin, pdf_view_plugin, g_object_get_type())

static void pdf_view_plugin_class_init(PdfViewPluginClass* klass) {}

static void pdf_view_plugin_init(PdfViewPlugin* self) {}

void pdf_view_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  PdfViewPlugin* plugin =
      PDF_VIEW_PLUGIN(g_object_new(pdf_view_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  PdfViewViewFactory* factory = pdfview_view_factory_new(messenger);
  fl_plugin_registrar_register_view_factory(registrar,
                                            FL_PLATFORM_VIEW_FACTORY(factory),
                                            "plugins.flutter.io/pdfview");

  g_object_unref(plugin);
}
