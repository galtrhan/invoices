#include "app_config.h"

#include <string.h>

namespace {

gchar* resolve_config_path() {
#ifdef APP_DEBUG_CONFIG_PATH
  return g_strdup(APP_DEBUG_CONFIG_PATH);
#else
  return g_build_filename(g_get_user_config_dir(), "invoices", "config.json",
                          nullptr);
#endif
}

gboolean parse_bool_key(const gchar* json, const gchar* key,
                        gboolean default_value) {
  g_autofree gchar* needle = g_strdup_printf("\"%s\"", key);
  const gchar* cursor = strstr(json, needle);
  if (cursor == nullptr) {
    return default_value;
  }

  cursor = strchr(cursor + strlen(needle), ':');
  if (cursor == nullptr) {
    return default_value;
  }
  ++cursor;

  while (*cursor == ' ' || *cursor == '\t' || *cursor == '\n' ||
         *cursor == '\r') {
    ++cursor;
  }

  if (g_str_has_prefix(cursor, "true")) {
    return TRUE;
  }
  if (g_str_has_prefix(cursor, "false")) {
    return FALSE;
  }
  return default_value;
}

}  // namespace

AppConfig app_config_load(void) {
  AppConfig config;
  config.window_decorations = FALSE;

  g_autofree gchar* path = resolve_config_path();
  g_autofree gchar* contents = nullptr;
  gsize length = 0;
  g_autoptr(GError) error = nullptr;

  if (!g_file_get_contents(path, &contents, &length, &error)) {
    g_debug("Config not loaded from %s: %s", path, error->message);
    return config;
  }

  config.window_decorations =
      parse_bool_key(contents, "window_decorations", config.window_decorations);
  return config;
}
