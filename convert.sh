mkdir sigmarules
for rule_category in sigma-master/rules/windows/* ; do
  for rule in $rule_category/* ; do
    sigma-master/tools/sigmac -t elastalert -c sigma-master/tools/config/helk.yml -o sigmarules/sigma_$(basename $rule) $rule
  done
done
