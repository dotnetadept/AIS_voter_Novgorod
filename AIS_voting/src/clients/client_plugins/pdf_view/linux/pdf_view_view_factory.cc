#include "pdf_view_view_factory.h"

#include "pdf_view_platform_view.h"

static void pdfview_view_factory_fl_platform_view_factory_iface_init(
    FlPlatformViewFactoryInterface* iface);

struct _PdfViewViewFactory {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
};

G_DEFINE_TYPE_WITH_CODE(
    PdfViewViewFactory,
    pdfview_view_factory,
    G_TYPE_OBJECT,
    G_IMPLEMENT_INTERFACE(
        fl_platform_view_factory_get_type(),
        pdfview_view_factory_fl_platform_view_factory_iface_init))

static FlPlatformView* pdfview_view_factory_create_platform_view(
    FlPlatformViewFactory* factory,
    int64_t view_identifier,
    FlValue* args) {
  g_return_val_if_fail(PDFVIEW_IS_VIEW_FACTORY(factory), nullptr);
  PdfViewViewFactory* self = PDFVIEW_VIEW_FACTORY(factory);
  return FL_PLATFORM_VIEW(
      pdfview_platform_view_new(self->messenger, view_identifier, args));
}

static FlMessageCodec* pdfview_view_factory_get_create_arguments_codec(
    FlPlatformViewFactory* self) {
  return FL_MESSAGE_CODEC(fl_standard_message_codec_new());
}

static void pdfview_view_factory_fl_platform_view_factory_iface_init(
    FlPlatformViewFactoryInterface* iface) {
  iface->create_platform_view = pdfview_view_factory_create_platform_view;
  iface->get_create_arguments_codec =
      pdfview_view_factory_get_create_arguments_codec;
}

static void pdfview_view_factory_class_init(PdfViewViewFactoryClass* klass) {}

static void pdfview_view_factory_init(PdfViewViewFactory* self) {}

PdfViewViewFactory* pdfview_view_factory_new(FlBinaryMessenger* messenger) {
  PdfViewViewFactory* view_factory = PDFVIEW_VIEW_FACTORY(
      g_object_new(pdfview_view_factory_get_type(), nullptr));
  view_factory->messenger = messenger;
  return view_factory;
}
