workdir=$(pwd)

for rule_category in rules/windows/* ; do
  for rule in $rule_category/* ; do
    tools/sigmac -t elastalert -c tools/config/helk.yml -o /home/ubuntu/sigmarules/sigma_$(basename $rule) $rule
  done
done
