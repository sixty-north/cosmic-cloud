#!/usr/bin/env bash
OS_DISTRO="$(echo $1 | tr '[:upper:]' '[:lower:]')"
ARCH_TYPE="$(echo $2 | tr '[:upper:]' '[:lower:]')"
AcceptedOSArray=("android" "darwin" "dragonfly" "freebsd" "linux" "netbsd" "openbsd" "plan9" "solaris" "windows")
AcceptedArchArray=("arm" "386" "amd64" "arm64" "ppc64" "ppc64le" "mips" "mipsle" "mips64" "mips64le")
TEMPFILE=`mktemp`
E_CODE=0
echo "TEMP: $TEMPFILE"

function checkArrayContains() {
    local arrayVal="$1[@]"
    local value=$2
    local res=false
    for i in "${!arrayVal}"; do
        if [ "$i" = "$value" ]; then
            res=true
        fi
    done
    echo $res
    return 0
}
if [[ $(checkArrayContains AcceptedOSArray "$OS_DISTRO") ]]; then
    if [[ $(checkArrayContains AcceptedArchArray "$ARCH_TYPE") ]]; then
        wget "https://github.com/nbering/terraform-provider-ansible/releases/download/v0.0.2/terraform-provider-ansible-"$OS_DISTRO"_"$ARCH_TYPE".zip" -O $TEMPFILE
        mkdir -p ~/.terraform.d/plugins
        unzip -o -d ~/.terraform.d/plugins $TEMPFILE
        rm -f $TEMPFILE
    else
        echo "ArchTypeNotFound"
        E_CODE=1
    fi
else
    echo "OSNotFound"
    E_CODE=1
fi
exit $E_CODE
