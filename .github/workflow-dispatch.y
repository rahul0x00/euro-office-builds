- name: Check Docker
    run: docker version

  - name: Pull Arch Linux
    run: docker pull archlinux:base-devel

  - name: Run Arch Linux
    run: |
      docker run --rm archlinux:base-devel bash -c "
        pacman -Sy --noconfirm
        echo Arch OK
      "
