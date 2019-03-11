
mkdir rulesformatted
cd sigmarules

for copy in * ; do
  cp $copy ../rulesformatted/$copy
done

for entry in ../rulesformatted/*.yml ; do

  if [ "$(sed -n '/description/{n;p}' $entry)" != "filter:" ]
  then
	echo $entry
#	echo "$(sed -n 's/description: //p' $entry)"
#	echo "$(sed -n '/description: /{n;p}' $entry)"
#	read -p "continue"
  fi

  sev=$(sed -n 's/priority: //p' $entry) #pushing priority level to assign to hive severity
  desc=$(sed -n 's/description: //p' $entry) #pushing description to variable to include within hive
  size=$(stat -c '%s' $entry) #count filesize used by truncate

    truncate -s $(expr $size - 2) $entry #trim whitespace from initial conversion

    sed -i '1s;^;import: globalconfig.txt\n;' $entry #adding globalconfig reference at start of file
    sed -i '/globalconfig.txt/a\ ' $entry #adding new line after globalconfig
    sed -i 's/- debug/- slack/g' $entry # replace debug alert types with slack and hive +  next 2 lines
    sed -i '/- slack/a\- hivealerter' $entry
    sed -i '/- hivealerter/a\ ' $entry

    echo '' >> $entry # these append new lines for formatting
    echo 'alert_text:' >> $entry #following code appends the fields we need to the end of the file

    echo '	EventId: {0}\n' >> $entry
    echo '        Timestamp: {1}\n' >> $entry
    echo '        Index: {2}\n' >> $entry
    echo '' >> $entry
    echo 'alert_text_args: ["event_id", "@timestamp","_id"]' >> $entry
    echo 'alert_text_type: alert_text_only' >> $entry
    echo '' >> $entry

    echo 'hive_alert_config:' >> $entry
    echo '	title: "{rule[name]}' >> $entry
    echo '	type: "external"' >> $entry
    echo '	source: "Elastalert"' >> $entry
    echo '	description: ''"'$desc'"''' >> $entry
    echo '	severity: ''"'$sev'"''' >> $entry
    echo '	tags: ["Security Alert", "Suspicious", "{match[event_id]}' >> $entry
    echo '	tlp: 1' >> $entry
    echo '	status: "New"' >> $entry
    echo '	follow: True' >> $entry
    echo '' >> $entry

    echo 'hive_observable_data_mapping:' >> $entry
    echo '  - index: "{match[_index]}"' >> $entry
    echo '  - timestamp: "{match[@timestamp]}"' >> $entry
    echo '  - event id: "{match[event_id]}"' >> $entry
    echo '' >> $entry

done

