#ifndef APP_CONFIG_H_
#define APP_CONFIG_H_

#include <glib.h>

typedef struct {
  gboolean window_decorations;
} AppConfig;

// Loads config from ./config/config.json (debug) or ~/.config/invoices/config.json.
// Missing file or keys fall back to defaults.
AppConfig app_config_load(void);

#endif  // APP_CONFIG_H_
