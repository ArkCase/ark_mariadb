#!/bin/bash
(
	. /.functions
	set -euo pipefail

	set_or_default DATA_DIR "/var/lib/mysql/data"
	set_or_default UPGRADE_LOG "${DATA_DIR}/auto-upgrade.log"

	#
	# FIRST THINGS FIRST!! See if we need to do an auto-upgrade
	#
	if ! mysql_upgrade -u root --check-if-upgrade-is-needed ; then
		# Just in case - cleanup!
		if is_file "${UPGRADE_LOG}" ; then
			warn "An old upgrade log was detected!!"
			rm -rf "${UPGRADE_LOG}" &>/dev/null
			is_file "${UPGRADE_LOG}" && err "Could not remove the old upgrade log at [${UPGRADE_LOG}]! Auto upgrades will not work until it's removed!"
		fi

		# We end all further execution b/c we're good to go as-is!
		quit "No upgrade is necessary"
	fi

	#
	# An upgrade appears to be needed ... so let's do it!
	#
	if is_file "${UPGRADE_LOG}" ; then
		err "An upgrade was previously attempted, but failed - please resolve those issues first (logs at ${UPGRADE_LOG})"
		warn "You may need to disable pod probes and such to avoid container/pod shutdowns"
	else
		: > "${UPGRADE_LOG}" || fail "Failed to create the upgrade log at [${UPGRADE_LOG}]"

		(
			running "Attempting an in-place upgrade!"
			mysql_upgrade -u root || fail "Upgrade attempt failed (rc=${?}), logs at [${UPGRADE_LOG}]"
			ok "Upgrade succeeded (the on-disk upgrade log should be auto-removed)!"
		) |& tee "${UPGRADE_LOG}"
		RC=${PIPESTATUS[0]}

		#
		# If everything's OK, we just move along and clear the marker!
		#
		if [ ${RC} -eq 0 ] ; then
			rm -rf "${UPGRADE_LOG}" &>/dev/null || true
			quit "Upgrade succeeded!"
		fi

		err "Upgrade failed (rc=${RC})"
	fi

	warn "The container will halt here to allow for debugging and triage"
	wait-forever
)
