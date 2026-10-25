---
sidebar_position: 1
slug: /
title: Overview
---

# Oppo F9 (CPH1823) unlock & GSI runbook

**No warranty. High brick risk. For a device you own.**

This runbook covers unlocking an Oppo F9 / F9 Pro (**CPH1823**, MediaTek **MT6771**), dumping partitions, installing OrangeFox recovery, and booting an Android 13 Treble GSI.

**Wipe is OK** on this device: userdata and ColorOS data may be erased during unlock and GSI install. Back up anything you still need before proceeding.

**GrapheneOS is not available on this device.** An unlocked bootloader plus an unsigned GSI **weakens** Android Verified Boot (AVB) relative to locked stock. Do not treat this as GrapheneOS-class security.

## Phases

Later docs will cover these phases in order:

1. Host setup and tooling
2. Unlock / deep flash / dump
3. OrangeFox recovery
4. Android 13 GSI boot
5. Hardening notes (and GrapheneOS gap again)
6. Changelog / verification status

Use the **Runbook** sidebar as pages are added.
