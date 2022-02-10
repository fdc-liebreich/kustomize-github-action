#!/bin/bash

function parse_inputs {
    # required inputs
    if [ "${INPUT_KUSTOMIZE_VERSION}" != "" ]; then
        kustomize_version=${INPUT_KUSTOMIZE_VERSION}
    else
        echo "Input kustomize_version cannot be empty."
        exit 1
    fi

    # optional inputs
    kustomize_build_dir="."
    if [ "${INPUT_KUSTOMIZE_BUILD_DIR}" != "" ] || [ "${INPUT_KUSTOMIZE_BUILD_DIR}" != "." ]; then
        kustomize_build_dir=${INPUT_KUSTOMIZE_BUILD_DIR}
    fi

    kustomize_comment=0
    if [ "${INPUT_KUSTOMIZE_COMMENT}" == "1" ] || [ "${INPUT_KUSTOMIZE_COMMENT}" == "true" ]; then
        kustomize_comment=1
    fi

    kustomize_output_file=""
    if [ -n "${INPUT_KUSTOMIZE_OUTPUT_FILE}" ]; then
      kustomize_output_file=${INPUT_KUSTOMIZE_OUTPUT_FILE}
    fi

    kustomize_build_options=""
    if [ -n "${INPUT_KUSTOMIZE_BUILD_OPTIONS}" ]; then
      kustomize_build_options=${INPUT_KUSTOMIZE_BUILD_OPTIONS}
    fi

    enable_alpha_plugins=""
   if [ "${INPUT_ENABLE_ALPHA_PLUGINS}" == "1" ] || [ "${INPUT_ENABLE_ALPHA_PLUGINS}" == "true" ]; then
       enable_alpha_plugins="--enable_alpha_plugins"
    fi
}

function install_kustomize {
    url = "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${kustomize_version}/kustomize_v${kustomize_version}_darwin_amd64.tar.gz"

    echo "Downloading kustomize v${kustomize_version} from $url"
    curl -s -S -L ${url} | tar -xz -C /usr/bin

    if [ "${?}" -ne 0 ]; then
        echo "Failed to download kustomize v${kustomize_version}."
        exit 1
    fi
    echo "Successfully downloaded kustomize v${kustomize_version}."

    echo "Allowing execute privilege to kustomize."
    chmod +x /usr/bin/kustomize
    if [ "${?}" -ne 0 ]; then
        echo "Failed to update kustomize privilege."
        exit 1
    fi
    echo "Successfully added execute privilege to kustomize."

}

function main {

    scriptDir=$(dirname ${0})
    source ${scriptDir}/kustomize_build.sh
    parse_inputs

    install_kustomize
    kustomize_build

}

main "${*}"
