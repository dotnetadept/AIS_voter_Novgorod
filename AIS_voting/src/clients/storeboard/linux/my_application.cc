#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  //GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
  //gtk_widget_show(GTK_WIDGET(header_bar));
  //gtk_header_bar_set_title(header_bar, "Табло v1.33");
  //gtk_header_bar_set_show_close_button(header_bar, TRUE);
  //gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  //gtk_window_set_default_size(window, 1800, 1000);
  //gtk_widget_set_size_request(GTK_WIDGET(window), 1280,
  //                            720);
  //gtk_window_fullscreen(window);

  GdkRectangle workarea = {0};
  gdk_monitor_get_workarea(
    gdk_display_get_primary_monitor(gdk_display_get_default()),
    &workarea);

  printf("Табло запущено"); //v1.33
  printf ("Width: %u x Height:%u\n", workarea.width, workarea.height);
  
  gtk_window_set_default_size(window, workarea.width, workarea.height);
  gtk_window_set_title (GTK_WINDOW(window), "Табло"); //v1.33
  gtk_window_set_decorated (GTK_WINDOW (window), FALSE);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  //gtk_window_set_resizable(window, FALSE);
  gtk_window_fullscreen(GTK_WINDOW(window));

  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     nullptr));
}
