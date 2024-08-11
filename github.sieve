# Sieve Email Filter for GitHub Notifications
# @Author  Léa Gris
# @Version 1.0.1
# @Licence MIT
# rule:[notifications@github.com]
#require ["fileinto", "mailbox", "variables", "imap4flags", "regex"];
if address :is "from" "notifications@github.com" {
	# Change this to your liking: Sets the root folder for GitHub notifications' emails
	set "ghFolder" "Lists/GitHub";
	if header :matches "List-ID" "*/* <*.github.com>" {
		set "ghUser" "${1}";
		set "ghRepository" "${2}";
		if header :matches "X-GitHub-Reason" "*" {
			set "ghReason" "${1}";
			# Extract the topic: pull, push, issues...
			if header :regex "Message-ID" ".*(releases|issues?|commit|pull)/[[:xdigit:]]+/?(issue_event|push|review)?.*" {
				set "ghTopic" "${1}";
				# Optional capture of git event like: issue_event
				set "ghEvent" "${2}"; 
			}
			setflag "ghMsgFlags" [ "${ghTopic}", "${ghReason}" ];
			# Adds git event flag if any
			if not string :is "${ghEvent}" "" {
				addflag "ghMsgFlags" "${ghEvent}";
			}
			if string :is "${ghReason}" "review_requested" {
				# Review request is system flagged and tagged TODO $label4 for Thunderbird
				addflag "ghMsgFlags" [ "\\Flagged", "\$label4" ];
			}
		}
		fileinto :flags "${ghMsgFlags}" :create "${ghFolder}/${ghUser}/${ghRepository}";
	}
	stop;
}
