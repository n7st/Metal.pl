CREATE TABLE `event` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `name` varchar(20) NOT NULL,
      `long_name` varchar(100) DEFAULT NULL,
      `date` datetime NOT NULL,
      `date_created` datetime NOT NULL,
      `date_modified` datetime NOT NULL,
      `created_by` int(10) unsigned NOT NULL,
      `modified_by` int(10) unsigned NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_event_1_idx` (`created_by`),
      KEY `fk_event_2_idx` (`modified_by`),
      CONSTRAINT `fk_event_1` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_event_2` FOREIGN KEY (`modified_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

