#!/usr/bin/env bash

# Base on https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/3284#issuecomment-2566351320

runcmd() {
    echo "Runing: $*"
    $@
}
runeval() {
    echo "Runing: $*"
    eval "$*"
}
header() {
    if [ -z "$1" ]; then
        name="${FUNCNAME[1]}"
    else
        name="$1"
    fi
    echo "-------------------------------------------"
    echo "[Info]: Step $name"
    echo "-------------------------------------------"
}


PATCH_CONTENT='
--- init.gradle 2025-04-01 14:29:58.000000000 +0800
+++ init.gradle 2025-07-20 00:11:03.720796989 +0800
@@ -466,6 +466,8 @@

 allprojects {
     afterEvaluate {
-        it.getPlugins().apply(JavaLanguageServerAndroidPlugin)
+        afterEvaluate {
+            it.getPlugins().apply(JavaLanguageServerAndroidPlugin)
+        }
     }
 }
'



header setup_env

# Configuration
JAR_FILE="$(realpath "$1")"                 # Path to the JAR file
declare -p JAR_FILE
FILE_IN_JAR="gradle/android/init.gradle" # File inside the JAR to patch
declare -p FILE_IN_JAR
PATCH_FILE="init.patch"                 # Patch file (generated with `diff -u`)
declare -p PATCH_FILE

# Create a temporary directory
TEMP_DIR="$(mktemp -d /tmp/patch-jdtls-XXXXXX)"
declare -p TEMP_DIR
EXTRACTED_FILE="$TEMP_DIR/$FILE_IN_JAR"
declare -p EXTRACTED_FILE
NEW_JAR_FILE="$TEMP_DIR/$(basename "$JAR_FILE")"
declare -p NEW_JAR_FILE
TEMP_PATCH_FILE="$TEMP_DIR/$PATCH_FILE"
declare -p TEMP_PATCH_FILE


envcheck() {
    header
    # Check if JAR file exists
    if [ ! -f "$JAR_FILE" ]; then
        echo "Error: JAR file $JAR_FILE not found!"
        exit 1
    fi

    # Check if patch file exists
    # if [ ! -f "$PATCH_FILE" ]; then
    #     echo "Error: Patch file $PATCH_FILE not found!"
    #     exit 1
    # fi
}


setup_file() {
    header
    runcmd cp "$JAR_FILE"  "$TEMP_DIR"

    echo "$PATCH_CONTENT" >  "$TEMP_PATCH_FILE"

    # Extract the file from the JAR
    runcmd unzip -q "$JAR_FILE" "$FILE_IN_JAR" -d "$TEMP_DIR"

    # Check if extraction succeeded
    if [ ! -f "$EXTRACTED_FILE" ]; then
        echo "Error: Failed to extract $FILE_IN_JAR from $JAR_FILE!"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
}

patch_file() {
    header

    # Apply the patch
    runeval patch "$EXTRACTED_FILE" "<" "$TEMP_PATCH_FILE" 
    

    if [ $? -ne 0 ]; then
        echo "Error: Failed to apply patch!"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
}


patch_jar() {
    header

    (
        runcmd cd "$TEMP_DIR"
        runcmd chmod a+w "$(basename "$JAR_FILE")"
        runcmd zip -q -u "$(basename "$JAR_FILE")" "$FILE_IN_JAR"
        runcmd chmod a-w "$(basename "$JAR_FILE")"
    )
}

# Clean up
# rm -rf "$TEMP_DIR"

envcheck &&
setup_file &&
patch_file &&
patch_jar


header Done
echo "MANNUAL: cp $NEW_JAR_FILE $JAR_FILE"
echo "MANNUAL: rm -rf $TEMP_DIR"
