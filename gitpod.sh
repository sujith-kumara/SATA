#!/bin/bash
pip install -q -r requirements.txt
pip -q install pyngrok==4.1.1 pymysql flask flask_ngrok flask_sqlalchemy flask_login PyPDF2==2.4.0
ngrok authtoken '2EaH7NdHZUkj1Ulc2tOh2rluSHA_2219GaUreB6qSpiWNRs8k'
apt install mysql-server -y > /dev/null
echo -e "[mysql]\nuser = root\npassword = root" > ~/.my.cnf
service mysql start
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS studentdbms;"
echo "USE studentdbms;" > query.sql
cat students.sql >> query.sql
mysql -u root < query.sql && rm query.sql
python3 main.py