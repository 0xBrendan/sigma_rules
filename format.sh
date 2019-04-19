
mkdir rulesformatted
cd sigmarules

for copy in * ; do #makes copies of the sigmarules we are formatting instead of editing them directly
  cp $copy ../rulesformatted/$copy
done

prefix="description: " #values to check against later
suffix="filter:"

for entry in ../rulesformatted/*.yml ; do

  doc=$(sed -n '/doc_type: /{p;q}' $entry)

  if [ "$doc" != "" ] #checks if doc_type line exists
  then

    sed -i "/$doc/d" $entry #delete old doc_type entry
    sed -i "/- debug/a\\$doc" $entry #put new doc_type entry in location that doesn't mess up desc

  fi

  desc=$(sed -n '/^description:/,/filter:$/p' $entry) #extracts the text for description across multiple lines
  desc=$(echo "$desc" | sed -e '1,/filter:/!d') #dedup for the description

  desc=${desc#"$prefix"} #trims off "description:"
  desc=${desc%"$suffix"} #trims off "filter:"

  desc=$(echo "$desc" | tr '\n' ' ') #changes description to one liner

  sev=$(sed -n '0,/priority: /s///p' $entry) #pushing priority level to assign to hive severity with dedup
  size=$(stat -c '%s' $entry) #count filesize used by truncate

  truncate -s $(expr $size - 2) $entry #trim whitespace from initial conversion

    sed -i '1s;^;import: globalconfig.txt\n;' $entry #adding globalconfig reference at start of file
    sed -i '/globalconfig.txt/a\ ' $entry #adding new line after globalconfig
    sed -i 's/- debug/- slack/g' $entry # replace debug alert types with slack and hive + next 2 lines
    sed -i '/- slack/a\- hivealerter' $entry
    sed -i '/- hivealerter/a\ ' $entry

    echo '' >> $entry # these append new lines for formatting
    echo 'alert_text: "' >> $entry #following code appends the fields we need to the end of the file

    echo '	EventId: {0}\n' >> $entry
    echo '        Timestamp: {1}\n' >> $entry
    echo '        Host: {2}\n' >> $entry
    echo '        Username: {3}\n' >> $entry
    echo '        Log ID: {4}\n' >> $entry
    echo '        Index: {5}\n"' >> $entry

    echo '' >> $entry
    echo 'alert_text_args: ["event_id", "@timestamp", "host_name", "user_name", "_id", "_index"]' >> $entry
    echo 'alert_text_type: alert_text_only' >> $entry
    echo '' >> $entry

    echo 'hive_alert_config:' >> $entry
    echo '    title: "{rule[name]}"' >> $entry
    echo '    type: "external"' >> $entry
    echo '    source: "Elastalert"' >> $entry
    echo '    description: ''"'$desc'"''' >> $entry # adds 1 liner description for hive
    echo '    severity: '''$sev'''' >> $entry # adds severity
    echo '    tags: ["Security Alert", "Suspicious", "{match[event_id]}"]' >> $entry
    echo '    tlp: 1' >> $entry
    echo '    status: "New"' >> $entry
    echo '    follow: True' >> $entry
    echo '' >> $entry

    echo 'hive_observable_data_mapping:' >> $entry
    echo '  - timestamp: "{match[@timestamp]}"' >> $entry
    echo '  - event id: "{match[event_id]}"' >> $entry
    echo '  - host: "{match[host_name]}"' >> $entry
    echo '  - username: "{match[user_name]}"' >> $entry
    echo '  - log id: "{match[_id]}"' >> $entry
    echo '  - index: "{match[_index]}"' >> $entry

    echo '' >> $entry

done

