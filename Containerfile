ARG FEDORA_VERSION=41

FROM registry.fedoraproject.org/fedora-minimal:${FEDORA_VERSION}

ARG FEDORA_VERSION

RUN sed -E \
        -e "s|(\[main\])|\1\ndeltarpm=1|" \
        -e "s|(\[main\])|\1\nfastestmirror=1|" \
        -e "s|(\[main\])|\1\ninstall_weak_deps=0|" \
        -e "s|(\[main\])|\1\nmax_parallel_downloads=10|" \
        -e "s|(\[main\])|\1\nmetadata_expire=-1|" \
        -i /etc/dnf/dnf.conf \
    && dnf install -y \
        dnf5-plugins \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
    && for PREVIOUS_FEDORA_VERSION in $(seq $(( FEDORA_VERSION - 2 )) "$FEDORA_VERSION"); do \
        sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[fedora|\[fedora-${PREVIOUS_FEDORA_VERSION}|g" \
            /etc/yum.repos.d/fedora.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[updates|\[fedora-${PREVIOUS_FEDORA_VERSION}-updates|g" \
            /etc/yum.repos.d/fedora-updates.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-updates.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-updates.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[rpmfusion-free|\[fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free|g" \
            /etc/yum.repos.d/rpmfusion-free.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[rpmfusion-free-updates|\[fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates|g" \
            /etc/yum.repos.d/rpmfusion-free-updates.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates.enabled=1" \
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
        /etc/yum.repos.d/rpmfusion-free-updates-testing.repo \
    && dnf makecache --refresh

ENTRYPOINT ["/bin/sh"]
