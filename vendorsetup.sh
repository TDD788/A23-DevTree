# Mkbootimage
sudo apt install nano
git clone https://gitlab.com/EdwinT2/avb_tool -b main out/host/linux-x86/bin
sudo chmod +rwx out/host/linux-x86/bin/avbtool
chmod a+x device/samsung/a23/prebuilt/avb/mkbootimg
add_lunch_combo twrp_a23-eng



FDEVICE1="a23"
CURR_DEVICE="a23"

RED_BACK="\e[101m"
RED="\e[91m"
RESET="\e[0m"
GREEN="\e[92m"

export_build_vars(){
	echo -e "${GREEN}Exporting build vars from the a23 tree${RESET}"
	# General Configurations
	export ALLOW_MISSING_DEPENDENCIES=true
	export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
	export LC_ALL="C"
	export OF_MAINTAINER="TheDarkDeath788"
	export FOX_BUILD_TYPE="Oficial"
	export FOX_VERSION="R12-(Oatmeal-Cookies)"
	export OF_CLASSIC_LEDS_FUNCTION=0
	export FOX_DELETE_AROMAFM=0
	export OF_CLOCK_POS=1
	export OF_IGNORE_LOGICAL_MOUNT_ERRORS=1
	export OF_FORCE_PREBUILT_KERNEL=1
	export OF_NO_SPLASH_CHANGE=0
	export OF_STATUS_INDENT_RIGHT=48
	export OF_STATUS_INDENT_LEFT=48
	export OF_WIPE_METADATA_AFTER_DATAFORMAT=1
	export OF_OPTIONS_LIST_NUM=8
	export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
	export OF_USE_TWRP_SAR_DETECT=1

	# Security Configurations
	export OF_ADVANCED_SECURITY=1
	export OF_FORCE_DISABLE_FORCED_ENCRYPTION=1
	export OF_FORCE_DISABLE_DM_VERITY=1
	export OF_DISABLE_FORCED_ENCRYPTION=1
	export OF_FORCE_DISABLE_FORCED_ENCRYPTION=1
	export OF_USE_SYSTEM_FINGERPRINT=1
	
	# Partition Configurations
	export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
	export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"
	export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/by-name/recovery"

	# Tools and Utilities Configurations
	export OF_USE_MAGISKBOOT=1
	export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
	export OF_USE_LZMA_COMPRESSION=1
	export OF_ENABLE_LPTOOLS=1
	export OF_ENABLE_FS_COMPRESSION=1
	export OF_USE_LOCKSCREEN_BUTTON=1

	# Newer Functions For Me Dark (TheDarkDeath788 )
	export OF_CHECK_OVERWRITE_ATTEMPTS=1
	export FOX_VANILLA_BUILD=1
	export FOX_PORTS_TMP=1
	export OF_OTA_BACKUP_STOCK_BOOT_IMAGE=1
	export OF_DONT_PATCH_ON_FRESH_INSTALLATION=1
	
	# maximum permissible splash image size
	# (in kilobytes); do *NOT* increase!
	export OF_SPLASH_MAX_SIZE=104

	# Specific Features Configurations
	export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
	export OF_NO_TREBLE_COMPATIBILITY_CHECK=0
	export OF_SKIP_MULTIUSER_FOLDERS_BACKUP=1
	export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
	export FOX_VARIANT="AOSP"
	export FOX_NO_SAMSUNG_SPECIAL=2
	export OF_PATCH_AVB20=1
	export OF_SUPPORT_VBMETA_AVB2_PATCHING=1
	export OF_SCREEN_H=2400
	export FOX_BUGGED_AOSP_ARB_WORKAROUND="1695707220" # [Tue Feb 27 2024 01:07:00 GMT]

	# File Paths Configurations
	#export OF_FL_PATH1="/sys/devices/virtual/camera/flash/rear_flash"
	export OF_FL_PATH1="/system/flashlight"
	export OF_FL_PATH2=""
	export OF_FLASHLIGHT_ENABLE=1
	
	# Maintainer Avatar
	wget https://raw.githubusercontent.com/TDD788/a23-DevTree/DT-Builder/recovery/root/TheDarkDeath788.png
	export OF_MAINTAINER_AVATAR="./maintainer.png"

	# Applications Configurations
	export FOX_ENABLE_APP_MANAGER=1

	# Custom Binaries to SD Card Configuration
	export FOX_CUSTOM_BINS_TO_SDCARD=2
	
	
	if [ "$FOX_CUSTOM_BINS_TO_SDCARD" != "" ]; then
		export FOX_USE_NANO_EDITOR=1
		export FOX_USE_SED_BINARY=1
		export FOX_USE_TAR_BINARY=1
		export FOX_USE_UNZIP_BINARY=1
		export FOX_USE_XZ_UTILS=1
		export FOX_REPLACE_BUSYBOX_PS=1
		export FOX_REPLACE_TOOLBOX_GETPROP=1
	else
		export FOX_DYNAMIC_SAMSUNG_FIX=1
	fi

	#Ofox 11
	#export FOX_R11=1
	
	# Magisk
	user='topjohnwu'
	repo='Magisk'
	pattern="$user/$repo/releases/download/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+\.apk"
	url_base="https://github.com/$user/$repo/releases"
	url_latest="$url_base/latest"

	echo 'Searching for latest Magisk...'
	redirect_url="$(curl "$url_latest" -s -L -I -o /dev/null -w '%{url_effective}')" || {
	    code=$?
	    echo "Failed to open $url_latest"
	    exit $code
	}

	# Extract tag
	version_tag="${redirect_url/$url_base\/tag\/}"

	url="https://github.com/topjohnwu/Magisk/releases/expanded_assets/$version_tag"

	echo 'Searching for Magisk download link...'
	html="$(curl --show-error --location "$url")" || {
	    code=$?
	    echo "Failed to download $url"
	    exit $code
	}

	file_link="$(echo "$html" | grep -iEo "$pattern" | (head -n 1; dd status=none of=/dev/null))"
	download_link="https://github.com/$file_link"
	file_name="/tmp/$(basename "${file_link/apk/zip}")"

	echo "Downloading Magisk from $download_link"
	response_code="$(curl \
	    --show-error \
	    --location "$download_link" \
	    --write-out '%{http_code}' \
	    --output "$file_name")"; code=$?

	if [ $code -gt 0 ] || [ $response_code -ge 400 ]; then
	    echo "Failed to download $download_link"
	    exit $code
	fi
	echo "Latest Magisk has been saved to: $file_name"

	export FOX_USE_SPECIFIC_MAGISK_ZIP="$file_name"
	
	# let's see what are our build VARs
	if [ -n "$FOX_BUILD_LOG_FILE" -a -f "$FOX_BUILD_LOG_FILE" ]; then
	  export | grep "FOX" >> $FOX_BUILD_LOG_FILE
	  export | grep "OF_" >> $FOX_BUILD_LOG_FILE
	  export | grep "TARGET_" >> $FOX_BUILD_LOG_FILE
	  export | grep "TW_" >> $FOX_BUILD_LOG_FILE
	fi
}

set_env_var(){
        echo -e "${RED_BACK}Environment Variable CURR_DEVICE not set... Aborting${RESET}"
        echo "Set to the codename of the device you're building for"
        echo -e "${GREEN}Example :${RESET}"
        echo " export CURR_DEVICE=a23"
        exit 1
}

var_not_eq(){
        echo -e "${RED_BACK}CURR_DEVICE not equal to a23${RESET}"
        echo -e "${RED_BACK}CURR_DEVICE = $CURR_DEVICE${RESET}"
        echo -e "${RED}If this is a mistake, then export CURR_DEVICE to the correct codename${RESET}"
        echo -e "${RED}Skipping a23 specific build vars...${RESET}"
}

case "$CURR_DEVICE" in
  "$FDEVICE1")
    export_build_vars;
    ;;
  "")
    set_env_var
    ;;
  *)
    var_not_eq
    ;;
esac

