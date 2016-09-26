#!/bin/bash
#

echo $(java -version)
#
sudo apt-get install curl
curl –O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz

tar -zxvf elasticsearch-1.5.2.tar.gz
cd elasticsearch-1.5.2
bin/elasticsearch

# new zerminal open
curl 'http://localhost:9200/?pretty'

# elasticsearch configuration 

# Install esearch plugins

# Install plugin elasticsearch-kopf

bin/plugin -install lmenezes/elasticsearch-kopf

## Install Logstash
curl –O http://download.elastic.co/logstash/logstash/logstash-1.5.0.tar.gz

tar -zxvf logstash-1.5.0.tar.gz
cd logstash-1.5.0


# execute logstah
# simple
# bin/logstash -e 'input { stdin { } } output { stdout {} }'
# better 
# bin/logstash -e 'input { stdin { } } output { stdout { codec => rubydebug} }'

cat > CONFIG << EOF
input {
file    {
type => "apache"
path => "/user/packtpub/intro-to-elk/elk.log"
	}
}

output {
stdout  {
codec => rubydebug
	}
}
EOF



