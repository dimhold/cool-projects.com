#!/bin/bash

clean () {
	if [ -f "/tmp/projects.html" ]
	then
		rm "/tmp/projects.html"
	fi
}

build_projects_to_html () {
	local template=$(cat project.template)
	local project=""
	local index=0
	local html=""

	cd "projects"

	for file in *
	do
		while read line
		do
			lines[$index]="$line"
			index=$(($index+1))
		done < "$file"

		title=${lines[0]}; unset lines[0]
		video=${lines[1]}; unset lines[1]
		description=${lines[@]}
		link="$file"

		project="$template"
		project="${project//TITLE/$title}"
		project="${project//VIDEO/$video}"
		project="${project//DESCRIPTION/$description}"
		project="${project//LINK/$link}"
		echo "$project" >> /tmp/projects.html 

		echo -n "+" #marker for pv (progress bar)
	done | pv -s $(ls | wc -l) > /dev/null

	cd ..
}

build_index_html () {
	local index=$(cat index.template)
	local html=$(cat /tmp/projects.html)

	html="${index//PROJECTS/$html}"
	echo "$html" > index.html
}

main () {
	clean
	build_projects_to_html
	build_index_html
	clean
}

time main
