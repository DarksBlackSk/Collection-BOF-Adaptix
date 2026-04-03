var metadata = {
    name: "SvcMgr-BOF",
    description: "Windows service management (list/query/create/delete/start/stop) local and remote via SCM."
};

function bof_path(id) {
    return ax.script_dir() + "_bin/svcmgr." + ax.arch(id) + ".o";
}

function check_bof(id) {
    var p = bof_path(id);
    if (!ax.file_exists(p)) {
        ax.console_message(id, "BOF not found: " + p, "error");
        return false;
    }
    return true;
}

// ── svc_list ─────────────────────────────────────────────────
var cmd_svc_list = ax.create_command(
    "svc_list",
    "List all services (local or remote).",
    "svc_list [-c <host>] [-f all|win32|driver]; svc_list; svc_list -c 192.168.1.10; svc_list -f driver"
);
cmd_svc_list.addArgFlagString("-c", "computer", "Remote computer (skip = localhost)", "localhost");
cmd_svc_list.addArgFlagString("-f", "filter",   "Filter: all | win32 | driver", "all");

cmd_svc_list.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var computer = parsed_json["computer"] || "localhost";
    var filter   = parsed_json["filter"]   || "all";
    var params   = ax.bof_pack("cstr,cstr,cstr", ["list", computer, filter]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_list en " + computer, null);
});

// ── svc_query ────────────────────────────────────────────────
var cmd_svc_query = ax.create_command(
    "svc_query",
    "Check the status and configuration of a service.",
    "svc_query -n <NameService> [-c <host>]; svc_query -n WinDefend; svc_query -n Spooler -c 192.168.1.10"
);
cmd_svc_query.addArgFlagString("-n", "svcname",  "Service name");
cmd_svc_query.addArgFlagString("-c", "computer", "Remote machine (skip = localhost)", "localhost");

cmd_svc_query.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var svcname  = parsed_json["svcname"]  || "";
    var computer = parsed_json["computer"] || "localhost";
    if (!svcname) { ax.console_message(id, "missing -n <svcname>", "error"); return; }
    var params = ax.bof_pack("cstr,cstr,cstr", ["query", computer, svcname]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_query [" + svcname + "] en " + computer, null);
});

// ── svc_create ───────────────────────────────────────────────
var cmd_svc_create = ax.create_command(
    "svc_create",
    "Create a new service.",
    "svc_create -n <ServiceName> -p <PathBinary> [-d <display>] [-t win32|driver] [-s auto|demand|disabled|boot|system] [-c <host>]"
);
cmd_svc_create.addArgFlagString("-n", "svcname",   "Service internal name");
cmd_svc_create.addArgFlagString("-p", "binpath",   "Path to the executable or .sys file");
cmd_svc_create.addArgFlagString("-d", "dispname",  "Display name (optional)", "");
cmd_svc_create.addArgFlagString("-t", "svctype",   "Type: win32 | driver", "win32");
cmd_svc_create.addArgFlagString("-s", "starttype", "Start: auto | demand | disabled | boot | system", "demand");
cmd_svc_create.addArgFlagString("-c", "computer",  "remote machine (skip = localhost)", "localhost");

cmd_svc_create.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var svcname   = parsed_json["svcname"]   || "";
    var binpath   = parsed_json["binpath"]   || "";
    var dispname  = parsed_json["dispname"]  || "";
    var svctype   = parsed_json["svctype"]   || "win32";
    var starttype = parsed_json["starttype"] || "demand";
    var computer  = parsed_json["computer"]  || "localhost";

    if (!svcname)  { ax.console_message(id, "missing -n <svcname>",  "error"); return; }
    if (!binpath)  { ax.console_message(id, "missing -p <binpath>",  "error"); return; }

    var params = ax.bof_pack("cstr,cstr,cstr,cstr,cstr,cstr,cstr",
        ["create", computer, svcname, dispname, binpath, svctype, starttype]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_create [" + svcname + "] en " + computer, null);
});

// ── svc_delete ───────────────────────────────────────────────
var cmd_svc_delete = ax.create_command(
    "svc_delete",
    "Removes a service (stops it earlier if it's running)",
    "svc_delete -n <ServiceName> [-c <host>]; svc_delete -n MySvc; svc_delete -n MySvc -c 192.168.1.10"
);
cmd_svc_delete.addArgFlagString("-n", "svcname",  "Service name");
cmd_svc_delete.addArgFlagString("-c", "computer", "Remote Machine (skip = localhost)", "localhost");

cmd_svc_delete.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var svcname  = parsed_json["svcname"]  || "";
    var computer = parsed_json["computer"] || "localhost";
    if (!svcname) { ax.console_message(id, "missing -n <svcname>", "error"); return; }
    var params = ax.bof_pack("cstr,cstr,cstr", ["delete", computer, svcname]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_delete [" + svcname + "] en " + computer, null);
});

// ── svc_start ────────────────────────────────────────────────
var cmd_svc_start = ax.create_command(
    "svc_start",
    "Start a service and wait for RUNNING status confirmation.",
    "svc_start -n <ServiceName> [-c <host>], svc_start -n Spooler, svc_start -n MySvc -c 192.168.1.10"
);
cmd_svc_start.addArgFlagString("-n", "svcname",  "Service Name");
cmd_svc_start.addArgFlagString("-c", "computer", "Remote Machine (skip = localhost)", "localhost");

cmd_svc_start.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var svcname  = parsed_json["svcname"]  || "";
    var computer = parsed_json["computer"] || "localhost";
    if (!svcname) { ax.console_message(id, "missing -n <svcname>", "error"); return; }
    var params = ax.bof_pack("cstr,cstr,cstr", ["start", computer, svcname]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_start [" + svcname + "] in " + computer, null);
});

// ── svc_stop ─────────────────────────────────────────────────
var cmd_svc_stop = ax.create_command(
    "svc_stop",
    "Stop a service and wait for confirmation of STOPPED status.",
    "svc_stop -n <ServiceName> [-c <host>], svc_stop -n Spooler, svc_stop -n MySvc -c 192.168.1.10"
);
cmd_svc_stop.addArgFlagString("-n", "svcname",  "Service Name");
cmd_svc_stop.addArgFlagString("-c", "computer", "Remote Machine (skip = localhost)", "localhost");

cmd_svc_stop.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    if (!check_bof(id)) return;
    var svcname  = parsed_json["svcname"]  || "";
    var computer = parsed_json["computer"] || "localhost";
    if (!svcname) { ax.console_message(id, "missing -n <svcname>", "error"); return; }
    var params = ax.bof_pack("cstr,cstr,cstr", ["stop", computer, svcname]);
    ax.execute_alias(id, cmdline,
        "execute bof " + bof_path(id) + " " + params,
        "Task: svc_stop [" + svcname + "] in " + computer, null);
});

// ── Registrar grupo ──────────────────────────────────────────
var group_svc = ax.create_commands_group("SvcMgr-BOF", [
    cmd_svc_list,
    cmd_svc_query,
    cmd_svc_create,
    cmd_svc_delete,
    cmd_svc_start,
    cmd_svc_stop
]);
ax.register_commands_group(group_svc, ["beacon", "gopher", "kharon"], ["windows"], []);
