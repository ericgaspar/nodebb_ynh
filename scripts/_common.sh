
#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="postgresql apt-transport-https"

nodejs_version=12

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================






#!/bin/bash

#=================================================


# EXEC_LOGIN_AS Helper

# Execute a command as another user with login
# (hence in user home dir, with prior loading of .profile, etc.)
# usage: exec_login_as USER COMMAND [ARG ...]
exec_login_as() {
  local user=$1
  shift 1
  exec_as $user --login "$@"
}
# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local user=$1
  shift 1

  if [[ $user = $(whoami) ]]; then
    eval "$@"
  else
    sudo -u "$user" "$@"
  fi
}

#=================================================
# PACKAGE CHECK BYPASSING...
#=================================================

IS_PACKAGE_CHECK () {	# Détermine une exécution en conteneur (Non testé)
	return $(uname -n | grep -c 'pchecker_lxc')
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# INFOS
# n (Node version management) utilise la variable PATH pour stocker le path de la version de node à utiliser.
# C'est ainsi qu'il change de version
# ynh_install_nodejs installe la version de nodejs demandée en argument, avec n
# ynh_use_nodejs active une version de nodejs dans le script courant
# 3 variables sont mises à disposition, et 2 sont stockées dans la config de l'app
# - nodejs_path: Le chemin absolu de cette version de node
# Utilisé pour des appels directs à node.
# - nodejs_version: Simplement le numéro de version de nodejs pour cette application
# - nodejs_use_version: Un alias pour charger une version de node dans le shell courant.
# Utilisé pour démarrer un service ou un script qui utilise node ou npm
# Dans ce cas, c'est $PATH qui contient le chemin de la version de node. Il doit être propagé sur les autres shell si nécessaire.



#=================================================

# Start or restart a service and follow its booting
#
# usage: ynh_check_starting "Line to match" [Log file] [Timeout]
#
# | arg: Line to match - The line to find in the log to attest the service have finished to boot.
# | arg: Log file - The log file to watch
# /var/log/$app/$app.log will be used if no other log is defined.
# | arg: Timeout - The maximum time to wait before ending the watching. Defaut 300 seconds.
ynh_check_starting () {
	local line_to_match="$1"
	local app_log="${2:-/var/log/$app/$app.log}"
	local timeout=${3:-300}

	ynh_clean_check_starting () {
		# Stop the execution of tail.
		kill -s 15 $pid_tail 2>&1
		ynh_secure_remove "$templog" 2>&1
	}

	echo "Starting of $app" >&2
	systemctl restart $app
	local templog="$(mktemp)"
	# Following the starting of the app in its log
	tail -f -n1 "$app_log" > "$templog" &
	# Get the PID of the tail command
	local pid_tail=$!

	local i=0
	for i in `seq 1 $timeout`
	do
		# Read the log until the sentence is found, that means the app finished to start. Or run until the timeout
		if grep --quiet "$line_to_match" "$templog"
		then
			echo "The service $app has correctly started." >&2
			break
		fi
		echo -n "." >&2
		sleep 1
	done
	if [ $i -eq $timeout ]
	then
		echo "The service $app didn't fully started before the timeout." >&2
	fi

	echo ""
	ynh_clean_check_starting
}

#=================================================

ynh_print_log () {
  echo "${1}"
}

# Print an info on stdout
#
# usage: ynh_print_info "Text to print"
# | arg: text - The text to print
ynh_print_info () {
  ynh_print_log "[INFO] ${1}"
}

# Print a warning on stderr
#
# usage: ynh_print_warn "Text to print"
# | arg: text - The text to print
ynh_print_warn () {
  ynh_print_log "[WARN] ${1}" >&2
}

# Print a error on stderr
#
# usage: ynh_print_err "Text to print"
# | arg: text - The text to print
ynh_print_err () {
  ynh_print_log "[ERR] ${1}" >&2
}

# Execute a command and print the result as an error
#
# usage: ynh_exec_err command to execute
# usage: ynh_exec_err "command to execute | following command"
# In case of use of pipes, you have to use double quotes. Otherwise, this helper will be executed with the first command, then be send to the next pipe.
#
# | arg: command - command to execute
ynh_exec_err () {
	ynh_print_err "$(eval $@)"
}

# Execute a command and print the result as a warning
#
# usage: ynh_exec_warn command to execute
# usage: ynh_exec_warn "command to execute | following command"
# In case of use of pipes, you have to use double quotes. Otherwise, this helper will be executed with the first command, then be send to the next pipe.
#
# | arg: command - command to execute
ynh_exec_warn () {
	ynh_print_warn "$(eval $@)"
}

# Execute a command and force the result to be printed on stdout
#
# usage: ynh_exec_warn_less command to execute
# usage: ynh_exec_warn_less "command to execute | following command"
# In case of use of pipes, you have to use double quotes. Otherwise, this helper will be executed with the first command, then be send to the next pipe.
#
# | arg: command - command to execute
ynh_exec_warn_less () {
	eval $@ 2>&1
}

# Execute a command and redirect stdout in /dev/null
#
# usage: ynh_exec_quiet command to execute
# usage: ynh_exec_quiet "command to execute | following command"
# In case of use of pipes, you have to use double quotes. Otherwise, this helper will be executed with the first command, then be send to the next pipe.
#
# | arg: command - command to execute
ynh_exec_quiet () {
	eval $@ > /dev/null
}

# Execute a command and redirect stdout and stderr in /dev/null
#
# usage: ynh_exec_fully_quiet command to execute
# usage: ynh_exec_fully_quiet "command to execute | following command"
# In case of use of pipes, you have to use double quotes. Otherwise, this helper will be executed with the first command, then be send to the next pipe.
#
# | arg: command - command to execute
ynh_exec_fully_quiet () {
	eval $@ > /dev/null 2>&1
}

# Remove any logs for all the following commands.
#
# usage: ynh_print_OFF
# WARNING: You should be careful with this helper, and never forgot to use ynh_print_ON as soon as possible to restore the logging.
ynh_print_OFF () {
	set +x
}

# Restore the logging after ynh_print_OFF
#
# usage: ynh_print_ON
ynh_print_ON () {
	set -x
	# Print an echo only for the log, to be able to know that ynh_print_ON has been called.
	echo ynh_print_ON > /dev/null
}

#=================================================

# Install or update the main directory yunohost.multimedia
#
# usage: ynh_multimedia_build_main_dir
ynh_multimedia_build_main_dir () {
	wget -nv https://github.com/YunoHost-Apps/yunohost.multimedia/archive/master.zip 2>&1
	unzip -q master.zip
	./yunohost.multimedia-master/script/ynh_media_build.sh
}

# Add a directory in yunohost.multimedia
# This "directory" will be a symbolic link to a existing directory.
#
# usage: ynh_multimedia_addfolder "Source directory" "Destination directory"
#
# | arg: Source directory - The real directory which contains your medias.
# | arg: Destination directory - The name and the place of the symbolic link, relative to "/home/yunohost.multimedia"
ynh_multimedia_addfolder () {
	local source_dir="$1"
	local dest_dir="$2"
	./yunohost.multimedia-master/script/ynh_media_addfolder.sh --source="$source_dir" --dest="$dest_dir"
}

# Move a directory in yunohost.multimedia, and replace by a symbolic link
#
# usage: ynh_multimedia_movefolder "Source directory" "Destination directory"
#
# | arg: Source directory - The real directory which contains your medias.
# It will be moved to "Destination directory"
# A symbolic link will replace it.
# | arg: Destination directory - The new name and place of the directory, relative to "/home/yunohost.multimedia"
ynh_multimedia_movefolder () {
	local source_dir="$1"
	local dest_dir="$2"
	./yunohost.multimedia-master/script/ynh_media_addfolder.sh --inv --source="$source_dir" --dest="$dest_dir"
}

# Allow an user to have an write authorisation in multimedia directories
#
# usage: ynh_multimedia_addaccess user_name
#
# | arg: user_name - The name of the user which gain this access.
ynh_multimedia_addaccess () {
	local user_name=$1
	groupadd -f multimedia
	usermod -a -G multimedia $user_name
}

#=================================================

# Create a dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_add_fail2ban_config log_file filter [max_retry [ports]]
# | arg: log_file - Log file to be checked by fail2ban
# | arg: failregex - Failregex to be looked for by fail2ban
# | arg: max_retry - Maximum number of retries allowed before banning IP address - default: 3
# | arg: ports - Ports blocked for a banned IP address - default: http,https
ynh_add_fail2ban_config () {
	# Process parameters
	logpath=$1
	failregex=$2
	max_retry=${3:-3}
	ports=${4:-http,https}

	test -n "$logpath" || ynh_die "ynh_add_fail2ban_config expects a logfile path as first argument and received nothing."
	test -n "$failregex" || ynh_die "ynh_add_fail2ban_config expects a failure regex as second argument and received nothing."

	finalfail2banjailconf="/etc/fail2ban/jail.d/$app.conf"
	finalfail2banfilterconf="/etc/fail2ban/filter.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalfail2banjailconf" 1
	ynh_backup_if_checksum_is_different "$finalfail2banfilterconf" 1

	sudo tee $finalfail2banjailconf <<EOF
[$app]
enabled = true
port = $ports
filter = $app
logpath = $logpath
maxretry = $max_retry" 
EOF

	sudo tee $finalfail2banfilterconf <<EOF
[INCLUDES]
before = common.conf
[Definition]
failregex = $failregex
ignoreregrex =" 
EOF

	ynh_store_file_checksum "$finalfail2banjailconf"
	ynh_store_file_checksum "$finalfail2banfilterconf"

	sudo systemctl restart fail2ban
}

# Remove the dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_remove_fail2ban_config
ynh_remove_fail2ban_config () {
	ynh_secure_remove "/etc/fail2ban/jail.d/$app.conf"
	ynh_secure_remove "/etc/fail2ban/filter.d/$app.conf"
	sudo systemctl restart fail2ban
}

#=================================================

# Read the value of a key in a ynh manifest file
#
# usage: ynh_read_manifest manifest key
# | arg: manifest - Path of the manifest to read
# | arg: key - Name of the key to find
ynh_read_manifest () {
	manifest="$1"
	key="$2"
	python3 -c "import sys, json;print(json.load(open('$manifest'))['$key'])"
}

# Exit without error if the package is up to date
#
# This helper should be used to avoid an upgrade of a package
# when it's not needed.
#
# To force an upgrade, even if the package is up to date,
# you have to set the variable YNH_FORCE_UPGRADE before.
# example: sudo YNH_FORCE_UPGRADE=1 yunohost app upgrade MyApp
#
# usage: ynh_abort_if_up_to_date
ynh_abort_if_up_to_date () {
	local force_upgrade=${YNH_FORCE_UPGRADE:-0}
	local package_check=${PACKAGE_CHECK_EXEC:-0}

	local version=$(ynh_read_manifest "/etc/yunohost/apps/$YNH_APP_INSTANCE_NAME/manifest.json" "version" || echo 1.0)
	local last_version=$(ynh_read_manifest "../manifest.json" "version" || echo 1.0)
	if [ "$version" = "$last_version" ]
	then
		if [ "$force_upgrade" != "0" ]
		then
			echo "Upgrade forced by YNH_FORCE_UPGRADE." >&2
			unset YNH_FORCE_UPGRADE
		elif [ "$package_check" != "0" ]
		then
			echo "Upgrade forced for package check." >&2
		else
			ynh_die "Up-to-date, nothing to do" 0
		fi
	fi
}

#=================================================

# Send an email to inform the administrator
#
# usage: ynh_send_readme_to_admin app_message [recipients]
# | arg: app_message - The message to send to the administrator.
# | arg: recipients - The recipients of this email. Use spaces to separate multiples recipients. - default: root
#	example: "root admin@domain"
#	If you give the name of a YunoHost user, ynh_send_readme_to_admin will find its email adress for you
#	example: "root admin@domain user1 user2"
ynh_send_readme_to_admin() {
	local app_message="${1:-...No specific information...}"
	local recipients="${2:-root}"

	# Retrieve the email of users
	find_mails () {
		local list_mails="$1"
		local mail
		local recipients=" "
		# Read each mail in argument
		for mail in $list_mails
		do
			# Keep root or a real email address as it is
			if [ "$mail" = "root" ] || echo "$mail" | grep --quiet "@"
			then
				recipients="$recipients $mail"
			else
				# But replace an user name without a domain after by its email
				if mail=$(ynh_user_get_info "$mail" "mail" 2> /dev/null)
				then
					recipients="$recipients $mail"
				fi
			fi
		done
		echo "$recipients"
	}
	recipients=$(find_mails "$recipients")

	local mail_subject="☁️🆈🅽🅷☁️: \`$app\` was just installed!"

	local mail_message="This is an automated message from your beloved YunoHost server.

Specific information for the application $app.

$app_message

---
Automatic diagnosis data from YunoHost

$(yunohost tools diagnosis | grep -B 100 "services:" | sed '/services:/d')"

	# Define binary to use for mail command
	if [ -e /usr/bin/bsd-mailx ]
	then
		local mail_bin=/usr/bin/bsd-mailx
	else
		local mail_bin=/usr/bin/mail.mailutils
	fi

	# Send the email to the recipients
	echo "$mail_message" | $mail_bin -a "Content-Type: text/plain; charset=UTF-8" -s "$mail_subject" "$recipients"
}

#=================================================
#============= FUTURE YUNOHOST HELPER ============
#=================================================

# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}
