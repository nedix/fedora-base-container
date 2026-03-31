ARG FEDORA_VERSION=43

FROM registry.fedoraproject.org/fedora-minimal:${FEDORA_VERSION}

ARG FEDORA_VERSION

RUN sed -E \
        -e "s|(\[main\])|\1\ndeltarpm=1|" \
        -e "s|(\[main\])|\1\nfastestmirror=1|" \
        -e "s|(\[main\])|\1\ninstall_weak_deps=0|" \
        -e "s|(\[main\])|\1\nmax_parallel_downloads=10|" \
        -e "s|(\[main\])|\1\nmetadata_expire=-1|" \
        -i /etc/dnf/dnf.conf \
    && dnf makecache --refresh \
    && dnf install -y \
        dnf5-plugins \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
    && for FEDORA_VERSION_N in $(seq $(( FEDORA_VERSION - 2 )) "$FEDORA_VERSION"); do \
        sed -E \
            -e "s|\\\$releasever|${FEDORA_VERSION_N}|g" \
            -e "s|^\[fedora|\[fedora-${FEDORA_VERSION_N}|g" \
            /etc/yum.repos.d/fedora.repo \
            > "/etc/yum.repos.d/fedora-${FEDORA_VERSION_N}.repo" \
        && dnf config-manager setopt "fedora-${FEDORA_VERSION_N}.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${FEDORA_VERSION_N}|g" \
            -e "s|^\[updates|\[fedora-${FEDORA_VERSION_N}-updates|g" \
            /etc/yum.repos.d/fedora-updates.repo \
            > "/etc/yum.repos.d/fedora-${FEDORA_VERSION_N}-updates.repo" \
        && dnf config-manager setopt "fedora-${FEDORA_VERSION_N}-updates.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${FEDORA_VERSION_N}|g" \
            -e "s|^\[rpmfusion-free|\[fedora-${FEDORA_VERSION_N}-rpmfusion-free|g" \
            /etc/yum.repos.d/rpmfusion-free.repo \
            > "/etc/yum.repos.d/fedora-${FEDORA_VERSION_N}-rpmfusion-free.repo" \
        && dnf config-manager setopt "fedora-${FEDORA_VERSION_N}-rpmfusion-free.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${FEDORA_VERSION_N}|g" \
            -e "s|^\[rpmfusion-free-updates|\[fedora-${FEDORA_VERSION_N}-rpmfusion-free-updates|g" \
            /etc/yum.repos.d/rpmfusion-free-updates.repo \
            > "/etc/yum.repos.d/fedora-${FEDORA_VERSION_N}-rpmfusion-free-updates.repo" \
        && dnf config-manager setopt "fedora-${FEDORA_VERSION_N}-rpmfusion-free-updates.enabled=1" \
    ; done \
    && dnf config-manager setopt "fedora-cisco-openh264.enabled=0" \
    && dnf config-manager setopt "fedora.enabled=0" \
    && dnf config-manager setopt "updates.enabled=0" \
    && dnf config-manager setopt "updates-testing.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free-updates.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free-updates-testing.enabled=0" \
    && rm \
        /etc/yum.repos.d/fedora-cisco-openh264.repo \
        /etc/yum.repos.d/fedora.repo \
        /etc/yum.repos.d/fedora-updates.repo \
        /etc/yum.repos.d/fedora-updates-testing.repo \
        /etc/yum.repos.d/rpmfusion-free.repo \
        /etc/yum.repos.d/rpmfusion-free-updates.repo \
        /etc/yum.repos.d/rpmfusion-free-updates-testing.repo

ENTRYPOINT ["/bin/sh"]
