#!/bin/bash

clean () {
	if [ -f "/tmp/projects.html" ]
	then
		rm "/tmp/projects.html"
	fi
	if [ -f "/tmp/projects.xml" ]
	then
		rm "/tmp/projects.xml"
	fi
}

sync_files_datetime () {
	cd "projects"
	for file in *
	do
		date=$(cat "$file" | grep "[0-9]*-[0-9]*-[0-9]*" | sed "s/-//g")
		date="$date""0000"
		touch "$file" -t "$date"
	done
	cd ..
}

build_projects_to_html () {
	local template=$(cat project.template)
	local rss=$(cat item-rss.template)
	local project=""
	local html=""

	cd "projects"

	for file in $(ls --sort=time)
	do
		local lines=()
		local index=0
		local description=""
		while read line
		do
			lines[$index]="$line"
			index=$(($index+1))

			if [ 3 -lt $index ]
			then
				description="$description$line<br/>"
			fi

		done < "$file"

		title=${lines[0]}
		video=${lines[1]}
		link="$file"
		
		project="$template"
		projectRss="$rss"

		project="${project//TITLE/$title}"
		projectRss="${projectRss//TITLE/$title}"

		project="${project//VIDEO/$video}"
		projectRss="${projectRss//VIDEO/$video}"

		project="${project//DESCRIPTION/$description}"
		projectRss="${projectRss//DESCRIPTION/$description}"

		project="${project//LINK/$link}"
		projectRss="${projectRss//LINK/$link}"

		echo "$project" >> /tmp/projects.html 
		echo "$projectRss" >> /tmp/projects.xml

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

build_rss_xml () {
	local rss=$(cat rss.template)
	local items=$(cat /tmp/projects.xml)

	rss="${rss//PROJECTS/$items}"
	echo "$rss" > rss.xml 
}

main () {
	clean
	sync_files_datetime
	build_projects_to_html
	build_index_html
	build_rss_xml
	clean
}

time main

