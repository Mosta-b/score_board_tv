# 📺 Flutter APK Installation Guide for Cristor Smart TVs

This guide provides step-by-step instructions for installing your Flutter application on **Cristor Smart TVs** via USB drive.

---

## 📋 Prerequisites

Before starting, ensure you have:

- A **USB flash drive** (at least 1GB capacity)
- Your **Flutter APK** file: `app-armeabi-v7a-release.apk`
- A **Cristor Smart TV** running Android TV OS
- A remote control for the TV

---

## 🛠️ Step-by-Step Instructions

### Step 1: Format USB Drive to FAT32

> **⚠️ IMPORTANT:** The USB drive **MUST** be formatted to FAT32 for the TV to recognize it properly.

#### On Windows:

1. Insert the USB drive into your computer
2. Open **File Explorer** → Right-click the USB drive
3. Select **Format...**
4. Choose **FAT32** from the "File system" dropdown
5. Click **Start** → **OK** to confirm

#### On Linux (Manjaro/Ubuntu):

```bash
# Find your USB device name (e.g., /dev/sdb1)
lsblk

# Unmount the drive
sudo umount /dev/sdX1

# Format to FAT32
sudo mkfs.vfat -F 32 /dev/sdX1

# Or use the GUI tool: GParted or KDE Partition Manager
```
