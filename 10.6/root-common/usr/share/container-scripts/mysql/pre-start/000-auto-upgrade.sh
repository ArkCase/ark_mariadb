#!/bin/bash
(
	. /.functions
	set -euo pipefail

	set_as_boolean AUTO_UPGRADE_DISABLE "false"
	set_or_default DATA_DIR "/var/lib/mysql/data"
	set_or_default UPGRADE_LOG "${DATA_DIR}/auto-upgrade.log"

	#
	# If we didn't rename the log to a timestamped name, then
	# it means the upgrade was interrupted for some reason
	#
	if ! is_file "${UPGRADE_LOG}" ; then

		#
		# We only do this check if our upgrade status is clean! Otherwise, we
		# still want to tell the admin that something's off and needs attention
		#
		as_boolean "${AUTO_UPGRADE_DISABLE}" && quit "Auto-upgrades are currently disabled"

		#
		# FIRST THINGS FIRST!! See if we need to do an auto-upgrade
		#
		mysql_upgrade ${mysql_flags} --check-if-upgrade-is-needed || quit "No upgrade appears to necessary necessary"

		#
		# An upgrade appears to be needed ... so let's do it!
		#
		: > "${UPGRADE_LOG}" || fail "Failed to create the upgrade log at [${UPGRADE_LOG}]"

		#
		# Do the deed!
		#
		TIMESTAMP="$(date -u "+%Y%m%d-%H%M%SZ")"
		(
			running "Attempting an in-place upgrade!"
			mysql_upgrade ${mysql_flags} --force || fail "Upgrade attempt failed (rc=${?}), logs at [${UPGRADE_LOG}]"
			ok "Upgrade complete"
		) |& tee "${UPGRADE_LOG}"
		RC=${PIPESTATUS[0]}

		#
		# If everything's OK, we just move along and clear the marker!
		#
		if [ ${RC} -eq 0 ] ; then
			mv -vf "${UPGRADE_LOG}" "${UPGRADE_LOG}.${TIMESTAMP}"
			quit "Upgrade log rotated"
		fi

		err "The auto-upgrade attempt failed (rc=${RC})"
	else
		err "An automatic upgrade was previously attempted, but appears to have failes - please resolve those issues first (the log is at [${UPGRADE_LOG}])"
	fi

	#
	# Something's off - go into a holding pattern to let
	# the admin come in and do any necessary cleanup
	#
	warn "The container will halt here to allow for debugging and triage"
	warn "You may need to disable pod probes and such to avoid container/pod shutdowns"
	wait-forever
)
