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
  g_application_set_application_id(application, "com.example.operator_panel");

  // GdkRectangle workarea = {0};
  // gdk_monitor_get_workarea(
  //   gdk_display_get_primary_monitor(gdk_display_get_default()),
  //   &workarea);

  printf("Рабочее место оператора v1.32 запущено\n");

  GdkDisplay *display = gdk_display_get_default();
  int n_monitors = gdk_display_get_n_monitors(display);
  printf ("Найдено мониторов: %u\n", n_monitors);

  bool isResolutionSet = false;
  for (int nth = 0; nth < n_monitors; nth++) 
  {
    GdkMonitor *monitor = gdk_display_get_monitor(display, nth);
    GdkRectangle geo;
    gdk_monitor_get_geometry(monitor, &geo);

    if(geo.width > 0 && geo.height >0){
      gtk_window_set_default_size(window, geo.width, geo.height);
      printf ("Width: %u x Height:%u\n", geo.width, geo.height);
      isResolutionSet = true;
      break;
    }
  }

  if(!isResolutionSet) {
     gtk_window_set_default_size(window, 1920, 1080);
     printf ("Set default Width: %u x Height:%u\n", 1920, 1080);
  }

  
  //GdkMonitor *monitor = gdk_display_get_primary_monitor(gdk_display_get_default());
  //GdkRectangle geo;
  //gdk_monitor_get_geometry(monitor, &geo);
  
  //gtk_window_set_default_size(window, workarea.width, workarea.height);

  //gtk_window_set_default_size(window, geo.width, geo.height);
  
  //printf ("Width: %u x Height:%u\n", workarea.width, workarea.height);

  gtk_window_set_title (GTK_WINDOW(window), "Рабочее место оператора v1.32");
  gtk_window_set_decorated (GTK_WINDOW (window), FALSE);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_resizable(window, FALSE);
  
  gtk_widget_show(GTK_WIDGET(window));
  //gtk_window_set_keep_above(window, TRUE);

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
