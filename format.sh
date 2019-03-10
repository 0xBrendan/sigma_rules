mkdir rulesformatted
cd sigmarules

for copy in * ; do
  cp $copy ../rulesformatted/$copy
done

for entry in ../rulesformatted/*.yml ; do

  sev=$(sed -n 's/priority: //p' $entry)
  desc=$(sed -n 's/description: //p' $entry)

    sed -i '1s;^;import: globalconfig.txt\n;' $entry
    sed -i '/globalconfig.txt/a\ ' $entry
    sed -i 's/- debug/- slack/g' $entry
    sed -i '/- slack/a\- hivealerter' $entry
    sed -i '/- hivealerter/a\ ' $entry

    echo '' >> $entry
    echo 'alert_text:' >> $entry

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

