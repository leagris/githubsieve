require ["fileinto", "mailbox", "variables", "imap4flags", "regex"];
# rule:[notifications@github.com]
#require ["fileinto", "mailbox", "variables", "imap4flags", "regex"];
if address :is "from" "notifications@github.com" {
	set "gitfolder" "Lists.GitHub";
	if header :matches "List-ID" "*<*.*.github.com>" {
		set "gituser" "${3}";
		set "gitrepository" "${2}";
		# Replace . or + by dashes for proper IMAP folder name
		# Sieve has no regex global replace, so do it at max 3 occurences
		if string :regex "${gitrepository}" "(.*)[.+]+(.*)" {
			set "gitrepository" "${1}-${2}";
			if string :regex "${gitrepository}" "(.*)[.+]+(.*)" {
				set "gitrepository" "${1}-${2}";
				if string :regex "${gitrepository}" "(.*)[.+]+(.*)" {
					set "gitrepository" "${1}-${2}";
				}
			}
		}
		if header :matches "X-GitHub-Reason" "*" {
			set "gitreason" "${1}";
			# Extract the topic: pull, push, issues...
			if header :regex "Message-ID" "([^/[:digit:]]+)/[[:digit:]]+(/([^/[:digit:]]+))?" {
				set "gittopic" "${1}";
				# Optional capture of git event like: issue_event
				set "gitevent" "${3}"; 
			}
			if string :is "${gitreason}" "review_requested" {
				# Review request is flagged and reaseon tagged first as it determines color in Thunderbird
				setflag "MyFlags" [ "\\Flagged", "${gitreason}", "${gittopic}" ];
			} else {
				setflag "MyFlags" [ "${gittopic}", "${gitreason}" ];
			}
			# Add git event flag if any
			if not string :is "${gitevent}" "" {
				addflag "MyFlags" "${gitevent}";
				}
		}
		fileinto :flags "${MyFlags}" :create "${gitfolder}.${gituser}.${gitrepository}";
	}
	stop;
}
