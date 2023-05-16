#!/usr/bin/env python3
import subprocess
import sys


def create_snapshot(snapshot_name):
    cmd = f"zfs snapshot sa_pool/data@{snapshot_name}"
    result = subprocess.run(cmd, shell=True)
    if result.returncode == 0:
        print(f"Snapshot {snapshot_name} created successfully.")
    else:
        print("Failed to create snapshot.")


def remove_snapshot(snapshot_name):
    if snapshot_name == "all":
        cmd = "zfs list -H -o name -t snapshot sa_pool/data | xargs -n1 zfs destroy"
    else:
        cmd = f"zfs destroy sa_pool/data@{snapshot_name}"
    result = subprocess.run(cmd, shell=True)
    if result.returncode == 0:
        print(f"Snapshot {snapshot_name} removed successfully.")
    else:
        print("Failed to remove snapshot.")


def list_snapshots():
    cmd = "zfs list -H -o name -t snapshot sa_pool/data"
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
    if result.returncode == 0:
        output = result.stdout.decode("utf-8")
        print(output, end="")
    else:
        print("Failed to list snapshots.")


def rollback_snapshot(snapshot_name):
    cmd = f"zfs rollback -r sa_pool/data@{snapshot_name}"
    result = subprocess.run(cmd, shell=True)
    if result.returncode == 0:
        print(f"Snapshot {snapshot_name} rolled back successfully.")
    else:
        print("Failed to rollback snapshot.")


def logrotate():
    cmd = "logrotate /etc/logrotate.d/fakelog1"
    result = subprocess.run(cmd, shell=True)
    if result.returncode == 0:
        print("Log rotated successfully.")
    else:
        print("Failed to rotate log.")


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "help":
        print("Usage:")
        print("  create <snapshot-name>")
        print("  remove <snapshot-name> | all")
        print("  list")
        print("  roll <snapshot-name>")
        print("  logrotate")
    elif sys.argv[1] == "create":
        if len(sys.argv) < 3:
            print("Error: please provide a snapshot name.")
        else:
            create_snapshot(sys.argv[2])
    elif sys.argv[1] == "remove":
        if len(sys.argv) < 3:
            print("Error: please provide a snapshot name or 'all'.")
        else:
            remove_snapshot(sys.argv[2])
    elif sys.argv[1] == "list":
        list_snapshots()
    elif sys.argv[1] == "roll":
        if len(sys.argv) < 3:
            print("Error: please provide a snapshot name.")
        else:
            rollback_snapshot(sys.argv[2])
    elif sys.argv[1] == "logrotate":
        logrotate()
    else:
        print(f"Error: unknown command '{sys.argv[1]}'")
