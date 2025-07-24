package com.finovo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;

@SpringBootApplication
@EnableR2dbcRepositories(basePackages = "com.finovo.repository")
@EntityScan(basePackages = "com.finovo.entity")
public class Finovo {
	public static void main(String[] args) {
		SpringApplication.run(Finovo.class, args);
	}



}
