MariaDB [db_akamura]> CREATE TABLE tbl_review(id INT PRIMARY KEY NOT NULL AUTO_INCREMENT, title VARCHAR(10) NOT NULL, comment VARCHAR(140) NOT NULL, age tinyint(4) NOT NULL, satisfied tinyint(4) NOT NULL, modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, posted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, flag tinyint(1) NOT NULL DEFAULT 0)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.004 sec)

MariaDB [db_akamura]> desc tbl_review;
+-----------+--------------+------+-----+---------------------+-------------------------------+
| Field     | Type         | Null | Key | Default             | Extra                         |
+-----------+--------------+------+-----+---------------------+-------------------------------+
| id        | int(11)      | NO   | PRI | NULL                | auto_increment                |
| title     | varchar(10)  | NO   |     | NULL                |                               |
| comment   | varchar(140) | NO   |     | NULL                |                               |
| age       | tinyint(4)   | NO   |     | NULL                |                               |
| satisfied | tinyint(4)   | NO   |     | NULL                |                               |
| modified  | datetime     | NO   |     | current_timestamp() | on update current_timestamp() |
| posted    | datetime     | NO   |     | current_timestamp() |                               |
| flag      | tinyint(1)   | NO   |     | 0                   |                               |
+-----------+--------------+------+-----+---------------------+-------------------------------+
8 rows in set (0.001 sec)