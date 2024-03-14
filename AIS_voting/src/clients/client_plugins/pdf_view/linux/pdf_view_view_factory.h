#ifndef PDFVIEW_VIEW_FACTORY_PRIVATE_H_
#define PDFVIEW_VIEW_FACTORY_PRIVATE_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(PdfViewViewFactory,
                     pdfview_view_factory,
                     PDFVIEW,
                     VIEW_FACTORY,
                     GObject)

PdfViewViewFactory* pdfview_view_factory_new(FlBinaryMessenger* messenger);

G_END_DECLS

#endif  // PDFVIEW_VIEW_FACTORY_PRIVATE_H_
