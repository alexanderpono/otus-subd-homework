create user 'root'@'%' identified WITH mysql_native_password by 'root';
GRANT ALL ON *.* TO 'root'@'%';
flush privileges;