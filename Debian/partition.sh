#!/bin/bash

devroot=$(awk '$2 == "/target" {print $1}' /proc/mounts)
devboot=$(awk '$2 == "/target/boot" {print $1}' /proc/mounts)
devefi=$(awk '$2 == "/target/boot/efi" {print $1}' /proc/mounts)

echo "Partition information:"
echo "    Partition 'root' mounted on '$devroot'"
echo "    Partition 'boot' mounted on '$devboot'"
echo "    Partition 'evi' mounted on '$devefi'"
