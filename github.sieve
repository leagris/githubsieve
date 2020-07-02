# rule:[notifications@github.com]
#require ["fileinto", "mailbox", "variables", "imap4flags", "regex"];
if address :is "from" "notifications@github.com" {
	set "gitfolder" "Lists/GitHub";
	if header :matches "List-ID" "*/* <*.github.com>" {
		set "gituser" "${1}";
		set "gitrepository" "${2}";
		if header :matches "X-GitHub-Reason" "*" {
			set "gitreason" "${1}";
			# Extract the topic: pull, push, issues...
			if header :regex "Message-ID" ".*(releases|issues?|commit|pull)/[[:xdigit:]]+/?(issue_event|push|review)?.*" {
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
		fileinto :flags "${MyFlags}" :create "${gitfolder}/${gituser}/${gitrepository}";
	}
	stop;
}
