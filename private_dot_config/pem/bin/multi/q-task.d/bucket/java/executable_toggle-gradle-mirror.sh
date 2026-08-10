#!/usr/bin/env bash

toggle_gradle_mirror() {
    local wrapper_file="gradle/wrapper/gradle-wrapper.properties"
    local original_url="https\\\\://services.gradle.org/distributions"
    local mirror_url="https\\\\://mirrors.cloud.tencent.com/gradle"

    if [ ! -f "$wrapper_file" ]; then
        echo "Error: $wrapper_file not found!"
        return 1
    fi

    if grep -q "distributionUrl=$original_url" "$wrapper_file"; then
        sed -i "s|distributionUrl=$original_url|distributionUrl=$mirror_url|" "$wrapper_file"
        echo "Replaced to mirror"
    elif grep -q "distributionUrl=$mirror_url" "$wrapper_file"; then
        sed -i "s|distributionUrl=$mirror_url|distributionUrl=$original_url|" "$wrapper_file"
        echo "Replaced back to original"
    else
        echo "Error: Neither URL pattern found in $wrapper_file"
        return 1
    fi
}

toggle_gradle_mirror
