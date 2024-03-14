#include "pdf_view_platform_view.h"
#include <unistd.h>
#include <iostream>
#include <string>

#include "poppler.h"
#include "cairo.h"
#include "evince/evince-document.h"
#include "evince/evince-view.h"
#include "evince/shell/ev-window.h"
#include "evince/shell/ev-window.c"
#include "gdk/gdk.h"
#include "gio/gio.h"

using namespace std;


struct _PdfViewPlatformView {
  FlPlatformView parent_instance;

  int64_t view_identifier;

  GtkWidget * pdfview;
};

static GtkWidget * evview;
static char * _currentDocUri;
static gboolean _isLoad;

G_DEFINE_TYPE(PdfViewPlatformView,
              pdfview_platform_view,
              fl_platform_view_get_type())

static void pdfview_platform_view_dispose(GObject * object) {
  // hide document view window under the main app window
  gtk_window_set_keep_above(GTK_WINDOW(evview), FALSE);
  gtk_widget_hide(GTK_WIDGET(evview));

  // dispose pdfview plugin widget
  PdfViewPlatformView * self = PDFVIEW_PLATFORM_VIEW(object);

  // return focus to main window
  GtkWidget *toplevel = gtk_widget_get_toplevel(GTK_WIDGET(self->pdfview));
  if (gtk_widget_is_toplevel(toplevel)) {
    gtk_widget_grab_focus(GTK_WIDGET(toplevel));
  }

  g_clear_object(&self->pdfview);
  G_OBJECT_CLASS(pdfview_platform_view_parent_class)->dispose(object);
}

static GtkWidget* pdfview_platform_view_get_view(
    FlPlatformView* platform_view) {
  g_return_val_if_fail(PDFVIEW_IS_PLATFORM_VIEW(platform_view), nullptr);
  PdfViewPlatformView* self = PDFVIEW_PLATFORM_VIEW(platform_view);
  return GTK_WIDGET(self->pdfview);
}

static void pdfview_platform_view_class_init(PdfViewPlatformViewClass * klass) {
  G_OBJECT_CLASS(klass)->dispose = pdfview_platform_view_dispose;

  FL_PLATFORM_VIEW_CLASS(klass)->get_view = pdfview_platform_view_get_view;
}

static void pdfview_platform_view_init(PdfViewPlatformView* platform_view) {
  ev_init();
}

static void evview_window_show(GtkWidget *widget, 
//cairo_t *cr, 
 gpointer *user_data) {
  const gchar * load_uri =  (gchar *)user_data;

  if(_isLoad == FALSE) {

    _isLoad = TRUE;

    if(_currentDocUri == NULL || strcmp((char *)load_uri, _currentDocUri) != 0) {
      // destroy prev window to release prev doc
      if(GTK_IS_WINDOW(evview)) {
        gtk_window_close(GTK_WINDOW(evview));
        gtk_widget_destroy(GTK_WIDGET(evview));
        evview = NULL;
      }

      // initialization of new outer evince window
      evview = ev_window_new();

      // get display size for window sizing and screen adjustment
      GdkRectangle workarea = {0};
      gdk_monitor_get_workarea(gdk_display_get_primary_monitor(gdk_display_get_default()), &workarea);

      gtk_window_set_default_size(GTK_WINDOW(evview), workarea.width, workarea.height - 162);
      gtk_window_set_decorated(GTK_WINDOW(evview), FALSE);
      gtk_window_set_resizable(GTK_WINDOW(evview), FALSE);

      // read document
      GError * error = NULL;
      EvDocument * document = ev_document_factory_get_document_for_gfile (g_file_new_for_uri(load_uri), EV_DOCUMENT_LOAD_FLAG_NONE, NULL, &error);
      if (error) {
        printf ("Error : %s", error->message);
      } 

      // set document to window
      ev_window_open_document(EV_WINDOW(evview), EV_DOCUMENT(document), NULL,	EV_WINDOW_MODE_NORMAL, NULL);

      gtk_widget_queue_draw(GTK_WIDGET(evview));

      _currentDocUri = strdup((char *)load_uri);
    } 

    // show document window above main window
    gtk_window_move(GTK_WINDOW(evview), 0, 80);
    gtk_window_set_keep_above (GTK_WINDOW(evview), true);
    gtk_widget_show(GTK_WIDGET(evview));
    gtk_widget_grab_focus(GTK_WIDGET(evview));
  }
}

PdfViewPlatformView * pdfview_platform_view_new(FlBinaryMessenger* messenger,
                                               int64_t view_identifier,
                                               FlValue* args) {
  _isLoad = FALSE;                                               
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    g_error("PdfView creation params expected a map");
    return nullptr;
  }

  FlValue* uri = fl_value_lookup_string(args, "uri");
  if (uri && fl_value_get_type(uri) == FL_VALUE_TYPE_STRING) {
    printf("URI: %s\n", fl_value_get_string(uri));
  }  
  
  PdfViewPlatformView* view = PDFVIEW_PLATFORM_VIEW(
      g_object_new(pdfview_platform_view_get_type(), nullptr));

  // generate stub widget
  GtkWidget * stub = gtk_vbox_new (FALSE, 0);
  //event for lazy initialization of evince window
  g_signal_connect(GTK_WIDGET(stub), "show", G_CALLBACK(evview_window_show), (gpointer)fl_value_get_string(uri));
  
  gtk_widget_show(stub);

  view->pdfview = GTK_WIDGET(stub);
  view->view_identifier = view_identifier;

  return view;
}