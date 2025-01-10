# Envsetup
# ========================
$DEBUG = $true

if ($env:PEM_ADB_CMD) {
    $ADB_CMD = "$env:PEM_ADB_CMD"
} else {
    $ADB_CMD = "adb"
}

(& $ADB_CMD root) -and
(& $ADB_CMD remount) -and
(& $ADB_CMD reboot) -and
(& $ADB_CMD remount)
