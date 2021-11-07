CREATE TABLE `faqs` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `question` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
                `answer` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
                `created_at` datetime DEFAULT NULL,
                `updated_at` datetime DEFAULT NULL,
                `category` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;