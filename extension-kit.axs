var metadata = {
    name: "",
    description: "",
    nosave: true
};

var path = ax.script_dir();
ax.script_load(path + "clipboard/clipboard.axs");
ax.script_load(path + "EdrEnum-BOF/edr.axs");
ax.script_load(path + "Keylogger-BOF/keylog.axs");
ax.script_load(path + "wifi/wifidump.axs");
ax.script_load(path + "ghost_task/ghost_task.axs");
