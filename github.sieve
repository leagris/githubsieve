# rule:[notifications@github.com]
#require ["fileinto", "mailbox", "variables", "imap4flags", "regex"];
if address :is "from" "notifications@github.com" {
	set "gitfolder" "Lists.GitHub";
	if header :matches "List-ID" "*/* <*.github.com>" {
		set "gituser" "${1}";
		set "gitrepository" "${2}";
		# Replace . by dashes for proper IMAP folder name
		# Sieve has no regex global replace, so do it at max 3 occurences
		if string :matches "${gitrepository}" "*.*" {
			set "gitrepository" "${1}-${2}";
			if string :matches "${gitrepository}" "*.*" {
				set "gitrepository" "${1}-${2}";
				if string :matches "${gitrepository}" "*.*" {
					set "gitrepository" "${1}-${2}";
				}
			}
		}
		if header :matches "X-GitHub-Reason" "*" {
			set "gitreason" "${1}";
			# Extract the topic: pull, push, issues...
			if header :regex "Message-ID" ".*(releases|issues?|commit|pull|push)/[[:xdigit:]]+/?(issue_event|push)?.*" {
				set "gittopic" "${1}";
				# Optional capture of git event like: issue_event
				set "gitevent" "${2}"; 
			}
			setflag "MyFlags" [ "${gittopic}", "${gitreason}" ];
			# Add git event flag if any
			if not string :is "${gitevent}" "" {
				addflag "MyFlags" "${gitevent}";
			}
			if string :is "${gitreason}" "review_requested" {
				# Review request is system flagged and tagged TODO $label4 for Thunderbird
				addflag "MyFlags" [ "\\Flagged", "\$label4" ];
			}
		}
		fileinto :flags "${MyFlags}" :create "${gitfolder}.${gituser}.${gitrepository}";
	}
	stop;
}
