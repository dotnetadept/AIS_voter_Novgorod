#ifndef PDFVIEW_PLATFORM_VIEW_H_
#define PDFVIEW_PLATFORM_VIEW_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(PdfViewPlatformView,
                     pdfview_platform_view,
                     PDFVIEW,
                     PLATFORM_VIEW,
                     FlPlatformView)

PdfViewPlatformView* pdfview_platform_view_new(FlBinaryMessenger* messenger,
                                               int64_t view_identifier,
                                               FlValue* args);

G_END_DECLS

#endif  // PDFVIEW_PLATFORM_VIEW_H_
