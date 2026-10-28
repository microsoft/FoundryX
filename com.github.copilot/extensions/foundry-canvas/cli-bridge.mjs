import { execFile, spawn } from "node:child_process";
import { createInterface } from "node:readline";
import { promisify } from "node:util";
import { isAbsolute } from "node:path";
import { userInfo } from "node:os";

const execute = promisify(execFile);

async function refreshPath() {
    try {
        const windows = process.platform === "win32";
        const { stdout } = windows
            ? await execute("powershell.exe", [
                "-NoProfile", "-NonInteractive", "-Command",
                "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); "
                + "[Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')",
            ], { timeout: 15_000, windowsHide: true })
            : await execute(process.env.SHELL || userInfo().shell || "/bin/sh", [
                "-ilc", "printf '\\0%s\\0' \"$PATH\"",
            ], { timeout: 15_000, killSignal: "SIGKILL" });
        // Delimit shell output so startup messages cannot become PATH entries.
        const refreshed = windows ? stdout.trim() : stdout.split("\0")[1] || "";
        const separator = windows ? ";" : ":";
        const inherited = process.env.PATH?.split(separator) || [];
        const entries = [
            ...(windows ? inherited.filter(Boolean) : inherited),
            ...refreshed.split(separator).filter(Boolean),
        ];
        process.env.PATH = [...new Set(entries)].join(separator);
    } catch {
        // Keep the inherited PATH available if system or shell settings cannot be read.
    }
}

export async function startCliBridge() {
    await refreshPath();
    let metadata;
    try {
        const { stdout } = process.platform === "win32"
            ? await execute("powershell.exe", [
                "-NoProfile", "-NonInteractive", "-Command",
                "& foundryx auth canvas --entrypoint; exit $LASTEXITCODE",
            ], { timeout: 15_000, windowsHide: true })
            : await execute("foundryx", ["auth", "canvas", "--entrypoint"], { timeout: 15_000 });
        metadata = JSON.parse(stdout);
    } catch {
        throw new Error("The canvas requires FoundryX CLI 0.4.1 or later on PATH. Finish installing the matching release and reopen the canvas.");
    }
    if (metadata.protocol !== 1 || typeof metadata.entrypoint !== "string" || !isAbsolute(metadata.entrypoint)
        || typeof metadata.node !== "string" || !isAbsolute(metadata.node)) {
        throw new Error("The installed FoundryX CLI has an incompatible canvas protocol.");
    }
    const child = spawn(metadata.node, [metadata.entrypoint, "auth", "canvas"], {
        stdio: ["pipe", "pipe", "pipe"], windowsHide: true, shell: false,
    });
    const lines = createInterface({ input: child.stdout, crlfDelay: Infinity });
    const pending = new Map();
    let nextId = 0;
    let failure;
    let stderr = "";
    const fail = (error) => {
        failure = error;
        for (const request of pending.values()) request.reject(error);
        pending.clear();
    };
    child.stderr.on("data", (chunk) => { stderr = (stderr + chunk.toString()).slice(-4096); });
    child.on("error", () => fail(new Error("Could not start the FoundryX CLI authentication bridge.")));
    child.stdin.on("error", () => fail(new Error("The FoundryX CLI bridge input was closed.")));
    child.on("exit", (code) => fail(new Error(
        `The FoundryX CLI bridge stopped (${code}). Reload the canvas. ${stderr.trim()}`,
    )));
    lines.on("line", (line) => {
        let message;
        try {
            message = JSON.parse(line);
            if (!Number.isSafeInteger(message.id) || !Number.isInteger(message.status)
                || message.status < 100 || message.status > 599 || !pending.has(message.id)) {
                throw new Error("Invalid bridge response.");
            }
        } catch {
            fail(new Error("The FoundryX CLI returned an invalid canvas response."));
            child.kill();
            return;
        }
        const request = pending.get(message.id);
        pending.delete(message.id);
        request.resolve({ status: message.status, data: message.data });
    });
    const close = () => {
        child.stdin.end();
        child.kill();
        fail(new Error("The FoundryX canvas was closed."));
    };
    process.once("exit", close);
    return {
        request(input) {
            if (failure) return Promise.reject(failure);
            const id = ++nextId;
            return new Promise((resolve, reject) => {
                pending.set(id, { resolve, reject });
                child.stdin.write(`${JSON.stringify({ id, input })}\n`, (error) => {
                    if (error) {
                        pending.delete(id);
                        reject(new Error("Could not send the canvas request to FoundryX CLI."));
                    }
                });
            });
        },
        close() {
            process.off("exit", close);
            close();
        },
    };
}
