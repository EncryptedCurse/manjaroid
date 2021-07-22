LOGO_COLOR='\e[1;32m'
MSG_COLOR='\e[1;35m'
PROMPT_COLOR='\e[1;33m'
RESET_COLOR='\e[0m'

function msg { echo -e "${MSG_COLOR}${1}${RESET_COLOR}"; }
function prompt { echo -ne "${PROMPT_COLOR}${1}${RESET_COLOR} "; }

echo -e "${LOGO_COLOR}                 _             _   _
 _____ ___ ___  |_|___ ___ ___|_|_| |
|     | .'|   | | | .'|  _| . | | . |
|_|_|_|__,|_|_|_| |__,|_| |___|_|___|
              |___|    ${RESET_COLOR}installer
"

# install Termux prerequisites
msg "Installing Termux prerequisites..."
pkg update -y && pkg install -y proot pulseaudio

# setup proot
prompt "Installation directory (~/manjaroid):"; read ROOTFS_DIR
ROOTFS_DIR="$(eval echo "${ROOTFS_DIR:-~/manjaroid}")"
mkdir -p "$ROOTFS_DIR"
msg "Downloading Manjaro ARM rootfs + setting up proot environment..."
ROOTFS_URL='https://osdn.net/projects/manjaro-arm/storage/.rootfs/Manjaro-ARM-aarch64-latest.tar.gz'
curl -L --retry 5 "$ROOTFS_URL" | proot -l tar -C "$ROOTFS_DIR" --preserve-permissions --delay-directory-restore -xzf -
rm -rf "${ROOTFS_DIR:?}/dev"

# create main (post-installation) launch script
msg "Creating $(pwd "$ROOTFS_DIR/..")/manjaroid.sh launch script..."
cat <<- EOF > "$ROOTFS_DIR/../manjaroid.sh"
	unset LD_PRELOAD

	ROOTFS_DIR="$ROOTFS_DIR"
	[ -z \$1 ] || [ \${1,,} = "root" ] && HOME_DIR="/root" || HOME_DIR="/home/\$1"
	PROOT_MOUNTS="-r "\$ROOTFS_DIR" -b /sdcard -b /system -b /sys -b /dev -b /proc -b "\$ROOTFS_DIR/tmp:/dev/shm""
	for PROC in loadavg stat uptime version vmstat; do
	    if ! cat /proc/\$PROC > /dev/null 2>&1; then
	        PROOT_MOUNTS+=" -b "\$ROOTFS_DIR/proc/.\$PROC:/proc/\$PROC""
	    fi
	done

	pulseaudio --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 --start
	proot --kill-on-exit --sysvipc -L -l -0 \$PROOT_MOUNTS -w \$HOME_DIR /usr/bin/env -i TERM=\$TERM /bin/sh --login
EOF
chmod +x "$ROOTFS_DIR/../manjaroid.sh"

# create fake /proc files for unrooted devices
msg "Creating fake /proc files..."
mkdir -p "$ROOTFS_DIR/proc"
chmod 700 "$ROOTFS_DIR/proc"
uname -a > "$ROOTFS_DIR/proc/.version"
echo '0.54 0.41 0.30 1/931 370386' > "$ROOTFS_DIR/proc/.loadavg"
echo '284684.56 513853.46' > "$ROOTFS_DIR/proc/.uptime"
cat <<- EOF > "$ROOTFS_DIR/proc/.stat"
	cpu  1050008 127632 898432 43828767 37203 63 99244 0 0 0
	cpu0 212383 20476 204704 8389202 7253 42 12597 0 0 0
	cpu1 224452 24947 215570 8372502 8135 4 42768 0 0 0
	cpu2 222993 17440 200925 8424262 8069 9 17732 0 0 0
	cpu3 186835 8775 195974 8486330 5746 3 8360 0 0 0
	cpu4 107075 32886 48854 8688521 3995 4 5758 0 0 0
	cpu5 90733 20914 27798 1429573 2984 1 11419 0 0 0
	intr 53261351 0 686 1 0 0 1 12 31 1 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7818 0 0 0 0 0 0 0 0 255 33 1912 33 0 0 0 0 0 0 3449534 2315885 2150546 2399277 696281 339300 22642 19371 0 0 0 0 0 0 0 0 0 0 0 2199 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 162240 14293 2858 0 151709 151592 0 0 0 284534 0 0 0 0 0 0 0 0 0 0 0 0 0 0 185353 0 0 938962 0 0 0 0 736100 0 0 1 1209 27960 0 0 0 0 0 0 0 0 303 115968 452839 2 0 0 0 0 0 0 0 0 0 0 0 0 0 160361 8835 86413 1292 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6091 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 35667 0 0 156823 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 138 2667417 0 41 4008 952 16633 533480 0 0 0 0 0 0 262506 0 0 0 0 0 0 126 0 0 1558488 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 8 0 0 6 0 0 0 10 3 4 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12 1 1 83806 0 1 1 0 1 0 1 1 319686 2 8 0 0 0 0 0 0 0 0 0 244534 0 1 10 9 0 10 112 107 40 221 0 0 0 144
	ctxt 90182396
	btime 1595203295
	processes 270853
	procs_running 2
	procs_blocked 0
	softirq 25293348 2883 7658936 40779 539155 497187 2864 1908702 7229194 279723 7133925
EOF
cat <<- EOF > "$ROOTFS_DIR/proc/.vmstat"
	nr_free_pages 146031
	nr_zone_inactive_anon 196744
	nr_zone_active_anon 301503
	nr_zone_inactive_file 2457066
	nr_zone_active_file 729742
	nr_zone_unevictable 164
	nr_zone_write_pending 8
	nr_mlock 34
	nr_page_table_pages 6925
	nr_kernel_stack 13216
	nr_bounce 0
	nr_zspages 0
	nr_free_cma 0
	numa_hit 672391199
	numa_miss 0
	numa_foreign 0
	numa_interleave 62816
	numa_local 672391199
	numa_other 0
	nr_inactive_anon 196744
	nr_active_anon 301503
	nr_inactive_file 2457066
	nr_active_file 729742
	nr_unevictable 164
	nr_slab_reclaimable 132891
	nr_slab_unreclaimable 38582
	nr_isolated_anon 0
	nr_isolated_file 0
	workingset_nodes 25623
	workingset_refault 46689297
	workingset_activate 4043141
	workingset_restore 413848
	workingset_nodereclaim 35082
	nr_anon_pages 599893
	nr_mapped 136339
	nr_file_pages 3086333
	nr_dirty 8
	nr_writeback 0
	nr_writeback_temp 0
	nr_shmem 13743
	nr_shmem_hugepages 0
	nr_shmem_pmdmapped 0
	nr_file_hugepages 0
	nr_file_pmdmapped 0
	nr_anon_transparent_hugepages 57
	nr_unstable 0
	nr_vmscan_write 57250
	nr_vmscan_immediate_reclaim 2673
	nr_dirtied 79585373
	nr_written 72662315
	nr_kernel_misc_reclaimable 0
	nr_dirty_threshold 657954
	nr_dirty_background_threshold 328575
	pgpgin 372097889
	pgpgout 296950969
	pswpin 14675
	pswpout 59294
	pgalloc_dma 4
	pgalloc_dma32 101793210
	pgalloc_normal 614157703
	pgalloc_movable 0
	allocstall_dma 0
	allocstall_dma32 0
	allocstall_normal 184
	allocstall_movable 239
	pgskip_dma 0
	pgskip_dma32 0
	pgskip_normal 0
	pgskip_movable 0
	pgfree 716918803
	pgactivate 68768195
	pgdeactivate 7278211
	pglazyfree 1398441
	pgfault 491284262
	pgmajfault 86567
	pglazyfreed 1000581
	pgrefill 7551461
	pgsteal_kswapd 130545619
	pgsteal_direct 205772
	pgscan_kswapd 131219641
	pgscan_direct 207173
	pgscan_direct_throttle 0
	zone_reclaim_failed 0
	pginodesteal 8055
	slabs_scanned 9977903
	kswapd_inodesteal 13337022
	kswapd_low_wmark_hit_quickly 33796
	kswapd_high_wmark_hit_quickly 3948
	pageoutrun 43580
	pgrotated 200299
	drop_pagecache 0
	drop_slab 0
	oom_kill 0
	numa_pte_updates 0
	numa_huge_pte_updates 0
	numa_hint_faults 0
	numa_hint_faults_local 0
	numa_pages_migrated 0
	pgmigrate_success 768502
	pgmigrate_fail 1670
	compact_migrate_scanned 1288646
	compact_free_scanned 44388226
	compact_isolated 1575815
	compact_stall 863
	compact_fail 392
	compact_success 471
	compact_daemon_wake 975
	compact_daemon_migrate_scanned 613634
	compact_daemon_free_scanned 26884944
	htlb_buddy_alloc_success 0
	htlb_buddy_alloc_fail 0
	unevictable_pgs_culled 258910
	unevictable_pgs_scanned 3690
	unevictable_pgs_rescued 200643
	unevictable_pgs_mlocked 199204
	unevictable_pgs_munlocked 199164
	unevictable_pgs_cleared 6
	unevictable_pgs_stranded 6
	thp_fault_alloc 10655
	thp_fault_fallback 130
	thp_collapse_alloc 655
	thp_collapse_alloc_failed 50
	thp_file_alloc 0
	thp_file_mapped 0
	thp_split_page 612
	thp_split_page_failed 0
	thp_deferred_split_page 11238
	thp_split_pmd 632
	thp_split_pud 0
	thp_zero_page_alloc 2
	thp_zero_page_alloc_failed 0
	thp_swpout 4
	thp_swpout_fallback 0
	balloon_inflate 0
	balloon_deflate 0
	balloon_migrate 0
	swap_ra 9661
	swap_ra_hit 7872
EOF

# set DNS servers (Cloudflare) to fix internet connectivity inside proot environment
msg "Configuring /etc/resolv.conf..."
cat <<- EOF > "$ROOTFS_DIR/etc/resolv.conf"
	nameserver 1.1.1.1
	nameserver 1.0.0.1
	nameserver 192.168.1.1
EOF

# set sensible startup defaults
msg "Configuring /etc/profile..."
cat <<- EOF >> "$ROOTFS_DIR/etc/profile"
	export PATH=\$PATH:/system/bin:/system/xbin
	export DISPLAY=":1"
	export LANG=en_US.UTF-8
	export PULSE_SERVER=127.0.0.1
	export MOZ_FAKE_NO_SANDBOX=1
EOF

# create intermediate setup script to run within proot environment
msg "Creating intermediate setup script..."
cat <<- EOF > "$ROOTFS_DIR/root/.bash_profile"
	function msg { echo -e "${MSG_COLOR}\${1}${RESET_COLOR}"; }
	function prompt { echo -ne "${PROMPT_COLOR}\${1}${RESET_COLOR} "; }

	# initialize pacman
	msg "Initializing pacman..."
	pacman-mirrors -gf
	pacman-key --init
	pacman-key --populate

	# install core packages
	msg "Installing core packages..."
	pacman -Syyuu --needed --noconfirm base manjaro-release sudo pulseaudio

	# set locale and timezone
	msg "Configuring 'en_US.UTF-8' locale..."
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	locale-gen
	msg "Configuring timezone..."
	echo "export TZ=\$(tzselect)" >> /etc/profile

	# optional: create sudo user
	prompt "Create sudo user? [Y/n]"; read -n 1 CREATE_USER; echo
	CREATE_USER=\${CREATE_USER:-n}
	if [[ \$CREATE_USER =~ [yY] ]]; then
		prompt "Sudo username (manjaro):"; read USERNAME
		USERNAME=\${USERNAME:-manjaro}
		useradd -m -G wheel \$USERNAME
		cat <<- FEO >> /etc/sudoers
			%wheel ALL=(ALL) ALL
			\$USERNAME ALL=(ALL) ALL
		FEO
	fi

	# optional: install and configure TigerVNC
	prompt "Install TigerVNC? [Y/n]"; read -n 1 INSTALL_VNC; echo
	INSTALL_VNC=\${INSTALL_VNC:-n}
	if [[ \$INSTALL_VNC =~ [yY] ]]; then
		pacman -S --needed --noconfirm tigervnc
		msg "Configuring TigerVNC..."
		prompt "VNC resolution (1920x1080):"; read VNC_RESOLUTION
		VNC_RESOLUTION=\${VNC_RESOLUTION:-1920x1080}
		mkdir -p /etc/vnc
		cat <<- FEO > /etc/vnc/config
			Desktop=manjaroid
			Geometry=\$VNC_RESOLUTION
			SecurityTypes=VncAuth,TLSVnc
			Localhost
		FEO
		cat <<- FEO > /etc/vnc/xstartup
			unset SESSION_MANAGER
			pulseaudio --start
			[[ -r \$HOME/.Xresources ]] && xrdb \$HOME/.Xresources
		FEO
		chmod +x /etc/vnc/xstartup
	fi

	# optional: install XFCE4
	prompt "Install XFCE4? [Y/n]"; read -n 1 INSTALL_DE; echo
	INSTALL_DE=\${INSTALL_DE:-n}
	if [[ \$INSTALL_DE =~ [yY] ]]; then
		pacman -S --needed --noconfirm noto-fonts xfce4 xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin pavucontrol
		echo "exec dbus-launch startxfce4" >> /etc/vnc/xstartup
	fi

	# delete pacman cache just in case
	msg "Tidying pacman..."
	paccache -rk0

	# set user + VNC passwords
	msg "Setting 'root' USER password..."
	passwd
	if [[ \$INSTALL_VNC =~ [yY] ]]; then
		msg "Setting 'root' VNC password..."
		vncpasswd
	fi
	if [[ \$CREATE_USER =~ [yY] ]]; then
		msg "Setting '\$USERNAME' USER password..."
		passwd \$USERNAME
		if [[ \$INSTALL_VNC =~ [yY] ]]; then
			msg "Setting '\$USERNAME' VNC password..."
			su - \$USERNAME -c vncpasswd
		fi
	fi

	# delete intermediate setup script
	rm -rf /root/.bash_profile

	exit
EOF
msg "Starting intermediate setup script..."
bash "$ROOTFS_DIR/../manjaroid.sh"

# change launch script to start interactive shell using 'su' now that it's installed (for multi-user compatibility)
sed -i 's/\/sh --login/\/su - $1/g' "$ROOTFS_DIR/../manjaroid.sh"

msg "Done!"
