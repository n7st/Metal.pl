CREATE TABLE `user_permission` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `user_id` int(10) unsigned NOT NULL,
      `permission_id` int(10) unsigned NOT NULL,
      `date_created` datetime NOT NULL,
      `date_modified` datetime NOT NULL,
      `created_by` int(10) unsigned NOT NULL,
      `modified_by` int(10) unsigned NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_user_permission_1_idx` (`user_id`),
      KEY `fk_user_permission_2_idx` (`created_by`),
      KEY `fk_user_permission_3_idx` (`modified_by`),
      KEY `fk_user_permission_4_idx` (`permission_id`),
      CONSTRAINT `fk_user_permission_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_user_permission_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_user_permission_3` FOREIGN KEY (`modified_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_user_permission_4` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `permission` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `name` varchar(15) NOT NULL,
      `description` varchar(100) DEFAULT NULL,
      `date_created` datetime NOT NULL,
      `date_modified` datetime NOT NULL,
      `created_by` int(10) unsigned NOT NULL,
      `modified_by` int(10) unsigned NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_permission_1_idx` (`created_by`),
      KEY `fk_permission_2_idx` (`modified_by`),
      CONSTRAINT `fk_permission_1` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_permission_2` FOREIGN KEY (`modified_by`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

