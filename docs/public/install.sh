#!/bin/bash

# Colored output function
color_echo() {
    if [ "$2" = "red" ]; then
        echo -e "\033[31m$1\033[0m"
    elif [ "$2" = "yellow" ]; then
        echo -e "\033[33m$1\033[0m"
    else
        echo -e "\033[32m$1\033[0m"
    fi
}

# Environment checks
check_environment() {
    # Check root user
    if [[ $(id -u) -ne 0 ]]; then
        color_echo "Error: This script must be run as root" red >&2
        exit 1
    else
        color_echo "[OK] Running as root user"
    fi

    # Check disk space
    disk_space=$(df / --output=avail | tail -n1 | tr -d ' ')
    if [[ $disk_space -lt $((5 * 1024 * 1024)) ]]; then
        color_echo "Error: Disk space less than 5GB (Available: $((disk_space/1024))MB)" red >&2
        exit 1
    else
        color_echo "[OK] Disk space sufficient (Available: $((disk_space/1024))MB)"
    fi

    # Check memory
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [[ $mem_total -lt $((2 * 1024 * 1024)) ]]; then
        color_echo "Error: Memory less than 2GB (Available: $((mem_total/1024))MB)" red >&2
        exit 1
    else
        color_echo "[OK] Memory sufficient (Available: $((mem_total/1024))MB)"
    fi

    # Check kernel version
    kernel_major=$(uname -r | cut -d. -f1)
    if [[ $kernel_major -lt 5 ]]; then
        color_echo "Error: Kernel version needs to be ≥5.x (Current: $(uname -r))" red >&2
        exit 1
    else
        color_echo "[OK] Kernel version meets requirement (Current: $(uname -r))"
    fi
}

# Docker installation
install_docker() {
    if ! command -v docker &>/dev/null; then
        color_echo "[Notice] Docker not found, installing..." yellow
        curl -fsSL https://get.docker.com | bash -s docker
        if [ $? -eq 0 ]; then
            color_echo "[OK] Docker installed successfully"
        else
            color_echo "[Error] Docker installation failed" red >&2
            exit 1
        fi
    else
        color_echo "[OK] Docker already installed (Version: $(docker --version | cut -d' ' -f3 | tr -d ','))"
    fi

    if ! systemctl is-active docker &>/dev/null; then
        color_echo "[Notice] Starting Docker service..." yellow
        service docker start
        if [ $? -eq 0 ]; then
            color_echo "[OK] Docker service started"
        else
            color_echo "[Error] Failed to start Docker service" red >&2
            exit 1
        fi
    else
        color_echo "[OK] Docker service is running"
    fi
}

# System optimization
optimize_system() {
    color_echo "\nSystem Optimization Options" yellow
    echo "----------------------------------------"
    echo "The following optimizations will be applied:"
    echo "1. Network Stack Tuning:"
    echo "   - TCP performance improvements"
    echo "   - Increased connection limits"
    echo "   - Reduced timeout values"
    echo "2. File Descriptor Limits:"
    echo "   - Increased open files limit to 65535"
    echo "3. Virtual Memory Settings:"
    echo "   - Adjusted vm.max_map_count for containers"
    echo ""
    echo "These changes will improve VIPER's network performance"
    echo "and handle more concurrent connections efficiently."
    echo "----------------------------------------"

    read -p "Apply system optimizations? [Y/n] " optimize_confirm
    if [[ "$optimize_confirm" =~ ^[Nn]$ ]]; then
        color_echo "Skipping system optimizations" yellow
        return
    fi

    color_echo "Applying system optimizations..." yellow

    # Network stack tuning
    sysctl -w net.ipv4.tcp_timestamps=0
    sysctl -w net.ipv4.tcp_tw_reuse=1
    sysctl -w net.ipv4.tcp_tw_recycle=1
    sysctl -w net.ipv4.tcp_fin_timeout=3
    sysctl -w net.ipv4.tcp_keepalive_time=1800
    sysctl -w net.ipv4.tcp_rmem="4096 87380 8388608"
    sysctl -w net.ipv4.tcp_wmem="4096 87380 8388608"
    sysctl -w net.ipv4.tcp_max_syn_backlog=262144
    sysctl -w net.ipv4.ip_local_port_range="1024 65535"
    sysctl -w net.core.rmem_max=16777216
    sysctl -w net.core.wmem_max=16777216
    sysctl -w net.ipv4.tcp_window_scaling=0
    sysctl -w net.ipv4.tcp_sack=0
    sysctl -w net.core.netdev_max_backlog=30000
    sysctl -w net.ipv4.tcp_no_metrics_save=1
    sysctl -w net.core.somaxconn=262144
    sysctl -w net.ipv4.tcp_syncookies=0
    sysctl -w net.ipv4.tcp_max_orphans=262144
    sysctl -w net.ipv4.tcp_synack_retries=2
    sysctl -w net.ipv4.tcp_syn_retries=2

    # File descriptor limits
    echo "ulimit -HSn 65535" >> /etc/rc.local
    echo "ulimit -HSn 65535" >> /root/.bash_profile
    echo "ulimit -SHn 65535" >> /etc/profile
    ulimit -SHn 65535

    # Virtual memory settings
    sysctl -w vm.max_map_count=262144

    # Make rc.local executable if it exists
    [ -f /etc/rc.local ] && chmod +x /etc/rc.local

    color_echo "[OK] System optimizations applied"
}

# VIPER installation
install_viper() {
    color_echo "\nStarting VIPER installation..." 

    # Interactive password input
    while true; do
        read -sp "Enter VIPER admin password (input hidden): " viper_pass
        echo
        read -sp "Confirm password: " viper_pass_confirm
        echo
        
        if [[ "$viper_pass" != "$viper_pass_confirm" ]]; then
            color_echo "Password mismatch, please try again" red
        elif [[ ${#viper_pass} -lt 8 ]]; then
            color_echo "Password must be at least 8 characters" red
        else
            break
        fi
    done

    # Create installation directory
    local viper_dir="/root/VIPER"
    mkdir -p "$viper_dir" || {
        color_echo "Failed to create directory $viper_dir" red
        exit 1
    }

    # Generate configuration file
    cat > "$viper_dir/docker-compose.yml" <<EOF
services:
  viper:
    image: viperplatform/viper:latest
    container_name: viper-c
    network_mode: "host"
    restart: always
    volumes:
      - \${PWD}/loot:/root/.msf4/loot
      - \${PWD}/db:/root/viper/Docker/db
      - \${PWD}/module:/root/viper/Docker/module
      - \${PWD}/log:/root/viper/Docker/log
      - \${PWD}/nginxconfig:/root/viper/Docker/nginxconfig
    ulimits:
      nofile:
        soft: 65534
        hard: 65534
      nproc:
        soft: 65534
        hard: 65534
    command: ["$viper_pass"]
EOF

    # Show configuration summary
    color_echo "\nReady to launch VIPER container. Please confirm:" yellow
    echo "----------------------------------------"
    echo "Installation directory: $viper_dir"
    echo "Network mode: host"
    echo "Persistent volumes:"
    echo "  - $viper_dir/loot"
    echo "  - $viper_dir/db"
    echo "  - $viper_dir/module"
    echo "  - $viper_dir/log"
    echo "  - $viper_dir/nginxconfig"
    echo "----------------------------------------"

    # User confirmation
    read -p "Proceed with VIPER container launch? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        color_echo "Installation cancelled" red
        exit 0
    fi

    # Launch container
    color_echo "Launching VIPER container..." yellow
    if (cd "$viper_dir" && docker compose up -d); then
        color_echo "VIPER successfully launched!"
        color_echo "Access URL: http://<server_ip>:60000"
        color_echo "Login credentials:"
        color_echo "  Username: root"
        color_echo "  Password: Your configured password"
        # Clean sensitive data
        unset viper_pass viper_pass_confirm
    else
        color_echo "VIPER launch failed, check logs" red
        exit 1
    fi
}

# Main execution flow
check_environment
install_docker
optimize_system
install_viper

color_echo "\nAll deployments completed successfully!" 
exit 0