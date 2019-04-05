# converting sigma rules

run ./convert to convert the stock sigma rules to ones compatible with elastalert and helk (sigmarules)

run ./format to convert the helk ruleset (sigmarules) to be compatible with slack and thehive (rulesformatted)

IMPORTANT NOTE: win_susp_samr_pwset.yml and sysmon_mimikatz_inmemory_detection.yml are NOT currently supported for conversions to elastalert

SECOND IMPORTANT NOTE: sigma_win_susp_net_recon_activity.yml & sigma_win_susp_eventlog_cleared.yml & sigma_win_sdbinst_shim_persistence.yml all need manual editing of their hive descriptions due to their inclusion of quotes
