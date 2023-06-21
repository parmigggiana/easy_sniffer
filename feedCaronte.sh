#!/bin/bash - 
#===============================================================================
#
#          FILE: feedCaronte.sh
# 
#         USAGE: ./feedCaronte.sh PCAP_DIR_PATH
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: inotify-tools, curl
#          BUGS: ---
#         NOTES: test in Debian Buster
#        AUTHOR: Andrea Giovine (AG), 
#  ORGANIZATION: 
#       CREATED: 17/08/2020 16:36:57
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

CHECK_INOTIFY_DEB=$(dpkg-query -W -f='${status}' 'inotify-tools' 2> /dev/null)
CHECK_INOTIFY_RPM=$(rpm -qa inotify-tools | sed 's/\([^-]*\)-.*/\1/' 2> /dev/null)

if [[ "$CHECK_INOTIFY_DEB" != 'install ok installed' ]] && [[ "$CHECK_INOTIFY_RPM" != 'inotify' ]]; then
        echo "Install inotify-tools"
        exit 1
fi

CHECK_CURL_DEB=$(dpkg-query -W -f='${Status}' 'curl' 2> /dev/null)
CHECK_CURL_RPM=$(rpm -qa curl | sed 's/\([^-]*\)-.*/\1/' 2> /dev/null)

if [[ "$CHECK_CURL_DEB" != 'install ok installed' ]] && [[ "$CHECK_CURL_RPM" != 'curl' ]]; then
        echo "Install curl"
        exit 1
fi

if [[ "$#" -ne 1 ]]; then
	echo "Need 1 arg"
	exit 2
fi

PCAP_DIR="$1"

if [[ -z "$PCAP_DIR" ]]; then
	echo "Need path to dir where are store pcaps"
	exit 2
fi

inotifywait -m "$PCAP_DIR" -e moved_to |
	while read dir action file; do
		echo "The file $file appeared in directory $dir via $action"
		curl -F "file=@${dir}$file" "http://localhost:3333/api/pcap/upload"
	done
